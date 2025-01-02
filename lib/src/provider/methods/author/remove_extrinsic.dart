import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Remove given extrinsic from the pool and temporarily ban it to prevent reimporting
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRequestAuthorRemoveExtrinsic
    extends SubstrateRequest<List<dynamic>, List<String>> {
  const SubstrateRequestAuthorRemoveExtrinsic(this.hash);
  final List<String> hash;

  /// author_removeExtrinsic
  @override
  String get rpcMethod => SubstrateRequestMethods.removeExtrinsic.value;

  @override
  List<dynamic> toJson() {
    return [hash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
