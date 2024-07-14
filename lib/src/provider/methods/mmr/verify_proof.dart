import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Verify an MMR proof.
/// https://polkadot.js.org/docs/substrate/rpc/#mmr
class SubstrateRPCMMRVerifyProof extends SubstrateRPCRequest<bool, bool> {
  const SubstrateRPCMMRVerifyProof(this.proof);
  final String proof;

  /// mmr_verifyProof
  @override
  String get rpcMethod => SubstrateRPCMethods.verifyProof.value;

  @override
  List<dynamic> toJson() {
    return [proof];
  }
}
