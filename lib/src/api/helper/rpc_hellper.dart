import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';

import 'package:blockchain_utils/service/service.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

/// Extension to assist with runtime calls based on metadata
extension ExtRuntimeCallHelper on MetadataApi {
  Future<List<int>> runtimeCallBytes({
    required String apiName,
    required String methodName,
    required List<Object?> params,
    required IProvider<IServiceProvider, SubstrateRequestDetails> rpc,
    bool fromTemplate = true,
  }) async {
    final method = generateRuntimeApiMethod(apiName, methodName);
    final encode = encodeRuntimeApiInputs(
      apiName: apiName,
      methodName: methodName,
      params: params,
      fromTemplate: fromTemplate,
    );
    final encodeInputs = BytesUtils.toHexString(encode, prefix: "0x");
    final rpcMethod = SubstrateRequestStateCall(
      method: method,
      data: encodeInputs,
    );
    final response = await rpc.request(rpcMethod);
    return response;
  }

  Future<T> runtimeCall<T>({
    required String apiName,
    required String methodName,
    required List<Object?> params,
    required IProvider<IServiceProvider, SubstrateRequestDetails> rpc,
    bool fromTemplate = true,
  }) async {
    final method = generateRuntimeApiMethod(apiName, methodName);
    final encode = encodeRuntimeApiInputs(
      apiName: apiName,
      methodName: methodName,
      params: params,
      fromTemplate: fromTemplate,
    );
    final encodeInputs = BytesUtils.toHexString(encode, prefix: "0x");
    final rpcMethod = SubstrateRequestStateCall(
      method: method,
      data: encodeInputs,
    );
    final response = await rpc.request(rpcMethod);
    return decodeRuntimeApiOutput(
      apiName: apiName,
      methodName: methodName,
      bytes: response,
    );
  }
}
