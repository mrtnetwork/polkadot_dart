import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:polkadot_dart/src/provider/models/runtime/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class InclusionFee extends SubstrateSerialization<Map<String, dynamic>> {
  final BigInt baseFee;
  final BigInt lenFee;
  final BigInt adjustedWeightFee;
  const InclusionFee(
      {required this.baseFee,
      required this.lenFee,
      required this.adjustedWeightFee});

  factory InclusionFee.fromJson(Map<String, dynamic> json) {
    return InclusionFee(
      baseFee: BigintUtils.parse(json['baseFee']),
      lenFee: BigintUtils.parse(json['lenFee']),
      adjustedWeightFee: BigintUtils.parse(json['adjustedWeightFee']),
    );
  }

  @override
  StructLayout layout({String? property}) =>
      RPCRuntimeLayouts.feeDetails(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "baseFee": baseFee,
      "lenFee": lenFee,
      "adjustedWeightFee": adjustedWeightFee
    };
  }
}
