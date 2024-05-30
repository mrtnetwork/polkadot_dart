import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class Si1Variant extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final List<Si1Field> fields;
  final int index;
  final List<String> docs;
  Si1Variant(
      {required this.name,
      required List<Si1Field> fields,
      required this.index,
      required List<String> docs})
      : fields = List<Si1Field>.unmodifiable(fields),
        docs = List<String>.unmodifiable(docs);
  Si1Variant.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        docs = List<String>.unmodifiable(json["docs"]),
        fields = List<Si1Field>.unmodifiable(
            (json["fields"] as List).map((e) => Si1Field.deserializeJson(e))),
        index = json["index"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.si1Variant(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "fields": fields.map((e) => e.scaleJsonSerialize()).toList(),
      "index": index,
      "docs": docs
    };
  }

  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    if (fields.isEmpty) {
      return LayoutConst.none(property: property);
    }
    if (fields.length == 1) {
      return registry.typeDefLayout(fields[0].type, value,
          property: property ?? fields[0].name);
    }
    if (fields[0].hasName) {
      final mapValue = MetadataUtils.isOf<Map<String, dynamic>>(value);
      final layouts = fields
          .map((e) => registry.typeDefLayout(e.type, mapValue[e.name],
              property: e.name))
          .toList();
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

  LayoutDecodeResult decode(PortableRegistry registry, List<int> bytes) {
    if (fields.isEmpty) {
      return LayoutDecodeResult(consumed: 0, value: {name: null});
    }
    if (fields.length == 1) {
      final type = registry.scaleType(fields[0].type);
      final decode = type.typeDefDecode(registry, bytes);
      return LayoutDecodeResult(
          consumed: decode.consumed, value: {name: decode.value});
    }

    Map<String, dynamic> mapResult = {};
    final List tupleResult = [];
    final bool isStruct = fields[0].hasName;
    int consumed = 0;
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final type = registry.scaleType(field.type);
      final decode = type.typeDefDecode(registry, bytes.sublist(consumed));
      if (isStruct) {
        mapResult[field.name!] = decode.value;
      } else {
        tupleResult.add(decode.value);
      }
      consumed += decode.consumed;
    }
    return LayoutDecodeResult(
        consumed: consumed, value: {name: isStruct ? mapResult : tupleResult});
  }

  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    return TypeTemlate(
        lookupId: id,
        type: null,
        name: name,
        children: fields
            .map((e) => registry
                .typeTemplate(e.type)
                .copyWith(name: e.name, typeName: e.typeName))
            .toList());
  }

  Object? getValue(PortableRegistry registry,
      {required Object? value, required bool fromTemplate}) {
    if (fields.isEmpty) {
      if (value != null) {
        throw MetadataException(
            "Value must be null for a variant without fields.",
            details: {"value": value, "variant": name});
      }
      return null;
    }
    if (fields.length == 1) {
      return registry.getValue(
          id: fields[0].type, value: value, fromTemplate: fromTemplate);
    }
    Object? data = MetadataCastingUtils.getValue(
        value: value,
        type: Si1TypeDefsIndexesConst.variant,
        fromTemplate: fromTemplate,
        lookupId: 0);
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
    final listValue =
        MetadataCastingUtils.hasList(value: data, length: fields.length);
    final List<Object?> values = [];
    Map<String, dynamic> mapValues = {};
    final bool isStruct = fields[0].hasName;
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final value = registry.getValue(
          id: field.type, value: listValue[i], fromTemplate: fromTemplate);
      if (isStruct) {
        mapValues[field.name!] = value;
      } else {
        values.add(value);
      }
    }
    if (isStruct) return mapValues;
    return values;
  }
}
