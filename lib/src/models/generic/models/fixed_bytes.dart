import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class ScaleFixedBytes extends SubstrateSerialization<List<int>> {
  final List<int> bytes;
  ScaleFixedBytes(List<int> bytes, {int? lengthInBytes, int? minLength})
      : bytes = List<int>.unmodifiable(MetadataCastingUtils.validateBytesLength(
                bytes,
                except: lengthInBytes,
                min: minLength)
            .sublist(0, lengthInBytes ?? minLength));
  ScaleFixedBytes.fromHex(String hex, {int? lengthInBytes, int? minLength})
      : bytes = List<int>.unmodifiable(MetadataCastingUtils.validateBytesLength(
                BytesUtils.fromHexString(hex),
                except: lengthInBytes,
                min: minLength)
            .sublist(0, lengthInBytes ?? minLength));

  @override
  RawBytesLayout layout({String? property}) =>
      LayoutConst.fixedBlobN(bytes.length, property: property);
  @override
  List<int> scaleJsonSerialize({String? property}) {
    return bytes;
  }

  @override
  String toString() {
    return toHex(prefix: "0x");
  }
}
