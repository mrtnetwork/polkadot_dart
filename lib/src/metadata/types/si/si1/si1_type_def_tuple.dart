import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_tuple.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class Si1TypeDefTuple extends Si1TypeDef<List<int>> implements TypeDefTuple {
  @override
  final List<int> values;
  Si1TypeDefTuple(List<int> values) : values = List<int>.unmodifiable(values);

  @override
  CustomLayout<Map<String, dynamic>, List<int>> layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefTuple(property: property);

  @override
  List<int> serializeJson({String? property}) {
    return values;
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.tuple;

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    return TypeTemlate(
        lookupId: id,
        type: typeName,
        children: values.map((e) => registry.typeTemplate(e)).toList());
  }

  /// Checks the provided [value] and returns the correct data compared to the template or simple design,
  /// using the provided [registry], [fromTemplate] flag, and optional [property].
  @override
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self}) {
    final Object? data = MetadataCastingUtils.getValue(
        value: value,
        type: typeName,
        fromTemplate: fromTemplate,
        id: self,
        registry: registry);
    final listValue = MetadataCastingUtils.asList(
        value: data, length: values.length, type: typeName, lookupId: self);
    final List<Object?> correctValues = [];
    for (int i = 0; i < values.length; i++) {
      final value = registry.getValue(
          id: values[i], value: listValue[i], fromTemplate: fromTemplate);
      correctValues.add(value);
    }
    return correctValues;
  }

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    return MetadataTypeInfoTuple(
        name: null,
        typeId: id,
        types: values.map((e) => registry.typeInfo(e)).toList());
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
    return LayoutConst.tuple(
        values
            .map((e) => registry.serializationLayout(e, params: params))
            .toList(),
        property: property);
  }
}
