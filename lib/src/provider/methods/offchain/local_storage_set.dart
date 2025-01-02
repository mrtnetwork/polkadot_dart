import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Set offchain local storage under given key and prefix
/// https://polkadot.js.org/docs/substrate/rpc/#offchain
class SubstrateRequestOffChainLocalStorageSet
    extends SubstrateRequest<Null, Null> {
  const SubstrateRequestOffChainLocalStorageSet({
    required this.kind,
    required this.key,
  });
  final String kind;
  final String key;

  /// offchain_localStorageSet
  @override
  String get rpcMethod => SubstrateRequestMethods.localStorageSet.value;

  @override
  List<dynamic> toJson() {
    return [kind, key];
  }

  @override
  Null onResonse(Null result) {
    return null;
  }
}
//localStorageGet(kind: StorageKind, key: Bytes): Option<Bytes>
