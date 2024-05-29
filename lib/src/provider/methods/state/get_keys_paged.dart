import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns the keys with prefix with pagination support.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetKeysPaged
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCStateGetKeysPaged({
    required this.key,
    required this.count,
    this.startKey,
    this.atBlockHash,
  });
  final String key;
  final int count;
  final String? startKey;
  final String? atBlockHash;

  /// state_getKeysPaged
  @override
  String get rpcMethod => SubstrateRPCMethods.stateGetKeysPaged.value;

  @override
  List<dynamic> toJson() {
    return [key, count, startKey, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
