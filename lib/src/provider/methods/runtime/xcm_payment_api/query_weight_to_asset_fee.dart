import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/models/generic/models/weight.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeXCMPaymentApiQueryWeightToAssetFee
    extends SubstrateRequest<String, String> {
  const SubstrateRequestRuntimeXCMPaymentApiQueryWeightToAssetFee(
      {required this.data, this.atBlockHash});
  factory SubstrateRequestRuntimeXCMPaymentApiQueryWeightToAssetFee.encode(
      {required SubstrateWeightV2 weight,
      required XCMVersionedAssetId asset,
      String? atBlockHash}) {
    final data = [
      ...weight.serialize(),
      ...asset.serializeVariant(),
    ];
    return SubstrateRequestRuntimeXCMPaymentApiQueryWeightToAssetFee(
        data: BytesUtils.toHexString(data, prefix: "0x"),
        atBlockHash: atBlockHash);
  }

  final String? atBlockHash;
  final String? data;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["XcmPaymentApi_query_weight_to_asset_fee", data, atBlockHash];
  }
}
