import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class Si0TypeDefPrimitive extends SubstrateSerialization<Map<String, dynamic>>
    implements ScaleTypeDef, PrimitiveType {
  @override
  final PrimitiveTypes type;
  Si0TypeDefPrimitive(String name) : type = PrimitiveTypes.fromValue(name);

  Si0TypeDefPrimitive.deserializeJson(Map<String, dynamic> json)
      : type = PrimitiveTypes.fromValue(
            SubstrateEnumSerializationUtils.getScaleEnumKey(json,
                keys: PrimitiveTypes.values.map((e) => e.name).toList()));

  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      SubstrateMetadataLayouts.si0TypeDefPrimitive(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {type.name: null};
  }

  @override
  Layout typeDefLayout(PortableRegistry registry, Object? value,
      {String? property}) {
    return type.toLayout(property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    final layout = type.toLayout();
    return layout.deserialize(bytes);
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.primitive;

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    return TypeTemlate(
        lookupId: id, type: typeName, children: [], primitive: this);
  }

  @override
  @override
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self}) {
    return MetadataCastingUtils.getValue(
        value: value,
        type: typeName,
        fromTemplate: fromTemplate,
        primitive: type,
        lookupId: self);
  }
}
