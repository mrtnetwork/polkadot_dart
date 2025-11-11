import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';

/// Represents an interface to interact with substrate nodes
/// using JSON-RPC requests.
class SubstrateProvider implements BaseProvider<SubstrateRequestDetails> {
  /// The JSON-RPC service used for communication with the substrate node.
  final BaseServiceProvider rpc;

  /// Creates a new instance of the [SubstrateProvider] class with the specified [rpc].
  SubstrateProvider(this.rpc);

  /// Finds the result in the JSON-RPC response data or throws an [RPCError]
  /// if an error is encountered.
  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse<Map<String, dynamic>> response,
      required SubstrateRequestDetails params}) {
    final Map<String, dynamic> r = response.getResult(params);
    final error = r["error"];
    if (error != null) {
      final errorCode = IntUtils.tryParse(error['code']);
      final String message =
          error['message']?.toString() ?? ServiceConst.defaultError;
      throw RPCError(
          errorCode: errorCode,
          message: message,
          request: params.toJson(),
          details: StringUtils.tryToJson(error));
    }
    return r["result"];
  }

  /// The unique identifier for each JSON-RPC request.
  int _id = 0;

  /// Sends a request to the substract network using the specified [request] parameter.
  ///
  /// The [timeout] parameter, if provided, sets the maximum duration for the request.
  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, SubstrateRequestDetails>
          request,
      {Duration? timeout}) async {
    final r = await requestDynamic(request, timeout: timeout);
    return request.onResonse(r);
  }

  /// Sends a request to the substract network using the specified [request] parameter.
  ///
  /// The [timeout] parameter, if provided, sets the maximum duration for the request.
  /// Whatever is received will be returned
  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, SubstrateRequestDetails>
          request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final response =
        await rpc.doRequest<Map<String, dynamic>>(params, timeout: timeout);
    return _findError(params: params, response: response);
  }
}
