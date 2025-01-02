import 'package:polkadot_dart/src/models/generic/models/hash.dart';

class SubstrateBlockHash extends SubstrateHash256 {
  SubstrateBlockHash(super.bytes);
  SubstrateBlockHash.hash(super.blockHashHex) : super.fromHex();
}
