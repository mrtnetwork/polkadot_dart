import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'si1_type.defs.dart';
import 'si1_type_parameter.dart';

class Si1Type extends SubstrateSerialization<Map<String, dynamic>> {
  final List<String> path;

  final ScaleTypeDef def;
  final List<Si1TypeParameter> params;
  final List<String> docs;

  Si1Type({
    required List<String> path,
    required List<Si1TypeParameter> params,
    required this.def,
    required List<String> docs,
  })  : params = List<Si1TypeParameter>.unmodifiable(params),
        docs = List<String>.unmodifiable(docs),
        path = List<String>.unmodifiable(path);
  Si1Type.deserializeJson(Map<String, dynamic> json)
      : path = json["path"],
        params = (json["params"] as List)
            .map((e) => Si1TypeParameter.deserializeJson(e))
            .toList(),
        docs = json["docs"],
        def = Si1TypeDef.deserializeJson(json["def"]);

  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1Type(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "path": path,
      "params": params.map((e) => e.scaleJsonSerialize()).toList(),
      "def": {
        typeName.name: (def as SubstrateSerialization).scaleJsonSerialize()
      },
      "docs": docs
    };
  }

  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    return def.typeDefLayout(registry, value, property: property);
  }

  LayoutDecodeResult typeDefDecode(
      {required PortableRegistry registry,
      required List<int> bytes,
      required int offset}) {
    return def.typeDefDecode(registry: registry, bytes: bytes, offset: offset);
  }

  Si1TypeDefsIndexesConst get typeName => def.typeName;

  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    if (!MetadataUtils.supportedTemplate(path)) {
      return TypeTemlate(
          lookupId: id, type: typeName, typeName: path.last, path: path);
    }
    return def.typeTemplate(registry, id).copyWith(path: path);
  }

  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self,
      String? property}) {
    return def.getValue(
        registry: registry,
        value: value,
        fromTemplate: fromTemplate,
        self: self);
  }

  PrimitiveTypes? toPrimitive() {
    if (typeName != Si1TypeDefsIndexesConst.primitive) return null;
    return (def as PrimitiveType).type;
  }

  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    return def.typeInfo(registry, id).copyWith(docs: docs, paths: path);
  }
}
