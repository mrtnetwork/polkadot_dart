import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';

class PalletAssociatedTypeMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  /// The name of the associated type.
  final String name;

  /// The type of the associated type.
  final int type;

  /// The documentation of the associated type.
  final List<String> docs;

  PalletAssociatedTypeMetadata({
    required this.name,
    required this.type,
    required List<int> fallback,
    required List<String> docs,
  }) : docs = docs.immutable;
  PalletAssociatedTypeMetadata.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        type = json["type"],
        docs = (json["docs"] as List).cast<String>().immutable;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletAssociatedTypeMetadata(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "type": type,
      "name": name,
      "docs": docs,
    };
  }
}
