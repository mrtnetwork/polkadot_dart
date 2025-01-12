import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/v14.dart';
import 'storage_entery_v16.dart';

class PalletStorageMetadataV16
    extends PalletStorageMetadata<StorageEntryMetadataV16> {
  @override
  final String prefix;
  @override
  final List<StorageEntryMetadataV16> items;
  PalletStorageMetadataV16(
      {required this.prefix, required List<StorageEntryMetadataV14> items})
      : items = List<StorageEntryMetadataV16>.unmodifiable(items);
  PalletStorageMetadataV16.deserializeJson(Map<String, dynamic> json)
      : prefix = json["prefix"],
        items = List<StorageEntryMetadataV16>.unmodifiable(
            (json["items"] as List)
                .map((e) => StorageEntryMetadataV16.deserializeJson(e)));

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletStorageMetadataV16(
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
