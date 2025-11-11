import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class PalletConstantMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  /// Name of the pallet constant
  final String name;

  /// Type of the pallet constant.
  final int type;

  /// Value stored in the constant (SCALE encoded).
  final List<int> value;

  /// Documentation of the constant.
  final List<String> docs;
  PalletConstantMetadata({
    required this.name,
    required this.type,
    required List<int> value,
    required List<String> docs,
  })  : value = value.asImmutableBytes,
        docs = docs.immutable;

  PalletConstantMetadata.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        type = json["type"],
        value = (json["value"] as List).cast<int>().asImmutableBytes,
        docs = (json["docs"] as List).cast<String>().immutable;
}

class PalletConstantMetadataV14 extends PalletConstantMetadata {
  PalletConstantMetadataV14({
    required super.name,
    required super.type,
    required super.value,
    required super.docs,
  });
  PalletConstantMetadataV14.deserializeJson(super.json)
      : super.deserializeJson();
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletConstantMetadataV14(
        property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"name": name, "type": type, "value": value, "docs": docs};
  }
}
