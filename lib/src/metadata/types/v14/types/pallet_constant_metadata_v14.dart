import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class PalletConstantMetadataV14
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final int type;
  final List<int> value;
  final List<String> docs;
  PalletConstantMetadataV14({
    required this.name,
    required this.type,
    required List<int> value,
    required List<String> docs,
  })  : value = BytesUtils.toBytes(value, unmodifiable: true),
        docs = List<String>.unmodifiable(docs);
  PalletConstantMetadataV14.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        type = json["type"],
        value = BytesUtils.toBytes(json["value"], unmodifiable: true),
        docs = List<String>.unmodifiable(json["docs"]);
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletConstantMetadataV14(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"name": name, "type": type, "value": value, "docs": docs};
  }
}
