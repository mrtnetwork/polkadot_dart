import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/storage_entry_type_v14.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'entry_modifier_v14.dart';

class StorageEntryMetadataV14
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final StorageEntryModifierV14 modifier;
  final StorageEntryTypeV14 type;
  final BuBytes fallback;
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
  }) : fallback = fallback.asImmutableBytes,
       docs = List<String>.unmodifiable(docs);
  StorageEntryMetadataV14.deserializeJson(Map<String, dynamic> json)
    : name = json["name"],
      modifier = StorageEntryModifierV14.deserializeJson(json["modifier"]),
      type = StorageEntryTypeV14.deserializeJson(json["type"]),
      fallback = (json["fallback"] as List).cast<int>().asImmutableBytes,
      docs = List<String>.unmodifiable(json["docs"]);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.storageEntryMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "name": name,
      "modifier": modifier.serializeJson(),
      "type": {type.typeName: type.serializeJson()},
      "fallback": fallback,
      "docs": docs,
    };
  }
}
