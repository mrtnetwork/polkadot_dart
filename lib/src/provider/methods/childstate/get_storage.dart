import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns a child storage entry at a specific block state
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRPCChildStateGetStorage
    extends SubstrateRPCRequest<String?, String?> {
  const SubstrateRPCChildStateGetStorage(
      {required this.childKey, required this.key, this.atBlockHash});

  final String childKey;
  final String key;
  final String? atBlockHash;

  /// childstate_getStorage
  @override
  String get rpcMethod => SubstrateRPCMethods.getStorage.value;

  @override
  List<dynamic> toJson() {
    return [childKey, key, atBlockHash];
  }
}
