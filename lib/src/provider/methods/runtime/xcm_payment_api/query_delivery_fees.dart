import 'package:polkadot_dart/src/provider/core/core.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeXCMPaymentApiQueryDeliveryFees
    extends SubstrateRequest<String, String> {
  const SubstrateRequestRuntimeXCMPaymentApiQueryDeliveryFees(
      {required this.data, this.atBlockHash});

  final String? atBlockHash;
  final String? data;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["XcmPaymentApi_query_delivery_fees", data, atBlockHash];
  }
}
