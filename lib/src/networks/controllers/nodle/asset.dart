import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';

abstract class BaseNodleNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseNodleNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseNodleNetworkAsset.fromJson(super.json) : super.fromJson();
}

class NodlenetNetworkNativeAsset extends BaseNodleNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  NodlenetNetworkNativeAsset({
    required this.location,
    super.isFeeToken = true,
    super.isSpendable = true,
    required super.name,
    required super.symbol,
    required super.decimals,
    super.minBalance,
  }) : super(excutionPallet: SubtrateMetadataPallet.balances);
  NodlenetNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();
  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }
}
