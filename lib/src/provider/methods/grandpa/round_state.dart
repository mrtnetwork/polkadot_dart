import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the state of the current best round state
/// as well as the ongoing background rounds
/// https://polkadot.js.org/docs/substrate/rpc/#grandpa
class SubstrateRequestGrandpaRoundState
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestGrandpaRoundState();

  /// grandpa_roundState
  @override
  String get rpcMethod => SubstrateRequestMethods.roundState.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
