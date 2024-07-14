import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/src/provider/models/models.dart';
import 'package:polkadot_dart/src/provider/models/runtime/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class QueryFeeInfoFrame extends SubstrateSerialization<Map<String, dynamic>> {
  final FeeDetailsFrame? inclusionFee;

  /// maybe not exist in some networks
  final BigInt tip;
  const QueryFeeInfoFrame({this.inclusionFee, required this.tip});
  factory QueryFeeInfoFrame.deserialize(List<int> bytes) {
    final data = RPCRuntimeLayouts.queryFeeInfo().deserialize(bytes);

    final value = data.value;
    final fee = value["inclusionFee"] == null
        ? null
        : FeeDetailsFrame(
            baseFee: value["inclusionFee"]["baseFee"],
            lenFee: value["inclusionFee"]["lenFee"],
            adjustedWeightFee: value["inclusionFee"]["adjustedWeightFee"]);
    if (bytes.length > data.consumed) {
      final tip = LayoutConst.u128().deserialize(bytes.sublist(data.consumed));
      return QueryFeeInfoFrame(inclusionFee: fee, tip: tip.value);
    }
    return QueryFeeInfoFrame(inclusionFee: fee, tip: BigInt.zero);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return RPCRuntimeLayouts.queryFeeInfo(property: property);
  }

  @override
  List<int> serialize({String? property}) {
    return [
      ...layout(property: property).serialize(scaleJsonSerialize()),
      ...LayoutConst.u128().serialize(tip),
    ];
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"inclusionFee": inclusionFee?.scaleJsonSerialize(), "tip": tip};
  }
}
