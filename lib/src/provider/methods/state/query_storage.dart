import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Query historical storage entries (by key) starting from a start block
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateQueryStorage
    extends SubstrateRequest<List<dynamic>, List<dynamic>> {
  const SubstrateRequestStateQueryStorage(
      {required this.keys, required this.fromBlock, this.toBlock});
  final List<String> keys;
  final String fromBlock;
  final String? toBlock;

  /// state_queryStorage
  @override
  String get rpcMethod => SubstrateRequestMethods.queryStorage.value;

  @override
  List<dynamic> toJson() {
    return [keys, fromBlock, toBlock];
  }
}
