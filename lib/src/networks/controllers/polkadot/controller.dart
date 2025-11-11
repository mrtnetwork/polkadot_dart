import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseRelayNetworkController<NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object,
        GenericBaseSubstrateNativeAsset, NETWORK> {
  @override
  final SubstrateNetworkControllerParams params;
  BaseRelayNetworkController({required this.params});

  @override
  GenericBaseSubstrateNativeAsset get relayAsset => defaultNativeAsset;

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

class PolkadotNetworkController
    extends BaseRelayNetworkController<PolkadotNetwork> {
  PolkadotNetworkController({required super.params});

  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "DOT",
          decimals: 10,
          symbol: "DOT",
          version: network.defaultXcmVersion,
          parents: 0,
          excutionPallet: SubtrateMetadataPallet.balances);

  @override
  PolkadotNetwork get network => PolkadotNetwork.polkadot;
  @override
  Future<List<R>> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination}) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .filterTransferableAssets(
            assets: assets,
            destination: destination,
            network: network,
            disableDot: destination == PolkadotNetwork.interlay,
            disabledRoutes: []);
  }

  @override
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets, required BaseSubstrateNetwork origin}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.filterReceivedAssets(
        assets: assets, origin: origin, network: network, disableDot: false);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    switch (params.destinationNetwork) {
      case PolkadotNetwork.interlay:
        throw SubstrateNetworkControllerConstants.transferDisabled;
      case PolkadotNetwork.centrifuge:
      case PolkadotNetwork.manta:
      case PolkadotNetwork.phala:
      case PolkadotNetwork.crust:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferDotThroughUsingTypeAndThen(
                params: params, provider: provider, network: network);
      default:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferAssetsThroughUsingTypeAndThen(
                params: params,
                provider: provider,
                network: network,
                onEstimateFee: onControllerRequest);
    }
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) {
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
        pallet: SubtrateMetadataPallet.xcmPallet);
  }
}

class KusamaNetworkController
    extends BaseRelayNetworkController<KusamaNetwork> {
  KusamaNetworkController({required super.params});

  @override
  KusamaNetwork get network => KusamaNetwork.kusama;
  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Kusama",
          decimals: 12,
          symbol: "KSM",
          version: network.defaultXcmVersion,
          minBalance: BigInt.parse("333333333"),
          parents: 0,
          excutionPallet: SubtrateMetadataPallet.balances);
  @override
  Future<List<R>> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination}) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .filterTransferableAssets(
            assets: assets,
            destination: destination,
            network: network,
            disableDot: false,
            disabledRoutes: []);
  }

  @override
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets, required BaseSubstrateNetwork origin}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.filterReceivedAssets(
        assets: assets, origin: origin, network: network, disableDot: false);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    switch (params.destinationNetwork) {
      case KusamaNetwork.altair:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferDotThroughUsingTypeAndThen(
                params: params, provider: provider, network: network);
      default:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferAssetsThroughUsingTypeAndThen(
                params: params,
                provider: provider,
                network: network,
                onEstimateFee: onControllerRequest);
    }
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) {
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
        pallet: SubtrateMetadataPallet.xcmPallet);
  }
}

class WestendNetworkController
    extends BaseRelayNetworkController<WestendNetwork> {
  WestendNetworkController({required super.params});

  @override
  WestendNetwork get network => WestendNetwork.westend;
  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Westend",
          decimals: 12,
          symbol: "WND",
          minBalance: BigInt.parse("10000000000"),
          version: network.defaultXcmVersion,
          parents: 0,
          excutionPallet: SubtrateMetadataPallet.balances);
  @override
  Future<List<R>> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination}) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .filterTransferableAssets(
            assets: assets,
            destination: destination,
            network: network,
            disableDot: false,
            disabledRoutes: []);
  }

  @override
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets, required BaseSubstrateNetwork origin}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.filterReceivedAssets(
        assets: assets, origin: origin, network: network, disableDot: false);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    switch (params.destinationNetwork) {
      case KusamaNetwork.altair:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferDotThroughUsingTypeAndThen(
                params: params, provider: provider, network: network);
      default:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferAssetsThroughUsingTypeAndThen(
                params: params,
                provider: provider,
                network: network,
                onEstimateFee: onControllerRequest);
    }
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) {
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
        pallet: SubtrateMetadataPallet.xcmPallet);
  }
}

class PaseoNetworkController extends BaseRelayNetworkController<PaseoNetwork> {
  PaseoNetworkController({required super.params});

  @override
  PaseoNetwork get network => PaseoNetwork.paseo;
  @override
  late final GenericBaseSubstrateNativeAsset defaultNativeAsset =
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Paseo",
          decimals: 10,
          symbol: "PAS",
          minBalance: BigInt.parse("10000000000"),
          version: network.defaultXcmVersion,
          parents: 0,
          excutionPallet: SubtrateMetadataPallet.balances);
  @override
  Future<List<R>> filterTransferableAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets,
      required BaseSubstrateNetwork destination}) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .filterTransferableAssets(
            assets: assets,
            destination: destination,
            network: network,
            disableDot: false,
            disabledRoutes: []);
  }

  @override
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>(
      {required List<R> assets, required BaseSubstrateNetwork origin}) async {
    return SubstrateNetworkControllerXCMTransferBuilder.filterReceivedAssets(
        assets: assets, origin: origin, network: network, disableDot: false);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    switch (params.destinationNetwork) {
      case KusamaNetwork.altair:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferDotThroughUsingTypeAndThen(
                params: params, provider: provider, network: network);
      default:
        return SubstrateNetworkControllerXCMTransferBuilder
            .transferAssetsThroughUsingTypeAndThen(
                params: params,
                provider: provider,
                network: network,
                onEstimateFee: onControllerRequest);
    }
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) {
    throw SubstrateNetworkControllerConstants.transferDisabled;
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
        pallet: SubtrateMetadataPallet.xcmPallet);
  }
}
