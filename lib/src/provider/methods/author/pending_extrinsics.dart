import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns all pending extrinsics, potentially grouped by sender
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRequestAuthorPendingExtrinsics
    extends SubstrateRequest<List<dynamic>, List<String>> {
  const SubstrateRequestAuthorPendingExtrinsics();

  /// author_pendingExtrinsics
  @override
  String get rpcMethod => SubstrateRequestMethods.pendingExtrinsics.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
