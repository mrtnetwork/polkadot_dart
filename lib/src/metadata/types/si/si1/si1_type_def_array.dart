import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class Si1TypeDefArray extends Si1TypeDef<Map<String, dynamic>> {
  final int len;
  final int type;
  Si1TypeDefArray({required this.len, required this.type});
  Si1TypeDefArray.deserializeJson(Map<String, dynamic> json)
      : len = json["len"],
        type = json["type"];

  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefArray(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"len": len, "type": type};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.array;

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    final parent = registry.typeTemplate(type);
    return TypeTemlate(
        lookupId: id, length: len, type: typeName, children: [parent]);
  }

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
    final listValue = MetadataCastingUtils.asList(
        value: data, length: len, lookupId: self, type: typeName);
    if (isPrimitive != null) {
      return listValue;
    }
    return listValue
        .map((e) =>
            registry.getValue(id: type, value: e, fromTemplate: fromTemplate))
        .toList();
  }

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    return MetadataTypeInfoArray(
        type: registry.typeInfo(type), length: len, name: null, typeId: id);
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
      return LayoutConst.byteArray(len,
          property: property, resultAsHex: params?.bytesAsHex ?? true);
    }
    return LayoutConst.array(layout, len, property: property);
  }
}
