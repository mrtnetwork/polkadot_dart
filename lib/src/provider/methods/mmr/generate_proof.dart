import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Generate MMR proof for the given block numbers.
/// https://polkadot.js.org/docs/substrate/rpc/#mmr
class SubstrateRPCMMRGenerateProof
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCMMRGenerateProof(
      {required this.blockNumbers,
      this.bestKnownBlockNumber,
      this.atBlockHash});
  final List<int> blockNumbers;
  final int? bestKnownBlockNumber;

  final String? atBlockHash;

  /// mmr_generateProof
  @override
  String get rpcMethod => SubstrateRPCMethods.generateProof.value;

  @override
  List<dynamic> toJson() {
    return [blockNumbers, bestKnownBlockNumber, atBlockHash];
  }
}
