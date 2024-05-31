import 'package:blockchain_utils/binary/utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/provider/methods/state/call.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

extension RuntimeCallHelper on MetadataApi {
  Future<T> runtimeCall<T>(
      {required String apiName,
      required String methodName,
      required List<Object?> params,
      required SubstrateRPC rpc,
      bool fromTemplate = true}) async {
    final method = getRuntimeApiMethod(apiName, methodName);
    final encode = encodeRuntimeApiInputs(
        apiName: apiName,
        methodName: methodName,
        params: params,
        fromTemplate: fromTemplate);
    final rpcMethod = SubstrateRPCStateCall(
        method: method, data: BytesUtils.toHexString(encode, prefix: "0x"));
    final response = await rpc.request(rpcMethod);
    return decodeRuntimeApiOutput(
        apiName: apiName,
        methodName: methodName,
        bytes: BytesUtils.fromHexString(response));
  }
}
