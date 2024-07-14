import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/layout/utils/utils.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/models/modesl.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/runtime/query_fee_info.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRPCRuntimeTransactionPaymentApiQueryFeeDetails
    extends SubstrateRPCRequest<String, QueryFeeInfoFrame> {
  const SubstrateRPCRuntimeTransactionPaymentApiQueryFeeDetails(
      {required this.data, this.atBlockHash});
  factory SubstrateRPCRuntimeTransactionPaymentApiQueryFeeDetails.fromExtrinsic(
      {required Extrinsic exirce, String? atBlockHash}) {
    final exirceBytes = exirce.serialize(encodeLength: false);
    final length = LayoutConst.u32().serialize(exirceBytes.length);
    final data = [
      ...LayoutSerializationUtils.encodeLength(exirceBytes),
      ...exirceBytes,
      ...length
    ];
    return SubstrateRPCRuntimeTransactionPaymentApiQueryFeeDetails(
        data: BytesUtils.toHexString(data, prefix: "0x"),
        atBlockHash: atBlockHash);
  }

  final String? atBlockHash;
  final String? data;

  @override
  String get rpcMethod => SubstrateRPCMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["TransactionPaymentApi_query_fee_details", data, atBlockHash];
  }

  @override
  QueryFeeInfoFrame onResonse(String result) {
    return QueryFeeInfoFrame.deserialize(BytesUtils.fromHexString(result));
  }
}
