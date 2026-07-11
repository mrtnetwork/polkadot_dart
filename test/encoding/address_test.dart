import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';
import 'package:test/test.dart';

void main() {
  test('IAddress encoding', () {
    final addr = SubstrateAddress.fromBytes(
      QuickCrypto.generateRandom(32),
      ss58Format: SS58Const.acala,
    );
    expect(
      BaseSubstrateAddress.deserializeIAddress(bytes: addr.encodeAsIAddress()),
      addr,
    );
  });
  test('IAddress encoding', () {
    final addr = SubstrateEthereumAddress.fromBytes(
      QuickCrypto.generateRandom(20),
    );
    expect(
      BaseSubstrateAddress.deserializeIAddress(bytes: addr.encodeAsIAddress()),
      addr,
    );
  });
}
