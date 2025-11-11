import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/interly/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseInterlayNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object, BaseInterlayNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseInterlayNetworkController({required this.params});
  @override
  InterlayNetworkNativeAsset get defaultNativeAsset;
  List<InterlayNetworkAsset> get defaultAssets;

  Future<Map<Map<String, dynamic>, InterlayAssetMetadata>> _getMetdata(
      {required MetadataWithProvider provider,
      List<Map<String, dynamic>>? assetIds}) async {
    final ids = assetIds
        ?.map((e) => e[InterlayAssetType.foreignAsset.type])
        .whereType<int>()
        .toList();
    final metadataEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegistryPalletMetadataIdentifierInt(provider, knownIds: ids);
    Map<Map<String, dynamic>, InterlayAssetMetadata> metadata = {};
    for (final i in metadataEntries.entries) {
      if (i.value == null) continue;
      metadata[{InterlayAssetType.foreignAsset.type: i.key}] =
          InterlayAssetMetadata.fromJson(i.value!);
    }
    return metadata;
  }

  Future<List<InterlayNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    ids ??= await SubstrateNetworkControllerAssetQueryHelper
        .getTokenPalletTotalIssuanceIdentifierMap(provider);
    final metadatas = await _getMetdata(provider: provider, assetIds: ids);
    final List<InterlayNetworkAsset> assets = [];
    for (final e in ids) {
      if (CompareUtils.mapIsEqual(e, defaultNativeAsset.identifier)) continue;
      BaseInterlayAsset asset = BaseInterlayAsset.fromJson(e);
      final metadata = metadatas.entries
          .firstWhereNullable((m) => CompareUtils.mapIsEqual(m.key, e))
          ?.value;
      bool isFeeToken = false;
      if (metadata != null && metadata.additional.feePerSecond > BigInt.zero) {
        isFeeToken = true;
      }
      final defaultAsset = defaultAssets.firstWhereNullable(
        (e) => CompareUtils.mapIsEqual(e.identifier, asset.identifier),
      );
      isFeeToken |= (defaultAsset?.isFeeToken ?? false);
      final location = metadata?.location ?? defaultAsset?.location;
      final acaAsset = InterlayNetworkAsset(
        asset: asset,
        metadata: metadata ?? defaultAsset?.metadata,
        isFeeToken: isFeeToken,
        location: location == null
            ? null
            : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                from: network, location: location),
      );
      assets.add(acaAsset);
    }

    return assets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<InterlayNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BaseInterlayNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<InterlayNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<Map<String, dynamic>, InterlayNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! InterlayNetworkAsset) continue;
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
            frozen: balance.frozen,
            reserved: balance.reserved));
      }
    }
    return balances;
  }

  @override
  Future<List<InterlayNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<InterlayNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseInterlayNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateNetworkControllerAssetQueryHelper
        .getTokensPalletAccountSignleAssetIdentifierMap(
            provider: provider,
            address: address,
            assetId: defaultNativeAsset.identifier);
    if (balance == null) return null;
    final b = TokenPalletAccountBalance.fromJson(balance);
    return SubstrateAccountAssetBalance<BaseInterlayNetworkAsset>(
        asset: defaultNativeAsset,
        free: b.free,
        frozen: b.free,
        reserved: b.reserved);
  }
}

