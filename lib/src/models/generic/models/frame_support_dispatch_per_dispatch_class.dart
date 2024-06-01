import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';
import 'package:polkadot_dart/src/models/generic/models/sp_weights_weight_v2_weight.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

/// frame_support, dispatch, PerDispatchClas
class FrameSupportDispatchPerDispatchClass
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SpWeightsWeightV2Weight normal;
  final SpWeightsWeightV2Weight operational;
  final SpWeightsWeightV2Weight mandatory;
  const FrameSupportDispatchPerDispatchClass(
      {required this.normal,
      required this.operational,
      required this.mandatory});
  FrameSupportDispatchPerDispatchClass.deserializeJson(
      Map<String, dynamic> json)
      : normal = SpWeightsWeightV2Weight.deserializeJson(json["normal"]),
        mandatory = SpWeightsWeightV2Weight.deserializeJson(json["mandatory"]),
        operational =
            SpWeightsWeightV2Weight.deserializeJson(json["operational"]);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.frameSupportDispatchPerDispatchClass(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "normal": normal.scaleJsonSerialize(),
      "operational": operational.scaleJsonSerialize(),
      "mandatory": mandatory.scaleJsonSerialize()
    };
  }
}
