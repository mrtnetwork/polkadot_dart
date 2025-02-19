import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Get offchain local storage under given key and prefix
/// https://polkadot.js.org/docs/substrate/rpc/#offchain
class SubstrateRequestOffChainLocalStorageGet
    extends SubstrateRequest<String?, String?> {
  const SubstrateRequestOffChainLocalStorageGet({
    required this.kind,
    required this.key,
  });
  final String kind;
  final String key;

  /// offchain_localStorageGet
  @override
  String get rpcMethod => SubstrateRequestMethods.localStorageGet.value;

  @override
  List<dynamic> toJson() {
    return [kind, key];
  }
}
//localStorageGet(kind: StorageKind, key: Bytes): Option<Bytes>
