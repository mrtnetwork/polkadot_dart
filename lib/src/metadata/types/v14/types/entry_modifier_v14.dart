import 'package:polkadot_dart/src/metadata/types/v9/types/storage_entry_modifier.dart';

class StorageEntryModifierV14 extends StorageEntryModifierV9 {
  StorageEntryModifierV14.deserializeJson(Map<String, dynamic> json)
      : super.deserializeJson(json);
  StorageEntryModifierV14(String type) : super(type);
}
