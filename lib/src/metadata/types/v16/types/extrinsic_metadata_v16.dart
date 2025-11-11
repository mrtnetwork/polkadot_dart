import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/extrinsic_metadata.dart';

import 'transaction_extension_metadata.dart';

class ExtrinsicMetadataV16 extends ExtrinsicMetadata {
  /// Extrinsic versions supported by the runtime.
  final List<int> versions;

  /// The type of the address that signs the extrinsic
  final int addressType;

  /// The type of the extrinsic's signature.
  final int signatureType;

  /// A mapping of supported transaction extrinsic versions to their respective transaction extension indexes.
  ///
  /// For each supported version number, list the indexes, in order, of the extensions used.
  final Map<int, List<int>> transactionExtensionsByVersion;

  /// The transaction extensions in the order they appear in the extrinsic.
  final List<TransactionExtensionMetadata> transactionExtensions;
  ExtrinsicMetadataV16({
    required this.addressType,
    required List<int> versions,
    required this.signatureType,
    required List<TransactionExtensionMetadata> transactionExtensions,
    required Map<int, List<int>> transactionExtensionsByVersion,
  })  : transactionExtensions = List<TransactionExtensionMetadata>.unmodifiable(
            transactionExtensions),
        transactionExtensionsByVersion = transactionExtensionsByVersion
            .map((k, v) => MapEntry(k, v.immutable))
            .immutable,
        versions = versions.immutable;
  ExtrinsicMetadataV16.deserializeJson(Map<String, dynamic> json)
      : transactionExtensions = List<TransactionExtensionMetadata>.unmodifiable(
            (json["transaction_extensions"] as List)
                .map((e) => TransactionExtensionMetadata.deserializeJson(e))),
        addressType = json["addressType"],
        signatureType = json["signatureType"],
        transactionExtensionsByVersion =
            (json["transaction_extensions_by_version"] as Map)
                .map((k, v) => MapEntry<int, List<int>>(
                    k, (v as List).cast<int>().immutable))
                .immutable,
        versions = (json["versions"] as List).cast<int>().immutable;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.extrinsicMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "versions": versions,
      "addressType": addressType,
      "signatureType": signatureType,
      "transaction_extensions":
          transactionExtensions.map((e) => e.serializeJson()).toList(),
      "transaction_extensions_by_version": transactionExtensionsByVersion
    };
  }
}
