import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class SubstrateWeightV2 extends SubstrateSerialization<Map<String, dynamic>>
    with Equality {
  final BigInt refTime;
  final BigInt proofSize;
  const SubstrateWeightV2({required this.refTime, required this.proofSize});
  SubstrateWeightV2.deserializeJson(Map<String, dynamic> json)
      : refTime = json.valueAs("ref_time"),
        proofSize = json.valueAs("proof_size");
  factory SubstrateWeightV2.fromJson(Map<String, dynamic> json) {
    return SubstrateWeightV2(
        refTime: json.valueAs("ref_time"),
        proofSize: json.valueAs("proof_size"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "ref_time"),
      LayoutConst.compactBigintU64(property: "proof_size"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"ref_time": refTime, "proof_size": proofSize};
  }

  Map<String, dynamic> toJson() {
    return {"ref_time": refTime, "proof_size": proofSize};
  }

  @override
  List get variabels => [refTime, proofSize];
}
