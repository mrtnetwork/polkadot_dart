import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/imp/metadata_interface.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/unsuported_metadata.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/metadata_v15.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class VersionedMetadata<T extends SubstrateMetadata>
    extends SubstrateSerialization<Map<String, dynamic>> {
  final T metadata;
  final int version;
  final int magicNumber;
  const VersionedMetadata(
      {required this.metadata,
      required this.version,
      required this.magicNumber});
  factory VersionedMetadata.fromHex(String metadataHex) {
    return VersionedMetadata.fromBytes(BytesUtils.fromHexString(metadataHex));
  }
  factory VersionedMetadata.fromBytes(List<int> bytes) {
    if (bytes.length < MetadataConstant.metadataMagicNumberAndVersionLength) {
      throw MetadataException("Invalid metadata bytes");
    }
    final getNumber = SubstrateMetadataLayouts.metadataMagicAndVersion()
        .deserialize(bytes.sublist(
            0, MetadataConstant.metadataMagicNumberAndVersionLength))
        .value;
    final int version = getNumber["version"];
    final int magicNumber = getNumber["magicNumber"];
    final List<int> metadataBytes =
        bytes.sublist(MetadataConstant.metadataMagicNumberAndVersionLength);
    final SubstrateMetadata metadata;
    if (!MetadataConstant.supportedMetadataVersion.contains(version)) {
      metadata = UnsupportedMetadata(version: version, bytes: metadataBytes);
    } else {
      switch (version) {
        case 14:
          metadata = MetadataV14.fromBytes(metadataBytes);
          break;
        default:
          metadata = MetadataV15.fromBytes(metadataBytes);
          break;
      }
    }
    if (metadata is! T) {
      throw MessageException("Incorrect metadata version.",
          details: {"excepted": "$T", "version": "$version"});
    }
    return VersionedMetadata(
        metadata: metadata, version: version, magicNumber: magicNumber);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.versionedMetadata(
        metadata.layout(property: "metadata"),
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "version": version,
      "metadata": metadata.scaleJsonSerialize(),
      "magicNumber": magicNumber
    };
  }

  bool get supportedByApi =>
      MetadataConstant.supportedMetadataVersion.contains(version);

  MetadataApi toApi() {
    if (!supportedByApi) {
      throw MetadataException("metadata does not supported by API", details: {
        "version": version,
        "api_support_versions":
            MetadataConstant.supportedMetadataVersion.join(", ")
      });
    }
    return MetadataApi(metadata as LatestMetadataInterface);
  }
}
