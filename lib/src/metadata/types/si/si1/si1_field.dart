import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';

class Si1Field extends SubstrateSerialization<Map<String, dynamic>> {
  final String? name;
  final int type;
  final String? typeName;
  final List<String> docs;
  Si1Field(
      {required this.name,
      required this.type,
      required this.typeName,
      required List<String> docs})
      : docs = List<String>.unmodifiable(docs);
  Si1Field.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        docs = (json["docs"] as List).cast(),
        type = json["type"],
        typeName = json["typeName"];

  bool get hasName => name != null;

  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1Field(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"name": name, "type": type, "typeName": typeName, "docs": docs};
  }

  Map<String, dynamic> toJson() {
    return scaleJsonSerialize();
  }

  MetadataTypeInfo typeInfo(PortableRegistry registry) {
    final type = registry.typeInfo(this.type);
    return type.copyWith(name: name ?? typeName ?? type.name, docs: docs);
  }
}
