import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/types.dart';

class StorageEntryMetadataV16 extends StorageEntryMetadataV14 {
  final DeprecationStatus deprecationInfo;
  StorageEntryMetadataV16(
      {required super.name,
      required super.modifier,
      required super.type,
      required super.fallback,
      required super.docs,
      required this.deprecationInfo});
  StorageEntryMetadataV16.deserializeJson(super.json)
      : deprecationInfo =
            DeprecationStatus.deserializeJson(json["deprecation_info"]),
        super.deserializeJson();

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.storageEntryMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "name": name,
      "modifier": modifier.serializeJson(),
      "type": {type.typeName: type.serializeJson()},
      "fallback": fallback,
      "docs": docs,
      "deprecation_info": deprecationInfo.serializeJsonVariant()
    };
  }
}
