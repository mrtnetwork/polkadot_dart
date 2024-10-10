import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

class Si1TypeDefCompact extends Si1TypeDef<Map<String, dynamic>> {
  final int type;
  Si1TypeDefCompact(this.type);
  Si1TypeDefCompact.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefCompact(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"type": type};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.compact;

  Layout _serializationLayout(Layout<dynamic> parent,
      {Object? value, String? property}) {
    if (parent is IntegerLayout) {
      return LayoutConst.compactInt(parent, property: property);
    } else if (parent is BigIntLayout) {
      return LayoutConst.compactBigint(parent, property: property);
    }

    /// fix metadata v14 compact(Tupple) accountIndex
    if (parent is TupleLayout) {
      return LayoutConst.compactIntU32(property: property);
    }
    throw const LayoutException(
        "Somthing wrong. compact layout must be integer layout.");
  }

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    final parent = registry.typeDefLayout(type, value);

    final layout =
        _serializationLayout(parent, value: value, property: property);
    if (layout is CompactIntLayout) {
      MetadataUtils.isOf<int>(value, info: "Compact value must be an int.");
    } else if (parent is CompactBigIntLayout) {
      MetadataUtils.isOf<BigInt>(value,
          info: "Compact value must be a BigInt.");
    }
    return layout;
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    final parent = registry.typeDefLayout(type, null);
    final layout = _serializationLayout(parent);
    final deserialize = layout.deserialize(bytes);
    return deserialize;
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
    if (parent.def.typeName == Si1TypeDefsIndexesConst.tuple) {
      return MetadataCastingUtils.getValue(
          value: value,
          type: typeName,
          fromTemplate: fromTemplate,
          lookupId: self,
          primitive: PrimitiveTypes.u32);
    }
    return registry.getValue(
        id: type, value: value, fromTemplate: fromTemplate);
  }
}
