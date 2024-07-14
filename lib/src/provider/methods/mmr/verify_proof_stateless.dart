import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Verify an MMR proof statelessly given an mmr_root.
/// https://polkadot.js.org/docs/substrate/rpc/#mmr
class SubstrateRPCMMRVerifyProofStateless
    extends SubstrateRPCRequest<bool, bool> {
  const SubstrateRPCMMRVerifyProofStateless(
      {required this.root, required this.proof});
  final String root;
  final String proof;

  /// mmr_verifyProofStateless
  @override
  String get rpcMethod => SubstrateRPCMethods.verifyProofStateless.value;

  @override
  List<dynamic> toJson() {
    return [root, proof];
  }
}
