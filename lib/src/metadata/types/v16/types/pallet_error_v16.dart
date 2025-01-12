import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_error_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/depecrated_info.dart';

class PalletErrorMetadataV16 extends PalletErrorMetadata {
  /// The error type information.
  @override
  final int type;

  /// Deprecation info
  final MetadataDeprecationInfo deprecationInfo;
  const PalletErrorMetadataV16(
      {required this.type, required this.deprecationInfo});
  PalletErrorMetadataV16.deserializeJson(Map<String, dynamic> json)
      : type = json["type"],
        deprecationInfo =
            MetadataDeprecationInfo.deserializeJson(json["deprecation_info"]);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletErrorMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "type": type,
      "deprecation_info": deprecationInfo.toVariantScaleJsonSerialize()
    };
  }
}
