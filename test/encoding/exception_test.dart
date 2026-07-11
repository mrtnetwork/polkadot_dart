import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/substrate.dart';
import 'package:test/test.dart' show test, expect;

void main() {
  test('Exception serialization', () {
    {
      final error = DartSubstratePluginException(
        "error",
        details: {"length": "32"},
      );
      final decode = BaseDartSubstratePluginException.deserialize(
        bytes: error.toCbor().encode(),
      );
      expect(decode, error);
    }
    {
      final error = MetadataException("error", details: {"length": "32"});
      final decode = BaseDartSubstratePluginException.deserialize(
        bytes: error.toCbor().encode(),
      );
      expect(decode, error);
    }
  });
}
