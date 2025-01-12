import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/signed_extension_metadata.dart';

class TransactionExtensionMetadata extends SignedExtensionMetadata {
  final int implicit;
  TransactionExtensionMetadata.deserializeJson(super.json)
      : implicit = json["implicit"],
        super.deserializeJson();
  TransactionExtensionMetadata(
      {required super.identifier, required super.type, required this.implicit});
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.transactionExtensionMetadata(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      ...super.scaleJsonSerialize(property: property),
      "implicit": implicit
    };
  }
}
