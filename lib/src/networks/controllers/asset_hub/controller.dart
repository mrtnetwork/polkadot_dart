import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseAssetHubNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object,
        BasePolkadotAssetHubNetworkAsset, NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseAssetHubNetworkController({required this.params});

  XCMVersionedLocation _createAssetLocation(
      {required XCMJunction pallet, required BigInt assetId, int parent = 0}) {
    final version = network.defaultXcmVersion;
    return XCMMultiLocation.fromVersion(
            parents: parent,
            version: version,
            interior: XCMJunctions.fromVersion(junctions: [
              if (parent == 1)
                XCMJunctionParaChain.fromVersion(
                    id: network.paraId, version: version),
              pallet,
              XCMJunctionGeneralIndex.fromVersion(
                  index: assetId, version: version)
            ], version: version))
        .asVersioned();
  }

  Future<Map<BigInt, PolkadotAssetHubNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider,
      required List<XCMVersionedLocation> fees,
      List<BigInt>? assetIds}) async {
    final assets = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletAssetIdentifierBigInt(provider, assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletMetadataIdentifierBigInt(provider, assetIds: assetIds);
    final version = network.defaultXcmVersion;
    final pallet = XCMJunctionPalletInstance.fromVersion(
        index: provider.metadata.api
            .getPalletIndexByName(SubtrateMetadataPallet.assets.name),
        version: version);
    final a = assets.entries.map((e) {
      final metadata = metadatas[e.key];
      final location = _createAssetLocation(pallet: pallet, assetId: e.key);
      return PolkadotAssetHubNetworkAsset(
          asset: PolkadotAssetHubAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          location:
              _createAssetLocation(pallet: pallet, assetId: e.key, parent: 1),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: fees.contains(location),
          chargeAssetTxPayment: fees.contains(location));
    }).toList();
    return {for (final i in a) i.identifier as BigInt: i};
  }

  Future<Map<XCMVersionedLocation, PolkadotAssetHubNetworkAsset>>
      _getForeignAsset(
          {required MetadataWithProvider provider,
          required List<XCMVersionedLocation> fees,
          List<XCMVersionedLocation>? assetIds}) async {
    final assetsEntires = await SubstrateNetworkControllerAssetQueryHelper
        .getForeignAssetsPalletAssetIdentifierMultiLocation(
            provider, network.defaultXcmVersion,
            assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getForeignAssetsPalletMetadataIdentifierMultiLocation(
            provider, network.defaultXcmVersion,
            locations: assetIds);
    final assets = assetsEntires.entries.map((e) {
      final metadata = metadatas[e.key];
      return PolkadotAssetHubNetworkAsset(
          asset: PolkadotAssetHubForeignAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          location: e.key,
          chargeAssetTxPayment: fees.contains(e.key),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: fees.contains(e.key));
    }).toList();
    return {for (final i in assets) i.identifier as XCMVersionedLocation: i};
  }

  @override
  Future<List<PolkadotAssetHubNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final List<BigInt>? assetAssetIds =
        knownAssetIds?.whereType<BigInt>().toList();
    final List<XCMVersionedLocation>? assetLocaios =
        knownAssetIds?.whereType<XCMVersionedLocation>().toList();
    final provider = await params.loadMetadata(network);
    final fees = await SubstrateNetworkControllerAssetQueryHelper
        .queryAcceptablePaymentAsset(
            provider: provider, version: network.defaultXcmVersion);
    List<PolkadotAssetHubNetworkAsset> allAssets = [];
    if (assetAssetIds == null || assetAssetIds.isNotEmpty) {
      final assets = await _getAssets(
          provider: provider, fees: fees, assetIds: assetAssetIds);
      allAssets.addAll(assets.values);
    }
    if (assetLocaios == null || assetLocaios.isNotEmpty) {
      final foreigAsset = await _getForeignAsset(
          provider: provider, fees: fees, assetIds: assetLocaios);
      allAssets.addAll(foreigAsset.values);
    }

    return allAssets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BasePolkadotAssetHubNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>>
        balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, PolkadotAssetHubNetworkAsset> assets = {};
    Map<XCMVersionedLocation, PolkadotAssetHubNetworkAsset> foreignAssets = {};
    for (final i in allAssets) {
      if (i is! PolkadotAssetHubNetworkAsset) continue;
      final assetId = i.identifier;
      if (assetId is BigInt) {
        assets[assetId] = i;
      } else if (assetId is XCMVersionedLocation) {
        foreignAssets[assetId] = i;
      }
    }
    if (assets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getAssetsPalletAccountIdentifierBigInt(
              provider: provider,
              address: address,
              assetIds: assets.keys.toList());
      for (final i in balancesEntries.entries) {
        if (i.value == null) continue;
        final asset = assets[i.key];
        if (asset == null) continue;
        final balance = PolkadotAssetBalance.fromJson(i.value!);
        balances.add(
            SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>(
                asset: asset,
                free: balance.balance,
                reason: balance.reason,
                status: balance.status));
      }
    }
    if (foreignAssets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getForeignAssetsPalletAccountIdentifierMultilocation(
              provider: provider,
              address: address,
              locations: foreignAssets.keys.toList());
      for (final i in balancesEntries.entries) {
        if (i.value == null) continue;
        final asset = foreignAssets[i.key];
        if (asset == null) continue;

        final balance = PolkadotAssetBalance.fromJson(i.value!);
        balances.add(
            SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>(
                asset: asset,
                free: balance.balance,
                reason: balance.reason,
                status: balance.status));
      }
    }
    return balances;
  }

  @override
  Future<SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class PolkadotAssetHubNetworkController
    extends BaseAssetHubNetworkController<PolkadotNetwork> {
  PolkadotAssetHubNetworkController({required super.params});

  @override
  late final PolkadotAssetHubNetworkNativeAsset defaultNativeAsset =
      PolkadotAssetHubNetworkNativeAsset(
    name: "Polkadot",
    decimals: 10,
    symbol: "DOT",
    location: SubstrateNetworkControllerUtils.relayLocation(
        version: network.defaultXcmVersion),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.polkadotAssetHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(params.destinationNetwork)) {
        throw SubstrateNetworkControllerConstants.transferDisabled;
      }
      return SubstrateNetworkControllerXCMTransferBuilder
          .transferDotThroughUsingTypeAndThen(
              params: params, provider: provider, network: network);
    }
    final bool isForeignAsset = params.assets[0].asset.excutionPallet ==
        SubtrateMetadataPallet.foreignAssets;
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: isForeignAsset ? XCMCallPalletMethod.transferAssets : null,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class KusamaAssetHubNetworkController
    extends BaseAssetHubNetworkController<KusamaNetwork> {
  KusamaAssetHubNetworkController({required super.params});
  @override
  late final PolkadotAssetHubNetworkNativeAsset defaultNativeAsset =
      PolkadotAssetHubNetworkNativeAsset(
    name: "Kusama",
    decimals: 12,
    symbol: "KSM",
    minBalance: BigInt.parse("3333333"),
    location: SubstrateNetworkControllerUtils.relayLocation(
        version: network.defaultXcmVersion),
  );

  @override
  KusamaNetwork get network => KusamaNetwork.kusamaAssetHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(params.destinationNetwork)) {
        throw SubstrateNetworkControllerConstants.transferDisabled;
      }
      return SubstrateNetworkControllerXCMTransferBuilder
          .transferDotThroughUsingTypeAndThen(
              params: params, provider: provider, network: network);
    }

    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class WestendAssetHubNetworkController
    extends BaseAssetHubNetworkController<WestendNetwork> {
  WestendAssetHubNetworkController({required super.params});
  @override
  late final PolkadotAssetHubNetworkNativeAsset defaultNativeAsset =
      PolkadotAssetHubNetworkNativeAsset(
    name: "Westend",
    decimals: 12,
    symbol: "WND",
    minBalance: BigInt.parse("10000000000"),
    location: SubstrateNetworkControllerUtils.relayLocation(
        version: network.defaultXcmVersion),
  );

  @override
  WestendNetwork get network => WestendNetwork.westendAssetHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(params.destinationNetwork)) {
        throw SubstrateNetworkControllerConstants.transferDisabled;
      }
      return SubstrateNetworkControllerXCMTransferBuilder
          .transferDotThroughUsingTypeAndThen(
              params: params, provider: provider, network: network);
    }

    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class WestendPenpalNetworkController
    extends BaseAssetHubNetworkController<WestendNetwork> {
  WestendPenpalNetworkController({required super.params});
  @override
  late final PolkadotAssetHubNetworkNativeAsset defaultNativeAsset =
      PolkadotAssetHubNetworkNativeAsset(
    name: "Penpal",
    decimals: 12,
    symbol: "Unit",
    minBalance: BigInt.parse("10000000000"),
    location: SubstrateNetworkControllerUtils.locationWithParaId(
      paraId: network.paraId,
      version: network.defaultXcmVersion,
    ),
  );

  @override
  WestendNetwork get network => WestendNetwork.penpal;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(params.destinationNetwork)) {
        throw SubstrateNetworkControllerConstants.transferDisabled;
      }
      return SubstrateNetworkControllerXCMTransferBuilder
          .transferDotThroughUsingTypeAndThen(
              params: params, provider: provider, network: network);
    }

    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .transferAssetsThroughUsingTypeAndThen(
            params: params,
            provider: provider,
            network: network,
            onEstimateFee: onControllerRequest);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.xcmTransferParaToSystem(
        params: params,
        provider: provider,
        network: network,
        defaultPallet: SubtrateMetadataPallet.polkadotXcm,
        onControllerRequest: onControllerRequest);
  }
}

class PaseoAssetHubNetworkController
    extends BaseAssetHubNetworkController<PaseoNetwork> {
  PaseoAssetHubNetworkController({required super.params});
  @override
  late final PolkadotAssetHubNetworkNativeAsset defaultNativeAsset =
      PolkadotAssetHubNetworkNativeAsset(
    name: "Paseo",
    decimals: 10,
    symbol: "PAS",
    minBalance: BigInt.parse("100000000"),
    location: SubstrateNetworkControllerUtils.relayLocation(
        version: network.defaultXcmVersion),
  );

  @override
  PaseoNetwork get network => PaseoNetwork.paseoAssetHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(params.destinationNetwork)) {
        throw SubstrateNetworkControllerConstants.transferDisabled;
      }
      return SubstrateNetworkControllerXCMTransferBuilder
          .transferDotThroughUsingTypeAndThen(
              params: params, provider: provider, network: network);
    }

    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}
