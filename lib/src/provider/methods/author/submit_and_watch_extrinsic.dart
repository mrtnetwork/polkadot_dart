import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Submit and subscribe to watch an extrinsic until unsubscribed.
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRPCAuthorSubmitAndWatchExtrinsic
    extends SubstrateRPCRequest<dynamic, dynamic> {
  const SubstrateRPCAuthorSubmitAndWatchExtrinsic(this.extrinsicHex);
  final String extrinsicHex;

  /// author_submitAndWatchExtrinsic
  @override
  String get rpcMethod => SubstrateRPCMethods.submitAndWatchExtrinsic.value;

  @override
  List<dynamic> toJson() {
    return [extrinsicHex];
  }
}
