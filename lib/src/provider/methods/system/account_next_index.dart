import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the next accountIndex as available on the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestAccountNextIndex extends SubstrateRequest<int, int> {
  const SubstrateRequestAccountNextIndex(this.address);
  final String address;

  /// system_accountNextIndex
  @override
  String get rpcMethod => SubstrateRequestMethods.accountNextIndex.value;

  @override
  List<dynamic> toJson() {
    return [address];
  }
}
