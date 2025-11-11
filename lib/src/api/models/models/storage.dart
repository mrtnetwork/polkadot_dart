import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';

typedef ONSTORAGERESPONEBYTES<T extends Object?> = T Function(
    List<int> response, StorageKey storageKey);
typedef ONSTORAGERESPONEJSON<T extends Object?, JSON extends Object> = T
    Function(JSON response, List<int> bytes, StorageKey storageKey);
typedef ONSTORAGERESPONENULL<T extends Object?> = T Function(
    StorageKey storageKey);
typedef DECODERESPONSE = Object? Function();
typedef ENCODEINPUT = List<int> Function(Object? input);
typedef ENCODEINPUTS = List<int>? Function(int index, ENCODEINPUT onEncode);

class QueryStorageResult<T extends Object?> {
  final StorageKey storageKey;
  final T result;
  const QueryStorageResult({required this.storageKey, required this.result});
  @override
  String toString() {
    return "storageKey: $storageKey value: $result";
  }
}

class StorageChangeStateResponse {
  final Map<String, String?> changes;
  StorageChangeStateResponse(List<List<String?>> changes)
      : changes =
            Map.unmodifiable(Map<String, String?>.fromEntries(changes.map((e) {
          if (e.length != 2 || e[0] == null) {
            throw MetadataException(
                "Invalid StorageChangeState response. response must be list with two string object",
                details: {
                  "length": e.length,
                  "value": e,
                  "storage_key": e.isEmpty ? null : e[0]
                });
          }
          return MapEntry(e[0]!, e[1]);
        })));
  List<int>? getValue(String key) {
    final val = changes[key];
    if (val == null) return null;
    return BytesUtils.fromHexString(val);
  }
}

class QueryStorageRequestBlock {
  final List<QueryStorageResponse> request;
  final String block;
  const QueryStorageRequestBlock({required this.request, required this.block});

  T getResult<T>(Object identifier) {
    return request
        .firstWhere(
          (element) => element.request.identifier == identifier,
          orElse: () => throw MetadataException("An identifier does not exist.",
              details: {
                "identifier": identifier,
                "identifiers":
                    request.map((e) => e.request.identifier).join(", ")
              }),
        )
        .result;
  }
}

class QueryStorageResponse<T> {
  final QueryStorageRequest<T> request;
  final T result;
  const QueryStorageResponse({required this.request, required this.result});
  @override
  String toString() {
    return result.toString();
  }
}

abstract class StorageRequest<RESPONSE extends Object?, JSON extends Object> {
  final ONSTORAGERESPONEBYTES<RESPONSE>? onBytesResponse;
  final ONSTORAGERESPONEJSON<RESPONSE, JSON>? onJsonResponse;
  final ENCODEINPUTS? onEncodeInputs;
  final ONSTORAGERESPONENULL<RESPONSE>? onNullResponse;
  const StorageRequest(
      {required this.onBytesResponse,
      required this.onJsonResponse,
      required this.onEncodeInputs,
      required this.onNullResponse});

  RESPONSE toResponse(
      {required DECODERESPONSE decode,
      required List<int>? bytes,
      required StorageKey storageKey}) {
    if (bytes == null) {
      if (null is RESPONSE) return null as RESPONSE;
      if (onNullResponse != null) {
        return onNullResponse!(storageKey);
      }
      throw DartSubstratePluginException('Unexpected response type.',
          details: {"excpected": "$RESPONSE", "value": 'Null'});
    }
    final onBytesResponse = this.onBytesResponse;
    if (onBytesResponse != null) return onBytesResponse(bytes, storageKey);
    final json = decode();
    if (json == null) {
      if (null is RESPONSE) return null as RESPONSE;
      throw DartSubstratePluginException('Unexpected response type.',
          details: {"excpected": "$RESPONSE", "value": 'Null'});
    }
    final onJsonResponse = this.onJsonResponse;
    if (onJsonResponse != null) {
      JSON data;
      try {
        data = JsonParser.valueAs<JSON>(json);
      } catch (_) {
        throw DartSubstratePluginException('Unexpected response type.',
            details: {"excpected": "$JSON", "value": json.runtimeType});
      }
      return onJsonResponse(data, bytes, storageKey);
    }
    RESPONSE data;
    try {
      data = JsonParser.valueAs<RESPONSE>(json);
    } catch (_) {
      throw DartSubstratePluginException('Unexpected response type.',
          details: {"excpected": "$RESPONSE", "value": json.runtimeType});
    }
    return data;
  }
}

