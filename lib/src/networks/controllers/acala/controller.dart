import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseAcalaNetworkController<NETWORK extends BaseSubstrateNetwork>
    with BaseSubstrateNetworkController<Object, AcalaNetworkAsset, NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseAcalaNetworkController({required this.params});

  List<AcalaNetworkAsset> get defaultAssets;
  Future<Map<Map<String, dynamic>, AcalaAssetMetadata>> _getMetadatas(
      MetadataWithProvider provider) async {
    final assetEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegistryPalletAssetMetadatasIdentifierMap(provider);
    final metadatas = assetEntries.map((k, v) {
      Map<String, dynamic> normalizeId = {};
      if (k.containsKey("NativeAssetId")) {
        normalizeId = k["NativeAssetId"];
      } else if (k.containsKey("ForeignAssetId")) {
        normalizeId["ForeignAsset"] = k["ForeignAssetId"];
      } else {
        normalizeId = k;
      }
      return MapEntry(normalizeId, AcalaAssetMetadata.fromJson(v));
    });
    return metadatas;
  }

  Future<List<AcalaNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    ids ??= await SubstrateNetworkControllerAssetQueryHelper
        .getTokenPalletTotalIssuanceIdentifierMap(provider);
    final metadatas = await _getMetadatas(provider);
    final locations = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegistryPalletLocationToCurrencyIdsEntriesIdentifierMap(
            provider, network.defaultXcmVersion,
            palletXCMVersion: XCMVersion.v3);
    return ids.map((e) {
      BaseAcalaAsset asset = BaseAcalaAsset.fromJson(e);
      AcalaAssetMetadata? metadata = metadatas.entries
          .firstWhereNullable((m) => CompareUtils.mapIsEqual(m.key, e))
          ?.value;
      XCMVersionedLocation? location = locations.entries
          .firstWhereNullable((m) => CompareUtils.mapIsEqual(m.key, e))
          ?.value;

      final defaultAsset = defaultAssets.firstWhereNullable(
          (e) => CompareUtils.mapIsEqual(e.identifier, asset.identifier));
      metadata ??= defaultAsset?.metadata;
      location ??= defaultAsset?.location;
      return AcalaNetworkAsset(
          asset: asset,
          metadata: metadata,
          isFeeToken: metadata != null,
          location: location == null
              ? null
              : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                  location: location, from: network));
    }).toList();
  }

  @override
  Future<List<SubstrateAccountAssetBalance<AcalaNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<AcalaNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<AcalaNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<Map<String, dynamic>, AcalaNetworkAsset> assets = {};
    for (final i in allAssets) {
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
  Future<List<AcalaNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<AcalaNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<AcalaNetworkAsset>?>
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

class AcalaNetworkController
    extends BaseAcalaNetworkController<PolkadotNetwork> {
  AcalaNetworkController({required super.params});

  @override
  late final AcalaNetworkNativeAsset defaultNativeAsset =
      AcalaNetworkNativeAsset(
          metadata: AcalaAssetMetadata(
              decimals: 12,
              name: "Acala",
              minimalBalance: BigInt.parse("100000000000"),
              symbol: "ACA"),
          location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
              variantIndex: 0,
              paraId: network.paraId,
              version: network.defaultXcmVersion));
  @override
  List<AcalaNetworkAsset> get defaultAssets => _defaultAssets;
  late final List<AcalaNetworkAsset> _defaultAssets = [
    AcalaNetworkAsset(
        asset: AcalaAsstConst.ausd,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("100000000000"),
          decimals: 12,
          name: "AUSD",
          symbol: "aSEED",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
          variantIndex: 0,
          secondVariantIndex: 1,
          paraId: network.paraId,
          version: network.defaultXcmVersion,
        )),
    AcalaNetworkAsset(
      asset: AcalaAsstConst.dot,
      metadata: AcalaAssetMetadata(
        minimalBalance: BigInt.parse("100000000"),
        decimals: 10,
        name: "DOT",
        symbol: "DOT",
      ),
      isFeeToken: true,
      location: SubstrateNetworkControllerConstants.relayLocation
          .asVersion(network.defaultXcmVersion),
    ),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.lDot,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("500000000"),
          decimals: 10,
          name: "LDOT",
          symbol: "LDOT",
        ),
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
          variantIndex: 0,
          secondVariantIndex: 3,
          paraId: network.paraId,
          version: network.defaultXcmVersion,
        ),
        isFeeToken: true),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.tap,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("1000000000000"),
          decimals: 12,
          name: "TAP",
          symbol: "TAP",
        ),
        isFeeToken: false),
  ].toImutableList;

  @override
  PolkadotNetwork get network => PolkadotNetwork.acala;

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

