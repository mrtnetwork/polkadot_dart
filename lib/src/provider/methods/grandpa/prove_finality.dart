import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Prove finality for the given block number,
/// returning the Justification for the last block in the set.
/// https://polkadot.js.org/docs/substrate/rpc/#grandpa
class SubstrateRPCGrandpaProveFinality
    extends SubstrateRPCRequest<String?, String?> {
  const SubstrateRPCGrandpaProveFinality(this.blockNumber);
  final int blockNumber;

  /// grandpa_proveFinality
  @override
  String get rpcMethod => SubstrateRPCMethods.proveFinality.value;

  @override
  List<dynamic> toJson() {
    return [blockNumber];
  }
}
