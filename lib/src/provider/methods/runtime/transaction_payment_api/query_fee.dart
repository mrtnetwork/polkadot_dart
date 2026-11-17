import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_info.dart';

/// Returns fee details for an extrinsic (TransactionPaymentApi `query_info`).
class SubstrateRequestRuntimeTransactionPaymentApiQueryInfo
    extends SubstrateRequest<String, QueryFeeInfo> {
  const SubstrateRequestRuntimeTransactionPaymentApiQueryInfo({
    required this.data,
    this.atBlockHash,
  });
  factory SubstrateRequestRuntimeTransactionPaymentApiQueryInfo.fromExtrinsic({
    required List<int> extrinsicBytes,
    String? atBlockHash,
  }) {
    final length = LayoutConst.u32().serialize(extrinsicBytes.length);
    final data = [...extrinsicBytes, ...length];
    return SubstrateRequestRuntimeTransactionPaymentApiQueryInfo(
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
    return ["TransactionPaymentApi_query_info", data, atBlockHash];
  }

  @override
  QueryFeeInfo onResponse(String result) {
    return QueryFeeInfo.deserialize(BytesUtils.fromHexString(result));
  }
}
