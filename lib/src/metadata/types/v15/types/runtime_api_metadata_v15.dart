import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'runtime_api_method_metadata_v15.dart';

abstract class RuntimeApiMetadata<METHOD extends RuntimeApiMethodMetadata>
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  abstract final List<METHOD> methods;
  final List<String> docs;
  RuntimeApiMetadata({
    required this.name,
    required List<String> docs,
  }) : docs = docs.immutable;
  RuntimeApiMetadata.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        docs = List<String>.unmodifiable(json["docs"]);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "methods": methods.map((e) => e.scaleJsonSerialize()).toList(),
      "docs": docs
    };
  }
}

class RuntimeApiMetadataV15
    extends RuntimeApiMetadata<RuntimeApiMethodMetadataV15> {
  @override
  final List<RuntimeApiMethodMetadataV15> methods;
  RuntimeApiMetadataV15({
    required super.name,
    required List<RuntimeApiMethodMetadataV15> methods,
    required super.docs,
  }) : methods = methods.immutable;
  RuntimeApiMetadataV15.deserializeJson(super.json)
      : methods = List<RuntimeApiMethodMetadataV15>.unmodifiable(
            (json["methods"] as List)
                .map((e) => RuntimeApiMethodMetadataV15.deserializeJson(e))),
        super.deserializeJson();
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.runtimeApiMetadataV15(property: property);
  }
}
