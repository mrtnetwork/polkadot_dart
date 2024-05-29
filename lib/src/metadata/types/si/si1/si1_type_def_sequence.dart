import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

class Si1TypeDefSequence extends Si1TypeDef<Map<String, dynamic>> {
  final int type;
  Si1TypeDefSequence(this.type);
  Si1TypeDefSequence.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefSequence(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"type": type};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.sequence;

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    final listValue = MetadataUtils.isList(value);
    final parent = registry.scaleType(type);
    if (parent.typeName.isPrimitive) {
      final layout = registry.typeDefLayout(
          type, listValue.isEmpty ? null : listValue[0],
          property: property);
      return LayoutConst.compactVec(layout, property: property);
    }
    final layouts =
        listValue.map((e) => registry.typeDefLayout(type, e)).toList();
    return LayoutConst.compactTuple(layouts, property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    final parent = registry.scaleType(type);
    final isPrimitive = parent.toPrimitive();
    if (isPrimitive != null) {
      final layout = registry.typeDefLayout(type, null);
      final listLayout = LayoutConst.compactVec(layout);
      return listLayout.deserialize(bytes);
    }
    final decodeLength = LayoutSerializationUtils.decodeLength(bytes);
    final count = decodeLength.item2.toInt();
    int consumed = decodeLength.item1;
    final List decoded = [];
    for (int i = 0; i < count; i++) {
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
        lookupId: self,
        primitive: isPrimitive);

    if (isPrimitive != null) {
      return data;
    }
    final listValue = MetadataCastingUtils.hasList(
        value: data, lookupId: self, type: typeName);
    return listValue
        .map((e) =>
            registry.getValue(id: type, value: e, fromTemplate: fromTemplate))
        .toList();
  }
}
