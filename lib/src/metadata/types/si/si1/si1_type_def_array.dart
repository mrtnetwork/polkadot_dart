import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

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
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"len": len, "type": type};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.array;

  @override
  Layout typeDefLayout(PortableRegistry registry, Object? value,
      {String? property}) {
    final listValue = MetadataUtils.isList(value);
    final parent = registry.type(type).type;
    MetadataUtils.hasLen(
      listValue,
      len,
      info: "Invalid fixed array length for type: ${parent.typeName}",
    );
    if (parent.typeName.isPrimitive) {
      final layout = registry.typeDefLayout(type, null);
      return LayoutConst.array(layout, len, property: property);
    }
    final layouts =
        listValue.map((e) => registry.typeDefLayout(type, e)).toList();

    return LayoutConst.tuple(layouts, property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    final parent = registry.scaleType(type);
    final isPrimitive = parent.toPrimitive();
    if (isPrimitive != null) {
      final parentLayout = registry.typeDefLayout(type, null);
      final layout = LayoutConst.array(parentLayout, len);
      final result = layout.deserialize(bytes);
      return result;
    }
    final List decoded = [];
    int consumed = 0;
    for (int i = 0; i < len; i++) {
      final decode = parent.typeDefDecode(registry, bytes.sublist(consumed));
      decoded.add(decode.value);
      consumed += decode.consumed;
    }
    return LayoutDecodeResult(consumed: consumed, value: decoded);
  }

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
        lookupId: self,
        primitive: isPrimitive);

    if (isPrimitive != null) {
      return data;
    }
    final listValue = MetadataCastingUtils.hasList(
        value: data, length: len, lookupId: self, type: typeName);
    return listValue
        .map((e) =>
            registry.getValue(id: type, value: e, fromTemplate: fromTemplate))
        .toList();
  }
}