class KaruraNetworkController
    extends BaseAcalaNetworkController<KusamaNetwork> {
  KaruraNetworkController({required super.params});
  @override
  @override
  late final AcalaNetworkNativeAsset defaultNativeAsset =
      AcalaNetworkNativeAsset(
          metadata: AcalaAssetMetadata(
              decimals: 12,
              name: "Karura",
              minimalBalance: BigInt.parse("100000000000"),
              symbol: "KAR"),
          location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
              variantIndex: 0,
              secondVariantIndex: 128,
              paraId: network.paraId,
              version: network.defaultXcmVersion));
  @override
  KusamaNetwork get network => KusamaNetwork.karura;

  @override
  List<AcalaNetworkAsset> get defaultAssets => _defaultAssets;
  late final List<AcalaNetworkAsset> _defaultAssets = [
    AcalaNetworkAsset(
        asset: AcalaAsstConst.vskSm,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("100000000"),
          decimals: 12,
          name: "Bifrost Voucher Slot KSM",
          symbol: "VSKSM",
        ),
        isFeeToken: true),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.pha,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("40000000000"),
          decimals: 12,
          name: "Phala Native Token",
          symbol: "PHA",
        ),
        isFeeToken: true,
        location:
            SubstrateNetworkControllerUtils.locationWithParaId(paraId: 2035)),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.ksm,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("100000000"),
          decimals: 12,
          name: "Kusama",
          symbol: "KSM",
        ),
        location: SubstrateNetworkControllerConstants.relayLocation
            .asVersion(network.defaultXcmVersion),
        isFeeToken: true),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.kbtc,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("66"),
          decimals: 8,
          name: "Kintsugi Wrapped BTC",
          symbol: "KBTC",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 11,
            paraId: KusamaNetwork.kintsugi.paraId,
            version: network.defaultXcmVersion)),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.tai,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("1000000000000"),
          decimals: 12,
          name: "Taiga",
          symbol: "TAI",
        ),
        isFeeToken: true),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.lksm,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("500000000"),
          decimals: 12,
          name: "Liquid KSM",
          symbol: "LKSM",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 131,
            paraId: network.paraId,
            version: network.defaultXcmVersion)),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.kint,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("133330000"),
          decimals: 12,
          name: "Kintsugi Native Token",
          symbol: "KINT",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 12,
            paraId: KusamaNetwork.kintsugi.paraId,
            version: network.defaultXcmVersion)),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.kusd,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("10000000000"),
          decimals: 12,
          name: "aUSD SEED",
          symbol: "aSEED",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 129,
            paraId: network.paraId,
            version: network.defaultXcmVersion)),
    AcalaNetworkAsset(
        asset: AcalaAsstConst.bnc,
        metadata: AcalaAssetMetadata(
          minimalBalance: BigInt.parse("8000000000"),
          decimals: 12,
          name: "Bifrost Native Token",
          symbol: "BNC",
        ),
        isFeeToken: true,
        location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
            variantIndex: 0,
            secondVariantIndex: 1,
            paraId: KusamaNetwork.bifrostKusama.paraId,
            version: network.defaultXcmVersion)),
  ].toImutableList;

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
        pallet: params.isLocalAssets
            ? SubtrateMetadataPallet.polkadotXcm
            : SubtrateMetadataPallet.xTokens);
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
        defaultPallet: SubtrateMetadataPallet.xTokens,
        onControllerRequest: onControllerRequest);
  }
}
