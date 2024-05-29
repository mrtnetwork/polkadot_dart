import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class CustomValueMetadata15
    extends SubstrateSerialization<Map<String, dynamic>> {
  final int type;
  final List<int> value;
  CustomValueMetadata15({required this.type, required List<int> value})
      : value = BytesUtils.toBytes(value, unmodifiable: true);
  CustomValueMetadata15.deserializeJson(Map<String, dynamic> json)
      : type = json["type"],
        value = BytesUtils.toBytes(json["value"], unmodifiable: true);
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.customValueMetadata15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"type": type, "value": value};
  }
}
