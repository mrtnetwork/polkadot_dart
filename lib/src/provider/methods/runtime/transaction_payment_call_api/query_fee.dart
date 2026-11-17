import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_info.dart';

/// Returns fee details for call bytes (TransactionPaymentCallApi `query_call_info`).
class SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo
    extends SubstrateRequest<String, QueryFeeInfo> {
  const SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo({
    required this.data,
    this.atBlockHash,
  });
  factory SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo.fromCallBytes({
    required List<int> call,
    String? atBlockHash,
  }) {
    final length = LayoutConst.u32().serialize(call.length);
    return SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo(
      data: BytesUtils.toHexString([...call, ...length], prefix: "0x"),
      atBlockHash: atBlockHash,
    );
  }

  final String? atBlockHash;
  final String? data;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["TransactionPaymentCallApi_query_call_info", data, atBlockHash];
  }

  @override
  QueryFeeInfo onResponse(String result) {
    return QueryFeeInfo.deserialize(BytesUtils.fromHexString(result));
  }
}
