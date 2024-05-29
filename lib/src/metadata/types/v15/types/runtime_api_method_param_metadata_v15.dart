import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class RuntimeApiMethodParamMetadataV15
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final int type;
  const RuntimeApiMethodParamMetadataV15(
      {required this.name, required this.type});
  RuntimeApiMethodParamMetadataV15.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        type = json["type"];
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.runtimeApiMethodParamMetadataV15(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"name": name, "type": type};
  }
}
