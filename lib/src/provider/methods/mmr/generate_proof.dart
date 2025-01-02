import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Generate MMR proof for the given block numbers.
/// https://polkadot.js.org/docs/substrate/rpc/#mmr
class SubstrateRequestMMRGenerateProof
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestMMRGenerateProof(
      {required this.blockNumbers,
      this.bestKnownBlockNumber,
      this.atBlockHash});
  final List<int> blockNumbers;
  final int? bestKnownBlockNumber;

  final String? atBlockHash;

  /// mmr_generateProof
  @override
  String get rpcMethod => SubstrateRequestMethods.generateProof.value;

  @override
  List<dynamic> toJson() {
    return [blockNumbers, bestKnownBlockNumber, atBlockHash];
  }
}
