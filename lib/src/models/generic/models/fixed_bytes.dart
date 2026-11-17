import 'package:blockchain_utils/blockchain_utils.dart' show BuBytes;
import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class ScaleFixedBytes extends SubstrateSerialization<List<int>> {
  final BuBytes bytes;
  ScaleFixedBytes(List<int> bytes, {int? lengthInBytes, int? minLength})
    : bytes =
          MetadataCastingUtils.validateBytesLength(
            bytes,
            expected: lengthInBytes,
            min: minLength,
          ).sublist(0, lengthInBytes ?? minLength).asImmutableBytes;
  ScaleFixedBytes.fromHex(String hex, {int? lengthInBytes, int? minLength})
    : bytes =
          MetadataCastingUtils.validateBytesLength(
            BytesUtils.fromHexString(hex),
            expected: lengthInBytes,
            min: minLength,
          ).sublist(0, lengthInBytes ?? minLength).asImmutableBytes;

  @override
  RawBytesLayout layout({String? property}) =>
      LayoutConst.fixedBlobN(bytes.length, property: property);
  @override
  BuBytes serializeJson({String? property}) {
    return bytes;
  }

  @override
  String toString() {
    return toHex(prefix: "0x");
  }
}
