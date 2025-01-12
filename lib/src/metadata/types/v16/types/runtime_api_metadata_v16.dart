import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'runtime_api_method_metadata_v16.dart';

class RuntimeApiMetadataV16
    extends RuntimeApiMetadata<RuntimeApiMethodMetadataV16> {
  @override
  final List<RuntimeApiMethodMetadataV16> methods;
  final DeprecationStatus deprecationInfo;
  RuntimeApiMetadataV16(
      {required super.name,
      required List<RuntimeApiMethodMetadataV16> methods,
      required super.docs,
      required this.deprecationInfo})
      : methods = methods.immutable;
  RuntimeApiMetadataV16.deserializeJson(super.json)
      : methods = List<RuntimeApiMethodMetadataV16>.unmodifiable(
            (json["methods"] as List)
                .map((e) => RuntimeApiMethodMetadataV16.deserializeJson(e))),
        deprecationInfo =
            DeprecationStatus.deserializeJson(json["deprecation_info"]),
        super.deserializeJson();
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.runtimeApiMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      ...super.scaleJsonSerialize(property: property),
      "deprecation_info": deprecationInfo.toVariantScaleJsonSerialize()
    };
  }
}
