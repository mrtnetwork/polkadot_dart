import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Get the block hash for a specific block.
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainGetBlockHash<T extends String?>
    extends SubstrateRequest<T, T> {
  const SubstrateRequestChainGetBlockHash({this.number});
  final int? number;

  /// chain_getBlockHash
  @override
  String get rpcMethod => SubstrateRequestMethods.getBlockHash.value;

  @override
  List<dynamic> toJson() {
    return [number];
  }
}
