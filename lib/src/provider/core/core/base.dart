import 'package:blockchain_utils/blockchain_utils.dart';

/// An abstract class representing substrate RPC request parameters.
abstract class SubstrateRequestParams {
// The Ethereum method associated with the request.
  abstract final String rpcMethod;

  /// Converts the request parameters to a JSON representation.
  List<dynamic> toJson();
}

/// Represents the details of an Ethereum JSON-RPC request.
class SubstrateRequestDetails {
  const SubstrateRequestDetails(
      {required this.id, required this.method, required this.params});

  /// The unique identifier for the JSON-RPC request.
  final int id;

  /// The Ethereum method name for the request.
  final String method;

  /// The JSON-formatted string containing the request parameters.
  final String params;

  /// Converts the request parameters to a JSON-formatted string.
  String toRequestBody() {
    return params;
  }
}

// /// An abstract class representing Substrate lookup block requests.
// abstract class LookupBlockRequest {
//   const LookupBlockRequest();

//   /// Converts the request parameters to a JSON representation.
//   List<dynamic> toJson();
// }

/// An abstract class representing Ethereum JSON-RPC requests with generic response types.
abstract class SubstrateRPCRequest<RPCRESPONSE, RPCRESULT>
    implements SubstrateRequestParams {
  const SubstrateRPCRequest() : super();

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

  /// Converts a dynamic response to the generic type [T].
  RPCRESULT onResonse(RPCRESPONSE result) {
    return result as RPCRESULT;
  }

  /// Converts the request parameters to a [SubstrateRequestDetails] object.
  SubstrateRequestDetails toRequest(int requestId) {
    List<dynamic> inJson = toJson();
    inJson.removeWhere((v) => v == null);
    inJson = inJson.map((e) {
      return e;
    }).toList();
    final params = {
      "jsonrpc": "2.0",
      "method": rpcMethod,
      "params": inJson,
      "id": requestId,
    };
    return SubstrateRequestDetails(
        id: requestId, params: StringUtils.fromJson(params), method: rpcMethod);
  }

  @override
  String toString() {
    return "$runtimeType${toJson()}";
  }
}
