import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Prove finality for the given block number,
/// returning the Justification for the last block in the set.
/// https://polkadot.js.org/docs/substrate/rpc/#grandpa
class SubstrateRequestGrandpaProveFinality
    extends SubstrateRequest<String?, String?> {
  const SubstrateRequestGrandpaProveFinality(this.blockNumber);
  final int blockNumber;

  /// grandpa_proveFinality
  @override
  String get rpcMethod => SubstrateRequestMethods.proveFinality.value;

  @override
  List<dynamic> toJson() {
    return [blockNumber];
  }
}
