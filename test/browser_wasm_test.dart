@TestOn('browser')
@Tags(['wasm'])
library;

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';
import 'package:test/test.dart';

import 'utils.dart';

void browserWasmTest() {
  setUpAll(() async {
    // Shared harness: injects the glue script (served by the dart-test
    // static handler from test/wasm_assets/), waits for bootstrap, then
    // selects the Rust backend. No .so involved.
    await PolkadotDartUtilsTestApi.initWasmBrowser();
  });

  group('wasm backend smoke (polkadot_dart)', () {
    test('sha256 empty (shared backend)', () {
      expect(
        BytesUtils.toHexString(QuickCrypto.sha256Hash([])),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });
    test('substrate IAddress roundtrip', () {
      final addr = SubstrateAddress.fromBytes(
        QuickCrypto.generateRandom(length: 32),
        ss58Format: SS58Const.acala,
      );
      expect(
        BaseSubstrateAddress.deserializeIAddress(bytes: addr.encodeAsIAddress()),
        addr,
      );
    });
  });
}

void main() {
  PolkadotDartUtilsTestApi.runTest(browserWasmTest, "Browser Wasm");
}
