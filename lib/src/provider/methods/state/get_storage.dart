import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the storage for a key
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCGetStorage extends SubstrateRPCRequest<String?, String?> {
  const SubstrateRPCGetStorage(this.queryHex, {this.atBlockHash});

  final String queryHex;
  final String? atBlockHash;

  /// state_getStorage
  @override
  String get rpcMethod => SubstrateRPCMethods.stateGetStorage.value;

  @override
  List<dynamic> toJson() {
    return [queryHex, atBlockHash];
  }
}
