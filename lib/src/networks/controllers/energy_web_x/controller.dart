import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/controllers/energy_web_x/assets.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseEnergyWebXNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseEnergyWebXNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseEnergyWebXNetworkController({required this.params});
  Map<BigInt, XCMVersionedLocation> get _assetIdToLocation;
  Future<Map<BigInt, EnergyWebXNetworkAsset>> _getAssets(
      {required MetadataWithProvider provider, List<BigInt>? assetIds}) async {
    final assets = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletAssetIdentifierBigInt(provider, assetIds: assetIds);
    final metadatas = await SubstrateNetworkControllerAssetQueryHelper
        .getAssetsPalletMetadataIdentifierBigInt(provider, assetIds: assetIds);
    final a = assets.entries.map((e) {
      final metadata = metadatas[e.key];
      final location = _assetIdToLocation[e.key];
      return EnergyWebXNetworkAsset(
          asset: PolkadotAssetHubAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key),
          metadata: metadata == null
              ? null
              : PolkadotAssetHubAssetMetadata.fromJson(metadata),
          isFeeToken: location != null,
          location: location == null
              ? null
              : SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                  from: network, location: location),
          unitsPerSecond: null);
    }).toList();
    return {for (final i in a) i.identifier: i};
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseEnergyWebXNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseEnergyWebXNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BaseEnergyWebXNetworkAsset>> balances =
        [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, EnergyWebXNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! EnergyWebXNetworkAsset) continue;
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
  Future<List<EnergyWebXNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);

    List<EnergyWebXNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets =
          await _getAssets(provider: provider, assetIds: knownAssetIds);
      allAssets.addAll(assets.values);
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseEnergyWebXNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseEnergyWebXNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class EnergyWebXNetworkController
    extends BaseEnergyWebXNetworkController<PolkadotNetwork> {
  EnergyWebXNetworkController({required super.params});

  @override
  late final Map<BigInt, XCMVersionedLocation> _assetIdToLocation =
      <BigInt, XCMVersionedLocation>{}.immutable;

  @override
  late final EnergyWebXNetworkNativeAsset defaultNativeAsset =
      EnergyWebXNetworkNativeAsset(
    decimals: 18,
    name: "EnergyWebX",
    symbol: "EWT",
    minBalance: BigInt.zero,
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        paraId: network.paraId, version: network.defaultXcmVersion),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.energyWebX;

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
