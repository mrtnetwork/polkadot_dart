import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Query storage entries (by key) starting at block hash given as the second parameter
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCQuerStateStorageAt
    extends SubstrateRPCRequest<List<dynamic>, List<dynamic>> {
  const SubstrateRPCQuerStateStorageAt(this.keys, {this.atBlockHash});
  final List<String> keys;
  final String? atBlockHash;

  /// state_queryStorageAt
  @override
  String get rpcMethod => SubstrateRPCMethods.queryStorageAt.value;

  @override
  List<dynamic> toJson() {
    return [keys, atBlockHash];
  }
}
