import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/exception/exception.dart';

/// Utility class for Substrate network operations, mainly for XCM and location handling.
class SubstrateNetworkControllerUtils {
  /// Converts a hex string to UTF-8 if possible, otherwise returns original string.
  static String? asUtf8(String? data) {
    if (data == null || !StringUtils.isHexBytes(data)) return data;
    return StringUtils.tryDecode(BytesUtils.tryFromHexString(data)) ?? data;
  }

  /// Tries to convert a hex string to UTF-8, fallback to original string.
  static String tryToUtf8(String data) {
    if (!StringUtils.isHexBytes(data)) return data;
    return StringUtils.tryDecode(BytesUtils.tryFromHexString(data)) ?? data;
  }

  /// Checks equality of two XCMMultiLocations, considering network and parents.
  static bool locationEquality(
      {required BaseSubstrateNetwork networkA,
      required BaseSubstrateNetwork networkB,
      required XCMMultiLocation? a,
      required XCMMultiLocation? b}) {
    if (a == null || b == null) return false;
    if (networkA == networkB) {
      return a.isEqual(b);
    }
    if (a.isExternalLocation() || b.isExternalLocation()) return a.isEqual(b);
    if (a.isOneParents() && b.isOneParents()) {
      return a.isEqual(b);
    }
    if (a.parents == b.parents) return false;
    if (a.isZeroParents() && b.isOneParents()) {
      if (a.isHere() && b.isHere()) return networkA.role.isRelay;
      final paraId = b.getParachain();
      if (paraId == null || paraId.id != networkA.paraId) {
        return false;
      }
      if (CompareUtils.iterableIsEqual(
          a.interior.junctions, b.interior.junctions.sublist(1))) {
        return true;
      }
    } else if (a.isOneParents() && b.isZeroParents()) {
      if (b.isHere() && a.isHere()) return networkB.role.isRelay;
      final paraid = a.getParachain();
      if (paraid == null || paraid.id != networkB.paraId) {
        return false;
      }
      if (CompareUtils.iterableIsEqual(
          b.interior.junctions, a.interior.junctions.sublist(1))) {
        return true;
      }
    }

    return false;
  }

  /// Returns the reserve location for a parachain.
  static XCMMultiLocation getParaReserveLocation(XCMMultiLocation location) {
    if (!location.isOneParents()) return location;
    if (location.isOneParentsAndHere()) return location;
    final parachain = location.getParachain();
    if (parachain == null) return location;
    return XCMMultiLocation.fromVersion(
        parents: 1,
        version: location.version,
        interior: XCMJunctions.fromVersion(
            junctions: [parachain], version: location.version));
  }

  /// Creates a versioned account junction for XCM from a network address.
  static XCMJunction createVersionedAccountJunction(
      {required BaseSubstrateAddress address,
      required XCMVersion version,
      BaseSubstrateNetwork? network}) {
    final toBytes = address.toBytes();
    if (network != null) {
      final chainType = network.chainType;
      if (chainType.isEthereum != address.type.isEthereum) {
        throw DartSubstratePluginException(
            "Invalid ${network.networkName} address.");
      }
      if (address is SubstrateAddress) {
        if (address.ss58Format != network.ss58) {
          throw DartSubstratePluginException(
              "Invalid ${network.networkName} address. Missmatch ssh58.",
              details: {"address": address.address});
        }
      }
    }
    return switch (address.type) {
      SubstrateAddressType.substrate =>
        XCMJunctionAccountId32.fromVersion(keyBytes: toBytes, version: version),
      SubstrateAddressType.ethereum =>
        XCMJunctionAccountKey20.fromVersion(keyBytes: toBytes, version: version)
    };
  }

  /// Creates a XCMMultiLocation for a beneficiary address.
  static XCMMultiLocation createBeneficiaryLocation(
      {required BaseSubstrateAddress address,
      required XCMVersion version,
      BaseSubstrateNetwork? network}) {
    final XCMJunction account = createVersionedAccountJunction(
        address: address, version: version, network: network);
    final junactions =
        XCMJunctions.fromVersion(junctions: [account], version: version);
    final location = XCMMultiLocation.fromVersion(
        parents: 0, version: version, interior: junactions);
    return location;
  }

