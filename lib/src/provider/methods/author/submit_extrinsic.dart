import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Submit a fully formatted extrinsic for block inclusion.
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRPCAuthorSubmitExtrinsic
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCAuthorSubmitExtrinsic(this.extrinsicHex);
  final String extrinsicHex;

  /// author_submitExtrinsic
  @override
  String get rpcMethod => SubstrateRPCMethods.submitExtrinsic.value;

  @override
  List<dynamic> toJson() {
    return [extrinsicHex];
  }
}
