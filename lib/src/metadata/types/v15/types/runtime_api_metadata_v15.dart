import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'runtime_api_method_metadata_v15.dart';

class RuntimeApiMetadataV15
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final List<RuntimeApiMethodMetadataV15> methods;
  final List<String> docs;
  RuntimeApiMetadataV15({
    required this.name,
    required List<RuntimeApiMethodMetadataV15> methods,
    required List<String> docs,
  })  : methods = List<RuntimeApiMethodMetadataV15>.unmodifiable(methods),
        docs = List<String>.unmodifiable(docs);
  RuntimeApiMetadataV15.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        methods = List<RuntimeApiMethodMetadataV15>.unmodifiable(
            (json["methods"] as List)
                .map((e) => RuntimeApiMethodMetadataV15.deserializeJson(e))),
        docs = List<String>.unmodifiable(json["docs"]);
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.runtimeApiMetadataV15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "methods": methods.map((e) => e.scaleJsonSerialize()).toList(),
      "docs": docs
    };
  }
}
