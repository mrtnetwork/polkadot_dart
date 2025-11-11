import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';

class MantaAsset {
  final PolkadotAssetHubAssetInfo asset;
  final BigInt assetId;

  MantaAsset.fromJson(Map<String, dynamic> json)
      : asset = PolkadotAssetHubAssetInfo.fromJson(json.valueAs("asset")),
        assetId = json.valueAs("asset_id");
  MantaAsset({required this.asset, required this.assetId});

  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "asset_id": assetId.toString(),
    };
  }
}

abstract class BaseMantaNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseMantaNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseMantaNetworkAsset.fromJson(super.json) : super.fromJson();

  @override
  Object? get xTokenTransferId => {"MantaCurrency": identifier};
}

class MantaNetworkAsset extends BaseMantaNetworkAsset {
  final PolkadotAssetHubAsset asset;
  final PolkadotAssetHubAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  final BigInt? unitsPerSecond;
  MantaNetworkAsset.fromJson(super.json)
      : asset = PolkadotAssetHubAsset.fromJson(json.valueAs("asset")),
        metadata =
            json.valueTo<PolkadotAssetHubAssetMetadata?, Map<String, dynamic>>(
          key: "metadata",
          parse: (v) => PolkadotAssetHubAssetMetadata.fromJson(v),
        ),
        location = json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
          key: "location",
          parse: (v) => XCMVersionedLocation.fromJson(v),
        ),
        unitsPerSecond = json.valueAs("units_per_second"),
        super.fromJson();
  MantaNetworkAsset(
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

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "units_per_second": unitsPerSecond?.toString(),
      "location": location?.toJson(),
      ...super.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    return identifier == this.identifier;
  }
}

class MantaNetworkNativeAsset extends BaseMantaNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  MantaNetworkNativeAsset(
      {required this.location,
      super.isFeeToken = true,
      super.isSpendable = true,
      required super.name,
      required super.symbol,
      required super.decimals,
      super.minBalance})
      : super(excutionPallet: SubtrateMetadataPallet.balances);

  MantaNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  Map<String, dynamic> toJson() {
    return {"location": location.toJson(), ...super.toJson()};
  }

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }
}
