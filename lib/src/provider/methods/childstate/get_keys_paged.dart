import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the keys with prefix from a child storage with pagination support
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRPCChildStateGetKeysPaged
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCChildStateGetKeysPaged({
    required this.childKey,
    required this.prefix,
    required this.count,
    this.startKey,
    this.atBlockHash,
  });
  final String childKey;
  final String prefix;
  final int count;
  final String? startKey;
  final String? atBlockHash;

  /// childstate_getKeysPaged
  @override
  String get rpcMethod => SubstrateRPCMethods.getKeysPaged.value;

  @override
  List<dynamic> toJson() {
    return [childKey, prefix, count, startKey, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
