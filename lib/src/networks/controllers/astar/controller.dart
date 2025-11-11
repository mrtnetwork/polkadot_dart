import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/astar/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseAstarNetworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseAstarNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseAstarNetworkController({required this.params});

  Future<Map<BigInt, AstarNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<BigInt>? assetIds}) async {
    final assets = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletAssetIdentifierBigInt(provider, assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletMetadataIdentifierBigInt(provider, assetIds: assetIds);
    final locations = await SubstrateNetworkControllerAssetQueryHelper
        .getXcAssetConfigPalletAssetIdToLocationEntriesIdentifierBigInt(
            provider, network.defaultXcmVersion);
    final fees = await SubstrateNetworkControllerAssetQueryHelper
        .getXcAssetConfigPalletAssetLocationUnitsPerSecondEntriesIdentifierMultilocation(
            provider, network.defaultXcmVersion);
    final fees2 = await SubstrateNetworkControllerAssetQueryHelper
        .queryAcceptablePaymentAsset(
            provider: provider, version: network.defaultXcmVersion);
    final a = assets.entries.map((e) {
      final metadata = metadatas[e.key];
      final location = locations[e.key];
      final BigInt? unitsPerSecond = fees[location];
      return AstarNetworkAsset(
          asset: PolkadotAssetHubAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          location: location == null
              ? null
              : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                  from: network, location: location),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: fees2.contains(location),
          unitsPerSecond: unitsPerSecond);
    }).toList();
    return {for (final i in a) i.identifier: i};
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseAstarNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseAstarNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BaseAstarNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, AstarNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! AstarNetworkAsset) continue;
      final assetId = i.identifier;
      assets[assetId] = i;
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
        balances.add(SubstrateAccountAssetBalance(
            asset: asset,
            free: balance.balance,
            reason: balance.reason,
            status: balance.status));
      }
    }
    return balances;
  }

  @override
  Future<List<AstarNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);

    List<AstarNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets.values);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseAstarNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseAstarNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class AstarNetworkController
    extends BaseAstarNetworkController<PolkadotNetwork> {
  AstarNetworkController({required super.params});

  @override
  late final AstarNetworkNativeAsset defaultNativeAsset =
      AstarNetworkNativeAsset(
    decimals: 18,
    name: "Astar",
    symbol: "ASTR",
    minBalance: BigInt.parse("1000000"),
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        paraId: network.paraId, version: network.defaultXcmVersion),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.astar;

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
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.xTokens);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    throw SubstrateNetworkControllerConstants.transferDisabled;
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (params.destinationNetwork.isAssetHub) {
        return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
            params: params, provider: provider, network: network);
      }
      throw SubstrateNetworkControllerConstants.transferDisabled;
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.xTokens);
  }
}

class ShidenNetworkController
    extends BaseAstarNetworkController<KusamaNetwork> {
  ShidenNetworkController({required super.params});

  @override
  late final AstarNetworkNativeAsset defaultNativeAsset =
      AstarNetworkNativeAsset(
    decimals: 18,
    name: "Shiden",
    symbol: "SDN",
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        paraId: network.paraId, version: network.defaultXcmVersion),
  );

  @override
  KusamaNetwork get network => KusamaNetwork.shiden;

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
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.xTokens);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    throw SubstrateNetworkControllerConstants.transferDisabled;
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      if (params.destinationNetwork.isAssetHub) {
        return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
            params: params, provider: provider, network: network);
      }
      throw SubstrateNetworkControllerConstants.transferDisabled;
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.xTokens);
  }
}
