import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';

/// Frequency (Polkadot para 2091, FRQCY/8).
///
/// Chain layout: native FRQCY in `Balances`; bridged/XCM assets in
/// `ForeignAssets` (a `pallet_assets` instance, same storage layout as
/// AssetHub's `ForeignAssets` — hence the shared asset types). There is no
/// local `assets` pallet and no asset-registry pallet, so only the foreign
/// branch is queried.
///
/// NOTE (mainnet `BaseCallFilter`): `pallet_xcm` transfer/teleport/reserve
/// extrinsics are restricted on mainnet. Standard XCM calls are still built
/// (dry-run surfaces chain-side rejection before any submission); local
/// `ForeignAssets` transfers are unaffected.
abstract class BaseFrequencyNetworkController<
  NETWORK extends BaseSubstrateNetwork
>
    extends
        BaseSubstrateNetworkController<
          Object,
          BasePolkadotAssetHubNetworkAsset,
          NETWORK
        > {
  @override
  final SubstrateNetworkControllerParams params;
  BaseFrequencyNetworkController({required this.params});

  Future<Map<XCMVersionedLocation, PolkadotAssetHubNetworkAsset>>
  _getForeignAssets({
    required MetadataWithProvider provider,
    required List<XCMVersionedLocation> fees,
    List<XCMVersionedLocation>? assetIds,
  }) async {
    final entries =
        await SubstrateNetworkControllerAssetQueryHelper.getForeignAssetsPalletAssetIdentifierMultiLocation(
          provider,
          network.defaultXcmVersion,
          assetIds: assetIds,
        );
    final metadatas =
        await SubstrateNetworkControllerAssetQueryHelper.getForeignAssetsPalletMetadataIdentifierMultiLocation(
          provider,
          network.defaultXcmVersion,
          locations: assetIds,
        );
    final assets =
        entries.entries.map((e) {
          final metadata = metadatas[e.key];
          return PolkadotAssetHubNetworkAsset(
            asset: PolkadotAssetHubForeignAsset(
              asset: PolkadotAssetHubAssetInfo.fromJson(e.value),
              assetId: e.key,
            ),
            location: e.key,
            chargeAssetTxPayment: fees.contains(e.key),
            metadata:
                metadata == null
                    ? null
                    : PolkadotAssetHubAssetMetadata.fromJson(metadata),
            isFeeToken: fees.contains(e.key),
          );
        }).toList();
    return {for (final i in assets) i.identifier as XCMVersionedLocation: i};
  }

  @override
  Future<List<PolkadotAssetHubNetworkAsset>> getAssetsInternal({
    List<Object>? knownAssetIds,
  }) async {
    final List<XCMVersionedLocation>? locations =
        knownAssetIds?.whereType<XCMVersionedLocation>().toList();
    final provider = await params.loadMetadata(network);
    // Frequency uses a custom fee-payment pallet; the generic acceptable-asset
    // query is best-effort here.
    List<XCMVersionedLocation> fees = [];
    try {
      fees =
          await SubstrateNetworkControllerAssetQueryHelper.queryAcceptablePaymentAsset(
            provider: provider,
            version: network.defaultXcmVersion,
          );
    } catch (_) {
      fees = [];
    }
    if (locations == null || locations.isNotEmpty) {
      final assets = await _getForeignAssets(
        provider: provider,
        fees: fees,
        assetIds: locations,
      );
      return assets.values.toList();
    }
    return [];
  }

  @override
  Future<List<SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>>>
  getAccountAssetsInternal({
    required BaseSubstrateAddress address,
    List<Object>? knownAssetIds,
    List<BasePolkadotAssetHubNetworkAsset>? knownAssets,
  }) async {
    final provider = await params.loadMetadata(network);
    List<SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>>
    balances = [];
    final allAssets =
        knownAssets ?? (await getAssets(knownAssetIds: knownAssetIds)).assets;
    Map<XCMVersionedLocation, PolkadotAssetHubNetworkAsset> foreignAssets = {};
    for (final i in allAssets) {
      if (i is! PolkadotAssetHubNetworkAsset) continue;
      final assetId = i.identifier;
      if (assetId is XCMVersionedLocation) {
        foreignAssets[assetId] = i;
      }
    }
    if (foreignAssets.isNotEmpty) {
      final balancesEntries =
          await SubstrateNetworkControllerAssetQueryHelper.getForeignAssetsPalletAccountIdentifierMultilocation(
            provider: provider,
            address: address,
            locations: foreignAssets.keys.toList(),
          );
      for (final i in balancesEntries.entries) {
        if (i.value == null) continue;
        final asset = foreignAssets[i.key];
        if (asset == null) continue;
        final balance = PolkadotAssetBalance.fromJson(i.value!);
        balances.add(
          SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>(
            asset: asset,
            free: balance.balance,
            reason: balance.reason,
            status: balance.status,
          ),
        );
      }
    }
    return balances;
  }

  @override
  Future<SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>?>
  getNativeAssetFreeBalance(BaseSubstrateAddress address) async {
    final provider = await params.loadMetadata(network);
    final balance = await SubstrateQuickStorageApi.system.accountWithDataFrame(
      api: provider.metadata.api,
      rpc: provider.provider,
      address: address,
    );
    return SubstrateAccountAssetBalance<BasePolkadotAssetHubNetworkAsset>(
      asset: defaultNativeAsset,
      reserved: balance.data.reserved,
      frozen: balance.data.flags,
      free: balance.data.free,
    );
  }
}

class FrequencyNetworkController
    extends BaseFrequencyNetworkController<PolkadotNetwork> {
  FrequencyNetworkController({required super.params});

  @override
  late final PolkadotAssetHubNetworkNativeAsset defaultNativeAsset =
      PolkadotAssetHubNetworkNativeAsset(
        name: "Frequency",
        decimals: 8,
        symbol: "FRQCY",
        location: SubstrateNetworkControllerUtils.locationWithParaId(
          paraId: network.paraId,
          version: network.defaultXcmVersion,
        ),
      );

  @override
  PolkadotNetwork get network => PolkadotNetwork.frequency;

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    ONREQUESTNETWORKPROVIDER? onControllerRequest,
  }) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
      params: params,
      provider: provider,
      network: network,
      pallet: SubstrateMetadataPallet.polkadotXcm,
    );
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    ONREQUESTNETWORKPROVIDER? onControllerRequest,
  }) async {
    return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
      params: params,
      provider: provider,
      network: network,
      pallet: SubstrateMetadataPallet.polkadotXcm,
    );
  }

  @override
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    ONREQUESTNETWORKPROVIDER? onControllerRequest,
  }) async {
    return SubstrateNetworkControllerXCMTransferBuilder.xcmTransferParaToSystem(
      params: params,
      provider: provider,
      network: network,
      defaultPallet: SubstrateMetadataPallet.polkadotXcm,
      onControllerRequest: onControllerRequest,
    );
  }
}
