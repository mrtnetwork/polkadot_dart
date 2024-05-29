import 'package:blockchain_utils/numbers/numbers.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class InclusionFee with JsonSerialization {
  final BigInt baseFee;
  final BigInt lenFee;
  final BigInt adjustedWeightFee;

  const InclusionFee({
    required this.baseFee,
    required this.lenFee,
    required this.adjustedWeightFee,
  });

  factory InclusionFee.fromJson(Map<String, dynamic> json) {
    return InclusionFee(
      baseFee: BigintUtils.parse(json['baseFee']),
      lenFee: BigintUtils.parse(json['lenFee']),
      adjustedWeightFee: BigintUtils.parse(json['adjustedWeightFee']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee.toString(),
      'lenFee': lenFee.toString(),
      'adjustedWeightFee': adjustedWeightFee.toString(),
    };
  }
}
