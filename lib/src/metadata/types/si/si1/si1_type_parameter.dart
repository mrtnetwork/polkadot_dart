import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class Si1TypeParameter extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final int? type;
  const Si1TypeParameter({required this.name, required this.type});
  Si1TypeParameter.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        type = json["type"];
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeParameter(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"name": name, "type": type};
  }
}
