import 'package:blockchain_utils/blockchain_utils.dart';

/// Represents the details of an Ethereum JSON-RPC request.
class SubstrateRequestDetails extends BaseServiceRequestParams {
  const SubstrateRequestDetails({
    required super.requestID,
    required super.type,
    required super.headers,
    required this.method,
    required this.jsonBody,
  });

  /// The Ethereum method name for the request.
  final String method;

  /// The JSON-formatted string containing the request parameters.
  final Map<String, dynamic> jsonBody;

  @override
  List<int>? body() {
    return StringUtils.encode(StringUtils.fromJson(jsonBody));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"method": method, "body": jsonBody, "type": type.name};
  }

  @override
  Uri toUri(String uri) {
    return Uri.parse(uri);
  }
}

/// An abstract class representing Ethereum JSON-RPC requests with generic response types.
abstract class SubstrateRequest<RESULT, SERVICERESPONSE>
    extends BaseServiceRequest<SERVICERESPONSE, RESULT,
        SubstrateRequestDetails> {
  const SubstrateRequest();

  @override
  RequestServiceType get requestType => RequestServiceType.post;

  /// JSON-RPC method name.
  abstract final String rpcMethod;

  /// Converts the request parameters to a JSON representation.
  List<dynamic> toJson();

  /// A validation property (not used in this implementation).
  String? get validate => null;

  /// Converts a dynamic response to a BigInt, handling hexadecimal conversion.
  static BigInt onBigintResponse(dynamic result) {
    if (result == "0x") return BigInt.zero;
    return BigInt.parse(StringUtils.strip0x(result), radix: 16);
  }

  /// Converts a dynamic response to an integer, handling hexadecimal conversion.
  static int onIntResponse(dynamic result) {
    if (result == "0x") return 0;
    return int.parse(StringUtils.strip0x(result), radix: 16);
  }

  /// Converts the request parameters to a [SubstrateRequestDetails] object.
  @override
  SubstrateRequestDetails buildRequest(int requestId) {
    List<dynamic> inJson = toJson();
    inJson.removeWhere((v) => v == null);
    inJson = inJson.map((e) {
      return e;
    }).toList();
    final Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": rpcMethod,
      "params": inJson,
      "id": requestId,
    };
    return SubstrateRequestDetails(
        requestID: requestId,
        jsonBody: params,
        method: rpcMethod,
        type: requestType,
        headers: ServiceConst.defaultPostHeaders);
  }

  @override
  String toString() {
    return "$runtimeType${toJson()}";
  }
}
