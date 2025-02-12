import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/payment/fee_details.dart';

/// Query the detailed fee of a given encoded extrinsic.
/// https://polkadot.js.org/docs/substrate/rpc/#payment
class SubstrateRequestPaymentQueryFeeDetails
    extends SubstrateRequest<Map<String, dynamic>, FeeDetails> {
  const SubstrateRequestPaymentQueryFeeDetails({
    required this.extrinsic,
    this.atBlockHash,
  });
  final String extrinsic;
  final String? atBlockHash;

  /// payment_queryFeeDetails
  @override
  String get rpcMethod => SubstrateRequestMethods.queryFeeDetails.value;

  @override
  List<dynamic> toJson() {
    return [extrinsic, atBlockHash];
  }

  @override
  FeeDetails onResonse(Map<String, dynamic> result) {
    return FeeDetails.fromJson(result);
  }
}
