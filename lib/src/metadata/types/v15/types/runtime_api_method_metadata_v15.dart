import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'runtime_api_method_param_metadata_v15.dart';

class RuntimeApiMethodMetadataV15
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final List<RuntimeApiMethodParamMetadataV15> inputs;
  final int output;
  final List<String> docs;
  RuntimeApiMethodMetadataV15({
    required this.name,
    required List<RuntimeApiMethodParamMetadataV15> inputs,
    required this.output,
    required List<String> docs,
  })  : inputs = List<RuntimeApiMethodParamMetadataV15>.unmodifiable(inputs),
        docs = List<String>.unmodifiable(docs);
  RuntimeApiMethodMetadataV15.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        inputs = List<RuntimeApiMethodParamMetadataV15>.unmodifiable(
            (json["inputs"] as List).map(
                (e) => RuntimeApiMethodParamMetadataV15.deserializeJson(e))),
        output = json["output"],
        docs = List<String>.unmodifiable(json["docs"]);
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.runtimeApiMethodMetadataV15(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "inputs": inputs.map((e) => e.scaleJsonSerialize()).toList(),
      "output": output,
      "docs": docs
    };
  }
}
// export interface RuntimeApiMethodMetadataV15 extends Struct {
//     readonly name: Text;
//     readonly inputs: Vec<RuntimeApiMethodParamMetadataV15>;
//     readonly output: SiLookupTypeId;
//     readonly docs: Vec<Text>;
// }
