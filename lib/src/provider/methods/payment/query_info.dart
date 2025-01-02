import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the fee information for an encoded extrinsic.
/// https://polkadot.js.org/docs/substrate/rpc/#payment
class SubstrateRequestPaymentQueryInfo
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestPaymentQueryInfo({
    required this.extrinsic,
    this.atBlockHash,
  });
  final String extrinsic;
  final String? atBlockHash;

  /// payment_queryInfo
  @override
  String get rpcMethod => SubstrateRequestMethods.queryInfo.value;

  @override
  List<dynamic> toJson() {
    return [extrinsic, atBlockHash];
  }
}
