import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'si1_field.dart';

class Si1TypeDefComposite extends Si1TypeDef<Map<String, dynamic>> {
  final List<Si1Field> fields;
  Si1TypeDefComposite(List<Si1Field> fields)
      : fields = List<Si1Field>.unmodifiable(fields);
  Si1TypeDefComposite.deserializeJson(Map<String, dynamic> json)
      : fields = (json["fields"] as List)
            .map((e) => Si1Field.deserializeJson(e))
            .toList();

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.si1TypeDefComposite(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"fields": fields.map((e) => e.scaleJsonSerialize()).toList()};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.composite;

  Map<String, dynamic> toJson() {
    return scaleJsonSerialize();
  }

  @override
  String toString() {
    return "Si1TypeDefComposite${toJson()}";
  }

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    if (fields.isEmpty) {
      return LayoutConst.none(property: property);
    }
    if (fields.length == 1 && !fields[0].hasName) {
      return registry.typeDefLayout(fields[0].type, value,
          property: property ?? fields[0].name);
    }
    if (fields[0].hasName) {
      final mapValue = MetadataUtils.isOf<Map<String, dynamic>>(value);
      final layouts = fields.map((e) {
        return registry.typeDefLayout(e.type, mapValue[e.name],
            property: e.name);
      }).toList();
      return LayoutConst.struct(layouts, property: property);
    }
    final listValue = MetadataUtils.isOf<List>(value);
    MetadataUtils.hasLen(listValue, fields.length);
    final List<Layout<dynamic>> layouts = [];
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final value = listValue[i];
      final layout =
          registry.typeDefLayout(field.type, value, property: field.name);
      layouts.add(layout);
    }

    return LayoutConst.tuple(layouts, property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    if (fields.isEmpty) {
      return const LayoutDecodeResult(consumed: 0, value: null);
    }
    if (fields.length == 1 && !fields[0].hasName) {
      final type = registry.scaleType(fields[0].type);
      final decode = type.typeDefDecode(registry, bytes);
      return decode;
    }
    final Map<String, dynamic> mapResult = {};
    final List tupleResult = [];
    final bool isStruct = fields[0].hasName;
    int consumed = 0;
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final type = registry.scaleType(field.type);
      final decodeBytes = bytes.sublist(consumed);
      final decode = type.typeDefDecode(registry, decodeBytes);
      if (isStruct) {
        mapResult[field.name!] = decode.value;
      } else {
        tupleResult.add(decode.value);
      }
      consumed += decode.consumed;
    }
    return LayoutDecodeResult(
        consumed: consumed, value: isStruct ? mapResult : tupleResult);
  }

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    return TypeTemlate(
        lookupId: id,
        type: typeName,
        children: fields
            .map((e) => registry
                .typeTemplate(e.type)
                .copyWith(name: e.name, typeName: e.typeName))
            .toList());
  }

  /// Checks the provided [value] and returns the correct data compared to the template or simple design,
  /// using the provided [registry], [fromTemplate] flag, and optional [property].
  @override
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self}) {
    if (fields.isEmpty) return null;
    if (fields.length == 1 && !fields[0].hasName) {
      return registry.getValue(
          id: fields[0].type, value: value, fromTemplate: fromTemplate);
    }
    final Object? data = MetadataCastingUtils.getValue(
        value: value,
        type: typeName,
        fromTemplate: fromTemplate,
        lookupId: self);
    if (fields[0].hasName) {
      final mapValue = MetadataCastingUtils.isMap<String, dynamic>(data);

      final Map<String, dynamic> values = {};
      for (final i in fields) {
        final value = registry.getValue(
            id: i.type, value: mapValue[i.name], fromTemplate: fromTemplate);
        values[i.name!] = value;
      }
      return values;
    }
    final listValue = MetadataCastingUtils.hasList(
        value: data, length: fields.length, lookupId: self, type: typeName);
    final List<Object?> values = [];
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final value = registry.getValue(
          id: field.type, value: listValue[i], fromTemplate: fromTemplate);
      values.add(value);
    }
    return values;
  }
}
