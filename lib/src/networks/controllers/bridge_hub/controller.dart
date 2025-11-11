import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseBridgeHubNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object,
        GenericBaseSubstrateNativeAsset, NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseBridgeHubNetworkController({required this.params});

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

class PolkadotBridgeHubNetworkController
    extends BaseBridgeHubNetworkController<PolkadotNetwork> {
  PolkadotBridgeHubNetworkController({required super.params});
  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "DOT",
          decimals: 10,
          symbol: "DOT",
          excutionPallet: SubtrateMetadataPallet.balances,
          version: network.defaultXcmVersion,
          parents: 1);

  @override
  PolkadotNetwork get network => PolkadotNetwork.polkadotBridgeHub;
  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
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

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class KusamaBridgeHubNetworkController
    extends BaseBridgeHubNetworkController<KusamaNetwork> {
  KusamaBridgeHubNetworkController({required super.params});

  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
    name: "Kusama",
    decimals: 12,
    symbol: "KSM",
    minBalance: BigInt.parse("33333333"),
    excutionPallet: SubtrateMetadataPallet.balances,
    version: network.defaultXcmVersion,
    parents: 1,
  );

  @override
  KusamaNetwork get network => KusamaNetwork.kusamaBridgeHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
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

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class WestendBridgeHubNetworkController
    extends BaseBridgeHubNetworkController<WestendNetwork> {
  WestendBridgeHubNetworkController({required super.params});

  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
    name: "Westend",
    decimals: 12,
    symbol: "WND",
    minBalance: BigInt.parse("10000000000"),
    excutionPallet: SubtrateMetadataPallet.balances,
    version: network.defaultXcmVersion,
    parents: 1,
  );

  @override
  WestendNetwork get network => WestendNetwork.westendBridgeHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
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

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class PaseoBridgeHubNetworkController
    extends BaseBridgeHubNetworkController<PaseoNetwork> {
  PaseoBridgeHubNetworkController({required super.params});

  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
    name: "Paseo",
    decimals: 10,
    symbol: "PAS",
    minBalance: BigInt.parse("100000000"),
    excutionPallet: SubtrateMetadataPallet.balances,
    version: network.defaultXcmVersion,
    parents: 1,
  );

  @override
  PaseoNetwork get network => PaseoNetwork.paseoBridgeHub;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
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

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.limitedTeleportAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}
