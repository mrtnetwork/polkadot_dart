import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Verify an MMR proof.
/// https://polkadot.js.org/docs/substrate/rpc/#mmr
class SubstrateRequestMMRVerifyProof extends SubstrateRequest<bool, bool> {
  const SubstrateRequestMMRVerifyProof(this.proof);
  final String proof;

  /// mmr_verifyProof
  @override
  String get rpcMethod => SubstrateRequestMethods.verifyProof.value;

  @override
  List<dynamic> toJson() {
    return [proof];
  }
}
