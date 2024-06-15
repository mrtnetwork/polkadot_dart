import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:test/test.dart';
import 'v14_metadata_hex.dart';
import 'v12_metadata_hex.dart';
import 'v15_metadata_hex.dart';

void main() {
  group("Metadata", () {
    _encodeDecode();
  });
}

void _encodeDecode() {
  test("V15 Encode and Decode", () {
    final metadataBytesV15 = BytesUtils.fromHexString(metadataV15);
    final VersionedMetadata<MetadataV15> metadata =
        VersionedMetadata.fromBytes(metadataBytesV15);
    final encode = metadata.serialize();
    expect(encode, metadataBytesV15);
    expect(metadata.version, 15);
    expect(metadata.supportedByApi, true);
  });
  test("V14 Encode and Decode", () {
    final metadataBytesV14 = BytesUtils.fromHexString(metadataV14);
    final VersionedMetadata<MetadataV14> metadata =
        VersionedMetadata.fromBytes(metadataBytesV14);
    final encode = metadata.serialize();
    expect(encode, metadataBytesV14);
    expect(metadata.version, 14);
    expect(metadata.supportedByApi, true);
  });
  test("V12-Unsuported Encode and Decode", () {
    final metadataBytesV12 = BytesUtils.fromHexString(metadataV12);
    final VersionedMetadata<UnsupportedMetadata> metadata =
        VersionedMetadata.fromBytes(metadataBytesV12);
    final encode = metadata.serialize();
    expect(encode, metadataBytesV12);
    expect(metadata.version, 12);
    expect(metadata.supportedByApi, false);
  });
}
