import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/constants/evm.dart';
import 'package:polkadot_dart/src/networks/controllers/moonbeam/assets.dart';
import 'package:polkadot_dart/src/networks/controllers/moonbeam/constants.dart';
import 'package:polkadot_dart/src/networks/controllers/moonbeam/utils.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

abstract class BaseMoonbeamNetworkController<
        NETWORK extends BaseSubstrateNetwork>
    extends BaseSubstrateNetworkController<Object, BaseMoonbeamNetworkAsset,
        NETWORK> {
  BigInt get chainId;
  @override
  final SubstrateNetworkControllerParams params;
  BaseMoonbeamNetworkController({required this.params});

  Map<BigInt, MoonbeamForeignAsset> _getAssetsConstants(
      {required MetadataWithProvider provider, List<Object>? assetIds}) {
    List<MoonbeamForeignAsset> assets =
        MoonbeamNetworkControllerConst.defaultAssets(chainId)
            .map((e) => MoonbeamForeignAsset.fromJson(e))
            .toList();
    if (assetIds != null) {
      final correctIds = assetIds.map((e) => e.toString()).toList();
      assets = assets.where((e) => correctIds.contains(e.assetId)).toList();
    }
    return {
      for (final i in assets) BigintUtils.parse(i.assetId, allowHex: false): i
    };
  }

  List<MoonbeamNetworkAsset> get defaultAssets;
  List<MoonbeamNetworkAsset> _getDefaultAssets({List<Object>? assetIds}) {
    if (assetIds == null) return defaultAssets;
    final correctIds = assetIds.map((e) => e.toString()).toList();
    return defaultAssets
        .where((e) => correctIds.contains(e.asset.assetId))
        .toList();
  }

  Future<Map<XCMVersionedLocation, MoonbeamForeignAsset>>
      _getMoonbeamForeignAssets(
          {required MetadataWithProvider provider,
          List<Object>? assetIds}) async {
    final assetsEntries = await SubstrateNetworkControllerAssetQueryHelper
        .getEvmForeignAssetsPalletIdentifierBigInt(
            provider: provider,
            version: network.defaultXcmVersion,
            assetIds: assetIds?.whereType<BigInt>().toList());
    final contantAssets = _getAssetsConstants(
        provider: provider,
        assetIds: assetIds ??
            assetsEntries.entries.map((e) => e.key.toString()).toList());
    final remainAssets =
        assetsEntries.entries.where((e) => !contantAssets.containsKey(e.key));
    if (remainAssets.isNotEmpty) {
      final evmParams = params.evmParams;
      if (evmParams == null) {
        throw DartSubstratePluginException("Missing evm network parameters.");
      }

      final response = await Future.wait(remainAssets.map((e) async {
        final address = MoonbeamNetworkControllerUtils.formatAssetIdToERC20(
            e.key.toString());
        final name = await evmParams.ethCall(
            provider: provider,
            contract: address,
            function: SubstratemEVMNetworkUtils.nameAbi);
        final symbol = await evmParams.ethCall(
            provider: provider,
            contract: address,
            function: SubstratemEVMNetworkUtils.symbolAbi);
        final decimals = await evmParams.ethCall(
            provider: provider,
            contract: address,
            function: SubstratemEVMNetworkUtils.decimalsAbi);
        return MoonbeamForeignAsset(
            assetId: e.key.toString(),
            name: name,
            symbol: symbol,
            decimals: decimals,
            location:
                SubstrateNetworkControllerUtils.asForeignVersionedLocation(
                    from: network, location: e.value));
      }).toList());
      for (final i in response) {
        // if (i == null) continue;
        contantAssets[BigInt.parse(i.assetId)] = i;
      }
    }
    return {for (final i in contantAssets.entries) i.value.location: i.value};
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BaseMoonbeamNetworkAsset>>>
      getAccountAssetsInternal(
          {required BaseSubstrateAddress address,
          List<Object>? knownAssetIds,
          List<BaseMoonbeamNetworkAsset>? knownAssets}) async {
    final bool selectedAssets = knownAssetIds != null || knownAssets != null;
    List<SubstrateAccountAssetBalance<BaseMoonbeamNetworkAsset>> balances = [];
    List<MoonbeamNetworkAsset> allAssets =
        (knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets)
            .whereType<MoonbeamNetworkAsset>()
            .toList();
    final evmParams = params.evmParams;
    if (evmParams == null) {
      throw DartSubstratePluginException("Missing evm network parameters.");
    }
    if (allAssets.isNotEmpty) {
      final provider = await metadata();
      balances = await Future.wait(allAssets.map((e) async {
        final balance = await evmParams.ethCall(
            provider: provider,
            function: SubstratemEVMNetworkUtils.balanceOfAbi,
            contract: e.asset.evmAddress(),
            params: [address.address]);
        return SubstrateAccountAssetBalance(asset: e, free: balance);
      }).toList());
      if (!selectedAssets) {
        balances = balances.where((e) => e.free > BigInt.zero).toList();
      }
    }
    return balances;
  }

  @override
  Future<List<MoonbeamNetworkAsset>> getAssetsInternal(
      {List<Object>? knownAssetIds}) async {
    final provider = await params.loadMetadata(network);

    List<MoonbeamNetworkAsset> allAssets = [];
    if (knownAssetIds == null || knownAssetIds.isNotEmpty) {
      final assets = await _getMoonbeamForeignAssets(
          provider: provider, assetIds: knownAssetIds);
      final defaultAssets = _getDefaultAssets(assetIds: knownAssetIds);
      allAssets.addAll(defaultAssets);
      final fees = await SubstrateNetworkControllerAssetQueryHelper
          .getXCMTransactorPalletDestinationFeePerSeconds(
              provider, network.defaultXcmVersion);
      final feePayments = await SubstrateNetworkControllerAssetQueryHelper
          .queryAcceptablePaymentAsset(
              provider: provider, version: network.defaultXcmVersion);
      for (final i in assets.entries) {
        allAssets.add(MoonbeamNetworkAsset(
            asset: i.value,
            isFeeToken: feePayments.contains(i.key),
            unitsPerSecond: fees[i.key]));
      }
    }
    return allAssets;
  }

  @override
  Future<SubstrateAccountAssetBalance<BaseMoonbeamNetworkAsset>?>
      getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
        api: provider.metadata.api, rpc: provider.provider, address: address);
    return SubstrateAccountAssetBalance<BaseMoonbeamNetworkAsset>(
        asset: defaultNativeAsset,
        reserved: balance.data.reserved,
        frozen: balance.data.flags,
        free: balance.data.free);
  }
}

