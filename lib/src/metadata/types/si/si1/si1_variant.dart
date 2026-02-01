import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class Si1Variant extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final List<Si1Field> fields;
  final int index;
  final List<String> docs;
  Si1Variant({
    required this.name,
    required List<Si1Field> fields,
    required this.index,
    required List<String> docs,
  }) : fields = List<Si1Field>.unmodifiable(fields),
       docs = List<String>.unmodifiable(docs);
  Si1Variant.deserializeJson(Map<String, dynamic> json)
    : name = json["name"],
      docs = List<String>.unmodifiable(json["docs"]),
      fields = List<Si1Field>.unmodifiable(
        (json["fields"] as List).map((e) => Si1Field.deserializeJson(e)),
      ),
      index = json["index"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.si1Variant(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "name": name,
      "fields": fields.map((e) => e.serializeJson()).toList(),
      "index": index,
      "docs": docs,
    };
  }

  Layout serializationLayout(
    PortableRegistry registry, {
    String? property,
    LookupDecodeParams? params,
  }) {
    if (fields.isEmpty) {
      return LayoutConst.none(property: property);
    }
    if (fields.length == 1) {
      return registry.serializationLayout(
        fields[0].type,
        property: property ?? fields[0].name,
        params: params,
      );
    }
    if (fields[0].hasName) {
      return LayoutConst.lazyStruct(
        fields
            .map(
              (e) => LazyStructLayoutBuilder(
                layout:
                    (property, _) => registry.serializationLayout(
                      e.type,
                      property: property,
                      params: params,
                    ),
                property: e.name,
              ),
            )
            .toList(),
        property: property,
      );
    }
    return LayoutConst.tuple(
      fields
          .map((e) => registry.serializationLayout(e.type, params: params))
          .toList(),
      property: property,
    );
  }

  TypeTemlate typeTemplate(PortableRegistry registry, int id, {int? lookup}) {
    List<Si1Field> fields = this.fields;
    if (lookup != null) fields = fields.where((e) => e.type == lookup).toList();
    return TypeTemlate(
      lookupId: id,
      type: null,
      name: name,
      variantIndex: index,
      children:
          fields
              .map(
                (e) => registry
                    .typeTemplate(e.type)
                    .copyWith(name: e.name, typeName: e.typeName),
              )
              .toList(),
    );
  }

  Object? getValue(
    PortableRegistry registry, {
    required Object? value,
    required bool fromTemplate,
    required int self,
  }) {
    if (fields.isEmpty) {
      if (value != null) {
        throw MetadataException(
          "Value must be null for a variant without fields.",
          details: {"value": value, "variant": name},
        );
      }
      return null;
    }

    if (fields.length == 1) {
      return registry.getValue(
        id: fields[0].type,
        value: value,
        fromTemplate: fromTemplate,
      );
    }
    final Object? data = MetadataCastingUtils.getValue(
      value: value,
      type: Si1TypeDefsIndexesConst.variant,
      fromTemplate: fromTemplate,
      id: self,
      registry: registry,
    );

    if (fields[0].hasName) {
      final mapValue = MetadataCastingUtils.isMap<String, dynamic>(data);
      final Map<String, dynamic> values = {};
      for (final i in fields) {
        final value = registry.getValue(
          id: i.type,
          value: mapValue[i.name],
          fromTemplate: fromTemplate,
        );
        values[i.name!] = value;
      }
      return values;
    }
    final listValue = MetadataCastingUtils.asList(
      value: data,
      length: fields.length,
    );
    final List<Object?> values = [];
    final Map<String, dynamic> mapValues = {};
    final bool isStruct = fields[0].hasName;
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final value = registry.getValue(
        id: field.type,
        value: listValue[i],
        fromTemplate: fromTemplate,
      );
      if (isStruct) {
        mapValues[field.name!] = value;
      } else {
        values.add(value);
      }
    }
    if (isStruct) return mapValues;
    return values;
  }

  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    if (fields.isEmpty) {
      return MetadataTypeInfoNone(typeId: id, name: name);
    }
    if (fields.length == 1) {
      return fields[0].typeInfo(registry);
    }
    final types = fields.map((e) => e.typeInfo(registry)).toList();
    if (fields[0].hasName) {
      return MetadataTypeInfoComposit(name: name, typeId: id, types: types);
    }
    return MetadataTypeInfoTuple(name: name, typeId: id, types: types);
  }
}
