import 'package:polkadot_dart/src/keypair/core/keypair.dart';

abstract mixin class SubstrateTransactionSigner {
  Future<List<int>> signAsync(List<int> digest);
  SubstrateKeyAlgorithm get algorithm;
}
