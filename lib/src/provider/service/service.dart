import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/core/core.dart';

typedef SubstrateServiceResponse<T> = BaseServiceResponse<T>;

/// A mixin for providing substrate JSON-RPC service functionality.
mixin SubstrateServiceProvider
    implements BaseServiceProvider<SubstrateRequestDetails> {
  /// Example:
  /// @override
  /// Future`<`SubstrateServiceResponse`<`T>> doRequest`<`T>(SubstrateRequestDetails params,
  ///     {Duration? timeout}) async {
  ///   final response = await client
  ///      .post(params.toUri(url), headers: params.headers, body: params.body())
  ///      .timeout(timeout ?? defaultTimeOut);
  ///   return params.toResponse(response.bodyBytes, response.statusCode);
  /// }
  @override
  Future<SubstrateServiceResponse<T>> doRequest<T>(
      SubstrateRequestDetails params,
      {Duration? timeout});
}
