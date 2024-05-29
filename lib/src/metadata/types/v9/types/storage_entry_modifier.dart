import 'package:blockchain_utils/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class StorageEntryModifierV9
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  const StorageEntryModifierV9._(this.name);
  StorageEntryModifierV9(String name) : name = fromValue(name).name;
  static const StorageEntryModifierV9 optional =
      StorageEntryModifierV9._("Optional");
  static const StorageEntryModifierV9 def = StorageEntryModifierV9._("Default");
  static const StorageEntryModifierV9 required =
      StorageEntryModifierV9._("Required");

  static const List<StorageEntryModifierV9> values = [
    StorageEntryModifierV9.optional,
    StorageEntryModifierV9.def,
    StorageEntryModifierV9.required
  ];
  static StorageEntryModifierV9 fromValue(String? value) {
    return values.firstWhere(
      (element) => element.name == value,
      orElse: () => throw MessageException(
          "No StorageEntryModifierV9 found matching the specified value",
          details: {"value": value}),
    );
  }

  StorageEntryModifierV9.deserializeJson(Map<String, dynamic> json)
      : name = fromValue(SubstrateEnumSerializationUtils.getScaleEnumKey(json))
            .name;
  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      SubstrateMetadataLayouts.storageEntryModifierV9(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {name: null};
  }

  bool get isOptional => name == optional.name;
  @override
  String toString() {
    return "StorageEntryModifierV9Options.$name";
  }
}
