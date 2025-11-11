import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class Si1TypeDefCompact extends Si1TypeDef<Map<String, dynamic>> {
  final int type;
  Si1TypeDefCompact(this.type);
  Si1TypeDefCompact.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefCompact(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"type": type};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.compact;

  Layout _serializationLayout(Layout<dynamic> parent, {String? property}) {
    if (parent is IntegerLayout) {
      return LayoutConst.compactInt(parent, property: property);
    } else if (parent is BigIntLayout) {
      return LayoutConst.compactBigint(parent, property: property);
    }

    /// fix metadata v14 compact(Tuple) accountIndex
    if (parent is TupleLayout) {
      return LayoutConst.compactIntU32(property: property);
    }
    throw const LayoutException(
        "Somthing wrong. compact layout must be integer layout.");
  }

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    final parent = registry.typeTemplate(type).copyWith(isCompact: true);
    return TypeTemlate(
        lookupId: id, type: typeName, children: [parent], isCompact: true);
  }

  /// Checks the provided [value] and returns the correct data compared to the template or simple design,
  /// using the provided [registry], [fromTemplate] flag, and optional [property].
  @override
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self}) {
    final parent = registry.scaleType(type);
    if (parent.def.typeName == Si1TypeDefsIndexesConst.tuple) {
      return MetadataCastingUtils.getValue(
          value: value,
          type: typeName,
          fromTemplate: fromTemplate,
          id: self,
          primitive: PrimitiveTypes.u32,
          registry: registry);
    }
    return registry.getValue(
        id: type, value: value, fromTemplate: fromTemplate);
  }

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    final type = registry.typeInfo(this.type);
    if (type.typeName == MetadataTypes.tuple) {
      return MetadataTypeInfoInt(
          name: type.name, typeId: id, primitiveType: PrimitiveTypes.u32);
    }

    return type.copyWith(typeId: id);
  }

  @override
  int? typeByFieldName(PortableRegistry registry, int id, String name) {
    return null;
  }

  @override
  int? typeByName(PortableRegistry registry, int id, String name) {
    return null;
  }

  @override
  Layout serializationLayout(PortableRegistry registry,
      {String? property, LookupDecodeParams? params}) {
    final parent = registry.serializationLayout(type, params: params);
    return _serializationLayout(parent, property: property);
  }
}
