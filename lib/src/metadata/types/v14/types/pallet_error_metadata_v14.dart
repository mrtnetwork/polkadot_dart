import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class PalletErrorMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  /// The error type information.
  abstract final int type;
  const PalletErrorMetadata();
}

class PalletErrorMetadataV14 extends PalletErrorMetadata {
  /// The error type information.
  @override
  final int type;
  const PalletErrorMetadataV14(this.type);
  PalletErrorMetadataV14.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletErrorMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"type": type};
  }
}
