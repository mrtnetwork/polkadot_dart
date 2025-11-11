import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/generic/models/weight.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

/// frame_support, dispatch, PerDispatchClas
class FrameSupportDispatchPerDispatchClass
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateWeightV2 normal;
  final SubstrateWeightV2 operational;
  final SubstrateWeightV2 mandatory;
  const FrameSupportDispatchPerDispatchClass(
      {required this.normal,
      required this.operational,
      required this.mandatory});
  FrameSupportDispatchPerDispatchClass.deserializeJson(
      Map<String, dynamic> json)
      : normal = SubstrateWeightV2.deserializeJson(json["normal"]),
        mandatory = SubstrateWeightV2.deserializeJson(json["mandatory"]),
        operational = SubstrateWeightV2.deserializeJson(json["operational"]);
  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      SubstrateWeightV2.layout_(property: "normal"),
      SubstrateWeightV2.layout_(property: "operational"),
      SubstrateWeightV2.layout_(property: "mandatory"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "normal": normal.serializeJson(),
      "operational": operational.serializeJson(),
      "mandatory": mandatory.serializeJson()
    };
  }
}