/// [RESPONSE] The exact type of data you expect to receive.
/// [JSON] The decoded result when metadata bytes are parsed into JSON.
/// For requests with optional data, use a nullable [RESPONSE] type (e.g., `int?`) for safety.
/// [onBytesResponse] A callback invoked when raw bytes are received; you should handle deserialization here.
/// [onJsonResponse] A callback invoked when the bytes are decoded into [JSON] using the output lookup.
/// [onEncodeInputs] called before encoding inputs instead encoding with metadata
class GetStorageRequest<RESPONSE extends Object?, JSON extends Object>
    extends StorageRequest<RESPONSE, JSON> {
  final String palletNameOrIndex;
  final String methodName;
  final Object? inputs;
  GetStorageRequest(
      {required this.palletNameOrIndex,
      required this.methodName,
      super.onNullResponse,
      this.inputs,
      super.onBytesResponse,
      super.onJsonResponse,
      super.onEncodeInputs});
}

/// [RESPONSE] The exact type of data you expect to receive.
/// [JSON] The decoded result when metadata bytes are parsed into JSON.
/// For requests with optional data, use a nullable [RESPONSE] type (e.g., `int?`) for safety.
/// [onBytesResponse] A callback invoked when raw bytes are received; you should handle deserialization here.
/// [onJsonResponse] A callback invoked when the bytes are decoded into [JSON] using the output lookup.
/// [onEncodeInputs] called before encoding inputs instead encoding with metadata
class GetStorageEntriesRequest<RESPONSE extends Object?, JSON extends Object>
    extends StorageRequest<RESPONSE, JSON> {
  final String palletNameOrIndex;
  final String methodName;
  final Object? inputs;
  final int? count;
  final String? startKey;
  final String? storageKey;
  GetStorageEntriesRequest._(
      {required this.palletNameOrIndex,
      required this.methodName,
      this.inputs,
      this.storageKey,
      super.onBytesResponse,
      super.onJsonResponse,
      super.onNullResponse,
      super.onEncodeInputs,
      this.count,
      this.startKey});

  factory GetStorageEntriesRequest.paged({
    required String palletNameOrIndex,
    required String methodName,
    required int count,
    Object? inputs,
    String? startKey,
    String? storageKey,
    ONSTORAGERESPONEBYTES<RESPONSE>? onBytesResponse,
    ONSTORAGERESPONEJSON<RESPONSE, JSON>? onJsonResponse,
  }) {
    assert(count > 0, "invalid paged request count");
    assert(
        (storageKey == null && inputs == null) ||
            (storageKey != null && inputs == null) ||
            (storageKey == null && inputs != null),
        "use input or storageKey for create or query from key or leaves them null for generate from pallet and method name");
    return GetStorageEntriesRequest._(
        palletNameOrIndex: palletNameOrIndex,
        methodName: methodName,
        onBytesResponse: onBytesResponse,
        onJsonResponse: onJsonResponse,
        count: count,
        startKey: startKey,
        storageKey: storageKey,
        inputs: inputs);
  }
}

/// [RESPONSE] The exact type of data you expect to receive.
/// [JSON] The decoded result when metadata bytes are parsed into JSON.
/// For requests with optional data, use a nullable [RESPONSE] type (e.g., `int?`) for safety.
/// [onBytesResponse] A callback invoked when raw bytes are received; you should handle deserialization here.
/// [onJsonResponse] A callback invoked when the bytes are decoded into [JSON] using the output lookup.
/// [onEncodeInputs] called before encoding inputs instead encoding with metadata
class GetStreamStorageEntriesRequest<RESPONSE extends Object?,
    JSON extends Object> extends StorageRequest<RESPONSE, JSON> {
  final String palletNameOrIndex;
  final String methodName;
  final int count;
  final int? total;
  final String? storageKey;
  final Object? inputs;
  GetStreamStorageEntriesRequest({
    required this.palletNameOrIndex,
    required this.methodName,
    this.inputs,
    this.storageKey,
    super.onNullResponse,
    super.onBytesResponse,
    super.onJsonResponse,
    super.onEncodeInputs,
    this.count = 1000,
    this.total,
  });
}

