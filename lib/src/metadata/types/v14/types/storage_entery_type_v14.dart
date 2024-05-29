import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v11/types/storage_hasher.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class StorageEntryTypeV14IndexKeys {
  static const String map = "Map";
  static const String plain = "Plain";
}

abstract class StorageEntryTypeV14<T> extends SubstrateSerialization<T> {
  abstract final String typeName;
  const StorageEntryTypeV14();
  int get outputTypeId;
  int? get inputTypeId;
  factory StorageEntryTypeV14.deserializeJson(Map<String, dynamic> json) {
    final key = SubstrateEnumSerializationUtils.getScaleEnumKey(json,
        className: "StorageEntryTypeV14Types",
        keys: [
          StorageEntryTypeV14IndexKeys.map,
          StorageEntryTypeV14IndexKeys.plain
        ]);
    final StorageEntryTypeV14 val;
    switch (key) {
      case StorageEntryTypeV14IndexKeys.map:
        val = StorageEntryTypeV14Map.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key));
        break;
      default:
        val = StorageEntryTypeV14Plain(
            SubstrateEnumSerializationUtils.getScaleEnumValue<int>(json, key));
        break;
    }
    return val as StorageEntryTypeV14<T>;
  }
}

class StorageEntryTypeV14Map extends StorageEntryTypeV14<Map<String, dynamic>> {
  final List<StorageHasherV14> hashers;
  final int key;
  final int value;
  StorageEntryTypeV14Map(
      {required List<StorageHasherV14> hashers,
      required this.key,
      required this.value})
      : hashers = List<StorageHasherV14>.unmodifiable(hashers);
  StorageEntryTypeV14Map.deserializeJson(Map<String, dynamic> json)
      : hashers = List.unmodifiable((json["hashers"] as List)
            .map((e) => StorageHasherV14.deserializeJson(e))),
        key = json["key"],
        value = json["value"];

  @override
  String get typeName => StorageEntryTypeV14IndexKeys.map;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.storageEnteryTypeMap(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "hashers": hashers.map((e) => e.scaleJsonSerialize()).toList(),
      "key": key,
      "value": value
    };
  }

  @override
  int get outputTypeId => value;

  @override
  int get inputTypeId => key;
}

class StorageEntryTypeV14Plain extends StorageEntryTypeV14<int> {
  final int plain;
  const StorageEntryTypeV14Plain(this.plain);

  @override
  String get typeName => StorageEntryTypeV14IndexKeys.plain;

  @override
  Layout<int> layout({String? property}) {
    return SubstrateMetadataLayouts.si1LookupTypeId(property: property);
  }

  @override
  int scaleJsonSerialize({String? property}) {
    return plain;
  }

  @override
  int get outputTypeId => plain;

  @override
  int? get inputTypeId => null;
}
