import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_constant_metadata_v14.dart';

import 'deprecation_status.dart';

class PalletConstantMetadataV16 extends PalletConstantMetadata {
  /// Deprecation info
  final DeprecationStatus deprecationInfo;
  PalletConstantMetadataV16(
      {required super.name,
      required super.type,
      required super.value,
      required super.docs,
      required this.deprecationInfo});
  PalletConstantMetadataV16.deserializeJson(super.json)
      : deprecationInfo =
            DeprecationStatus.deserializeJson(json["deprecation_info"]),
        super.deserializeJson();
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletConstantMetadataV16(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "type": type,
      "value": value,
      "docs": docs,
      "deprecation_info": deprecationInfo.toVariantScaleJsonSerialize()
    };
  }
}
