import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_fee_info.dart';

/// Returns inclusion fee details for an extrinsic (TransactionPaymentApi `query_fee_details`).
class SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails
    extends SubstrateRequest<String, QueryFeeDetails> {
  const SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails({
    required this.data,
    this.atBlockHash,
  });
  factory SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails.fromExtrinsic({
    required List<int> extrinsicBytes,
    String? atBlockHash,
  }) {
    final length = LayoutConst.u32().serialize(extrinsicBytes.length);
    final data = [
      ...LayoutSerializationUtils.encodeLength(
        extrinsicBytes.length.toString(),
      ),
      ...extrinsicBytes,
      ...length,
    ];
    return SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails(
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
    return ["TransactionPaymentApi_query_fee_details", data, atBlockHash];
  }

  @override
  QueryFeeDetails onResponse(String result) {
    return QueryFeeDetails.deserialize(BytesUtils.fromHexString(result));
  }
}