class QueryStorageResponses<T extends Object?> {
  final List<QueryStorageResult<T>> results;
  final String? block;
  QueryStorageResponses(
      {List<QueryStorageResult<T>> results = const [], this.block})
      : results = results.immutable;
  QueryStorageResult<RESPONSE> getResultAt<RESPONSE extends Object?>(
      int index) {
    if (index >= results.length) {
      throw DartSubstratePluginException('Index out of reange.');
    }
    final query = results.elementAt(index);
    final result = query.result;
    RESPONSE response;
    try {
      response = result as RESPONSE;
    } catch (_) {
      throw DartSubstratePluginException('Unexpected response type.',
          details: {"excpected": "$RESPONSE", "value": result.runtimeType});
    }
    return QueryStorageResult<RESPONSE>(
        storageKey: query.storageKey, result: response);
  }
}

class QueryStorageRequest<T> {
  final String palletNameOrIndex;
  final String methodName;
  final Object identifier;
  final Object? input;

  QueryStorageRequest(
      {required this.palletNameOrIndex,
      required this.methodName,
      this.input,
      required this.identifier});
  QueryStorageResponse<T> toResponse(T result) {
    return QueryStorageResponse(request: this, result: result);
  }
}

/// the storage key of storage method without inputs
class MethodStorageKey {
  final List<int> keyBytes;
  late String keyHex = BytesUtils.toHexString(keyBytes, prefix: "0x");
  MethodStorageKey({required List<int> keyBytes})
      : keyBytes = keyBytes.immutable;
}

class StorageKeyInput {
  final List<int>? encodedInput;

  final Object? input;
  StorageKeyInput({List<int>? encodedInput, this.input})
      : encodedInput = encodedInput?.asImmutableBytes;
}

class StorageKey {
  final MethodStorageKey prefix;

  /// fully storage key in hex. method and inputs.
  final String key;

  /// storage method inputs.
  final List<StorageKeyInput> inputs;
  StorageKey({
    required this.prefix,
    required this.key,
    required List<StorageKeyInput> inputs,
  }) : inputs = inputs.immutable;

  void _checkIndex(int index) {
    if (index >= inputs.length) {
      throw DartSubstratePluginException("Invalid input index.");
    }
  }

  BigInt inputAsBigInt(int index) {
    _checkIndex(index);
    final result =
        BigintUtils.tryParse(inputs.elementAt(index).input, allowHex: false);
    if (result == null) {
      throw DartSubstratePluginException("Failed to cast input as BigInt.",
          details: {"input": inputs.elementAt(index).input.runtimeType});
    }
    return result;
  }

  T inputAs<T extends Object>(int index) {
    _checkIndex(index);
    final result = inputs.elementAt(index).input;
    if (result is! T) {
      throw DartSubstratePluginException("Failed to cast input.",
          details: {"excepted": "$T", "input": result.runtimeType});
    }
    return result;
  }

  int inputAsInt(int index) {
    _checkIndex(index);
    final result =
        IntUtils.tryParse(inputs.elementAt(index).input, allowHex: false);
    if (result == null) {
      throw DartSubstratePluginException("Failed to cast input as Int.",
          details: {"input": inputs.elementAt(index).input.runtimeType});
    }
    return result;
  }

  List<int> encodedInput(int index) {
    _checkIndex(index);
    final result = inputs.elementAt(index).encodedInput;
    if (result == null) {
      throw DartSubstratePluginException("Missing encoded input.");
    }
    return result;
  }

  Map<K, V> inputAsMap<K, V>(int index) {
    _checkIndex(index);
    final input = inputs.elementAt(index).input;
    if (input is Map<K, V>) return input;
    try {
      return Map<K, V>.from(input as Map);
    } catch (_) {}
    throw DartSubstratePluginException("Failed to cast input as ${Map<K, V>}.",
        details: {"input": inputs.elementAt(index).input.runtimeType});
  }
}

class QueryStorageFullResponse<T extends Object?> {
  /// storage key
  final StorageKey storageKey;

  /// response bytes
  final List<int>? responseBytes;

  /// decoded response.
  final T response;
  const QueryStorageFullResponse(
      {required this.storageKey,
      required this.responseBytes,
      required this.response});
}
