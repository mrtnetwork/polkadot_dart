import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';

abstract class BaseLaosNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseLaosNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseLaosNetworkAsset.fromJson(super.json) : super.fromJson();
}

class LaosnetNetworkNativeAsset extends BaseLaosNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  LaosnetNetworkNativeAsset({
    required this.location,
    super.isFeeToken = true,
    super.isSpendable = true,
    required super.name,
    required super.symbol,
    required super.decimals,
    super.minBalance,
  }) : super(excutionPallet: SubtrateMetadataPallet.balances);
  LaosnetNetworkNativeAsset.fromJson(super.json)
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
