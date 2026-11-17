import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_event_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/enum_deprecation_info.dart';

class PalletEventMetadataV16 extends PalletEventMetadata {
  @override
  final int type;
  final EnumDeprecationInfo deprecationInfo;
  const PalletEventMetadataV16({
    required this.type,
    required this.deprecationInfo,
  });
  PalletEventMetadataV16.deserializeJson(Map<String, dynamic> json)
    : type = json["type"],
      deprecationInfo = EnumDeprecationInfo.deserializeJson(
        json["deprecation_info"],
      );

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletEventMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"type": type, "deprecation_info": deprecationInfo.serializeJson()};
  }
}
