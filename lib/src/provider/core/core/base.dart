import 'package:blockchain_utils/blockchain_utils.dart';

class SubstrateRequestDetails extends BaseServiceRequestParams {
  final String method;
  const SubstrateRequestDetails({
    required super.requestID,
    super.path,
    required super.responseEncoding,
    required super.headers,
    super.successStatusCodes,
    super.errorStatusCodes,
    required super.requestMethod,
    super.bodyBytes,
    super.bodyString,
    required this.method,
  }) : super(network: BlockchainNetwork.substrateAndRelated);
  factory SubstrateRequestDetails.deserialize({
    List<int>? bytes,
    CborObject? obj,
  }) {
    final values = CborTagSerializable.decodeTaggedValue(
      identifier: BlockchainNetwork.substrateAndRelated.identifier,
      cborBytes: bytes,
      cborObject: obj,
    );
    return SubstrateRequestDetails(
      headers: values
          .mapAt<CborStringValue, CborStringValue>(0)
          .map((k, v) => MapEntry(k.value, v.value)),
      requestMethod: RequestMethod.fromValue(values.rawValueAt(1)),
      responseEncoding: ServiceReponseEncoding.fromValue(values.rawValueAt(2)),
      successStatusCodes:
          values
              .listAt<CborIntValue>(3)
              .map((e) => e.value)
              .toList()
              .emptyAsNull,
      errorStatusCodes:
          values
              .listAt<CborIntValue>(4)
              .map((e) => e.value)
              .toList()
              .emptyAsNull,
      bodyBytes: values.rawValueAt(5),
      bodyString: values.rawValueAt(6),
      path: values.rawValueAt(7),
      requestID: values.rawValueAt(8),
      method: values.rawValueAt(9),
    );
  }
  SubstrateRequestDetails copyWith({
    int? requestID,
    String? path,
    RequestMethod? requestMethod,
    Map<String, String>? headers,
    List<int>? bodyBytes,
    String? bodyString,
    ServiceReponseEncoding? responseEncoding,
    List<int>? errorStatusCodes,
    List<int>? successStatusCodes,
    String? method,
  }) {
    return SubstrateRequestDetails(
      requestID: requestID ?? this.requestID,
      headers: headers ?? this.headers,
      path: path ?? this.path,
      responseEncoding: responseEncoding ?? this.responseEncoding,
      requestMethod: requestMethod ?? this.requestMethod,
      bodyString: bodyString ?? this.bodyString,
      errorStatusCodes: errorStatusCodes ?? this.errorStatusCodes,
      bodyBytes: bodyBytes ?? this.bodyBytes,
      successStatusCodes: successStatusCodes ?? this.successStatusCodes,
      method: method ?? this.method,
    );
  }

  @override
  List<int>? encodeBody({ServiceProtocol protocol = ServiceProtocol.http}) {
    assert(!protocol.isGrpc, "Unsupported protocol.");
    return super.encodeBody(protocol: protocol);
  }

  @override
  Uri encodeUrl(String uri) {
    return Uri.parse(uri);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "method": method,
      "body": bodyString ?? BytesUtils.tryToHexString(bodyBytes),
      "type": requestMethod.name,
    };
  }

  @override
  SerializationIdentifier get serializationIdentifier =>
      BlockchainNetwork.substrateAndRelated.identifier;

  @override
  List<CborObject?> get serializationItems => [
    CborMapValue.definite(
      headers.map((k, v) => MapEntry(CborStringValue(k), CborStringValue(v))),
    ),
    requestMethod.value.toCbor(),
    responseEncoding.value.toCbor(),
    CborTagSerializable.listFromDynamic(
      successStatusCodes?.map((e) => CborIntValue(e)).toList() ?? [],
    ),
    CborTagSerializable.listFromDynamic(
      errorStatusCodes?.map((e) => CborIntValue(e)).toList() ?? [],
    ),
    bodyBytes?.toCborBytes(),
    bodyString?.toCbor(),
    path?.toCbor(),
    requestID.toCbor(),
    method.toCbor(),
  ];
}

/// An abstract class representing Ethereum JSON-RPC requests with generic response types.
abstract class SubstrateRequest<RESULT, SERVICERESPONSE>
    extends
        BaseServiceRequest<SERVICERESPONSE, RESULT, SubstrateRequestDetails> {
  const SubstrateRequest();

  @override
  RequestMethod get requestMethod => RequestMethod.post;

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
    final Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": rpcMethod,
      "params": inJson,
      "id": requestId,
    };
    return SubstrateRequestDetails(
      requestID: requestId,
      bodyString: StringUtils.fromJson(params),
      requestMethod: requestMethod,
      headers: ServiceConst.defaultPostHeaders,
      responseEncoding: ServiceReponseEncoding.map,
      method: rpcMethod,
    );
  }

  @override
  String toString() {
    return "$runtimeType${toJson()}";
  }
}