class InterlayNetworkController
    extends BaseInterlayNetworkController<PolkadotNetwork> {
  InterlayNetworkController({required super.params});
  @override
  InterlayNetworkNativeAsset get defaultNativeAsset =>
      InterlayNetworkNativeAsset(
          asset: InterlayAssetConst.intr,
          metadata: InterlayAssetMetadata(
            decimals: 10,
            name: "INTR",
            symbol: "INTR",
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
          ),
          location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
              variantIndex: 0,
              secondVariantIndex: 2,
              paraId: network.paraId,
              version: network.defaultXcmVersion));

  late final List<InterlayNetworkAsset> _defaultAssets = [
    // defaultNativeAsset,
    InterlayNetworkAsset(
        asset: InterlayAssetConst.dot,
        metadata: InterlayAssetMetadata(
          existentialDeposit: BigInt.zero,
          additional: InterlayAssetMetadataAdditional(
              feePerSecond: BigInt.zero, coingeckoId: ""),
          // minimalBalance: BigInt.parse("100000000000"),
          decimals: 10,
          name: "DOT",
          symbol: "DOT",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerConstants.relayLocation
            .asVersion(network.defaultXcmVersion)),
    InterlayNetworkAsset(
      asset: InterlayAssetConst.iBTC,
      location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
          variantIndex: 0,
          secondVariantIndex: 1,
          paraId: network.paraId,
          version: network.defaultXcmVersion),
      metadata: InterlayAssetMetadata(
        existentialDeposit: BigInt.zero,
        additional: InterlayAssetMetadataAdditional(
            feePerSecond: BigInt.zero, coingeckoId: ""),
        decimals: 8,
        name: "IBTC",
        symbol: "IBTC",
      ),
      isFeeToken: true,
    ),
    InterlayNetworkAsset(
        location: XCMVersionedLocationV3(
            location: XCMV3MultiLocation(
                parents: 2,
                interior: XCMV3Junctions.fromJunctions([
                  XCMV3JunctionGlobalConsensus(network: XCMV3Kusama())
                ]))).asVersion(network.defaultXcmVersion),
        asset: InterlayAssetConst.ksm,
        metadata: InterlayAssetMetadata(
          existentialDeposit: BigInt.zero,
          additional: InterlayAssetMetadataAdditional(
              feePerSecond: BigInt.zero, coingeckoId: ""),
          decimals: 12,
          name: "KSM",
          symbol: "KSM",
        ),
        isFeeToken: true),
    InterlayNetworkAsset(
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 11,
            paraId: network.paraId,
            version: network.defaultXcmVersion),
        asset: InterlayAssetConst.kbtc,
        metadata: InterlayAssetMetadata(
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
            // minimalBalance: BigInt.parse("100000000000"),
            decimals: 8,
            name: "KBTC",
            symbol: "KBTC"),
        isFeeToken: true),
    InterlayNetworkAsset(
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 12,
            paraId: network.paraId,
            version: network.defaultXcmVersion),
        asset: InterlayAssetConst.kint,
        metadata: InterlayAssetMetadata(
          existentialDeposit: BigInt.zero,
          additional: InterlayAssetMetadataAdditional(
              feePerSecond: BigInt.zero, coingeckoId: ""),
          decimals: 12,
          name: "KINT",
          symbol: "KINT",
        ),
        isFeeToken: true),
  ].toImutableList;

  @override
  PolkadotNetwork get network => PolkadotNetwork.interlay;

  @override
  List<InterlayNetworkAsset> get defaultAssets => _defaultAssets;

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

class KintsugiNetworkController
    extends BaseInterlayNetworkController<KusamaNetwork> {
  KintsugiNetworkController({required super.params});

  @override
  InterlayNetworkNativeAsset get defaultNativeAsset =>
      InterlayNetworkNativeAsset(
          metadata: InterlayAssetMetadata(
            decimals: 12,
            name: "KINT",
            symbol: "KINT",
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
          ),
          asset: InterlayAssetConst.kint,
          location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
              variantIndex: 0,
              secondVariantIndex: 12,
              paraId: network.paraId,
              version: network.defaultXcmVersion));

  @override
  KusamaNetwork get network => KusamaNetwork.kintsugi;
  late final List<InterlayNetworkAsset> _defaultAssets = [
    InterlayNetworkAsset(
        location: null,
        asset: InterlayAssetConst.kbtc,
        metadata: InterlayAssetMetadata(
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
            decimals: 8,
            name: "KBTC",
            symbol: "KBTC"),
        isFeeToken: true),
    InterlayNetworkAsset(
        asset: InterlayAssetConst.ksm,
        metadata: InterlayAssetMetadata(
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
            decimals: 12,
            name: "Kusama",
            symbol: "KSM"),
        isFeeToken: true,
        location: SubstrateNetworkControllerConstants.relayLocation
            .asVersion(network.defaultXcmVersion)),
    InterlayNetworkAsset(
        location: null,
        asset: InterlayAssetConst.iBTC,
        metadata: InterlayAssetMetadata(
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
            decimals: 8,
            name: "IBTC",
            symbol: "IBTC"),
        isFeeToken: true),
    InterlayNetworkAsset(
        location: null,
        asset: InterlayAssetConst.intr,
        metadata: InterlayAssetMetadata(
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
            decimals: 10,
            name: "INTR",
            symbol: "INTR"),
        isFeeToken: true),
    InterlayNetworkAsset(
        location: null,
        asset: InterlayAssetConst.dot,
        metadata: InterlayAssetMetadata(
            existentialDeposit: BigInt.zero,
            additional: InterlayAssetMetadataAdditional(
                feePerSecond: BigInt.zero, coingeckoId: ""),
            decimals: 10,
            name: "DOT",
            symbol: "DOT"),
        isFeeToken: true),
  ].toImutableList;

  @override
  List<InterlayNetworkAsset> get defaultAssets => _defaultAssets;

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
      if (!params.destinationNetwork.isAssetHub) {
        throw SubstrateNetworkControllerConstants.transferDisabled;
      }
    }
    return SubstrateNetworkControllerXCMTransferBuilder.xcmTransferParaToSystem(
        params: params,
        provider: provider,
        network: network,
        useTypeAndThen: false,
        defaultPallet: SubtrateMetadataPallet.xTokens,
        onControllerRequest: onControllerRequest);
  }
}
