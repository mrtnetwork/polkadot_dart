import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Instructs the manual-seal authorship task to finalize a block
/// https://polkadot.js.org/docs/substrate/rpc/#engine
class SubstrateRPCEngineFinalizeBlock extends SubstrateRPCRequest<bool, bool> {
  const SubstrateRPCEngineFinalizeBlock(
      {required this.hash, this.justification});

  final String hash;
  final String? justification;

  /// SubstrateRPCMethods
  @override
  String get rpcMethod => SubstrateRPCMethods.finalizeBlock.value;

  @override
  List<dynamic> toJson() {
    return [hash, justification];
  }
}
// createBlock(createEmpty: bool, finalize: bool, parentHash?: BlockHash): CreatedBlock
