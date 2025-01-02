import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Submit and subscribe to watch an extrinsic until unsubscribed.
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRequestAuthorSubmitAndWatchExtrinsic
    extends SubstrateRequest<dynamic, dynamic> {
  const SubstrateRequestAuthorSubmitAndWatchExtrinsic(this.extrinsicHex);
  final String extrinsicHex;

  /// author_submitAndWatchExtrinsic
  @override
  String get rpcMethod => SubstrateRequestMethods.submitAndWatchExtrinsic.value;

  @override
  List<dynamic> toJson() {
    return [extrinsicHex];
  }
}
