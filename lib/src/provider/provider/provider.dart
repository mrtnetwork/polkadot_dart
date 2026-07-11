import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';

/// Represents an interface to interact with substrate nodes
/// using JSON-RPC requests.
class SubstrateProvider<SERVICE extends IServiceProvider>
    implements IProvider<SERVICE, SubstrateRequestDetails> {
  /// The JSON-RPC service used for communication with the substrate node.
  @override
  final SERVICE service;

  SubstrateProvider(this.service);

  /// Finds the result in the JSON-RPC response data or throws an [RPCError]
  /// if an error is encountered.
  static SERVICERESPONSE _findError<SERVICERESPONSE>({
    required BaseServiceResponse response,
    required SubstrateRequestDetails params,
  }) {
    final Map<String, dynamic> r = params.toEncodingResponse(response);
    final error = r["error"];
    if (error != null) {
      final errorCode = IntUtils.tryParse(error['code']);
      final message = error['message'];
      throw RPCError(
        errorCode: errorCode,
        message: (message is String ? message : ServiceConst.defaultError),
        request: params.toJson(),
        jsonRpcErrpr: r,
        relatedNetwork: BlockchainNetwork.substrateAndRelated,
        statusCode: response.statusCode,
      );
    }
    return ServiceProviderUtils.toResponse<SERVICERESPONSE>(
      object: r["result"],
      params: params,
    );
  }

  /// The unique identifier for each JSON-RPC request.
  int _id = 0;

  /// Sends a request to the substract network using the specified [request] parameter.
  ///
  /// The [timeout] parameter, if provided, sets the maximum duration for the request.
  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
    IServiceRequest<RESULT, SERVICERESPONSE, SubstrateRequestDetails> request, {
    Duration? timeout,
  }) async {
    final r = await requestDynamic<RESULT, SERVICERESPONSE>(
      request,
      timeout: timeout,
    );
    return request.onResonse(r);
  }

  /// Sends a request to the substract network using the specified [request] parameter.
  ///
  /// The [timeout] parameter, if provided, sets the maximum duration for the request.
  /// Whatever is received will be returned
  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
    IServiceRequest<RESULT, SERVICERESPONSE, SubstrateRequestDetails> request, {
    Duration? timeout,
  }) async {
    final params = request.buildRequest(_id++);
    final response = await service.doRequest(params, timeout: timeout);
    return _findError<SERVICERESPONSE>(params: params, response: response);
  }
}
