import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Retrieves the fee information for an encoded extrinsic.
/// https://polkadot.js.org/docs/substrate/rpc/#payment
class SubstrateRPCPaymentQueryInfo
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCPaymentQueryInfo({
    required this.extrinsic,
    this.atBlockHash,
  });
  final String extrinsic;
  final String? atBlockHash;

  /// payment_queryInfo
  @override
  String get rpcMethod => SubstrateRPCMethods.queryInfo.value;

  @override
  List<dynamic> toJson() {
    return [extrinsic, atBlockHash];
  }
}
