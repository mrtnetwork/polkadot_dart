import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Instructs the manual-seal authorship task to finalize a block
/// https://polkadot.js.org/docs/substrate/rpc/#engine
class SubstrateRequestEngineFinalizeBlock extends SubstrateRequest<bool, bool> {
  const SubstrateRequestEngineFinalizeBlock(
      {required this.hash, this.justification});

  final String hash;
  final String? justification;

  /// SubstrateRequestMethods
  @override
  String get rpcMethod => SubstrateRequestMethods.finalizeBlock.value;

  @override
  List<dynamic> toJson() {
    return [hash, justification];
  }
}
// createBlock(createEmpty: bool, finalize: bool, parentHash?: BlockHash): CreatedBlock
