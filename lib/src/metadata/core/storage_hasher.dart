/// Abstract class representing a storage hasher in the Substrate framework.
abstract class StorageHasher {
  /// Hashes the given [data] and returns the resulting list of bytes.
  ///
  /// [data] is the list of bytes to be hashed.
  List<int> toHash(List<int> data);

  // List<int> getHashedParts(List<int> data, {int offset = 0});
  int get hashLength;
  bool get isConcat;
  String get name;
}
