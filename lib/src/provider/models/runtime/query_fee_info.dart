import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/utils/numbers/numbers.dart';
import 'package:polkadot_dart/src/provider/models/models.dart';
import 'package:polkadot_dart/src/provider/models/runtime/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class QueryFeeDetails extends SubstrateSerialization<Map<String, dynamic>> {
  final InclusionFee? inclusionFee;

  /// maybe not exist in some networks
  final BigInt tip;
  const QueryFeeDetails({this.inclusionFee, required this.tip});
  factory QueryFeeDetails.deserialize(List<int> bytes) {
    final data = RPCRuntimeLayouts.queryFeeInfo().deserialize(bytes);

    final value = data.value;
    final fee = value["inclusionFee"] == null
        ? null
        : InclusionFee(
            baseFee: value["inclusionFee"]["baseFee"],
            lenFee: value["inclusionFee"]["lenFee"],
            adjustedWeightFee: value["inclusionFee"]["adjustedWeightFee"]);
    if (bytes.length > data.consumed) {
      final tip = LayoutConst.u128().deserialize(bytes.sublist(data.consumed));
      return QueryFeeDetails(inclusionFee: fee, tip: tip.value);
    }
    return QueryFeeDetails(inclusionFee: fee, tip: BigInt.zero);
  }

  factory QueryFeeDetails.fromJson(Map<String, dynamic> json) {
    return QueryFeeDetails(
        inclusionFee: json["inclusionFee"] == null
            ? null
            : InclusionFee.fromJson(json["inclusionFee"]),
        tip: BigintUtils.tryParse(json["tip"]) ?? BigInt.zero);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return RPCRuntimeLayouts.queryFeeInfo(property: property);
  }

  @override
  List<int> serialize({String? property}) {
    return [
      ...layout(property: property).serialize(serializeJson()),
      ...LayoutConst.u128().serialize(tip),
    ];
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"inclusionFee": inclusionFee?.serializeJson(), "tip": tip};
  }
}
