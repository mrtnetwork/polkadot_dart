import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class Si1TypeDefSequence extends Si1TypeDef<Map<String, dynamic>> {
  final int type;
  Si1TypeDefSequence(this.type);
  Si1TypeDefSequence.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefSequence(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"type": type};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.sequence;

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    final parent = registry.typeTemplate(type);
    return TypeTemlate(lookupId: id, type: typeName, children: [parent]);
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
    final isPrimitive = parent.toPrimitive();
    final Object? data = MetadataCastingUtils.getValue(
        value: value,
        type: typeName,
        fromTemplate: fromTemplate,
        id: self,
        primitive: isPrimitive,
        registry: registry);

    if (isPrimitive != null) {
      return data;
    }
    final listValue = MetadataCastingUtils.asList(
        value: data, lookupId: self, type: typeName);
    return listValue
        .map((e) =>
            registry.getValue(id: type, value: e, fromTemplate: fromTemplate))
        .toList();
  }

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    return MetadataTypeInfoSequence(
        name: null, typeId: id, type: registry.typeInfo(type));
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
    final layout = registry.serializationLayout(type, params: params);
    final parent = registry.scaleType(type);
    final tryAsPrimitive = parent.toPrimitive();
    if (tryAsPrimitive == PrimitiveTypes.u8) {
      return LayoutConst.compactBytes(
          property: property, resultAsHex: params?.bytesAsHex ?? true);
    }
    return LayoutConst.compactVec(layout, property: property);
  }
}
