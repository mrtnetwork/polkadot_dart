import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';

abstract class BaseDarwinia2NetworkAsset extends BaseSubstrateNetworkAsset {
  BaseDarwinia2NetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseDarwinia2NetworkAsset.fromJson(super.json) : super.fromJson();
}

class Darwinia2NetworkAsset extends BaseDarwinia2NetworkAsset {
  final PolkadotAssetHubAsset asset;
  final PolkadotAssetHubAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;

  final BigInt? unitsPerSecond;
  Darwinia2NetworkAsset(
      {required this.asset,
      required this.metadata,
      required super.isFeeToken,
      this.unitsPerSecond,
      this.location})
      : super(
            decimals: metadata?.decimals,
            isSpendable:
                asset.asset.status != BasePolkadotNetworkAssetsStatus.frozen,
            excutionPallet: SubtrateMetadataPallet.assets,
            minBalance: asset.asset.minBalance,
            name: metadata?.name,
            symbol: metadata?.symbol);
  @override
  BigInt get identifier => asset.assetId;
  factory Darwinia2NetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = PolkadotAssetHubAsset.fromJson(json.valueAs("asset"));
    final metadata =
        json.valueTo<PolkadotAssetHubAssetMetadata?, Map<String, dynamic>>(
      key: "metadata",
      parse: (v) {
        return PolkadotAssetHubAssetMetadata.fromJson(v);
      },
    );
    final bool isFeeToken = json.valueAs("is_fee_token");
    return Darwinia2NetworkAsset(
        asset: asset,
        metadata: metadata,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken,
        unitsPerSecond: json.valueAsBigInt("units_per_second"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
      "units_per_second": unitsPerSecond?.toString(),
      "location": location?.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    return identifier == this.identifier;
  }
}

class Darwinia2NetworkNativeAsset extends BaseDarwinia2NetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  Darwinia2NetworkNativeAsset(
      {required this.location,
      super.isFeeToken = true,
      super.isSpendable = true,
      required super.name,
      required super.symbol,
      required super.decimals,
      super.minBalance})
      : super(excutionPallet: SubtrateMetadataPallet.balances);
  Darwinia2NetworkNativeAsset.fromJson(super.json)
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