class MoonbeamNetworkController
    extends BaseMoonbeamNetworkController<PolkadotNetwork> {
  MoonbeamNetworkController({required super.params});
  @override
  List<MoonbeamNetworkAsset> get defaultAssets => _defaultAssets;
  @override
  late final MoonbeamNetworkNativeAsset defaultNativeAsset =
      MoonbeamNetworkNativeAsset(
          decimals: 18,
          name: "Moonbeam",
          symbol: "GLMR",
          location: SubstrateNetworkControllerUtils
              .locationWithPalletInstanceAndAccountKey20(
                  paraId: network.paraId,
                  palletInstance: 10,
                  version: network.defaultXcmVersion));

  late final List<MoonbeamNetworkAsset> _defaultAssets = [
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0x99Fec54a5Ad36D50A4Bba3a41CAB983a5BB86A7d",
            name: "Wrapped SOL",
            symbol: "SOL",
            decimals: 9,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0x99Fec54a5Ad36D50A4Bba3a41CAB983a5BB86A7d",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0x931715FEE2d06333043d11F658C8CE934aC61D0c",
            name: "USD Coin",
            symbol: "USDC",
            decimals: 6,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0x931715FEE2d06333043d11F658C8CE934aC61D0c",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0xc30E9cA94CF52f3Bf5692aaCF81353a27052c46f",
            name: "Tether USD",
            symbol: "USDT",
            decimals: 6,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0xc30E9cA94CF52f3Bf5692aaCF81353a27052c46f",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0xE57eBd2d67B462E9926e04a8e33f01cD0D64346D",
            name: "Wrapped BTC",
            symbol: "WBTC",
            decimals: 8,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0xE57eBd2d67B462E9926e04a8e33f01cD0D64346D",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0xab3f0245B83feB11d15AAffeFD7AD465a59817eD",
            name: "Wrapped Ether",
            symbol: "WETH",
            decimals: 18,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0xab3f0245B83feB11d15AAffeFD7AD465a59817eD",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0x06e605775296e851FF43b4dAa541Bb0984E9D6fD",
            name: "Dai Stablecoin",
            symbol: "DAI",
            decimals: 18,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0x06e605775296e851FF43b4dAa541Bb0984E9D6fD",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
    MoonbeamNetworkAsset(
        asset: MoonbeamForeignAsset(
            assetId: "0xDa430218862d3dB25DE9F61458645Dde49a9e9C1",
            name: "Savings USDS",
            symbol: "sUSDS",
            decimals: 18,
            location: SubstrateNetworkControllerUtils
                .locationWithPalletInstanceAndAccountKey20(
                    paraId: network.paraId,
                    palletInstance:
                        MoonbeamNetworkControllerConst.erc20BrdigePalletIndex,
                    accountKey: "0xDa430218862d3dB25DE9F61458645Dde49a9e9C1",
                    version: network.defaultXcmVersion)),
        isFeeToken: true),
  ].toImutableList;

  @override
  PolkadotNetwork get network => PolkadotNetwork.moonbeam;

  @override
  BigInt get chainId => MoonbeamNetworkControllerConst.moonbeamChainId;

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
        pallet: SubtrateMetadataPallet.polkadotXcm,
        method: XCMCallPalletMethod.transferAssets);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      return SubstrateNetworkControllerXCMTransferBuilder
          .xcmTransferParaToSystem(
              params: params,
              provider: provider,
              network: network,
              defaultPallet: SubtrateMetadataPallet.xcmPallet,
              onControllerRequest: onControllerRequest);
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.transferAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}

class MoonriverNetworkController
    extends BaseMoonbeamNetworkController<KusamaNetwork> {
  MoonriverNetworkController({required super.params});
  @override
  List<MoonbeamNetworkAsset> get defaultAssets => [];
  @override
  late final MoonbeamNetworkNativeAsset defaultNativeAsset =
      MoonbeamNetworkNativeAsset(
          decimals: 18,
          name: "Moonriver",
          symbol: "MOVR",
          location: SubstrateNetworkControllerUtils
              .locationWithPalletInstanceAndAccountKey20(
                  paraId: network.paraId,
                  palletInstance: 10,
                  version: network.defaultXcmVersion));

  @override
  KusamaNetwork get network => KusamaNetwork.moonriver;

  @override
  BigInt get chainId => MoonbeamNetworkControllerConst.moonRiverChainId;

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
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMPalletTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.transferAssets);
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (params.hasRelayAsset) {
      return SubstrateNetworkControllerXCMTransferBuilder
          .xcmTransferParaToSystem(
              params: params,
              provider: provider,
              network: network,
              defaultPallet: SubtrateMetadataPallet.polkadotXcm,
              onControllerRequest: onControllerRequest);
    }
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
        params: params,
        provider: provider,
        network: network,
        method: XCMCallPalletMethod.transferAssets,
        pallet: SubtrateMetadataPallet.polkadotXcm);
  }
}
