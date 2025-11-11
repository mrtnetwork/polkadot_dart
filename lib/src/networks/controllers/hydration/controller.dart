import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/hydration/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseHydrationNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseHydrationNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseHydrationNetworkController({required this.params});

  Future<Map<BigInt, HydrationNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<BigInt>? assetIds}) async {
    final assetsEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegisteryPalletAssetsIdentifierBigInt(provider,
            assetIds: assetIds);
    final locations = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetRegistryPalletAssetLocationsIdentifierBigInt(
            provider, network.defaultXcmVersion,
            palletXCMVersion: XCMVersion.v3);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .tryGetAssetRegistryPalletAssetMetadataMapIdentifierBigInt(provider);

    final fees = await SubstrateNetworkControllerAssetQueryHelper
        .queryAcceptablePaymentAsset(
            provider: provider, version: network.defaultXcmVersion);

    final assets = assetsEntries.entries.map((e) {
      final location = locations[e.key];
      final metadata = () {
        final metadata = metadatas[e.key];
        if (metadata == null) return null;
        return HydrationAssetMetadata.fromJson(metadata);
      }();
      final asset = HydrationAsset.fromJson(e.value).copyWith(
          decimals: metadata?.decimals,
          symbol: metadata?.symbol,
          name: metadata?.symbol);
      bool isFee = asset.xcmRateLimit != null || fees.contains(location);

      return HydrationNetworkAsset(
        identifier: e.key,
        isFeeToken: isFee,
        asset: asset,
        location: () {
          try {
            return location == null
                ? null
                : SubstrateNetworkControllerUtils.asForeignLocation(
                        from: network, location: location.location)
                    .asVersioned();
          } catch (e) {
            return null;
          }
        }(),
      );
    }).toList();
    return {for (final i in assets) i.identifier: i};
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseHydrationNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseHydrationNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BaseHydrationNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, HydrationNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! HydrationNetworkAsset) continue;
      final assetId = i.identifier;
      assets[assetId] = i;
    }
    if (assets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getTokensPalletAccountIdentifierBigInt(
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
  Future<List<HydrationNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);

    List<HydrationNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets.values);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseHydrationNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseHydrationNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class HydrationNetworkController
    extends BaseHydrationNetworkController<PolkadotNetwork> {
  HydrationNetworkController({required super.params});
  @override
  late final HydrationNetworkNativeAsset defaultNativeAsset =
      HydrationNetworkNativeAsset(
    decimals: 12,
    name: "Hydration",
    symbol: "HDX",
    location: SubstrateNetworkControllerUtils.locationWithGeneralIndex(
        paraId: network.paraId,
        index: BigInt.zero,
        version: network.defaultXcmVersion),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.hydration;

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

class BasiliskNetworkController
    extends BaseHydrationNetworkController<KusamaNetwork> {
  BasiliskNetworkController({required super.params});
  @override
  late final HydrationNetworkNativeAsset defaultNativeAsset =
      HydrationNetworkNativeAsset(
    decimals: 12,
    name: "Basilisk",
    symbol: "BSX",
    minBalance: BigInt.parse("1000000000000"),
    location: SubstrateNetworkControllerUtils.locationWithGeneralIndex(
        paraId: network.paraId,
        version: network.defaultXcmVersion,
        index: BigInt.zero),
  );
  @override
  KusamaNetwork get network => KusamaNetwork.basilisk;

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
        defaultPallet: SubtrateMetadataPallet.polkadotXcm,
        onControllerRequest: onControllerRequest);
  }
}

class HydrationPaseoNetworkController
    extends BaseHydrationNetworkController<PaseoNetwork> {
  HydrationPaseoNetworkController({required super.params});
  @override
  late final HydrationNetworkNativeAsset defaultNativeAsset =
      HydrationNetworkNativeAsset(
    decimals: 12,
    name: "Hydration",
    symbol: "HDX",
    location: SubstrateNetworkControllerUtils.locationWithGeneralIndex(
        paraId: network.paraId,
        index: BigInt.zero,
        version: network.defaultXcmVersion),
  );

  @override
  PaseoNetwork get network => PaseoNetwork.hydration;

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
