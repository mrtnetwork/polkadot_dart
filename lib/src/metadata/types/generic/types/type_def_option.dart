import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class TypeDefOption<T> extends SubstrateSerialization<T>
    implements ScaleTypeDef {
  final int optionType;
  final Si1TypeDef<T> def;
  TypeDefOption(this.optionType, this.def);

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    final parent = registry.type(optionType);
    final option =
        MetadataUtils.validateOptionBytes(bytes, infos: {"typeId": optionType});
    if (!option) return const LayoutDecodeResult(consumed: 1, value: null);
    final decode = parent.type.typeDefDecode(registry, bytes.sublist(1));
    return LayoutDecodeResult(
        consumed: decode.consumed + 1, value: decode.value);
  }

  @override
  Layout<T> layout({String? property}) {
    return def.layout(property: property);
  }

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    if (value == null) {
      return LayoutConst.optional(LayoutConst.none(), property: property);
    }
    final parent = registry.scaleType(optionType);
    final layout = parent.typeDefLayout(registry, value);
    return LayoutConst.optional(layout, property: property);
  }

  @override
  T scaleJsonSerialize({String? property}) {
    return def.scaleJsonSerialize();
  }

  @override
  Si1TypeDefsIndexesConst get typeName => def.typeName;

  /// Returns the type template using the provided [registry].
  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    final parent = registry.typeTemplate(optionType);
    return TypeTemlate(
        lookupId: id, type: Si1TypeDefsIndexesConst.option, children: [parent]);
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

    if (data == null) return null;
    return registry.getValue(
        id: optionType, value: value, fromTemplate: fromTemplate);
  }
}
