import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/pendulum/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BasePendulumNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object, BasePendulumNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  @override
  PendulumNetworkNativeAsset get defaultNativeAsset;
  BasePendulumNetworkController({required this.params});

  Future<Map<Map<String, dynamic>, PendulumAssetMetadata?>> _getMetadatas(
      MetadataWithProvider provider) async {
    final assetEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getPalletAssetRegistryMetadataIdentifierMap(provider);
    final metadatas = assetEntries.map((k, v) {
      return MapEntry<Map<String, dynamic>, PendulumAssetMetadata?>(
          k, PendulumAssetMetadata.fromJson(v));
    });
    return metadatas;
  }

  Future<List<PendulumNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    final assetsEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getTokenPalletTotalIssuanceIdentifierMap(provider);
    final metadatas = await _getMetadatas(provider);

    List<PendulumNetworkAsset> assets = [];
    for (final i in assetsEntries) {
      if (!metadatas.keys.any((e) => CompareUtils.mapIsEqual(e, i))) {
        metadatas[i] = null;
      }
    }
    for (final e in metadatas.entries) {
      if (CompareUtils.mapIsEqual(e.key, defaultNativeAsset.identifier)) {
        continue;
      }
      if (ids != null && !ids.any((id) => CompareUtils.mapIsEqual(id, e.key))) {
        continue;
      }
      BasePendulumAsset asset = BasePendulumAsset.fromJson(e.key);
      XCMVersionedLocation? location = e.value?.location;
      if (location != null) {
        location = SubstrateNetworkControllerUtils.asForeignVersionedLocation(
            from: network,
            location: location.asVersion(network.defaultXcmVersion));
      }
      final bAsset = PendulumNetworkAsset(
          asset: asset, metadata: e.value?.copyWith(location: location));
      assets.add(bAsset);
    }
    return assets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<PendulumNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BasePendulumNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<PendulumNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<Map<String, dynamic>, PendulumNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! PendulumNetworkAsset) continue;
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
        if (asset == null || asset.type.isNative) continue;
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
  Future<List<PendulumNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<PendulumNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BasePendulumNetworkAsset>?>
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

class PendulumNetworkController
    extends BasePendulumNetworkController<PolkadotNetwork> {
  PendulumNetworkController({required super.params});
  @override
  late final PendulumNetworkNativeAsset defaultNativeAsset =
      PendulumNetworkNativeAsset(
    metadata: PendulumAssetMetadata(
        decimals: 12,
        name: "Pendulum",
        symbol: "PEN",
        additional: PendulumAssetMetadatAdditional(
            diaKeys: PendulumAssetMetadatAdditionalDiaKeys(
                blockchain: "Pendulum", symbol: "PEN"),
            feePerSecond: BigInt.parse("250000000000000")),
        existentialDeposit: BigInt.parse('1000000000'),
        location: XCMMultiLocation.fromVersion(
                parents: 1,
                version: network.defaultXcmVersion,
                interior: XCMJunctions.fromVersion(junctions: [
                  XCMJunctionParaChain.fromVersion(
                      id: network.paraId, version: network.defaultXcmVersion),
                  XCMJunctionPalletInstance.fromVersion(
                      index: 10, version: network.defaultXcmVersion)
                ], version: network.defaultXcmVersion))
            .asVersioned()),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.pendulum;

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
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
        useTypeAndThen: false,
        defaultPallet: params.isLocalAssets
            ? SubtrateMetadataPallet.polkadotXcm
            : SubtrateMetadataPallet.xTokens,
        onControllerRequest: onControllerRequest);
  }
}

class AmplitudeNetworkController
    extends BasePendulumNetworkController<KusamaNetwork> {
  AmplitudeNetworkController({required super.params});
  @override
  late final PendulumNetworkNativeAsset defaultNativeAsset =
      PendulumNetworkNativeAsset(
    metadata: PendulumAssetMetadata(
        decimals: 12,
        name: "Amplitude",
        symbol: "AMPE",
        additional: PendulumAssetMetadatAdditional(
            diaKeys: PendulumAssetMetadatAdditionalDiaKeys(
                blockchain: "Amplitude", symbol: "AMPE"),
            feePerSecond: BigInt.parse("4000000000000000")),
        existentialDeposit: BigInt.parse('1000000000'),
        location: SubstrateNetworkControllerUtils.locationWithParaId(
            paraId: network.paraId,
            version: network.defaultXcmVersion,
            palletInstance: 10)),
  );

  @override
  KusamaNetwork get network => KusamaNetwork.amplitude;

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
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
        onControllerRequest: onControllerRequest,
        useTypeAndThen: false);
  }
}
