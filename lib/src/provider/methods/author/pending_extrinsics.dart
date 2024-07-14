import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns all pending extrinsics, potentially grouped by sender
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRPCAuthorPendingExtrinsics
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCAuthorPendingExtrinsics();

  /// author_pendingExtrinsics
  @override
  String get rpcMethod => SubstrateRPCMethods.pendingExtrinsics.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
