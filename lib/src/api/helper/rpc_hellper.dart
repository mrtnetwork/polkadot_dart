import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/provider/methods/state/call.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

/// Extension to assist with runtime calls based on metadata
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
    final encodeInputs = BytesUtils.toHexString(encode, prefix: "0x");
    final rpcMethod = SubstrateRPCStateCall(method: method, data: encodeInputs);
    final response = await rpc.request(rpcMethod);
    return decodeRuntimeApiOutput(
        apiName: apiName,
        methodName: methodName,
        bytes: BytesUtils.fromHexString(response));
  }
}
