import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/zeitgeist/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

class ZeitgeistNetworkController extends BaseSubstrateNetworkController<Object,
    BaseZeitgeistNetworkAsset, PolkadotNetwork> {
  @override
  final SubstrateNetworkControllerParams params;
  ZeitgeistNetworkController({required this.params});

  @override
  PolkadotNetwork get network => PolkadotNetwork.zeitgeist;

  @override
  ZeitgeistNetworkNativeAsset
      get defaultNativeAsset => ZeitgeistNetworkNativeAsset(
          decimals: 10,
          name: "Zeitgeist",
          symbol: "ZTG",
          location: SubstrateNetworkControllerUtils.locationWithGeneralKey(
              variantIndex: 0,
              secondVariantIndex: 1,
              version: network.defaultXcmVersion,
              paraId: network.paraId));

  Future<Map<Map<String, dynamic>, ZeitgeistAssetMetadata?>> _getMetadatas(
      MetadataWithProvider provider) async {
    final assetEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getPalletAssetRegistryMetadataIdentifierMap(provider);
    final metadatas = assetEntries.map((k, v) {
      return MapEntry<Map<String, dynamic>, ZeitgeistAssetMetadata?>(
          k, ZeitgeistAssetMetadata.fromJson(v));
    });
    return metadatas;
  }

  Future<List<ZeitgeistNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    final assetsEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getTokenPalletTotalIssuanceIdentifierMap(provider);

    final metadatas = await _getMetadatas(provider);
    List<ZeitgeistNetworkAsset> assets = [];
    for (final i in assetsEntries) {
      if (!metadatas.keys.any((e) => CompareUtils.mapIsEqual(e, i))) {
        metadatas[i] = null;
      }
    }
    for (final e in metadatas.entries) {
      if (ids != null && !ids.any((id) => CompareUtils.mapIsEqual(id, e.key))) {
        continue;
      }
      BaseZeitgeistAsset asset = BaseZeitgeistAsset.fromJson(e.key);
      XCMVersionedLocation? location = e.value?.location;
      if (location != null) {
        location = SubstrateNetworkControllerUtils.asForeignVersionedLocation(
            from: network,
            location: location.asVersion(network.defaultXcmVersion));
      }
      BigInt? existentialDeposit = e.value?.existentialDeposit;
      final decimals = e.value?.decimals;
      final asBase = e.value?.additional?.allowAsBaseAsset ?? false;
      if (asBase && decimals != null && existentialDeposit != null) {
        existentialDeposit = AmountConverterUtils.convertDecimals(
            amount: existentialDeposit,
            from: defaultNativeAsset.decimals!,
            to: decimals);
      }
      final bAsset = ZeitgeistNetworkAsset(
          asset: asset,
          metadata: e.value?.copyWith(
              location: location, existentialDeposit: existentialDeposit));
      assets.add(bAsset);
    }
    return assets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseZeitgeistNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BaseZeitgeistNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<ZeitgeistNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<Map<String, dynamic>, ZeitgeistNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! ZeitgeistNetworkAsset) continue;
      assets[i.identifier] = i;
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
        TokenPalletAccountBalance balance =
            TokenPalletAccountBalance.fromJson(i.value!);

        /// AmountConverterUtils
        final asBase = asset.metadata?.additional?.allowAsBaseAsset ?? false;
        final decimals = asset.metadata?.decimals;
        if (asBase && decimals != null) {
          final free = AmountConverterUtils.convertDecimals(
              amount: balance.free,
              from: defaultNativeAsset.decimals!,
              to: decimals);
          final reserved = AmountConverterUtils.convertDecimals(
              amount: balance.reserved,
              from: defaultNativeAsset.decimals!,
              to: decimals);
          final frozen = AmountConverterUtils.convertDecimals(
              amount: balance.frozen,
              from: defaultNativeAsset.decimals!,
              to: decimals);
          balance = TokenPalletAccountBalance(
              free: free, reserved: reserved, frozen: frozen);
        }
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
  Future<List<ZeitgeistNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<ZeitgeistNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<ZeitgeistNetworkNativeAsset>?>
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
        defaultPallet: SubtrateMetadataPallet.xTokens,
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
            disableDot: true,
            disabledRoutes: []);
  }

  @override
  Future<SubstrateTransferEncodedParams<SubstrateCallPallet>> assetTransfer(
      {required SubstrateLocalTransferAssetParams params,
      bool converAmountAsBase = true}) {
    final asset = params.asset;
    if (!converAmountAsBase || asset == null || asset.type.isNative) {
      return super.assetTransfer(params: params);
    }

    if (asset is! ZeitgeistNetworkAsset) {
      throw DartSubstratePluginException(
          "Invalid ${network.networkName} asset.",
          details: {
            "expected": "ZeitgeistNetworkAsset",
            "asset": asset.runtimeType
          });
    }
    final decimals = asset.metadata?.decimals;
    final asBase = asset.metadata?.additional?.allowAsBaseAsset ?? false;
    final amount = params.amount;
    if (amount == null) {
      throw DartSubstratePluginException("Amount required for transfer asset.");
    }
    if (decimals == null || !asBase) return super.assetTransfer(params: params);
    final cAmount = AmountConverterUtils.convertDecimals(
        amount: amount, from: decimals, to: defaultNativeAsset.decimals!);
    return super.assetTransfer(
        params: SubstrateLocalTransferAssetParams(
      asset: asset,
      destinationAddress: params.destinationAddress,
      amount: cAmount,
      keepAlive: params.keepAlive,
      method: params.method,
    ));
  }
}
