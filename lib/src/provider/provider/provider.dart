import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/service.dart';

/// Represents an interface to interact with substrate nodes
/// using JSON-RPC requests.
class SubstrateRPC {
  /// The JSON-RPC service used for communication with the substrate node.
  final SubstrateRPCService rpc;

  /// Creates a new instance of the [SubstrateRPC] class with the specified [rpc].
  SubstrateRPC(this.rpc);

  /// Finds the result in the JSON-RPC response data or throws an [RPCError]
  /// if an error is encountered.
  T _findResult<T>(Map<String, dynamic> data, SubstrateRequestDetails request) {
    if (data["error"] != null) {
      final code = int.tryParse(((data["error"]?['code']?.toString()) ?? "0"));
      final message = data["error"]?['message'] ?? "";
      throw RPCError(
        errorCode: code ?? 0,
        message: message,
        data: data["error"]?["data"],
        request: data["request"] ?? StringUtils.toJson(request.toRequestBody()),
      );
    }
    return data["result"];
  }

  /// The unique identifier for each JSON-RPC request.
  int _id = 0;

  /// Sends a JSON-RPC request to the substrate node and returns the result after
  /// processing the response.
  ///
  /// [request]: The JSON-RPC request to be sent.
  /// [timeout]: The maximum duration for waiting for the response.
  Future<RPCRESULT> request<RPCRESPONSE, RPCRESULT>(
      SubstrateRPCRequest<RPCRESPONSE, RPCRESULT> request,
      [Duration? timeout]) async {
    final id = ++_id;
    final params = request.toRequest(id);
    final data = await rpc.call(params, timeout);
    return request.onResonse(_findResult<RPCRESPONSE>(data, params));
  }
}
