import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/bifrost/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseBifrostNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object, BaseBifrostNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseBifrostNetworkController({required this.params});

  @override
  BifrostNetworkNativeAsset get defaultNativeAsset => BifrostNetworkNativeAsset(
      metadata: BifrostAssetMetadata(
          decimals: 12,
          symbol: "BNC",
          minimalBalance: BigInt.parse("10000000000"),
          name: "Bifrost"),
      location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
          version: network.defaultXcmVersion,
          variantIndex: 0,
          secondVariantIndex: 1,
          paraId: network.paraId));

  Future<Map<Map<String, dynamic>, BifrostAssetMetadata>> _getMetadatas(
      MetadataWithProvider provider) async {
    final assetEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegistryPalletcurrencyMetadatasEntriesIdentifierMap(provider);
    final metadatas = assetEntries.map((k, v) {
      return MapEntry(k, BifrostAssetMetadata.fromJson(v));
    });
    return metadatas;
  }

  Future<List<BifrostNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    ids ??= await SubstrateNetworkControllerAssetQueryHelper
        .getTokenPalletTotalIssuanceIdentifierMap(provider);
    final metadatas = await _getMetadatas(provider);
    final locations = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegistryPalletCurrencyIdToLocationsEntriesIdentifierMap(
            provider, network.defaultXcmVersion);
    List<BifrostNetworkAsset> assets = [];
    for (final e in ids) {
      if (CompareUtils.mapIsEqual(e, defaultNativeAsset.identifier)) continue;
      BaseBifrostAsset asset = BaseBifrostAsset.fromJson(e);
      final metadata = metadatas.entries
          .firstWhereNullable((m) => CompareUtils.mapIsEqual(m.key, e))
          ?.value;
      final location = locations.entries
          .firstWhereNullable((m) => CompareUtils.mapIsEqual(m.key, e))
          ?.value;

      final bAsset = BifrostNetworkAsset(
          asset: asset,
          metadata: metadata,
          isFeeToken: metadata != null,
          location: location == null
              ? null
              : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                  location: location, from: network));
      assets.add(bAsset);
    }
    return assets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseBifrostNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BaseBifrostNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BifrostNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<Map<String, dynamic>, BifrostNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! BifrostNetworkAsset) continue;
      final assetId = i.identifier;

      assets[assetId] = i;
    }
    if (assets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getTokensPalletAccountIdentifierMap(
              provider: provider,
              address: address,
              assetIds: assets.keys.toList());
      for (final i in balancesEntries.entries) {
        if (i.value == null) continue;
        final asset = assets[i.key];
        if (asset == null) continue;
        final balance = TokenPalletAccountBalance.fromJson(i.value!);
        balances.add(SubstrateAccountAssetBalance(
          asset: asset,
          free: balance.free,
          frozen: balance.free,
          reserved: balance.frozen,
        ));
      }
    }
    return balances;
  }

  @override
  Future<List<BifrostNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<BifrostNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseBifrostNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class BifrostNetworkController
    extends BaseBifrostNetworkController<PolkadotNetwork> {
  BifrostNetworkController({required super.params});

  @override
  PolkadotNetwork get network => PolkadotNetwork.bifrostPolkadot;

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
        pallet: SubtrateMetadataPallet.polkadotXcm);
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
        useTypeAndThen: true,
        onControllerRequest: onControllerRequest);
  }
}

class BifrostKusamaNetworkController
    extends BaseBifrostNetworkController<KusamaNetwork> {
  BifrostKusamaNetworkController({required super.params});

  @override
  KusamaNetwork get network => KusamaNetwork.bifrostKusama;

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
