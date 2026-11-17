import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_error_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/enum_deprecation_info.dart';

class PalletErrorMetadataV16 extends PalletErrorMetadata {
  /// The error type information.
  @override
  final int type;

  /// Deprecation info
  final EnumDeprecationInfo deprecationInfo;
  const PalletErrorMetadataV16({
    required this.type,
    required this.deprecationInfo,
  });
  PalletErrorMetadataV16.deserializeJson(Map<String, dynamic> json)
    : type = json["type"],
      deprecationInfo = EnumDeprecationInfo.deserializeJson(
        json["deprecation_info"],
      );

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletErrorMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"type": type, "deprecation_info": deprecationInfo.serializeJson()};
  }
}
