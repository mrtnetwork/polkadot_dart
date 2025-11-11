import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

/// Callback to request a network controller.
///
/// Used when calculating fees on the destination or reserve chain in an XCM transaction.
/// If no controller is returned, some parts of the dry-run may not be supported.
typedef ONREQUESTNETWORKCONTROLLER = Future<BaseSubstrateNetworkController?>
    Function(BaseSubstrateNetwork network);

/// Callback for a request to get a network provider.
///
/// Used when calculating fees on the destination or reserve chain of asset.
/// In some cases, if no provider is returned, the fee amount is divided by 2
/// to estimate or generate a "buy extension".
typedef ONREQUESTNETWORKPROVIDER = Future<MetadataWithProvider?> Function(
    BaseSubstrateNetwork from);

/// Internal helper for building XCM transfer calls; do not use directly.
abstract mixin class SubstrateNetworkControllerXCMTransferBuilder {
  static SubtrateMetadataPallet findXcmPallet(MetadataWithProvider provider) {
    if (provider.metadata.api
        .palletExists(SubtrateMetadataPallet.xcmPallet.name)) {
      return SubtrateMetadataPallet.xcmPallet;
    }
    return SubtrateMetadataPallet.polkadotXcm;
  }

  static List<SubstrateCallPalletXCMTransferMethod>
      getAllAvailableXCMTransferMethod(
    MetadataWithProvider provider,
  ) {
    final xcmPallet = findXcmPallet(provider);
    final xcmMethods = provider.metadata.api.getCallMethodNames(xcmPallet.name);
    final xTokenMethod = provider.metadata.api
        .getCallMethodNames(SubtrateMetadataPallet.xTokens.name);
    final xTransfer = provider.metadata.api
        .getCallMethodNames(SubtrateMetadataPallet.xTransfer.name);
    return [
      ...XCMCallPalletMethod.values.where((e) => xcmMethods.contains(e.method)),
      ...XTokenCallPalletMethod.values
          .where((e) => xTokenMethod.contains(e.method)),
      ...XTransferCallPalletMethod.values
          .where((e) => xTransfer.contains(e.method))
    ];
  }

  static bool transferMethodExists(
      {required MetadataWithProvider provider,
      required SubstrateCallPalletXCMTransferMethod method}) {
    return switch (method) {
      final XCMCallPalletMethod method => () {
          final xcmPallet = findXcmPallet(provider);
          final xcmMethods =
              provider.metadata.api.getCallMethodNames(xcmPallet.name);
          return xcmMethods.contains(method.method);
        }(),
      final XTokenCallPalletMethod method => () {
          final xTokenMethod = provider.metadata.api
              .getCallMethodNames(SubtrateMetadataPallet.xTokens.name);
          return xTokenMethod.contains(method.method);
        }(),
      final XTransferCallPalletMethod method => () {
          final xTokenMethod = provider.metadata.api
              .getCallMethodNames(SubtrateMetadataPallet.xTransfer.name);
          return xTokenMethod.contains(method.method);
        }(),
      _ => false
    };
  }

  static WeightLimit _createWeight(XCMVersion version, WeightLimit? weight) {
    if (version > XCMVersion.v3) {
      version = XCMVersion.v3;
    }
    if (weight != null) {
      if (weight.version != version) {
        throw DartSubstratePluginException("Invalid weight limit version.",
            details: {
              "expected": version.type,
              "version": weight.version.type
            });
      }
      return weight;
    }
    switch (version) {
      case XCMVersion.v2:
        return XCMV2WeightLimitUnlimited();
      default:
        return XCMV3WeightLimitUnlimited();
    }
  }

  static Future<BigInt> queryXcmWeightToFee(
      {required MetadataWithProvider provier,
      required XCMVersionedXCM xcm,
      required XCMAssetId asset}) async {
    if (!SubstrateQuickRuntimeApi.xcmPayment.methodExists(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryXcmWeight,
        api: provier.metadata.api)) {
      throw DartSubstratePluginException(
          "XCM payment API method not available.");
    }
    final queryXcmWeight = await SubstrateQuickRuntimeApi.xcmPayment
        .queryXcmWeight(
            api: provier.metadata.api, rpc: provier.provider, xcm: xcm);
    if (!queryXcmWeight.type.isOk) {
      throw DartSubstratePluginException(
        "Failed to calculate XCM execution weight.",
        details: {
          "error": queryXcmWeight.cast<SubstrateDispatchResultError>().error,
        },
      );
    }
    final weight = queryXcmWeight.ok!;
    final fee = await SubstrateQuickRuntimeApi.xcmPayment.queryWeightToAssetFee(
        api: provier.metadata.api,
        rpc: provier.provider,
        weight: weight,
        asset: asset.asVersioned());
    if (!fee.type.isOk) {
      throw DartSubstratePluginException(
        "Failed to calculate XCM fee for given weight.",
        details: {
          "error": fee.cast<SubstrateDispatchResultError>().error.type,
          "weight": weight.toJson(),
        },
      );
    }
    return fee.ok!;
  }

  static XCMDepositAsset _createDepositAssets(
      {required XCMMultiLocation asset,
      required BaseSubstrateNetwork to,
      required BaseSubstrateAddress address,
      required BaseSubstrateNetwork network,
      required XCMVersion xcmVersion}) {
    return XCMDepositAsset.fromAssets(
        assets: XCMMultiAssetFilter.wild(XCMWildMultiAsset.allOf(
            assetId: asset.toAssetId(),
            fungibility: XCMWildFungibilityType.fungible)),
        beneficiary: SubstrateNetworkControllerUtils.createBeneficiaryLocation(
            address: address, version: xcmVersion, network: to));
  }

  static XCMCallPallet transferDotThroughUsingTypeAndThen(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    List<XCMTransferType> assetsTypes = params.assets
        .map(
          (e) => _determineAssetTransferType(
              origin: network,
              assetLocation: e.getLocation(xcmVersion),
              destinationLocation: params.destinationNetwork.location()),
        )
        .toList();
    if (assetsTypes.toSet().length != 1) {
      throw DartSubstratePluginException("Multiple reserve not allowed.");
    }
    if (!params.hasRelayAsset) {
      throw DartSubstratePluginException(
          "This operation is only allowed for transfer relay chain asset.");
    }
    XCMTransferType transferType = assetsTypes.first;
    List<(SubstrateXCMTransferAsset, XCMAsset)> assets = params.assets
        .map((e) => (
              e,
              e.tolocalizedFungibleAsset(
                  reserveNetwork: network, xcmVersion: xcmVersion)
            ))
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    int feeItem = assets
        .indexWhere((e) => e.$1 == params.assets.elementAt(params.feeIndex));
    final feeAsset = assets[feeItem];
    final deposit = XCMDepositAsset.fromAssets(
        assets: XCMMultiAssetFilter.wild(
            XCMWildMultiAsset.all(version: xcmVersion)),
        beneficiary: SubstrateNetworkControllerUtils.createBeneficiaryLocation(
            address: params.destinationAddress,
            version: xcmVersion,
            network: params.destinationNetwork));

    final instruction = assets.map((e) => _createDepositAssets(
        asset: SubstrateNetworkControllerUtils.localizeFor(
            reserveNetwork: params.destinationNetwork,
            version: xcmVersion,
            location: e.$2.id.getLocation()),
        network: network,
        to: params.destinationNetwork,
        address: params.destinationAddress,
        xcmVersion: xcmVersion));
    final XCMVersionedXCM customXcm =
        XCMVersionedXCM.fromXCM(XCM.fromInstructions(instructions: [
      XCMSetAppendix.fromXCM(
          XCM.fromInstructions(instructions: [deposit], version: xcmVersion)),
      ...instruction
    ], version: xcmVersion));
    return XCMCallPalletTransferAssetsUsingTypeAndThen(
        pallet: findXcmPallet(provider),
        dest: SubstrateNetworkControllerUtils.createVersionedDestination(
            destination: params.destinationNetwork,
            version: xcmVersion,
            origin: network),
        assets: XCMVersionedAssets.fromVersion(
            assets: assets.map((e) => e.$2).toList(), version: xcmVersion),
        assetsTransferType: assetsTypes.first,
        remoteFeesId: feeAsset.$2.id.asVersioned(),
        feesTransferType: transferType,
        customXcmOnDest: customXcm,
        version: xcmVersion,
        weightLimit: _createWeight(xcmVersion, params.destinationWeightLimit));
  }

  static XCMCallPalletMethod _findTeleportMethod(
      {required SubtrateMetadataPallet pallet,
      required MetadataWithProvider provider,
      required WeightLimit? weight}) {
    final methods = provider.metadata.api.getCallMethodNames(pallet.name);
    if (weight != null) {
      if (!methods.contains(XCMCallPalletMethod.limitedTeleportAssets.method)) {
        throw DartSubstratePluginException(
            "${pallet.name} not supported by ${XCMCallPalletMethod.limitedTeleportAssets.method} pallet.");
      }
      return XCMCallPalletMethod.limitedTeleportAssets;
    }
    if (methods.contains(XCMCallPalletMethod.limitedTeleportAssets.method)) {
      return XCMCallPalletMethod.limitedTeleportAssets;
    }
    if (methods.contains(pallet.name)) {
      return XCMCallPalletMethod.teleportAssets;
    }
    throw DartSubstratePluginException(
        "No teleport asset method available in ${pallet.name} pallet.");
  }

  static XCMCallPalletMethod _findReserveTransferMethod(
      {required SubtrateMetadataPallet pallet,
      required MetadataWithProvider provider,
      required WeightLimit? weight}) {
    final methods = provider.metadata.api.getCallMethodNames(pallet.name);
    if (weight != null) {
      if (!methods
          .contains(XCMCallPalletMethod.limitedReserveTransferAssets.method)) {
        throw DartSubstratePluginException(
            "${pallet.name} not supported by ${XCMCallPalletMethod.limitedReserveTransferAssets.method} pallet.");
      }
      return XCMCallPalletMethod.limitedReserveTransferAssets;
    }
    if (methods
        .contains(XCMCallPalletMethod.limitedReserveTransferAssets.method)) {
      return XCMCallPalletMethod.limitedReserveTransferAssets;
    }
    if (methods.contains(XCMCallPalletMethod.reserveTransferAssets.method)) {
      return XCMCallPalletMethod.reserveTransferAssets;
    }
    throw DartSubstratePluginException(
        "No teleport asset method available in ${pallet.name} pallet.");
  }

  static XCMCallPallet _teleportAssets(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required SubtrateMetadataPallet pallet,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion);
    final beneficiary =
        SubstrateNetworkControllerUtils.createVersionedBeneficiaryLocation(
            version: xcmVersion,
            address: params.destinationAddress,
            network: params.destinationNetwork);
    List<(SubstrateXCMTransferAsset, XCMAsset)> assets = params.assets
        .map((e) => (
              e,
              e.tolocalizedFungibleAsset(
                  xcmVersion: xcmVersion, reserveNetwork: network)
            ))
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    int feeItem = assets
        .indexWhere((e) => e.$1 == params.assets.elementAt(params.feeIndex));
    final method = _findTeleportMethod(
        provider: provider,
        weight: params.destinationWeightLimit,
        pallet: pallet);
    return switch (method) {
      XCMCallPalletMethod.teleportAssets => XCMCallPalletTeleportAssets(
          dest: destination,
          pallet: pallet,
          beneficiary: beneficiary,
          assets: XCMVersionedAssets.fromVersion(
              assets: assets.map((e) => e.$2).toList(),
              version: xcmVersion,
              sort: false),
          feeAssetItem: feeItem),
      XCMCallPalletMethod.limitedTeleportAssets =>
        XCMCallPalletLimitedTeleportAssets(
            pallet: pallet,
            dest: destination,
            beneficiary: beneficiary,
            version: xcmVersion,
            weightLimit:
                _createWeight(xcmVersion, params.destinationWeightLimit),
            assets: XCMVersionedAssets.fromVersion(
                assets: assets.map((e) => e.$2).toList(),
                version: xcmVersion,
                sort: false),
            feeAssetItem: feeItem),
      _ => throw DartSubstratePluginException("Invalid teleport asset method.",
          details: {"method": method})
    };
  }

  static XCMCallPallet _reserveTransferAssets(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required SubtrateMetadataPallet pallet,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(network);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion);
    final beneficiary =
        SubstrateNetworkControllerUtils.createVersionedBeneficiaryLocation(
            version: xcmVersion,
            address: params.destinationAddress,
            network: params.destinationNetwork);
    List<(SubstrateXCMTransferAsset, XCMAsset)> assets = params.assets
        .map((e) => (
              e,
              e.tolocalizedFungibleAsset(
                  xcmVersion: xcmVersion, reserveNetwork: network)
            ))
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    int feeItem = assets
        .indexWhere((e) => e.$1 == params.assets.elementAt(params.feeIndex));
    final method = _findReserveTransferMethod(
        provider: provider,
        weight: params.destinationWeightLimit,
        pallet: pallet);
    return switch (method) {
      XCMCallPalletMethod.reserveTransferAssets =>
        XCMCallPalletReserveTransferAssets(
            dest: destination,
            beneficiary: beneficiary,
            pallet: pallet,
            assets: XCMVersionedAssets.fromVersion(
                assets: assets.map((e) => e.$2).toList(),
                version: xcmVersion,
                sort: false),
            feeAssetItem: feeItem),
      XCMCallPalletMethod.limitedReserveTransferAssets =>
        XCMCallPalletLimitedReserveTransferAssets(
            dest: destination,
            beneficiary: beneficiary,
            version: xcmVersion,
            pallet: pallet,
            weightLimit:
                _createWeight(xcmVersion, params.destinationWeightLimit),
            assets: XCMVersionedAssets.fromVersion(
                assets: assets.map((e) => e.$2).toList(),
                version: xcmVersion,
                sort: false),
            feeAssetItem: feeItem),
      _ => throw DartSubstratePluginException(
          "Invalid reserve transfer assets method.",
          details: {"method": method})
    };
  }

  static XCMCallPallet _transferAssets({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    required SubtrateMetadataPallet pallet,
    required BaseSubstrateNetwork network,
  }) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion);
    final beneficiary =
        SubstrateNetworkControllerUtils.createVersionedBeneficiaryLocation(
            version: xcmVersion,
            address: params.destinationAddress,
            network: params.destinationNetwork);

    List<(SubstrateXCMTransferAsset, XCMAsset)> assets = params.assets
        .map((e) => (
              e,
              e.tolocalizedFungibleAsset(
                  xcmVersion: xcmVersion, reserveNetwork: network)
            ))
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    int feeItem = assets
        .indexWhere((e) => e.$1 == params.assets.elementAt(params.feeIndex));
    return XCMCallPalletTransferAssets(
        dest: destination,
        beneficiary: beneficiary,
        pallet: pallet,
        version: xcmVersion,
        weightLimit: _createWeight(xcmVersion, params.destinationWeightLimit),
        assets: XCMVersionedAssets.fromVersion(
            assets: assets.map((e) => e.$2).toList(),
            version: xcmVersion,
            sort: false),
        feeAssetItem: feeItem);
  }

  static XCMCallPalletMethod _findTransferMethod(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final locations = params.locations;
    final parents = locations.map((e) => e.parents).toSet();
    final paras = locations.map((e) => e.getParachain()?.id).toSet();
    if (parents.length != 1 || paras.length != 1) {
      throw DartSubstratePluginException(
          "Multiple reserve locations are not allowed.");
    }
    final dest = params.destinationNetwork;
    if ((network.role.isRelay && dest.role.isSystem) ||
        (dest.role.isRelay && network.role.isSystem)) {
      return XCMCallPalletMethod.teleportAssets;
    }
    if (network.role.isSystem && dest.role.isSystem) {
      if (params.hasRelayAsset) return XCMCallPalletMethod.teleportAssets;
    }
    if (!network.role.isRelay && params.isLocalAssets) {
      return XCMCallPalletMethod.transferAssets;
    }
    return XCMCallPalletMethod.reserveTransferAssets;
  }

  static BaseSubstrateNetwork? _findNetworkFromLocation(
      BaseSubstrateNetwork origin, XCMMultiLocation location) {
    if (location.isOneParentsAndHere()) return origin.relayChain;
    if (location.isZeroParentsAndHere()) return origin;
    final parachain = location.getParachain();
    if (parachain == null) return null;
    return origin.relaySystem.networks
        .firstWhereNullable((e) => e.paraId == parachain.id);
  }

  static Future<QueryDeleveriesFeeWithAmount> queryDeliveryFees(
      {required MetadataWithProvider metadata,
      required BaseSubstrateNetwork network,
      required BaseSubstrateNetworkAsset nativeAsset,
      required XCMVersionedXCM xcm,
      required XCMVersionedLocation destination,
      BaseSubstrateNetworkAsset? fee}) async {
    if (!SubstrateQuickRuntimeApi.xcmPayment.methodExists(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryWeightToAssetFee,
        api: metadata.metadata.api)) {
      return QueryDeleveriesFeeWithAmount.unsuportedApi();
    }
    final localDeliveryFees = await SubstrateQuickRuntimeApi.xcmPayment
        .queryDeliveryFees(
            destination: destination,
            xcm: xcm,
            api: metadata.metadata.api,
            rpc: metadata.provider);
    final assets = localDeliveryFees.ok?.assets.assets;
    if (assets == null || assets.isEmpty) {
      return QueryDeleveriesFeeWithAmount(result: localDeliveryFees);
    }
    final List<QueryDeleveriesFeeAmount> fees = [];
    final supportAssetConversion = SubstrateQuickRuntimeApi.assetConversion
        .methodExists(
            api: metadata.metadata.api,
            method: SubstrateRuntimeApiAssetConversionMethods
                .quotePriceTokensForExactTokens);
    for (final i in assets) {
      final location = i.id.location;
      final amount = i.fun.cast<XCMFungibilityFungible>().units;
      if (location == null) {
        fees.add(QueryDeleveriesFeeAmount(asset: null, amount: amount));
        continue;
      }
      final isNativeAssset = nativeAsset
          .getlocalizedLocation(
              version: network.defaultXcmVersion, reserveNetwork: network)
          .location
          .isEqual(location);

      if (!isNativeAssset) {
        fees.add(QueryDeleveriesFeeAmount(asset: null, amount: amount));
        continue;
      }
      if (fee == null) {
        fees.add(QueryDeleveriesFeeAmount(asset: nativeAsset, amount: amount));
        continue;
      }
      final feelocation = fee
          .getlocalizedLocation(
              reserveNetwork: network, version: network.defaultXcmVersion)
          .location;
      if (feelocation.isEqual(location)) {
        fees.add(QueryDeleveriesFeeAmount(asset: fee, amount: amount));
        continue;
      }
      if (!supportAssetConversion) {
        fees.add(QueryDeleveriesFeeAmount(asset: nativeAsset, amount: amount));
        continue;
      }
      BigInt? nativeAmount = await SubstrateQuickRuntimeApi.assetConversion
          .quotePriceTokensForExactTokens(
              params: QuotePriceParams(
                  includeFee: true,
                  amount: amount,
                  assetA: feelocation,
                  assetB: location),
              api: metadata.metadata.api,
              rpc: metadata.provider);
      nativeAmount ??= await SubstrateQuickRuntimeApi.assetConversion
          .quotePriceExactTokensForTokens(
              params: QuotePriceParams(
                  includeFee: false,
                  amount: amount,
                  assetA: location,
                  assetB: feelocation),
              api: metadata.metadata.api,
              rpc: metadata.provider);
      if (nativeAmount == null) {
        fees.add(QueryDeleveriesFeeAmount(asset: nativeAsset, amount: amount));
      } else {
        fees.add(QueryDeleveriesFeeAmount(asset: fee, amount: nativeAmount));
      }
    }
    return QueryDeleveriesFeeWithAmount(
        result: localDeliveryFees, amounts: fees);
  }

  /// Performs a dry-run simulation of an XCM transfer.
  ///
  /// Simulates the transaction from the [origin] network to the [destination] or reserve networks,
  /// using [destinationFee] for estimating fees on the target chain.
  /// [transfer] is the encoded call for the XCM transfer, and [owner] is the account initiating it.
  ///
  /// [onRequestController] is a callback used to fetch a network controller if needed
  /// for calculating fees or other operations on the destination or reserve chains.
  /// Returns a [SubstrateTransactionXCMSimulateResult] containing the simulation result,
  /// or null if the simulation cannot be performed.
  static Future<SubstrateTransactionXCMSimulateResult?> dryRunXcm(
      {required BaseSubstrateNetwork origin,
      required BaseSubstrateNetwork destination,
      required BaseSubstrateNetworkAsset destinationFee,
      required SubstrateEncodedCallParams transfer,
      required BaseSubstrateAddress owner,
      required ONREQUESTNETWORKCONTROLLER onRequestController}) async {
    final localProvider = await onRequestController(origin);
    if (localProvider == null) return null;
    final metadata = await localProvider.metadata();
    if (!SubstrateQuickRuntimeApi.dryRun.methodExists(
        method: SubstrateRuntimeApiDryRunMethods.dryRunCall,
        api: metadata.metadata.api)) {
      return null;
    }
    final xcmVersion = origin.findXcmVersion(destination);
    final localDryRun = await SubstrateQuickRuntimeApi.dryRun.dryRunCall(
        owner: owner,
        callBytes: transfer.bytes,
        api: metadata.metadata.api,
        rpc: metadata.provider,
        version: xcmVersion);

    if (!(localDryRun.ok?.executionResult.type.isOk ?? false)) {
      return SubstrateTransactionXCMSimulateResult(
          dryRun: localDryRun,
          status: SubstrateTransactionXCMDryRunStatus.complete);
    }
    SubstrateTransactionXCMDryRunStatus status =
        SubstrateTransactionXCMDryRunStatus.unsuportedXcmPaymentApi;
    List<QueryDeleveriesFeeWithAmount> localDeliveryFees = [];
    if (SubstrateQuickRuntimeApi.xcmPayment.methodExists(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryDeliveryFees,
        api: metadata.metadata.api)) {
      for (final i in localDryRun.ok!.forwardXcms) {
        for (final xcm in i.$2) {
          final fee = await queryDeliveryFees(
              metadata: metadata,
              network: origin,
              nativeAsset: localProvider.defaultNativeAsset,
              xcm: xcm,
              destination: i.$1);
          localDeliveryFees.add(fee);
        }
      }
      status = SubstrateTransactionXCMDryRunStatus.complete;
    }
    List<SubstrateTransactionXCMDryRunResult> simulates = [];
    for (final i in localDryRun.ok!.forwardXcms) {
      for (final xcm in i.$2) {
        final simulate = await _dryRunXcm(
            origin: origin,
            fees: destinationFee,
            onRequestController: onRequestController,
            xcm: xcm,
            xcmLocation: i.$1);
        simulates.addAll(simulate);
      }
    }
    return SubstrateTransactionXCMSimulateResult(
        externalXcm: simulates,
        dryRun: localDryRun,
        localDeliveryFees: localDeliveryFees,
        status: status);
  }

  static Future<List<SubstrateTransactionXCMDryRunResult>> _dryRunXcm({
    required BaseSubstrateNetwork origin,
    required ONREQUESTNETWORKCONTROLLER onRequestController,
    required XCMVersionedLocation xcmLocation,
    required XCMVersionedXCM xcm,
    required BaseSubstrateNetworkAsset fees,
  }) async {
    BaseSubstrateNetwork? location =
        _findNetworkFromLocation(origin, xcmLocation.location);
    if (location == null) {
      return [SubstrateTransactionXCMDryRunResult.unsupported(location)];
    }
    final controller = await onRequestController(location);
    if (controller == null) {
      return [SubstrateTransactionXCMDryRunResult.unsupported(location)];
    }
    final metadata = await controller.metadata();
    if (!SubstrateQuickRuntimeApi.dryRun.methodExists(
        method: SubstrateRuntimeApiDryRunMethods.dryRunXcm,
        api: metadata.metadata.api)) {
      return [
        SubstrateTransactionXCMDryRunResult.unsupported(location,
            status: SubstrateTransactionXCMDryRunStatus.unsuportedDryRun)
      ];
    }
    final localLocation =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: location,
            destination: origin,
            version: location.defaultXcmVersion);
    final xcmDryRun = await SubstrateQuickRuntimeApi.dryRun.dryRunXcm(
        originlocation: localLocation,
        xcm: xcm,
        api: metadata.metadata.api,
        rpc: metadata.provider);
    final isComplete = xcmDryRun.ok?.isComplete ?? false;
    final weight = xcmDryRun.ok?.weight;
    if (!isComplete || weight == null) {
      return [
        SubstrateTransactionXCMDryRunResult(
            xcmDryRun: xcmDryRun,
            weightToFee: null,
            network: location,
            status: SubstrateTransactionXCMDryRunStatus.complete,
            deleveriesFee: [])
      ];
    }
    SubstrateTransactionXCMDryRunStatus status =
        SubstrateTransactionXCMDryRunStatus.unsuportedXcmPaymentApi;
    List<SubstrateTransactionXCMDryRunResult> simulates = [];
    SubstrateDispatchResult<BigInt>? weigthToAssetFee;
    if (SubstrateQuickRuntimeApi.xcmPayment.methodExists(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryWeightToAssetFee,
        api: metadata.metadata.api)) {
      status = SubstrateTransactionXCMDryRunStatus.complete;
      // xcm = xcmDryRun.ok!.forwardXcms;
      final feeAssetLocation = fees
          .getlocalizedLocation(
              reserveNetwork: location, version: location.defaultXcmVersion)
          .location;
      weigthToAssetFee = await queryWeightToAssetFee(
          provider: metadata,
          weight: weight,
          asset: feeAssetLocation.toAssetId().asVersioned());
    }
    final forwardXcm = xcmDryRun.ok!.forwardXcms;
    List<QueryDeleveriesFeeWithAmount> deliveriesFee = [];
    if (forwardXcm.any((e) => e.$2.isNotEmpty)) {
      if (SubstrateQuickRuntimeApi.xcmPayment.methodExists(
          method: SubstrateRuntimeApiXCMPaymentMethods.queryDeliveryFees,
          api: metadata.metadata.api)) {
        for (final i in forwardXcm) {
          for (final xcm in i.$2) {
            final deliveryFees = await queryDeliveryFees(
                metadata: metadata,
                network: location,
                nativeAsset: controller.defaultNativeAsset,
                xcm: xcm,
                destination: i.$1,
                fee: fees);
            deliveriesFee.add(deliveryFees);
          }
        }
      } else {
        status = SubstrateTransactionXCMDryRunStatus.unsuportedXcmPaymentApi;
      }
    }
    simulates.add(SubstrateTransactionXCMDryRunResult(
        xcmDryRun: xcmDryRun,
        weightToFee: weigthToAssetFee,
        network: location,
        status: status,
        deleveriesFee: deliveriesFee));
    for (final i in xcmDryRun.ok!.forwardXcms) {
      for (final xcm in i.$2) {
        final dryRun = await _dryRunXcm(
            origin: location,
            onRequestController: onRequestController,
            xcmLocation: i.$1,
            xcm: xcm,
            fees: fees);
        simulates.addAll(dryRun);
      }
    }

    return simulates;
  }

  static Future<SubstrateDispatchResult<BigInt>> queryWeightToAssetFee(
      {required MetadataWithProvider provider,
      required SubstrateWeightV2 weight,
      required XCMVersionedAssetId asset}) async {
    return await SubstrateQuickRuntimeApi.xcmPayment.queryWeightToAssetFee(
        weight: weight,
        asset: asset,
        api: provider.metadata.api,
        rpc: provider.provider);
  }

  static XCMCallPallet createXCMPalletTransfer({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    required BaseSubstrateNetwork network,
    SubstrateCallPalletXCMTransferMethod? method,
  }) {
    final pallet = findXcmPallet(provider);
    method ??= _findTransferMethod(
        params: params, provider: provider, network: network);
    switch (method) {
      case XCMCallPalletMethod.teleportAssets:
      case XCMCallPalletMethod.limitedTeleportAssets:
        return _teleportAssets(
            params: params,
            provider: provider,
            pallet: pallet,
            network: network);
      case XCMCallPalletMethod.reserveTransferAssets:
      case XCMCallPalletMethod.limitedReserveTransferAssets:
        return _reserveTransferAssets(
            params: params,
            provider: provider,
            pallet: pallet,
            network: network);

      case XCMCallPalletMethod.transferAssets:
        return _transferAssets(
            params: params,
            provider: provider,
            pallet: pallet,
            network: network);
      default:
        throw DartSubstratePluginException("Unsuported xcm transfer method.");
    }
  }

  static XTokenCallPalletMethod _findXTokenMethod(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider}) {
    final assets = params.assets.toSet();
    int assetsLength = assets.length;

    bool hasLocation = assets.every((e) => e.hasLocation());
    bool hasIdentifier = assets.every((e) => e.asset.hasIdentifier);
    if (!hasLocation && !hasIdentifier) {
      throw DartSubstratePluginException(
          "all transfer assets must have asset or location.");
    }
    return XTokenCallPalletMethod.findMethod(
        assetsLength: assetsLength,
        hasIdentifier: hasIdentifier,
        hasFee: assets.length > 1);
  }

  static XTokenCallPallet _xtokenTransfer(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion,
            address: params.destinationAddress);
    final asset = params.assets[0];
    final weightLimit =
        _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XTokenCallPalletTransfer(
        currencyId: asset.asset.xTokenTransferIdAs(),
        amount: asset.amount,
        dest: destination,
        destWeightLimit: weightLimit.cast());
  }

  static XTokenCallPallet _xtokenTransferWithFee(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            address: params.destinationAddress,
            version: xcmVersion);
    final asset = params.assets[0];
    final feeAmount = params.assets.elementAt(params.feeIndex).amount;
    final weightLimit =
        _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XTokenCallPalletTransferWithFee(
        currencyId: asset.asset.xTokenTransferIdAs(),
        amount: asset.amount,
        dest: destination,
        fee: feeAmount,
        destWeightLimit: weightLimit.cast());
  }

  static XTokenCallPallet _xtokenTransferMulticurrencies(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion,
            address: params.destinationAddress);
    final assets = params.assets;
    List<XTokenTransferTokenWithAmount> transferAssets = assets
        .map((e) => XTokenTransferTokenWithAmount(
            amount: e.amount, currencyId: e.asset.xTokenTransferIdAs()))
        .toList();
    final weightLimit =
        _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XTokenCallPalletTransferMulticurrencies(
        tokens: transferAssets,
        dest: destination,
        feeItem: params.feeIndex,
        destWeightLimit: weightLimit.cast());
  }

  static XTokenCallPallet _xtokenTransferMultiasset({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    required BaseSubstrateNetwork network,
  }) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion,
            address: params.destinationAddress);
    final asset = params.assets[0];
    final weightLimit =
        _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XTokenCallPalletTransferMultiAsset(
        asset: asset.tolocalizedFungibleVersionedAsset(
            reserveNetwork: network, xcmVersion: xcmVersion),
        dest: destination,
        destWeightLimit: weightLimit.cast());
  }

  static XTokenCallPallet _xtokenTransferMultiassetWithFee(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion,
            address: params.destinationAddress);

    final asset =
        params.assets.indexed.firstWhere((e) => e.$1 != params.feeIndex).$2;
    final fee = params.assets.elementAt(params.feeIndex);
    final weightLimit =
        _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XTokenCallPalletTransferMultiAssetWithFee(
        asset: asset.tolocalizedFungibleVersionedAsset(
            xcmVersion: xcmVersion, reserveNetwork: network),
        fee: fee.tolocalizedFungibleVersionedAsset(
            xcmVersion: xcmVersion, reserveNetwork: network),
        dest: destination,
        destWeightLimit: weightLimit.cast());
  }

  static XTokenCallPallet _xtokenTransferMultiassets(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xcmVersion,
            address: params.destinationAddress);
    List<(SubstrateXCMTransferAsset, XCMAsset)> assets = params.assets
        .map((e) => (
              e,
              e.tolocalizedFungibleAsset(
                  xcmVersion: xcmVersion, reserveNetwork: network)
            ))
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    int feeItem = assets
        .indexWhere((e) => e.$1 == params.assets.elementAt(params.feeIndex));
    final weightLimit =
        _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XTokenCallPalletTransferMultiAssets(
        assets: XCMVersionedAssets.fromVersion(
            assets: assets.map((e) => e.$2).toList(),
            version: xcmVersion,
            sort: false),
        dest: destination,
        feeItem: feeItem,
        destWeightLimit: weightLimit.cast());
  }

  static XTokenCallPallet createXCMXTokenTransferInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network,
      SubstrateCallPalletXCMTransferMethod? method}) {
    method ??= _findXTokenMethod(params: params, provider: provider);
    switch (method) {
      case XTokenCallPalletMethod.transfer:
        return _xtokenTransfer(
            params: params, provider: provider, network: network);
      case XTokenCallPalletMethod.transferMultiasset:
        return _xtokenTransferMultiasset(
            params: params, provider: provider, network: network);
      case XTokenCallPalletMethod.transferMultiassetWithFee:
        return _xtokenTransferMultiassetWithFee(
            params: params, provider: provider, network: network);
      case XTokenCallPalletMethod.transferMultiassets:
        return _xtokenTransferMultiassets(
            params: params, provider: provider, network: network);
      case XTokenCallPalletMethod.transferMulticurrencies:
        return _xtokenTransferMulticurrencies(
            params: params, provider: provider, network: network);
      case XTokenCallPalletMethod.transferWithFee:
        return _xtokenTransferWithFee(
            params: params, provider: provider, network: network);
      default:
        throw DartSubstratePluginException("Unsuported xtoken method.");
    }
  }

  static SubstrateXCMCallPallet createXCMXTransferTransferInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network}) {
    const XCMVersion xTransferXcmVersion = XCMVersion.v3;

    final xcmVersion = network.findXcmVersion(params.destinationNetwork);
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destination: params.destinationNetwork,
            version: xTransferXcmVersion,
            address: params.destinationAddress);
    final asset = params.assets[0];
    if (params.destinationWeightLimit?.version == XCMVersion.v2) {
      throw DartSubstratePluginException("Invalid Weight limit xcm version");
    }
    return XTransferCallPalletTransfer(
        asset: asset
            .tolocalizedFungibleAsset(
                xcmVersion: xcmVersion, reserveNetwork: network)
            .cast(),
        dest: destination.location.asVersion(xTransferXcmVersion).cast(),
        destWeight: switch (params.destinationWeightLimit?.type) {
          null || XCMWeightLimitType.unlimited => null,
          XCMWeightLimitType.limited =>
            _createWeight(xTransferXcmVersion, params.destinationWeightLimit)
                .cast<XCMV3WeightLimitLimited>()
                .weight
        });
  }

  static SubstrateXCMCallPallet createXCMTransfer({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    required BaseSubstrateNetwork network,
    SubstrateCallPalletXCMTransferMethod? method,
    SubtrateMetadataPallet pallet = SubtrateMetadataPallet.polkadotXcm,
  }) {
    switch (pallet) {
      case SubtrateMetadataPallet.xcmPallet:
      case SubtrateMetadataPallet.polkadotXcm:
        return createXCMPalletTransfer(
            params: params,
            provider: provider,
            network: network,
            method: method);
      case SubtrateMetadataPallet.xTokens:
        return createXCMXTokenTransferInternal(
          params: params,
          provider: provider,
          network: network,
          method: method,
        );
      case SubtrateMetadataPallet.xTransfer:
        return createXCMXTransferTransferInternal(
            params: params, provider: provider, network: network);
      default:
        throw DartSubstratePluginException("Unsupported xcm transfer method.");
    }
  }

  /// transfer assets from para to system chains
  static Future<SubstrateXCMCallPallet> xcmTransferParaToSystem(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network,
      required SubtrateMetadataPallet defaultPallet,
      ONREQUESTNETWORKPROVIDER? onControllerRequest,
      bool useTypeAndThen = true}) async {
    if (!network.role.isPara || !params.destinationNetwork.role.isSystem) {
      throw DartSubstratePluginException(
          "This operation is only allowed from a parachain to the relay chain.");
    }
    if (useTypeAndThen) {
      if (!params.destinationNetwork.isAssetHub) {
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferAssetsThroughUsingTypeAndThen(
                params: params,
                provider: provider,
                network: network,
                onEstimateFee: onControllerRequest);
      }
      if (params.hasRelayAsset) {
        return transferDotThroughUsingTypeAndThen(
            params: params, provider: provider, network: network);
      }
    }
    return createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: defaultPallet);
  }

  static List<R> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination,
      required BaseSubstrateNetwork network,
      List<BaseSubstrateNetwork> disabledRoutes = const [],
      bool disableDot = false}) {
    if (destination.relaySystem != destination.relaySystem) return [];
    if (disabledRoutes.contains(destination)) return [];
    List<R> assetsWithLocation =
        assets.where((e) => e.isSpendable && e.location != null).toList();
    final locations = assetsWithLocation.map((e) {
      final location = e
          .getlocalizedLocation(
              reserveNetwork: network, version: network.defaultXcmVersion)
          .location;
      return (
        e,
        location,
        network.role.isRelay
            ? location.isZeroParentsAndHere()
            : location.isOneParentsAndHere()
      );
    }).toList();
    final dotTransfer = network.role.isRelay || locations.any((e) => e.$3);
    if (dotTransfer && disableDot) {
      return locations.where((e) => !e.$3).map((e) => e.$1).toList();
    }
    return assetsWithLocation;
  }

  static List<R> filterReceivedAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork origin,
      required BaseSubstrateNetwork network,
      List<XCMMultiLocation> disabledLocations = const [],
      bool disableDot = false}) {
    List<R> assetsWithLocation =
        assets.where((e) => e.isSpendable && e.location != null).toList();
    if (!disableDot && disabledLocations.isEmpty) return assetsWithLocation;
    final locations = assetsWithLocation.map((e) {
      final location = e.location!.location;
      return (
        e,
        location,
        origin.role.isRelay
            ? location.isZeroParentsAndHere()
            : location.isOneParentsAndHere()
      );
    }).toList();
    final dotTransfer = locations.any((e) => e.$3);
    if (dotTransfer && disableDot) {
      return locations.where((e) => !e.$3).map((e) => e.$1).toList();
    }
    if (disabledLocations.isEmpty) return assetsWithLocation;
    List<R> filteredLocations = [];

    for (final destAsset in assetsWithLocation) {
      final dLocation = destAsset.location?.location;
      final location = disabledLocations.firstWhereNullable((e) =>
          SubstrateNetworkControllerUtils.locationEquality(
              networkA: network, networkB: origin, b: dLocation, a: e));
      if (location == null) filteredLocations.add(destAsset);
    }
    return filteredLocations.toList();
  }

  static XCMDepositReserveAsset _depositReserve(
      {required List<XCMAsset> transferAssets,
      required XCMAsset feeAsset,
      required BaseSubstrateNetwork to,
      required BaseSubstrateAddress address,
      required XCMMultiLocation reserveLocation,
      required XCMVersion xcmVersion,
      required XCMVersion destXCMVersion,
      bool canEstimateFee = false,
      BigInt? fee}) {
    final assets = () {
      if (!canEstimateFee || fee == null) {
        return XCMMultiAssetFilter.wild(
            XCMWildMultiAsset.all(version: xcmVersion));
      }
      final sort = transferAssets.clone()..sort((a, b) => a.compareTo(b));
      return XCMMultiAssetFilter.definite(
          XCMAssets.fromAsset(assets: sort, version: xcmVersion));
    }();
    final destination = SubstrateNetworkControllerUtils.createDestination(
        destination: to, version: xcmVersion, originlocation: reserveLocation);
    final assetAmount = feeAsset.fun.cast<XCMFungibilityFungible>().units;
    fee ??= assetAmount ~/ BigInt.from(2);
    final amount = assetAmount - fee;
    if (amount <= BigInt.zero) {
      throw DartSubstratePluginException(
        "Insufficient balance for fee.",
        details: {
          "provided": assetAmount.toString(),
          "required_fee": fee.toString()
        },
      );
    }
    return XCMDepositReserveAsset.fromAssets(
        dest: destination,
        xcm: XCM.fromInstructions(instructions: [
          XCMBuyExecution.fromFees(
              fees: XCMAsset.fungibleAsset(amount: amount, id: feeAsset.id)),
          XCMDepositAsset.fromAssets(
              assets: XCMMultiAssetFilter.wild(
                  XCMWildMultiAsset.all(version: destXCMVersion)),
              beneficiary:
                  SubstrateNetworkControllerUtils.createBeneficiaryLocation(
                      address: address, version: destXCMVersion, network: to))
        ], version: destXCMVersion),
        assets: assets);
  }

  static XCMInitiateTeleport _initiateTeleport(
      {required List<XCMAsset> transferAssets,
      required XCMAsset feeAsset,
      required BaseSubstrateNetwork to,
      required BaseSubstrateAddress address,
      required XCMMultiLocation reserveLocation,
      required XCMVersion xcmVersion,
      bool canEstimateFee = false,
      BigInt? fee}) {
    final assets = () {
      if (!canEstimateFee || fee == null) {
        return XCMMultiAssetFilter.wild(
            XCMWildMultiAsset.all(version: xcmVersion));
      }
      final sort = transferAssets.clone()..sort((a, b) => a.compareTo(b));
      return XCMMultiAssetFilter.definite(
          XCMAssets.fromAsset(assets: sort, version: xcmVersion));
    }();
    final destination = SubstrateNetworkControllerUtils.createDestination(
        destination: to, version: xcmVersion, originlocation: reserveLocation);
    final assetAmount = feeAsset.fun.cast<XCMFungibilityFungible>().units;
    fee ??= assetAmount ~/ BigInt.from(2);
    final amount = assetAmount - fee;
    if (amount <= BigInt.zero) {
      throw DartSubstratePluginException(
        "Insufficient balance for fee.",
        details: {
          "provided": assetAmount.toString(),
          "required_fee": fee.toString()
        },
      );
    }
    final feeLocation = SubstrateNetworkControllerUtils.localizeFor(
        reserveNetwork: to,
        location: feeAsset.id.getLocation(),
        version: xcmVersion);
    return XCMInitiateTeleport.fromAsset(
        dest: destination,
        xcm: XCM.fromInstructions(instructions: [
          XCMBuyExecution.fromFees(
              fees: XCMAsset.fungibleAsset(
                  amount: amount, id: XCMAssetId.fromLocation(feeLocation))),
          XCMDepositAsset.fromAssets(
              assets: XCMMultiAssetFilter.wild(
                  XCMWildMultiAsset.all(version: xcmVersion)),
              beneficiary:
                  SubstrateNetworkControllerUtils.createBeneficiaryLocation(
                      address: address, version: xcmVersion, network: to))
        ], version: xcmVersion),
        asset: assets);
  }

  static XCMTransferType _determineAssetTransferType(
      {required XCMMultiLocation assetLocation,
      required XCMMultiLocation destinationLocation,
      required BaseSubstrateNetwork origin}) {
    final destPara = destinationLocation.getParachain()?.id;
    final assetPara = assetLocation.getParachain()?.id;
    if (origin.role.isRelay) {
      if (SubstrateNetworkControllerUtils.isSystemLocation(
          destinationLocation)) {
        return XCMTransferTypeTeleport();
      }
      return XCMTransferTypeLocalReserve();
    }
    if (origin.role.isSystem) {
      if (destinationLocation.isZeroParentsAndHere()) {
        return XCMTransferTypeTeleport();
      }
      if (assetLocation.isOneParentsAndHere() &&
          SubstrateNetworkControllerUtils.isSystemLocation(
              destinationLocation)) {
        return XCMTransferTypeTeleport();
      }
      if (assetLocation.isZeroParents() ||
          assetLocation.isOneParentsAndHere()) {
        return XCMTransferTypeLocalReserve();
      }

      if (destPara == assetPara) {
        return XCMTransferTypeDestinationReserve();
      }
    }
    if (origin.role.isPara) {
      if (assetLocation.isZeroParents()) {
        return XCMTransferTypeLocalReserve();
      }
      if (destPara == assetPara) {
        return XCMTransferTypeDestinationReserve();
      }
      if (assetLocation.isOneParentsAndHere()) {
        return XCMTransferTypeDestinationReserve();
      }
    }
    throw DartSubstratePluginException("Remote reserve not supported.");
  }

  static Future<XCMCallPallet> transferAssetsThroughUsingTypeAndThen(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      required BaseSubstrateNetwork network,
      required ONREQUESTNETWORKPROVIDER? onEstimateFee,
      XCMMultiLocation? reserve}) async {
    final pallet = findXcmPallet(provider);
    XCMMultiLocation reserveLocation = reserve ?? network.assetHub.location();
    if (!params.hasRelayAsset) {
      if (!params.locations.every((e) => e.isOneParents())) {
        throw DartSubstratePluginException(
            "Unsuported asset reserve location.");
      }
      final paras = params.locations
          .map((e) => e.getParachain()?.id)
          .whereType<int>()
          .toList();
      if (paras.toSet().length != 1 ||
          paras.length != params.locations.length) {
        throw DartSubstratePluginException(
            "Multiple reserve chain not allowed.");
      }
      reserveLocation = SubstrateNetworkControllerUtils.getParaReserveLocation(
          params.locations[0]);
    }
    final reserveNetwork = BaseSubstrateNetwork.fromPara(
        reserveLocation.getParachain()?.id ?? 0,
        relay: network.relaySystem);
    final reserveXcmVersion = network.findXcmVersion(params.destinationNetwork);
    reserveLocation = reserveLocation.asVersion(reserveXcmVersion);
    List<(SubstrateXCMTransferAsset, XCMAsset, XCMAsset)> assets =
        params.assets.indexed
            .map((e) => (
                  e.$2,
                  e.$2.tolocalizedFungibleAsset(
                      reserveNetwork: network,
                      xcmVersion: network.defaultXcmVersion),
                  e.$2.tolocalizedFungibleAsset(
                      reserveLocation: reserveLocation,
                      xcmVersion: reserveXcmVersion),
                ))
            .toList()
          ..sort((a, b) => a.$2.compareTo(b.$2));
    if (params.hasRelayAsset && params.assets.length != 1) {
      throw DartSubstratePluginException("Duplicate asset not allowed.");
    }
    int feeItem = assets
        .indexWhere((e) => e.$1 == params.assets.elementAt(params.feeIndex));
    final feeAsset = assets[feeItem];
    XCMTransferType assetType = _determineAssetTransferType(
        origin: network,
        destinationLocation: reserveLocation,
        assetLocation: feeAsset.$2.id.getLocation());

    XCMVersionedXCM createXCM({BigInt? fee, bool canEstimateFee = false}) {
      if (params.hasRelayAsset && !params.destinationNetwork.role.isPara) {
        return XCMVersionedXCM.fromXCM(XCM.fromInstructions(instructions: [
          _initiateTeleport(
              transferAssets: assets.map((e) => e.$3).toList(),
              feeAsset: feeAsset.$3,
              to: params.destinationNetwork,
              address: params.destinationAddress,
              reserveLocation: reserveLocation,
              xcmVersion: reserveXcmVersion,
              canEstimateFee: canEstimateFee,
              fee: fee),
        ], version: reserveXcmVersion));
      }
      return XCMVersionedXCM.fromXCM(XCM.fromInstructions(instructions: [
        _depositReserve(
            transferAssets: assets.map((e) => e.$3).toList(),
            feeAsset: feeAsset.$1.tolocalizedFungibleAsset(
                xcmVersion: reserveXcmVersion,
                reserveNetwork: params.destinationNetwork),
            to: params.destinationNetwork,
            address: params.destinationAddress,
            reserveLocation: reserveLocation,
            xcmVersion: reserveXcmVersion,
            canEstimateFee: canEstimateFee,
            destXCMVersion: reserveXcmVersion,
            fee: fee),
      ], version: reserveXcmVersion));
    }

    BigInt? fee;
    if (reserveNetwork != null && onEstimateFee != null) {
      final assetHubProvider = await onEstimateFee(reserveNetwork);
      if (assetHubProvider != null) {
        final feelocation = SubstrateNetworkControllerUtils.localizeFor(
            reserveNetwork: reserveNetwork,
            location: feeAsset.$3.id.getLocation(),
            version: reserveXcmVersion);
        fee = await queryXcmWeightToFee(
            asset: feelocation.toAssetId(),
            provier: assetHubProvider,
            xcm: createXCM(canEstimateFee: true));
      }
    }
    final destination =
        SubstrateNetworkControllerUtils.createVersionedDestination(
            origin: network,
            destinationLocation: reserveLocation,
            version: network.defaultXcmVersion);
    final weight = _createWeight(XCMVersion.v3, params.destinationWeightLimit);
    return XCMCallPalletTransferAssetsUsingTypeAndThen(
        pallet: pallet,
        dest: destination,
        assets: XCMVersionedAssets.fromVersion(
            assets: assets.map((e) => e.$2).toList(),
            version: network.defaultXcmVersion),
        assetsTransferType: assetType,
        remoteFeesId: feeAsset.$2.id.asVersioned(),
        feesTransferType: assetType,
        customXcmOnDest: createXCM(canEstimateFee: fee != null, fee: fee),
        version: network.defaultXcmVersion,
        weightLimit: weight);
  }
}
