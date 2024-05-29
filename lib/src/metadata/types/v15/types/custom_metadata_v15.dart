import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/custom_value_metadata_v15.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class CustomMetadata15 extends SubstrateSerialization<Map<String, dynamic>> {
  final Map<String, CustomValueMetadata15> map;
  CustomMetadata15(Map<String, CustomValueMetadata15> map)
      : map = Map<String, CustomValueMetadata15>.unmodifiable(map);
  CustomMetadata15.deserializeJson(Map<String, dynamic> json)
      : map = Map<String, CustomValueMetadata15>.unmodifiable(<String, dynamic>{
          for (final i in (json["map"] as Map).entries)
            i.key: CustomValueMetadata15.deserializeJson(i.value)
        });
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.customMetadata15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "map": {for (final i in map.entries) i.key: i.value.scaleJsonSerialize()}
    };
  }
}
