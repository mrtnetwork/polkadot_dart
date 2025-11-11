import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/acala/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/jamton/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseJamtonNetworkController<NETWORK extends BaseSubstrateNetwork>
    with
        BaseSubstrateNetworkController<Object, BaseJamtonNetworkAsset,
            NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseJamtonNetworkController({required this.params});

  Future<Map<Map<String, dynamic>, JamtonAssetMetadata>> _getMetadatas(
      MetadataWithProvider provider) async {
    final assetEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getPalletAssetRegistryMetadataIdentifierMap(provider);
    final metadatas = assetEntries.map((k, v) {
      return MapEntry(k, JamtonAssetMetadata.fromJson(v));
    });
    return metadatas;
  }

  Future<List<JamtonNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<Object>? assetIds}) async {
    List<Map<String, dynamic>>? ids = SubstrateNetworkControllerAssetQueryHelper
        .toAssetId<Map<String, dynamic>>(assetIds);
    ids ??= await SubstrateNetworkControllerAssetQueryHelper
        .getTokenPalletTotalIssuanceIdentifierMap(provider);
    final metadatas = await _getMetadatas(provider);
    final fees = await SubstrateNetworkControllerAssetQueryHelper
        .queryAcceptablePaymentAsset(
            provider: provider, version: network.defaultXcmVersion);
    return ids.map((e) {
      BaseJamtonAsset asset = BaseJamtonAsset.fromJson(e);
      JamtonAssetMetadata? metadata = metadatas.entries
          .firstWhereNullable((m) => CompareUtils.mapIsEqual(m.key, e))
          ?.value;
      final location = metadata?.location;
      return JamtonNetworkAsset(
        asset: asset,
        metadata: metadata,
        chargeAssetTxPayment: fees.contains(location),
        isFeeToken: fees.contains(location),
        location: location == null
            ? null
            : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                from: network, location: location),
      );
    }).toList();
  }

  @override
  Future<List<SubstrateAccountAssetBalance<JamtonNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BaseJamtonNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<JamtonNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<Map<String, dynamic>, JamtonNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! JamtonNetworkAsset) continue;
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
  Future<List<JamtonNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);
    List<JamtonNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseJamtonNetworkAsset>?>
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

class JamtonNetworkController
    extends BaseJamtonNetworkController<PolkadotNetwork> {
  JamtonNetworkController({required super.params});

  @override
  late final JamtonNetworkNativeAsset defaultNativeAsset =
      JamtonNetworkNativeAsset(
          location:
              SubstrateNetworkControllerUtils.locationWithParaId(
                  paraId: network.paraId, version: network.defaultXcmVersion),
          metadata: JamtonAssetMetadata(
              decimals: 18,
              name: "Jamton",
              existentialDeposit: BigInt.parse("1000000000000000"),
              symbol: "DOTON"));

  @override
  PolkadotNetwork get network => PolkadotNetwork.jamton;

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
