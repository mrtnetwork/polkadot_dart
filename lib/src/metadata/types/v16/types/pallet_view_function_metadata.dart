import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/runtime_api_method_param_metadata_v15.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/deprecation_status.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class PalletViewFunctionMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  final List<int> id;
  final String name;
  final List<RuntimeApiMethodParamMetadataV15> inputs;
  final int output;
  final List<String> docs;
  final DeprecationStatus deprecationInfo;

  PalletViewFunctionMetadata({
    required List<int> id,
    required this.name,
    required List<RuntimeApiMethodParamMetadataV15> inputs,
    required this.output,
    required List<String> docs,
    required this.deprecationInfo,
  }) : id = List<int>.unmodifiable(id),
       inputs = List<RuntimeApiMethodParamMetadataV15>.unmodifiable(inputs),
       docs = List<String>.unmodifiable(docs);

  PalletViewFunctionMetadata.deserializeJson(Map<String, dynamic> json)
    : id = (json["id"] as List).cast<int>().immutable,
      name = json["name"],
      inputs = List<RuntimeApiMethodParamMetadataV15>.unmodifiable(
        (json["inputs"] as List).map(
          (e) => RuntimeApiMethodParamMetadataV15.deserializeJson(e),
        ),
      ),
      output = json["output"],
      docs = (json["docs"] as List).cast<String>().immutable,
      deprecationInfo = DeprecationStatus.deserializeJson(
        json["deprecation_info"],
      );

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletViewFunctionMetadata(
      property: property,
    );
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "id": id,
      "name": name,
      "inputs": inputs.map((e) => e.serializeJson()).toList(),
      "output": output,
      "docs": docs,
      "deprecation_info": deprecationInfo.serializeJsonVariant(),
    };
  }
}
