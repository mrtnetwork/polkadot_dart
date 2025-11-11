import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

import 'asset.dart';

abstract class BaseUniqueworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseUniqueNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseUniqueworkController({required this.params});
  late final List<UniqueNetworkAsset> _defaultAssets = [
    UniqueNetworkAsset(
        location: SubstrateNetworkControllerUtils.locationWithParaId(),
        name: "Polkadot",
        symbol: "DOT",
        assetId: BigInt.from(437),
        isFeeToken: true,
        isSpendable: true,
        decimals: 10),
    UniqueNetworkAsset(
        location: SubstrateNetworkControllerUtils.locationWithParaId(
            paraId: PolkadotNetwork.polkadotAssetHub.paraId,
            palletInstance: 50,
            generalIndex: BigInt.from(23)),
        name: "PINK",
        symbol: "PINK",
        assetId: BigInt.from(459),
        decimals: 10),
    UniqueNetworkAsset(
        location: SubstrateNetworkControllerUtils.locationWithParaId(
            paraId: PolkadotNetwork.polkadotAssetHub.paraId,
            palletInstance: 50,
            generalIndex: BigInt.from(1984)),
        name: "USDT",
        symbol: "USDT",
        assetId: BigInt.from(473),
        decimals: 6),
    UniqueNetworkAsset(
        location: SubstrateNetworkControllerUtils
            .locationWithPalletInstanceAndAccountKey20(
                paraId: PolkadotNetwork.moonbeam.paraId,
                palletInstance: 10,
                version: network.defaultXcmVersion),
        name: "Moonbeam",
        symbol: "GLMR",
        assetId: BigInt.from(498),
        decimals: 18),
  ].toImutableList;

  @override
  Future<List<BaseUniqueNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    List<BaseUniqueNetworkAsset> knownAssets = _defaultAssets;
    if (knownAssetIds != null) {
      knownAssets = _defaultAssets
          .where((e) => knownAssetIds.contains(e.assetId))
          .toList();
    }
    return knownAssets;
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseUniqueNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseUniqueNetworkAsset>? knownAssets}) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<UniqueNetworkAsset>> balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<BigInt, UniqueNetworkAsset> assets = {};
    for (final i in allAssets) {
      if (i is! UniqueNetworkAsset) continue;
      final assetId = i.identifier;
      assets[assetId] = i;
    }
    if (assets.isNotEmpty) {
      final balancesEntries = await SubstrateNetworkControllerAssetQueryHelper
          .getFungiblePalletBalanceIdentifierBigInt(
              provider: provider,
              address: address,
              assetIds: assets.keys.toList());
      for (final i in balancesEntries.entries) {
        final balance = i.value ?? BigInt.zero;
        final asset = assets[i.key];
        if (asset == null) continue;
        balances.add(SubstrateAccountAssetBalance<UniqueNetworkAsset>(
            asset: asset, free: balance));
      }
    }
    return balances;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseUniqueNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseUniqueNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class UniqueworkController extends BaseUniqueworkController<PolkadotNetwork> {
  UniqueworkController({required super.params});

  @override
  late final UniqueNetworkNativeAsset defaultNativeAsset =
      UniqueNetworkNativeAsset(
    name: "UNIQUE",
    decimals: 18,
    symbol: "UNQ",
    minBalance: BigInt.zero,
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        version: network.defaultXcmVersion, paraId: network.paraId),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.unique;

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
