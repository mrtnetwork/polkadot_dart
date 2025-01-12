import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/runtime_api_method_metadata_v15.dart';

import 'deprecation_status.dart';

class RuntimeApiMethodMetadataV16 extends RuntimeApiMethodMetadata {
  /// Deprecation info
  final DeprecationStatus deprecationInfo;
  RuntimeApiMethodMetadataV16(
      {required super.name,
      required super.inputs,
      required super.output,
      required super.docs,
      required this.deprecationInfo});
  RuntimeApiMethodMetadataV16.deserializeJson(super.json)
      : deprecationInfo =
            DeprecationStatus.deserializeJson(json["deprecation_info"]),
        super.deserializeJson();
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.runtimeApiMethodMetadataV16(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      ...super.scaleJsonSerialize(property: property),
      "deprecation_info": deprecationInfo.toVariantScaleJsonSerialize()
    };
  }
}
