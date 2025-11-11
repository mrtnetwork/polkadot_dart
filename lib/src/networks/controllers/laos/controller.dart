import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

import 'asset.dart';

abstract class BaseLaosNetworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseLaosNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseLaosNetworkController({required this.params});

  @override
  Future<List<BaseLaosNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    return [];
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseLaosNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseLaosNetworkAsset>? knownAssets}) async {
    return [];
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseLaosNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseLaosNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class LaosNetworkController extends BaseLaosNetworkController<PolkadotNetwork> {
  LaosNetworkController({required super.params});

  @override
  late final LaosnetNetworkNativeAsset defaultNativeAsset =
      LaosnetNetworkNativeAsset(
    name: "Laos Network",
    decimals: 18,
    symbol: "LAOS",
    minBalance: BigInt.zero,
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        version: network.defaultXcmVersion, paraId: network.paraId),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.laos;

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
        pallet: SubtrateMetadataPallet.polkadotXcm);
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
