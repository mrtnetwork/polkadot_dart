import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeTransactionPaymentApiQueryWeightToFee
    extends SubstrateRequest<String, BigInt> {
  final SubstrateWeightV2 weigth;
  const SubstrateRequestRuntimeTransactionPaymentApiQueryWeightToFee(
      {required this.weigth, this.atBlockHash});

  final String? atBlockHash;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return [
      "TransactionPaymentApi_query_weight_to_fee",
      weigth.toHex(prefix: "0x"),
      atBlockHash
    ];
  }

  @override
  BigInt onResonse(String result) {
    return LayoutConst.u128()
        .deserialize(BytesUtils.fromHexString(result))
        .value;
  }
}
