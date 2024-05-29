import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/storage_entery_type_v14.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'entry_modifier_v14.dart';

class StorageEntryMetadataV14
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final StorageEntryModifierV14 modifier;
  final StorageEntryTypeV14 type;
  final List<int> fallback;
  final List<String> docs;

  bool get isPlain => type.typeName == StorageEntryTypeV14IndexKeys.plain;

  int? getInputlookupId() {
    if (isPlain) return null;
    return (StorageEntryTypeV14 as StorageEntryTypeV14Map).key;
  }

  StorageEntryMetadataV14({
    required this.name,
    required this.modifier,
    required this.type,
    required List<int> fallback,
    required List<String> docs,
  })  : fallback = BytesUtils.toBytes(fallback, unmodifiable: true),
        docs = List<String>.unmodifiable(docs);
  StorageEntryMetadataV14.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        modifier = StorageEntryModifierV14.deserializeJson(json["modifier"]),
        type = StorageEntryTypeV14.deserializeJson(json["type"]),
        fallback = BytesUtils.toBytes(json["fallback"], unmodifiable: true),
        docs = List<String>.unmodifiable(json["docs"]);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.storageEntryMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "modifier": modifier.scaleJsonSerialize(),
      "type": {type.typeName: type.scaleJsonSerialize()},
      "fallback": fallback,
      "docs": docs
    };
  }
}
