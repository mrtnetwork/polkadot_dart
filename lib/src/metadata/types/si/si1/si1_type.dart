import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'si1_type.defs.dart';
import 'si1_type_parameter.dart';

class Si1Type extends SubstrateSerialization<Map<String, dynamic>>
    implements ScaleInfoVersioned {
  @override
  final List<String> path;

  @override
  late final ScaleTypeDef def;
  final List<Si1TypeParameter> params;
  @override
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
        docs = json["docs"] {
    def = MetadataUtils.toOption(Si1TypeDef.deserializeJson(json["def"]), path,
        params.map((e) => e.type).toList());
  }

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

  static const xcm = ["staging_xcm", "xcm"];

  final x = ["staging_xcm", "v4", "Xcm"];

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    return def.typeDefLayout(registry, value, property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    return def.typeDefDecode(registry, bytes);
  }

  @override
  Si1TypeDefsIndexesConst get typeName => def.typeName;

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    if (path.isNotEmpty && path.last == "RuntimeCall") {
      return TypeTemlate(
        lookupId: id,
        type: typeName,
        typeName: "RuntimeCall",
      );
    }
    if (path.isNotEmpty && path.last == "Instruction") {
      return TypeTemlate(
        lookupId: id,
        type: typeName,
        typeName: "Instruction",
      );
    }
    return def.typeTemplate(registry, id).copyWith(path: path);
  }

  @override
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

  @override
  PrimitiveTypes? toPrimitive() {
    if (typeName != Si1TypeDefsIndexesConst.primitive) return null;
    return (def as PrimitiveType).type;
  }
}
