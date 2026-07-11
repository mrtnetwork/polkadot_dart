import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/core/core.dart';

typedef SubstrateServiceResponse = BaseServiceResponse;

/// A mixin for providing substrate JSON-RPC service functionality.
mixin SubstrateServiceProvider
    implements
        IServiceProvider<
          SubstrateRequestDetails,
          BaseGRPCServiceRequestParams
        > {
  /// Example:
  /// @override
  /// Future`<`SubstrateServiceResponse> doRequest(SubstrateRequestDetails params,
  ///     {Duration? timeout}) async {
  ///   final response = await client
  ///      .post(params.toUri(url), headers: params.headers, body: params.body())
  ///      .timeout(timeout ?? defaultTimeOut);
  ///   return params.toResponse(response.bodyBytes, response.statusCode);
  /// }
  @override
  Future<SubstrateServiceResponse> doRequest(
    SubstrateRequestDetails params, {
    Duration? timeout,
  });

  @override
  Future<BaseServiceSubscribtionResponse> doSubscribtionRequest({
    required SubstrateRequestDetails params,
    required BaseServiceSubscribtionRequest<
      dynamic,
      dynamic,
      BaseSubscribtionEvent<dynamic>,
      SubstrateRequestDetails
    >
    request,
    Duration? timeout,
  }) {
    throw UnsupportedError(
      "Subscribtion requests are not supported by this service.",
    );
  }

  @override
  Future<List<int>> doGrpcRequest(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }

  @override
  Stream<List<int>> doGrpcRequestStream(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }

  @override
  Future<Stream<List<int>>> doGrpcRequestStreamAsync(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) {
    throw UnsupportedError("gRPC requests are not supported by this service.");
  }
}
