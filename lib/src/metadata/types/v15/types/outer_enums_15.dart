import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class OuterEnums15 extends SubstrateSerialization<Map<String, dynamic>> {
  final int callType;
  final int eventType;
  final int errorType;
  const OuterEnums15(
      {required this.callType,
      required this.errorType,
      required this.eventType});
  OuterEnums15.deserializeJson(Map<String, dynamic> json)
      : callType = json["callType"],
        eventType = json["eventType"],
        errorType = json["errorType"];
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.outerEnums15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "callType": callType,
      "eventType": eventType,
      "errorType": errorType
    };
  }
}
