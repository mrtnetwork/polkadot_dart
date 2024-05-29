import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'storage_entry_metadata_v14.dart';

class PalletStorageMetadataV14
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String prefix;
  final List<StorageEntryMetadataV14> items;
  PalletStorageMetadataV14(
      {required this.prefix, required List<StorageEntryMetadataV14> items})
      : items = List<StorageEntryMetadataV14>.unmodifiable(items);
  PalletStorageMetadataV14.deserializeJson(Map<String, dynamic> json)
      : prefix = json["prefix"],
        items = List<StorageEntryMetadataV14>.unmodifiable(
            (json["items"] as List)
                .map((e) => StorageEntryMetadataV14.deserializeJson(e)));

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletStorageMetadataV14(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "prefix": prefix,
      "items": items.map((e) => e.scaleJsonSerialize()).toList()
    };
  }
}
