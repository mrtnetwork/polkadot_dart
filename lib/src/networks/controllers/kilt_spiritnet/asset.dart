import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';

abstract class BaseKLITSpiritNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseKLITSpiritNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseKLITSpiritNetworkAsset.fromJson(super.json) : super.fromJson();
}

class KLITSpiritnetNetworkAsset extends BaseKLITSpiritNetworkAsset {
  final PolkadotAssetHubForeignAsset asset;
  final PolkadotAssetHubAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;

  /// KLITSpiritFungibleAsset
  KLITSpiritnetNetworkAsset({
    required this.asset,
    required this.metadata,
    required this.location,
    required super.isFeeToken,
  }) : super(
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.fungibles,
            minBalance: asset.asset.minBalance,
            name: metadata?.name,
            symbol: metadata?.symbol,
            isSpendable:
                asset.asset.status != BasePolkadotNetworkAssetsStatus.frozen);
  factory KLITSpiritnetNetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = PolkadotAssetHubForeignAsset.fromJson(json.valueAs("asset"));
    final bool isFeeToken = json.valueAs("is_fee_token");
    final metadata =
        json.valueTo<PolkadotAssetHubAssetMetadata?, Map<String, dynamic>>(
            key: "metadata",
            parse: (v) => PolkadotAssetHubAssetMetadata.fromJson(json));
    return KLITSpiritnetNetworkAsset(
        asset: asset,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken,
        metadata: metadata);
  }

  @override
  Object get identifier => asset.assetId;
  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
      "location": location?.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    return asset.identifierEqual(identifier);
  }
}

class KLITSpiritnetNetworkNativeAsset extends BaseKLITSpiritNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  KLITSpiritnetNetworkNativeAsset({
    required this.location,
    super.isFeeToken = true,
    super.isSpendable = true,
    required super.name,
    required super.symbol,
    required super.decimals,
    super.minBalance,
  }) : super(excutionPallet: SubtrateMetadataPallet.balances);
  KLITSpiritnetNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();
  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "location": location.toJson()};
  }
}
