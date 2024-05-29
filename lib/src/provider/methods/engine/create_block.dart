import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Instructs the manual-seal authorship task to create a new block
/// https://polkadot.js.org/docs/substrate/rpc/#engine
class SubstrateRPCEngineCreateBlock
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCEngineCreateBlock(
      {required this.createEmpty, required this.finalize, this.parentHash});
  final bool createEmpty;
  final bool finalize;
  final String? parentHash;

  /// engine_createBlock
  @override
  String get rpcMethod => SubstrateRPCMethods.createBlock.value;

  @override
  List<dynamic> toJson() {
    return [createEmpty, finalize, parentHash];
  }
}
// createBlock(createEmpty: bool, finalize: bool, parentHash?: BlockHash): CreatedBlock