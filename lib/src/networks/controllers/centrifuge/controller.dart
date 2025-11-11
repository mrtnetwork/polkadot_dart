import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/centrifuge/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseCentrifugeNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object, BaseCentrifugeNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseCentrifugeNetworkController({required this.params});
  @override
  CentrifugeNetworkNativeAsset get defaultNativeAsset;

  Future<Map<Map<String, dynamic>, CentrifugeAssetMetadata>> _getMetadatas(
      MetadataWithProvider provider) async {
    final assetEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getPalletOrmlAssetRegistryMetadataIdentifierMap(provider);
    final metadatas = assetEntries.map((k, v) {
      return MapEntry(k, CentrifugeAssetMetadata.fromJson(v));
    });
    return metadatas;
  }

  Future<List<CentrifugeNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    final metadatas = await _getMetadatas(provider);
    List<CentrifugeNetworkAsset> assets = [];
    for (final e in metadatas.entries) {
      if (CompareUtils.mapIsEqual(e.key, defaultNativeAsset.identifier)) {
        continue;
      }
      if (ids != null && !ids.any((id) => CompareUtils.mapIsEqual(id, e.key))) {
        continue;
      }
      BaseCentrifugeAsset asset = BaseCentrifugeAsset.fromJson(e.key);
      XCMVersionedLocation? location = e.value.location;
      if (location != null) {
        location = SubstrateNetworkControllerUtils.asForeignVersionedLocation(
            from: network,
            location: location.asVersion(network.defaultXcmVersion));
      }
      final bAsset = CentrifugeNetworkAsset(
          asset: asset, metadata: e.value.copyWith(location: location));
      assets.add(bAsset);
    }
    return assets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseCentrifugeNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BaseCentrifugeNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<CentrifugeNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;

    Map<Map<String, dynamic>, CentrifugeNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! CentrifugeNetworkAsset) continue;
      final assetId = i.identifier;
      assets[assetId] = i;
    }
    if (assets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getOrmlTokensPalletAccountIdentifierMap(
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
  Future<List<CentrifugeNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<CentrifugeNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseCentrifugeNetworkAsset>?>
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

class CentrifugeNetworkController
    extends BaseCentrifugeNetworkController<PolkadotNetwork> {
  CentrifugeNetworkController({required super.params});

  @override
  late final CentrifugeNetworkNativeAsset defaultNativeAsset =
      CentrifugeNetworkNativeAsset(
    metadata: CentrifugeAssetMetadata(
        decimals: 18,
        name: "Centrifuge",
        symbol: "CFG",
        existentialDeposit: BigInt.zero,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 1,
            version: network.defaultXcmVersion,
            paraId: network.paraId)),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.centrifuge;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      throw SubstrateNetworkControllerConstants.transferDisabled;
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
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.xTokens);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      throw SubstrateNetworkControllerConstants.transferDisabled;
    }
    return SubstrateNetworkControllerXCMTransferBuilder.xcmTransferParaToSystem(
        params: params,
        provider: provider,
        network: network,
        defaultPallet: SubtrateMetadataPallet.xTokens,
        useTypeAndThen: false,
        onControllerRequest: onControllerRequest);
  }

  @override
  Future<List<R>> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination}) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .filterTransferableAssets(
      assets: assets,
      destination: destination,
      network: network,
      disabledRoutes: [],
    );
  }
}

class AltairNetworkController
    extends BaseCentrifugeNetworkController<KusamaNetwork> {
  AltairNetworkController({required super.params});
  @override
  late final CentrifugeNetworkNativeAsset defaultNativeAsset =
      CentrifugeNetworkNativeAsset(
    metadata: CentrifugeAssetMetadata(
        decimals: 18,
        name: "Altair",
        symbol: "AIR",
        existentialDeposit: BigInt.parse("1000000000000"),
        location: SubstrateNetworkControllerUtils.locationWithParaId(
            version: network.defaultXcmVersion, paraId: network.paraId)),
  );

  @override
  KusamaNetwork get network => KusamaNetwork.altair;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
    throw SubstrateNetworkControllerConstants.transferDisabled;
  }

  @override
  Future<List<R>> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination}) async {
    return [];
  }

  @override
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets, required BaseSubstrateNetwork origin}) async {
    if (origin.role.isRelay) {
      return assets;
    }
    return [];
  }
}
