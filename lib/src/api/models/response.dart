import 'package:blockchain_utils/binary/utils.dart';

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
      : changes = Map.unmodifiable(Map<String, String?>.fromEntries(
            changes.map((e) => MapEntry(e[0]!, e[1]))));
  List<int>? getValue(String key) {
    final val = changes[key];
    if (val == null) return null;
    return BytesUtils.fromHexString(val);
  }
}