  /// Creates a versioned location for a beneficiary.
  static XCMVersionedLocation createVersionedBeneficiaryLocation(
      {required BaseSubstrateAddress address,
      required XCMVersion version,
      BaseSubstrateNetwork? network}) {
    return XCMVersionedLocation.fromLocation(createBeneficiaryLocation(
        address: address, version: version, network: network));
  }

  static XCMMultiLocation _localizeFor(
      {required XCMMultiLocation reserveLocation,
      required XCMMultiLocation location,
      XCMVersion? version}) {
    version ??= location.version;
    bool isRelay = reserveLocation.isZeroParentsAndHere();

    if (location.isHere() && isRelay) {
      return location.copyWith(parents: 0).asVersion(version);
    }
    if (location.isZeroParentsAndHere() && !isRelay) {
      return location.copyWith(parents: 1).asVersion(version);
    }
    final paraId = reserveLocation.getParachain()?.id;
    if (paraId == null) {
      throw DartSubstratePluginException(
          "Invalid reserve location. Missing location para Id.");
    }
    if (location.hasParachain(paraId)) {
      return location
          .copyWith(
              parents: 0,
              interior: XCMJunctions.fromVersion(
                  junctions: location.interior.junctions
                      .where((e) =>
                          (e.type != XCMJunctionType.parachain) ||
                          (e.cast<XCMJunctionParaChain>().id != paraId))
                      .toList(),
                  version: location.version))
          .asVersion(version);
    }
    return location.asVersion(version);
  }

  /// Adjusts a location to be relative to a reserve location or network.
  static XCMMultiLocation localizeFor(
      {BaseSubstrateNetwork? reserveNetwork,
      XCMMultiLocation? reserveLocation,
      required XCMMultiLocation location,
      required XCMVersion version}) {
    if (reserveNetwork == null && reserveLocation == null) {
      throw DartSubstratePluginException(
          "Localize location required network or reserve location.");
    }
    return _localizeFor(
        reserveLocation:
            reserveNetwork?.location(version: version) ?? reserveLocation!,
        location: location,
        version: version);
  }

  /// Creates a destination location for XCM transfer, including optional account
  static XCMMultiLocation createDestination(
      {BaseSubstrateNetwork? origin,
      XCMMultiLocation? originlocation,
      BaseSubstrateNetwork? destination,
      XCMMultiLocation? destinationLocation,
      required XCMVersion version,
      BaseSubstrateAddress? address}) {
    if (origin == null && originlocation == null) {
      throw DartSubstratePluginException(
          "origin network or location required for create destination location.");
    }
    if (destination == null && destinationLocation == null) {
      throw DartSubstratePluginException(
          "destination network or location required for create destination location.");
    }
    originlocation ??= origin!.location(version: version);
    destinationLocation ??= destination!.location(version: version);
    final destPara = destinationLocation.getParachain()?.id;
    XCMJunction? account;
    if (address != null) {
      account = createVersionedAccountJunction(
          address: address, version: version, network: destination);
    }

    if (destinationLocation.isEqual(originlocation)) {
      return XCMMultiLocation.fromVersion(
          parents: 0,
          interior: XCMJunctions.fromVersion(
              junctions: [if (account != null) account], version: version),
          version: version);
    }
    if (originlocation.isZeroParents()) {
      return XCMMultiLocation.fromVersion(
          parents: 0,
          version: version,
          interior: XCMJunctions.fromVersion(junctions: [
            if (destPara != null)
              XCMJunctionParaChain.fromVersion(id: destPara, version: version),
            if (account != null) account
          ], version: version));
    }
    return XCMMultiLocation.fromVersion(
        parents: 1,
        version: version,
        interior: XCMJunctions.fromVersion(junctions: [
          if (destPara != null)
            XCMJunctionParaChain.fromVersion(id: destPara, version: version),
          if (account != null) account
        ], version: version));
  }

