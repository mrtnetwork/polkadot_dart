import 'package:polkadot_dart/src/models/generic/models/hash.dart';

class SubstrateBlockHash extends SubstrateHash256 {
  SubstrateBlockHash(List<int> bytes) : super(bytes);
  SubstrateBlockHash.hash(String blockHashHex) : super.fromHex(blockHashHex);
}
