import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

import 'asset.dart';

abstract class BaseNodleNetworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<BigInt, BaseNodleNetworkAsset,
        NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseNodleNetworkController({required this.params});

  @override
  Future<List<BaseNodleNetworkAsset>> getAssetsInternal(
      {List<BigInt>? knownAssetIds}) async {
    return [];
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseNodleNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<BigInt>? knownAssetIds,
          List<BaseNodleNetworkAsset>? knownAssets}) async {
    return [];
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseNodleNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseNodleNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class NodleNetworkController
    extends BaseNodleNetworkController<PolkadotNetwork> {
  NodleNetworkController({required super.params});

  @override
  late final NodlenetNetworkNativeAsset defaultNativeAsset =
      NodlenetNetworkNativeAsset(
    name: "Nodle",
    decimals: 11,
    symbol: "NODL",
    minBalance: BigInt.from(10000),
    location: SubstrateNetworkControllerUtils.locationWithParaId(
        version: network.defaultXcmVersion,
        paraId: network.paraId,
        palletInstance: 2),
  );

  @override
  PolkadotNetwork get network => PolkadotNetwork.nodle;

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
