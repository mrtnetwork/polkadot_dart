import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/layout/utils/utils.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_fee_info.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails
    extends SubstrateRequest<String, QueryFeeDetails> {
  const SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails(
      {required this.data, this.atBlockHash});
  factory SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails.fromExtrinsic(
      {required List<int> exirceBytes, String? atBlockHash}) {
    final length = LayoutConst.u32().serialize(exirceBytes.length);
    final data = [
      ...LayoutSerializationUtils.encodeLength(exirceBytes),
      ...exirceBytes,
      ...length
    ];
    return SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails(
        data: BytesUtils.toHexString(data, prefix: "0x"),
        atBlockHash: atBlockHash);
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
  QueryFeeDetails onResonse(String result) {
    return QueryFeeDetails.deserialize(BytesUtils.fromHexString(result));
  }
}
