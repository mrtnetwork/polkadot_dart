import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/phala/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

class PhalaNetworkController extends BaseSubstrateNetworkController<BigInt,
    BasePhalaNetworkAsset, PolkadotNetwork> {
  @override
  final SubstrateNetworkControllerParams params;
  PhalaNetworkController({required this.params});
  @override
  PolkadotNetwork get network => PolkadotNetwork.phala;

  @override
  late final PhalaNetworkNativeAsset defaultNativeAsset =
      PhalaNetworkNativeAsset(
    decimals: 12,
    name: "Phala",
    symbol: "PHA",
    location: XCMMultiLocation.fromVersion(
            parents: 1,
            version: network.defaultXcmVersion,
            interior: XCMJunctions.fromVersion(junctions: [
              XCMJunctionParaChain.fromVersion(
                  id: network.paraId, version: network.defaultXcmVersion)
            ], version: network.defaultXcmVersion))
        .asVersioned(),
  );

  Future<Map<BigInt, PhalaNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<BigInt>? assetIds}) async {
    final assets = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletAssetIdentifierBigInt(provider, assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletMetadataIdentifierBigInt(provider, assetIds: assetIds);
    final locations = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsRegistryPalletIdByLocationsIdentifierMap(
            provider, network.defaultXcmVersion);
    final fees = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsRegistryPalletRegistryInfoByIds(provider);
    final a = assets.entries.map((e) {
      final fee = fees[e.key];
      final metadata = metadatas[e.key];
      final location = locations[e.key];
      final BigInt? executionPrice =
          MetadataUtils.parseOptional(fee?["execution_price"]);
      return PhalaNetworkAsset(
          asset: PolkadotAssetHubAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          location: location == null
              ? null
              : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                  from: network, location: location),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: executionPrice != null || fee != null,
          executionPrice: executionPrice);
    }).toList();
    return {for (final i in a) i.identifier: i};
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BasePhalaNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BasePhalaNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BasePhalaNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, PhalaNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! PhalaNetworkAsset) continue;
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
  Future<List<PhalaNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);

    List<PhalaNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets.values);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BasePhalaNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BasePhalaNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }

  @override
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets, required BaseSubstrateNetwork origin}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.filterReceivedAssets(
        assets: assets, origin: origin, network: network, disableDot: true);
  }

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
        pallet: SubtrateMetadataPallet.xTransfer);
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
        defaultPallet: SubtrateMetadataPallet.xTransfer,
        onControllerRequest: onControllerRequest);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    throw SubstrateNetworkControllerConstants.transferDisabled;
  }
}
