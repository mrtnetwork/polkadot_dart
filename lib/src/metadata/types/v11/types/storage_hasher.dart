import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/metadata/core/storage_hasher.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class StorageHasherV11Options implements StorageHasher {
  @override
  final String name;
  @override
  final int hashLength;
  const StorageHasherV11Options._(this.name, {this.hashLength = 0});
  static const StorageHasherV11Options blake2128 = StorageHasherV11Options._(
      "Blake2128",
      hashLength: QuickCrypto.blake2b128DigestSize);
  static const StorageHasherV11Options blake2256 = StorageHasherV11Options._(
      "Blake2256",
      hashLength: QuickCrypto.blake2b256DigestSize);
  static const StorageHasherV11Options blake2128Concat =
      StorageHasherV11Options._("Blake2128Concat",
          hashLength: QuickCrypto.blake2b128DigestSize);
  static const StorageHasherV11Options twox128 = StorageHasherV11Options._(
      "Twox128",
      hashLength: QuickCrypto.twoX128DigestSize);
  static const StorageHasherV11Options twox256 = StorageHasherV11Options._(
      "Twox256",
      hashLength: QuickCrypto.twoX256DigestSize);
  static const StorageHasherV11Options twox64Concat = StorageHasherV11Options._(
      "Twox64Concat",
      hashLength: QuickCrypto.twoX64DigestSize);
  static const StorageHasherV11Options identity =
      StorageHasherV11Options._("Identity");
  static const List<StorageHasherV11Options> values = [
    StorageHasherV11Options.blake2128,
    StorageHasherV11Options.blake2256,
    StorageHasherV11Options.blake2128Concat,
    StorageHasherV11Options.twox128,
    StorageHasherV11Options.twox256,
    StorageHasherV11Options.twox64Concat,
    StorageHasherV11Options.identity
  ];

  static StorageHasherV11Options fromValue(String? value) {
    return values.firstWhere((element) => element.name == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }

  @override
  List<int> toHash(List<int> data) {
    final toBytes = BytesUtils.toBytes(data, unmodifiable: true);
    switch (this) {
      case StorageHasherV11Options.blake2128:
        return QuickCrypto.blake2b128Hash(toBytes);
      case StorageHasherV11Options.blake2256:
        return QuickCrypto.blake2b256Hash(toBytes);
      case StorageHasherV11Options.blake2128Concat:
        return [...QuickCrypto.blake2b128Hash(toBytes), ...toBytes];
      case StorageHasherV11Options.identity:
        return toBytes;
      case StorageHasherV11Options.twox128:
        return QuickCrypto.twoX128(toBytes);
      case StorageHasherV11Options.twox256:
        return QuickCrypto.twoX256(toBytes);
      case StorageHasherV11Options.twox64Concat:
        return [...QuickCrypto.twoX64(toBytes), ...toBytes];
      default:
        throw MetadataException("Invalid Hasher option v11",
            details: {"hasher": name});
    }
  }

  @override
  bool get isConcat {
    switch (this) {
      case StorageHasherV11Options.blake2128Concat:
      case StorageHasherV11Options.identity:
      case StorageHasherV11Options.twox64Concat:
        return true;
      default:
        return false;
    }
  }
}

class StorageHasherV11 extends SubstrateSerialization<Map<String, dynamic>> {
  final StorageHasherV11Options option;
  const StorageHasherV11(this.option);
  StorageHasherV11.deserializeJson(Map<String, dynamic> json)
      : option = StorageHasherV11Options.fromValue(json.keys.firstOrNull);
  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      SubstrateMetadataLayouts.storageHasherV11(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {option.name: null};
  }
}

class StorageHasherV14 extends StorageHasherV11 {
  StorageHasherV14.deserializeJson(super.json) : super.deserializeJson();
  StorageHasherV14(super.option);
  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      SubstrateMetadataLayouts.storageHasherV14(property: property);
}
