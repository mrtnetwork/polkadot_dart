import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseMythosNetworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object,
        GenericBaseSubstrateNativeAsset, NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseMythosNetworkController({required this.params});

  @override
  Future<List<SubstrateAccountAssetBalance<GenericBaseSubstrateNativeAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<GenericBaseSubstrateNativeAsset>? knownAssets}) async {
    return [];
  }

  @override
  Future<List<GenericBaseSubstrateNativeAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    return [];
  }

  @override
  Future<SubstrateAccountAssetBalance<GenericBaseSubstrateNativeAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<GenericBaseSubstrateNativeAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class MythosNetworkController
    extends BaseMythosNetworkController<PolkadotNetwork> {
  MythosNetworkController({required super.params});
  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Mythos",
          decimals: 18,
          symbol: "MYTH",
          excutionPallet: SubtrateMetadataPallet.balances,
          version: network.defaultXcmVersion,
          parachain: network.paraId);

  @override
  PolkadotNetwork get network => PolkadotNetwork.mythos;

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
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.xcmTransferParaToSystem(
        params: params,
        provider: provider,
        network: network,
        onControllerRequest: onControllerRequest,
        defaultPallet: SubtrateMetadataPallet.polkadotXcm);
  }
}
