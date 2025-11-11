import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

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
  Map<String, dynamic> serializeJson({String? property}) {
    return {"fields": fields.map((e) => e.serializeJson()).toList()};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.composite;

  Map<String, dynamic> toJson() {
    return serializeJson();
  }

  @override
  String toString() {
    return "Si1TypeDefComposite${toJson()}";
  }

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id, {int? lookup}) {
    List<Si1Field> fields = this.fields;
    if (lookup != null) fields = fields.where((e) => e.type == lookup).toList();
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
        id: self,
        registry: registry);
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
    final listValue = MetadataCastingUtils.asList(
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

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    if (fields.isEmpty) return MetadataTypeInfoNone(name: null, typeId: id);

    if (fields.length == 1 && !fields[0].hasName) {
      return fields[0].typeInfo(registry);
    }
    final types = fields.map((e) => e.typeInfo(registry)).toList();
    if (fields[0].hasName) {
      return MetadataTypeInfoComposit(name: null, typeId: id, types: types);
    }
    return MetadataTypeInfoTuple(name: null, typeId: id, types: types);
  }

  @override
  @override
  int? typeByFieldName(PortableRegistry registry, int id, String name) {
    return fields.firstWhereNullable((e) => e.name == name)?.type;
  }

  @override
  int? typeByName(PortableRegistry registry, int id, String name) {
    return fields.firstWhereNullable((e) => e.typeName == name)?.type;
  }

  @override
  Layout serializationLayout(PortableRegistry registry,
      {String? property, LookupDecodeParams? params}) {
    if (fields.isEmpty) {
      return LayoutConst.none(property: property);
    }
    if (fields.length == 1 && !fields[0].hasName) {
      return registry.serializationLayout(fields[0].type,
          property: property, params: params);
    }
    if (fields[0].hasName) {
      return LayoutConst.lazyStruct(
          fields
              .map((e) => LazyLayout(
                  layout: ({property}) => registry.serializationLayout(e.type,
                      property: property, params: params),
                  property: e.name))
              .toList(),
          property: property);
    }
    return LayoutConst.tuple(
        fields
            .map((e) => registry.serializationLayout(e.type, params: params))
            .toList(),
        property: property);
  }
}
