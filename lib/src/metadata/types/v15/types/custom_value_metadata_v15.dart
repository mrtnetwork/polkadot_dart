import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class CustomValueMetadata15
    extends SubstrateSerialization<Map<String, dynamic>> {
  final int type;
  final BuBytes value;
  CustomValueMetadata15({required this.type, required List<int> value})
    : value = value.asImmutableBytes;
  CustomValueMetadata15.deserializeJson(Map<String, dynamic> json)
    : type = json["type"],
      value = (json["value"] as List).cast<int>().asImmutableBytes;
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.customValueMetadata15(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"type": type, "value": value};
  }
}
