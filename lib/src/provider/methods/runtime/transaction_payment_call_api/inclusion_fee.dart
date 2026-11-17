import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_fee_info.dart';

/// Returns inclusion fee details for call bytes (TransactionPaymentCallApi `query_call_fee_details`).
class SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallFeeDetails
    extends SubstrateRequest<String, QueryFeeDetails> {
  const SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallFeeDetails({
    required this.data,
    this.atBlockHash,
  });
  factory SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallFeeDetails.fromCallBytes({
    required List<int> callBytes,
    String? atBlockHash,
  }) {
    final length = LayoutConst.u32().serialize(callBytes.length);
    final data = [...callBytes, ...length];
    return SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallFeeDetails(
      data: BytesUtils.toHexString(data, prefix: "0x"),
      atBlockHash: atBlockHash,
    );
  }

  final String? atBlockHash;
  final String? data;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return [
      "TransactionPaymentCallApi_query_call_fee_details",
      data,
      atBlockHash,
    ];
  }

  @override
  QueryFeeDetails onResponse(String result) {
    return QueryFeeDetails.deserialize(BytesUtils.fromHexString(result));
  }
}
