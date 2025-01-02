import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the storage for a key
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestGetStorage extends SubstrateRequest<String?, String?> {
  const SubstrateRequestGetStorage(this.queryHex, {this.atBlockHash});

  final String queryHex;
  final String? atBlockHash;

  /// state_getStorage
  @override
  String get rpcMethod => SubstrateRequestMethods.stateGetStorage.value;

  @override
  List<dynamic> toJson() {
    return [queryHex, atBlockHash];
  }
}
