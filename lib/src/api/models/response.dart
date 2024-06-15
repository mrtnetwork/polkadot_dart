import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';

class QueryStorageResult<T> {
  final String storageKey;
  final T result;
  const QueryStorageResult({required this.storageKey, required this.result});
  @override
  String toString() {
    return "storageKey: $storageKey value: $result";
  }
}

class QueryStorageAtResult<T> {
  final String block;
  final T result;
  const QueryStorageAtResult({required this.block, required this.result});
  @override
  String toString() {
    return "block: $block result: $result";
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
}

class QueryStorageRequest<T> {
  final String palletNameOrIndex;
  final String methodName;
  final Object identifier;
  final Object? input;

  QueryStorageRequest(
      {required this.palletNameOrIndex,
      required this.methodName,
      required this.input,
      required this.identifier});
  QueryStorageResponse<T> toResponse(T result) {
    return QueryStorageResponse(request: this, result: result);
  }
}