  /// Creates a versioned destination location for XCM transfer.
  static XCMVersionedLocation createVersionedDestination(
      {BaseSubstrateNetwork? origin,
      XCMMultiLocation? originlocation,
      BaseSubstrateNetwork? destination,
      XCMMultiLocation? destinationLocation,
      required XCMVersion version,
      BaseSubstrateAddress? address}) {
    return XCMVersionedLocation.fromLocation(createDestination(
        origin: origin,
        destination: destination,
        destinationLocation: destinationLocation,
        originlocation: originlocation,
        version: version,
        address: address));
  }

  /// Converts a location to a foreign location relative to a network.
  static XCMMultiLocation asForeignLocation(
      {required BaseSubstrateNetwork from,
      required XCMMultiLocation location}) {
    if (location.isExternalLocation()) return location;
    if (from.role.isRelay || !location.isZeroParents()) {
      return location;
    }
    if (location.getParachain() != null) {
      throw DartSubstratePluginException("Invalid location.");
    }
    return location.copyWith(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          XCMJunctionParaChain.fromVersion(
              id: from.paraId, version: location.version),
          ...location.interior.junctions
        ], version: location.version));
  }

  /// Converts a foreign location to versioned format.
  static XCMVersionedLocation asForeignVersionedLocation(
      {required BaseSubstrateNetwork from,
      required XCMVersionedLocation location}) {
    return XCMVersionedLocation.fromLocation(
        asForeignLocation(from: from, location: location.location));
  }

  /// Returns a versioned location with a general key for XCM.
  static XCMVersionedLocation locationWithGeneralKey(
      {required int paraId,
      int variantIndex = 0,
      int? secondVariantIndex,
      XCMJunctionGeneralKey? key,
      XCMVersion version = XCMVersion.v3}) {
    List<XCMJunction> junctions = [
      XCMJunctionParaChain.fromVersion(id: paraId, version: version)
    ];
    if (key == null) {
      final locationIndex =
          List<int>.filled(SubstrateConstant.accountIdLengthInBytes, 0);
      locationIndex[0] = variantIndex;
      if (secondVariantIndex != null) {
        locationIndex[1] = secondVariantIndex;
      }
      junctions.add(XCMJunctionGeneralKey.fromVersion(
          length: 2, data: locationIndex, version: version));
    } else {
      junctions.add(key);
    }
    return XCMVersionedLocation.fromLocation(XCMMultiLocation.fromVersion(
        parents: 1,
        interior:
            XCMJunctions.fromVersion(junctions: junctions, version: version),
        version: version));
  }

  /// Returns a location with pallet instance and optional AccountKey20.
  static XCMVersionedLocation locationWithPalletInstanceAndAccountKey20(
      {required int paraId,
      required int palletInstance,
      String? accountKey,
      XCMVersion version = XCMVersion.v3}) {
    List<XCMJunction> junctions = [
      XCMJunctionParaChain.fromVersion(id: paraId, version: version),
      XCMJunctionPalletInstance.fromVersion(
          index: palletInstance, version: version),
      if (accountKey != null)
        XCMJunctionAccountKey20.fromVersion(
            keyBytes: BytesUtils.fromHexString(accountKey), version: version)
    ];
    return XCMVersionedLocation.fromLocation(XCMMultiLocation.fromVersion(
        parents: 1,
        interior:
            XCMJunctions.fromVersion(junctions: junctions, version: version),
        version: version));
  }

  /// Returns a location with a general index for XCM.
  static XCMVersionedLocation locationWithGeneralIndex(
      {required int paraId,
      required BigInt index,
      XCMVersion version = XCMVersion.v3}) {
    return XCMVersionedLocation.fromLocation(XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          XCMJunctionParaChain.fromVersion(id: paraId, version: version),
          XCMJunctionGeneralIndex.fromVersion(index: index, version: version)
        ], version: version),
        version: version));
  }

  /// Returns a location with optional paraId, palletInstance, and generalIndex.
  static XCMVersionedLocation locationWithParaId(
      {int? paraId,
      int? palletInstance,
      BigInt? generalIndex,
      XCMVersion version = XCMVersion.v3}) {
    return XCMVersionedLocation.fromLocation(XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          if (paraId != null)
            XCMJunctionParaChain.fromVersion(id: paraId, version: version),
          if (palletInstance != null)
            XCMJunctionPalletInstance.fromVersion(
                index: palletInstance, version: version),
          if (generalIndex != null)
            XCMJunctionGeneralIndex.fromVersion(
                index: generalIndex, version: version)
        ], version: version),
        version: version));
  }

  /// Returns the relay network location for XCM.
  static XCMVersionedLocation relayLocation(
      {XCMVersion version = XCMVersion.v3}) {
    return XCMVersionedLocation.fromLocation(XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [], version: version),
        version: version));
  }

  /// Checks if a location represents a system parachain (< 2000).
  static bool isSystemLocation(XCMMultiLocation location) {
    if (location.isOneParents()) {
      final paraId = location.getParachain()?.id;
      return paraId != null && paraId < 2000;
    }
    return false;
  }

  /// Checks if a location represents the relay chain.
  static bool isRelay(XCMMultiLocation location) {
    return location.isZeroParentsAndHere();
  }

  /// Finds the message ID for a sent XCM event
  static String? findSendXCMMessageId(
      {required BaseSubstrateNetwork network,
      required SubstrateGroupEvents events,
      required SubtrateMetadataPallet transferPallet}) {
    /// XcmpQueue
    return events.firstWhereOrNull((event) {
      final pallet = SubtrateMetadataPallet.fromName(event.pallet);
      switch (pallet) {
        case SubtrateMetadataPallet.xcmPallet:
        case SubtrateMetadataPallet.polkadotXcm:
          final data = event.tryInputAs<Map<String, dynamic>>();
          return data?.valueAsString("message_id");
        case SubtrateMetadataPallet.xcmpQueue:
          return event.tryInputAs<String>();
        default:
          return null;
      }
    }, pallets: [
      SubtrateMetadataPallet.xcmPallet.name,
      SubtrateMetadataPallet.polkadotXcm.name,
      SubtrateMetadataPallet.xcmpQueue.name,
    ]);
  }

  /// Extracts deposit events related to a transfer.
  static List<SubstrateAssetDepositEvent> _extractDeposit(
      {required SubstrateGroupEvents events,
      required SubstrateXCMTransferEncodedParams params}) {
    final String account = params.params.destinationAddress.toHex();
    return events.where((event) {
      final pallet = SubtrateMetadataPallet.fromName(event.pallet);
      final deposit = switch (pallet) {
        SubtrateMetadataPallet.assets => SubstrateAssetsDepositedEvent.fromJson(
            event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.tokens => SubstrateTokensDepositedEvent.fromJson(
            event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.xTransfer =>
          SubstrateXTransferDepositedEvent.fromJson(
              event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.currencies =>
          SubstrateCurrenciesDepositedEvent.fromJson(
              event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.balances =>
          SubstrateBalancesMintedEvent.fromJson(
              event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.foreignAssets =>
          SubstrateForeignAssetsDepositedEvent.fromJson(
              event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.evm => SubstrateEthereumEvmLogEvent.fromJson(
            event.inputAs<Map<String, dynamic>>()),
        SubtrateMetadataPallet.common =>
          SubstrateCommonItemCreatedEvent.itemCreated(event.inputAs<List>()),
        _ => null,
      };
      final address = deposit?.address;
      if (address == null) return null;
      if (StringUtils.hexEqual(account, address)) {
        return deposit;
      }
      return null;
    },
        methods: ["Deposited", "Minted", "Log", "Issued", "ItemCreated"],
        catchError: true);
  }

  /// Handles xTransfer deposits from events and updates deposit list.
  static SubstrateXCMTransctionTrackerResult? _xTransferDeposit(
      {required SubstrateGroupEvents events,
      required SubstrateXCMTransferEncodedParams params,
      required List<SubstrateXcmProcessEvent> xcmEvents,
      required List<SubstrateAssetDepositEvent> deposits,
      required SubstrateGroupEvents blockEvents,
      required int blockNumber}) {
    if (!xcmEvents.any((e) => e.success)) return null;
    final xTransferDeposit =
        deposits.whereType<SubstrateXTransferDepositedEvent>().toList();
    if (xTransferDeposit.isEmpty) return null;
    for (final i in params.params.assets) {
      final assetLocation = i.getlocalizedLocation(
          version: params.params.destinationNetwork.defaultXcmVersion,
          reserveNetwork: params.params.destinationNetwork);
      for (final deposit in xTransferDeposit) {
        final location = deposit.what.id.location;
        if (location == null) continue;
        if (location.isEqual(assetLocation)) deposits.add(deposit);
      }
    }
    if (deposits.isEmpty) return null;
    return SubstrateXCMTransctionTrackerResult(
        deposits: deposits,
        status: SubstrateXCMTransctionTrackerStatus.success,
        blockNumber: blockNumber,
        blockEvent: blockEvents);
  }

  /// Finds processed XCM messages in events for a given message ID.
  static SubstrateXCMTransctionTrackerResult? findProcessedXCMMessage(
      {required SubstrateGroupEvents events,
      required String id,
      required SubstrateXCMTransferEncodedParams params,
      required int blockNumber}) {
    final destination = params.params.destinationNetwork;
    final List<SubstrateXcmProcessEvent> processedEvents =
        events.where((event) {
      final data = event.getMethodData();
      switch (event.pallet) {
        case "XcmpQueue":
          return SubstrateXcmpQueueEvent.fromJson(data);
        case "MessageQueue":
          return SubstrateMessageQueueEvent.fromJson(data);
        default:
          return null;
      }
    }, pallets: ["XcmpQueue", "MessageQueue"], catchError: true);
    if (processedEvents.isEmpty) return null;
    final xcmEvent = processedEvents
        .firstWhereNullable((e) => StringUtils.hexEqual(e.xcmMessageId, id));
    final deposits = _extractDeposit(events: events, params: params);
    if (xcmEvent != null) {
      return SubstrateXCMTransctionTrackerResult(
          status: (xcmEvent.success && deposits.isNotEmpty)
              ? SubstrateXCMTransctionTrackerStatus.success
              : SubstrateXCMTransctionTrackerStatus.failed,
          deposits: deposits,
          blockNumber: blockNumber,
          blockEvent: events);
    }
    try {
      if (deposits.isEmpty) return null;
      final assetHubLocation = params.params.origin.assetHub.location();
      final origin = params.params.origin.location();
      XCMMultiLocation assetLocation() =>
          getParaReserveLocation(params.params.assets[0].getlocalizedLocation(
              version: destination.defaultXcmVersion,
              reserveNetwork: destination));
      final relatedOrigin = processedEvents.where((e) {
        final location = e.originLocation;
        if (location == null) return true;
        if (location.isEqual(origin)) return true;
        if (params.params.hasRelayAsset) {
          return location.isHere() || location.isEqual(assetHubLocation);
        }
        return location.isEqual(assetLocation());
      });
      switch (destination) {
        case PolkadotNetwork.phala:
          return _xTransferDeposit(
              events: events,
              params: params,
              xcmEvents: processedEvents,
              deposits: deposits,
              blockNumber: blockNumber,
              blockEvents: events);
        default:
          if (relatedOrigin.isEmpty) return null;
          return SubstrateXCMTransctionTrackerResult(
              deposits: deposits,
              status: SubstrateXCMTransctionTrackerStatus.success,
              blockNumber: blockNumber,
              blockEvent: events);
      }
    } catch (e) {
      return null;
    }
  }
}
