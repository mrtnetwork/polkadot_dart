import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/error/substrate_error.dart';
import 'package:polkadot_dart/src/substrate.dart';
import 'package:test/test.dart' show test, expect, equals;

import '../utils.dart';

void exceptionTest() {
  test('Exception serialization', () {
    BuErrorCodec.registerTypes(SubstrateErrorType.values);
    {
      final error = BuError(
        SubstrateErrorType.plugin,
        "error",
        details: {"length": "32"},
      );
      final decode = BuErrorCodec.decode(bytes: error.toCborBytes());
      expect(decode.type, SubstrateErrorType.plugin);
      expect(decode.message, "error");
      expect(decode.details, {"length": "32"});
    }
    {
      final error = BuError(
        SubstrateErrorType.metadata,
        "error",
        details: {"length": "32"},
      );
      final decode = BuErrorCodec.decode(bytes: error.toCborBytes());
      expect(decode.type, SubstrateErrorType.metadata);
      expect(decode.message, "error");
    }
    {
      // Canonical const sentinels keep identity for == checks.
      expect(
        identical(
          SubstrateLookupBlockExceptionConst.blockNotFound,
          SubstrateLookupBlockExceptionConst.blockNotFound,
        ),
        equals(true),
      );
      final ids = SubstrateErrorType.values.map((e) => e.id);
      expect(ids.toSet().length, SubstrateErrorType.values.length);
      for (final id in ids) {
        expect(id > 258, equals(true));
      }
    }
  });
}

void main() {
  PolkadotDartUtilsTestApi.runTest(exceptionTest, "Exception");
}
