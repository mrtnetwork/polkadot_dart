import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';

abstract class BaseUniqueNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseUniqueNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseUniqueNetworkAsset.fromJson(super.json) : super.fromJson();
}

class UniqueNetworkAsset extends BaseUniqueNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  BigInt get identifier => assetId;
  final BigInt assetId;
  UniqueNetworkAsset({
    required this.location,
    required this.assetId,
    super.isFeeToken = true,
    super.isSpendable = true,
    required super.name,
    required super.symbol,
    required super.decimals,
    super.minBalance,
  }) : super(excutionPallet: SubtrateMetadataPallet.erc20XcmBridge);
  UniqueNetworkAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        assetId = json.valueAs("asset_id"),
        super.fromJson();
  @override
  SubstrateAssetType get type => SubstrateAssetType.token;

  @override
  bool identifierEqual(Object? identifier) {
    return identifier == this.identifier;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "location": location.toJson(),
      ...super.toJson(),
      "asset_id": assetId.toString()
    };
  }
}

class UniqueNetworkNativeAsset extends BaseUniqueNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  UniqueNetworkNativeAsset({
    required this.location,
    super.isFeeToken = true,
    super.isSpendable = true,
    required super.name,
    required super.symbol,
    required super.decimals,
    super.minBalance,
  }) : super(excutionPallet: SubtrateMetadataPallet.balances);
  UniqueNetworkNativeAsset.fromJson(super.json)
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
    return {"location": location.toJson(), ...super.toJson()};
  }
}
