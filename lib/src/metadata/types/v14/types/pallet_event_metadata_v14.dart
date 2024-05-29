import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class PalletEventMetadataV14
    extends SubstrateSerialization<Map<String, dynamic>> {
  final int type;
  const PalletEventMetadataV14(this.type);
  PalletEventMetadataV14.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletEventMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"type": type};
  }
}
