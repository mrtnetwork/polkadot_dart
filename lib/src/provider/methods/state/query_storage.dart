import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Query historical storage entries (by key) starting from a start block
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateQueryStorage
    extends SubstrateRPCRequest<List<dynamic>, List<dynamic>> {
  const SubstrateRPCStateQueryStorage(
      {required this.keys, required this.fromBlock, this.toBlock});
  final List<String> keys;
  final String fromBlock;
  final String? toBlock;

  /// state_queryStorage
  @override
  String get rpcMethod => SubstrateRPCMethods.queryStorage.value;

  @override
  List<dynamic> toJson() {
    return [keys, fromBlock, toBlock];
  }
}
