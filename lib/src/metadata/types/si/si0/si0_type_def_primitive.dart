import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class Si0TypeDefPrimitive extends ScaleTypeDef<Map<String, dynamic>>
    implements PrimitiveType {
  @override
  final PrimitiveTypes type;
  Si0TypeDefPrimitive(String name) : type = PrimitiveTypes.fromValue(name);

  Si0TypeDefPrimitive.deserializeJson(Map<String, dynamic> json)
      : type = PrimitiveTypes.fromValue(json.keys.firstOrNull);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      SubstrateMetadataLayouts.si0TypeDefPrimitive(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {type.name: null};
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
        id: self,
        registry: registry);
  }

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    return type.typeInfo(typeId: id);
  }

  @override
  int? typeByFieldName(PortableRegistry registry, int id, String name) {
    return null;
  }

  @override
  int? typeByName(PortableRegistry registry, int id, String name) {
    if (type.name == name) {
      return id;
    }
    return null;
  }

  @override
  Layout serializationLayout(PortableRegistry registry,
      {String? property, LookupDecodeParams? params}) {
    return type.toLayout(property: property);
  }
}
