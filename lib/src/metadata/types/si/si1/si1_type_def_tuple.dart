import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_tuple.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

class Si1TypeDefTuple extends Si1TypeDef<List<int>> implements TypeDefTuple {
  @override
  final List<int> values;
  Si1TypeDefTuple(List<int> values) : values = List<int>.unmodifiable(values);

  @override
  CustomLayout<Map<String, dynamic>, List<int>> layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefTuple(property: property);

  @override
  List<int> scaleJsonSerialize({String? property}) {
    return values;
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.tuple;

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    final listValue = MetadataUtils.isOf<List>(value);
    MetadataUtils.hasLen(listValue, values.length);
    final List<Layout> layouts = [];
    for (int i = 0; i < values.length; i++) {
      final type = values[i];
      final value = listValue[i];
      final layout = registry.typeDefLayout(type, value);
      layouts.add(layout);
    }
    return LayoutConst.tuple(layouts, property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    int consumed = 0;
    final List decoded = [];
    for (int i = 0; i < values.length; i++) {
      final type = registry.scaleType(values[i]);
      final decode = type.typeDefDecode(registry, bytes.sublist(consumed));
      decoded.add(decode.value);
      consumed += decode.consumed;
    }
    return LayoutDecodeResult(consumed: consumed, value: decoded);
  }

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
        lookupId: self);
    final listValue = MetadataCastingUtils.hasList(
        value: data, length: values.length, type: typeName, lookupId: self);
    final List<Object?> correctValues = [];
    for (int i = 0; i < values.length; i++) {
      final value = registry.getValue(
          id: values[i], value: listValue[i], fromTemplate: fromTemplate);
      correctValues.add(value);
    }
    return correctValues;
  }
}
