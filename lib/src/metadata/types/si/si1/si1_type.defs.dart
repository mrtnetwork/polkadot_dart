import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_historic_meta_compat.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';
import 'si1_type_def_array.dart';
import 'si1_type_def_bit_sequence.dart';
import 'si1_type_def_compact.dart';
import 'si1_type_def_composite.dart';
import 'si1_type_def_primitive.dart';
import 'si1_type_def_sequence.dart';
import 'si1_type_def_tuple.dart';
import 'si1_type_def_variant.dart';

class Si1TypeDefsIndexesConst {
  final String name;
  const Si1TypeDefsIndexesConst._(this.name);
  static const Si1TypeDefsIndexesConst option =
      Si1TypeDefsIndexesConst._("Option");
  static const Si1TypeDefsIndexesConst composite =
      Si1TypeDefsIndexesConst._('Composite');
  static const Si1TypeDefsIndexesConst variant =
      Si1TypeDefsIndexesConst._('Variant');
  static const Si1TypeDefsIndexesConst sequence =
      Si1TypeDefsIndexesConst._('Sequence');
  static const Si1TypeDefsIndexesConst array =
      Si1TypeDefsIndexesConst._('Array');
  static const Si1TypeDefsIndexesConst tuple =
      Si1TypeDefsIndexesConst._('Tuple');
  static const Si1TypeDefsIndexesConst primitive =
      Si1TypeDefsIndexesConst._('Primitive');
  static const Si1TypeDefsIndexesConst compact =
      Si1TypeDefsIndexesConst._('Compact');
  static const Si1TypeDefsIndexesConst bitSequence =
      Si1TypeDefsIndexesConst._('BitSequence');
  static const Si1TypeDefsIndexesConst historicMetaCompat =
      Si1TypeDefsIndexesConst._('HistoricMetaCompat');
  static const List<Si1TypeDefsIndexesConst> values = [
    composite,
    variant,
    sequence,
    array,
    tuple,
    primitive,
    compact,
    bitSequence,
    historicMetaCompat
  ];

  static Si1TypeDefsIndexesConst fromValue(String? name) {
    return values.firstWhere(
      (element) => element.name == name,
      orElse: () => throw MetadataException(
          "No Si1Type found matching the specified name",
          details: {"name": name}),
    );
  }

  bool get isPrimitive => this == primitive;

  @override
  String toString() {
    return "Si1TypeDefsIndexesConst.$name";
  }
}

abstract class Si1TypeDef<T> extends SubstrateSerialization<T>
    implements ScaleTypeDef {
  @override
  abstract final Si1TypeDefsIndexesConst typeName;
  const Si1TypeDef();

  factory Si1TypeDef.deserializeJson(Map<String, dynamic> json) {
    final key = Si1TypeDefsIndexesConst.fromValue(
        SubstrateEnumSerializationUtils.getScaleEnumKey(json));

    final ScaleTypeDef def;
    switch (key) {
      case Si1TypeDefsIndexesConst.composite:
        def = Si1TypeDefComposite.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.variant:
        def = Si1TypeDefVariant.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.array:
        def = Si1TypeDefArray.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.tuple:
        def = Si1TypeDefTuple(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.primitive:
        def = Si1TypeDefPrimitive.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.sequence:
        def = Si1TypeDefSequence.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.compact:
        def = Si1TypeDefCompact.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      case Si1TypeDefsIndexesConst.bitSequence:
        def = Si1TypeDefBitSequence.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
      default:
        def = Si1TypeDefHistoricMetaCompat(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key.name));
        break;
    }
    return def as Si1TypeDef<T>;
  }
}
