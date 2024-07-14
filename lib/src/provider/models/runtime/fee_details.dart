import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/provider/models/runtime/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class FeeDetailsFrame extends SubstrateSerialization<Map<String, dynamic>> {
  final BigInt baseFee;
  final BigInt lenFee;
  final BigInt adjustedWeightFee;
  const FeeDetailsFrame(
      {required this.baseFee,
      required this.lenFee,
      required this.adjustedWeightFee});

  @override
  StructLayout layout({String? property}) =>
      RPCRuntimeLayouts.feeDetails(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "baseFee": baseFee,
      "lenFee": lenFee,
      "adjustedWeightFee": adjustedWeightFee
    };
  }
}
