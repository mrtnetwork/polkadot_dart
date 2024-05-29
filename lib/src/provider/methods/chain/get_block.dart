import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Get header and body of a relay chain block.
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainGetBlock extends SubstrateRPCRequest<dynamic, dynamic> {
  const SubstrateRPCChainGetBlock({this.atBlockHash});
  final String? atBlockHash;

  /// chain_getBlock
  @override
  String get rpcMethod => SubstrateRPCMethods.getBlock.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
