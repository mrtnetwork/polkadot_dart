import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class SpWeightsWeightV2Weight
    extends SubstrateSerialization<Map<String, dynamic>> {
  final BigInt refTime;
  final BigInt proofSize;
  const SpWeightsWeightV2Weight(
      {required this.refTime, required this.proofSize});

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.spWeightsWeightV2Weight(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"ref_time": refTime, "proof_size": proofSize};
  }
}
