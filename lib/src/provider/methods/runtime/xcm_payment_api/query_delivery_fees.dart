import 'package:polkadot_dart/src/provider/core/core.dart';

/// Returns delivery fees for an XCM message (XcmPaymentApi `query_delivery_fees`).
class SubstrateRequestRuntimeXCMPaymentApiQueryDeliveryFees
    extends SubstrateRequest<String, String> {
  const SubstrateRequestRuntimeXCMPaymentApiQueryDeliveryFees({
    required this.data,
    this.atBlockHash,
  });

  final String? atBlockHash;
  final String? data;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["XcmPaymentApi_query_delivery_fees", data, atBlockHash];
  }
}
