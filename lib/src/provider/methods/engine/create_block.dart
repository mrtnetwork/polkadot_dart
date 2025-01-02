import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Instructs the manual-seal authorship task to create a new block
/// https://polkadot.js.org/docs/substrate/rpc/#engine
class SubstrateRequestEngineCreateBlock
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestEngineCreateBlock(
      {required this.createEmpty, required this.finalize, this.parentHash});
  final bool createEmpty;
  final bool finalize;
  final String? parentHash;

  /// engine_createBlock
  @override
  String get rpcMethod => SubstrateRequestMethods.createBlock.value;

  @override
  List<dynamic> toJson() {
    return [createEmpty, finalize, parentHash];
  }
}
// createBlock(createEmpty: bool, finalize: bool, parentHash?: BlockHash): CreatedBlock
