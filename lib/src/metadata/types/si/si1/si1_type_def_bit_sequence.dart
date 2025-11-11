import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/bit.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class Si1TypeDefBitSequence extends Si1TypeDef<Map<String, dynamic>> {
  final int bitStoreType;
  final int bitOrderType;
  Si1TypeDefBitSequence(
      {required this.bitOrderType, required this.bitStoreType});
  Si1TypeDefBitSequence.deserializeJson(Map<String, dynamic> json)
      : bitStoreType = json["bitStoreType"],
        bitOrderType = json["bitOrderType"];

  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefBitSequence(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"bitStoreType": bitStoreType, "bitOrderType": bitOrderType};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.bitSequence;

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    return TypeTemlate(lookupId: id, type: typeName, children: []);
  }

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
        id: self,
        registry: registry);
  }

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    throw UnimplementedError();
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
    return SubstrateBitSequenceLayout(property: property);
  }
}
