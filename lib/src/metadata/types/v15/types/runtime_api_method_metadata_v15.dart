import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'runtime_api_method_param_metadata_v15.dart';

abstract class RuntimeApiMethodMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  /// Method name.
  final String name;

  /// Method parameters.
  final List<RuntimeApiMethodParamMetadataV15> inputs;

  /// Method output.
  final int output;

  /// Method documentation.
  final List<String> docs;
  RuntimeApiMethodMetadata({
    required this.name,
    required List<RuntimeApiMethodParamMetadataV15> inputs,
    required this.output,
    required List<String> docs,
  })  : inputs = List<RuntimeApiMethodParamMetadataV15>.unmodifiable(inputs),
        docs = List<String>.unmodifiable(docs);
  RuntimeApiMethodMetadata.deserializeJson(Map<String, dynamic> json)
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
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "name": name,
      "inputs": inputs.map((e) => e.serializeJson()).toList(),
      "output": output,
      "docs": docs
    };
  }
}

class RuntimeApiMethodMetadataV15 extends RuntimeApiMethodMetadata {
  RuntimeApiMethodMetadataV15(
      {required super.name,
      required super.inputs,
      required super.output,
      required super.docs});
  RuntimeApiMethodMetadataV15.deserializeJson(super.json)
      : super.deserializeJson();
}
