import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_info.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo
    extends SubstrateRequest<String, QueryFeeInfo> {
  const SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo(
      {required this.data, this.atBlockHash});
  factory SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo.fromCallBytes(
      {required List<int> call, String? atBlockHash}) {
    final length = LayoutConst.u32().serialize(call.length);
    return SubstrateRequestRuntimeTransactionPaymentCallApiQueryCallInfo(
        data: BytesUtils.toHexString([...call, ...length], prefix: "0x"),
        atBlockHash: atBlockHash);
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
  QueryFeeInfo onResonse(String result) {
    return QueryFeeInfo.deserialize(BytesUtils.fromHexString(result));
  }
}
