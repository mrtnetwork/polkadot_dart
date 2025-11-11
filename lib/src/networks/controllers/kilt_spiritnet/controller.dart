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

import 'asset.dart';

abstract class BaseKILTSpiritnetNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<XCMVersionedLocation,
        BaseKLITSpiritNetworkAsset, NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseKILTSpiritnetNetworkController({required this.params});

  Future<Map<XCMVersionedLocation, KLITSpiritnetNetworkAsset>> _getForeignAsset(
      {required MetadataWithProvider provider,
      List<XCMVersionedLocation>? assetIds}) async {
    final assetsEntires = await SubstrateNetworkControllerAssetQueryHelper
        .getFungiblesPalletAssetsIdentifierMultiLocation(
            provider, network.defaultXcmVersion,
            assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getFungiblesPalletMetadataIdentifierMultiLocation(
            provider, network.defaultXcmVersion,
            locations: assetIds);
    final assets = assetsEntires.entries.map((e) {
      final metadata = metadatas[e.key];
      return KLITSpiritnetNetworkAsset(
          asset: PolkadotAssetHubForeignAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          location: SubstrateNetworkControllerUtils.asForeignVersionedLocation(
              from: network, location: e.key),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: true);
    }).toList();
    return {for (final i in assets) i.identifier as XCMVersionedLocation: i};
  }

  @override
  Future<List<KLITSpiritnetNetworkAsset>> getAssetsInternal(
      {List<XCMVersionedLocation>? knownAssetIds}) async {
    final List<XCMVersionedLocation>? assetLocaios = knownAssetIds;
    final provider = await params.loadMetadata(network);

    List<KLITSpiritnetNetworkAsset> allAssets = [];
    if (assetLocaios == null || assetLocaios.isNotEmpty) {
      final foreigAsset =
          await _getForeignAsset(provider: provider, assetIds: assetLocaios);
      allAssets.addAll(foreigAsset.values);
    }

    return allAssets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseKLITSpiritNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<XCMVersionedLocation>? knownAssetIds,
          List<BaseKLITSpiritNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BaseKLITSpiritNetworkAsset>> balances =
        [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<XCMVersionedLocation, KLITSpiritnetNetworkAsset> foreignAssets = {};
    for (final i in allAssets) {
      if (i is! KLITSpiritnetNetworkAsset) continue;
      final assetId = i.identifierAs<XCMVersionedLocation>();
      foreignAssets[assetId] = i;
    }
    if (foreignAssets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getFungiblesPalletAccountIdentifierMultilocation(
              provider: provider,
              address: address,
              locations: foreignAssets.keys.toList());
      for (final i in balancesEntries.entries) {
        if (i.value == null) continue;
        final asset = foreignAssets[i.key];
        if (asset == null) continue;

        final balance = PolkadotAssetBalance.fromJson(i.value!);
        balances.add(SubstrateAccountAssetBalance<BaseKLITSpiritNetworkAsset>(
            asset: asset,
            free: balance.balance,
            reason: balance.reason,
            status: balance.status));
      }
    }
    return balances;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseKLITSpiritNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseKLITSpiritNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class KILTSpiritnetNetworkController
    extends BaseKILTSpiritnetNetworkController<PolkadotNetwork> {
  KILTSpiritnetNetworkController({required super.params});

  @override
  late final KLITSpiritnetNetworkNativeAsset defaultNativeAsset =
      KLITSpiritnetNetworkNativeAsset(
    name: "KILT Spiritnet",
    decimals: 15,
    symbol: "KILT",
    minBalance: BigInt.parse("10000000000000"),
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        version: network.defaultXcmVersion, paraId: network.paraId),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.kiltSpiritnet;

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
          .transferAssetsThroughUsingTypeAndThen(
              params: params,
              provider: provider,
              network: network,
              onEstimateFee: onControllerRequest);
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: params.isLocalAssets
            ? SubtrateMetadataPallet.polkadotXcm
            : SubtrateMetadataPallet.xTokens);
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
        defaultPallet: SubtrateMetadataPallet.xTokens,
        onControllerRequest: onControllerRequest);
  }
}
