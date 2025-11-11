import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/xode/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseXodeNetworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseXodeNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseXodeNetworkController({required this.params});
  Map<BigInt, XCMVersionedLocation> get _assetIdToLocation;
  Future<Map<BigInt, XodeNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<BigInt>? assetIds}) async {
    final assets = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletAssetIdentifierBigInt(provider, assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletMetadataIdentifierBigInt(provider, assetIds: assetIds);
    final a = assets.entries.map((e) {
      final metadata = metadatas[e.key];
      final location = _assetIdToLocation[e.key];
      return XodeNetworkAsset(
          asset: PolkadotAssetHubAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: location != null,
          location: location,
          unitsPerSecond: null);
    }).toList();
    return {for (final i in a) i.identifier: i};
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseXodeNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseXodeNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BaseXodeNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, XodeNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! XodeNetworkAsset) continue;
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
  Future<List<XodeNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);

    List<XodeNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets.values);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseXodeNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseXodeNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class XodeNetworkController extends BaseXodeNetworkController<PolkadotNetwork> {
  XodeNetworkController({required super.params});

  @override
  late final Map<BigInt, XCMVersionedLocation> _assetIdToLocation = {
    BigInt.from(1984): SubstrateNetworkControllerUtils.locationWithParaId(
        paraId: PolkadotNetwork.polkadotAssetHub.paraId,
        palletInstance: 50,
        generalIndex: BigInt.from(1984),
        version: network.defaultXcmVersion),
    BigInt.from(100000000): SubstrateNetworkControllerUtils.locationWithParaId(
        version: network.defaultXcmVersion)
  }.immutable;

  @override
  late final XodeNetworkNativeAsset defaultNativeAsset = XodeNetworkNativeAsset(
    decimals: 12,
    name: "Xode",
    symbol: "XON",
    minBalance: BigInt.parse("1000000000"),
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        paraId: network.paraId, version: network.defaultXcmVersion),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.xode;

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
        pallet: SubtrateMetadataPallet.polkadotXcm);
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
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}
