import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Get the block hash for a specific block.
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainGetBlockHash
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCChainGetBlockHash({this.number});
  final int? number;

  /// chain_getBlockHash
  @override
  String get rpcMethod => SubstrateRPCMethods.getBlockHash.value;

  @override
  List<dynamic> toJson() {
    return [number];
  }
}
