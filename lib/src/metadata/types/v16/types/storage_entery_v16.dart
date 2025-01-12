import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';

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
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "modifier": modifier.scaleJsonSerialize(),
      "type": {type.typeName: type.scaleJsonSerialize()},
      "fallback": fallback,
      "docs": docs,
      "deprecation_info": deprecationInfo.toVariantScaleJsonSerialize()
    };
  }
}
