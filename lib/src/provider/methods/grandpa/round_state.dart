import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the state of the current best round state
/// as well as the ongoing background rounds
/// https://polkadot.js.org/docs/substrate/rpc/#grandpa
class SubstrateRPCGrandpaRoundState
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCGrandpaRoundState();

  /// grandpa_roundState
  @override
  String get rpcMethod => SubstrateRPCMethods.roundState.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
