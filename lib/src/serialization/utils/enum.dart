import 'package:blockchain_utils/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

class SubstrateEnumSerializationUtils {
  static String getScaleEnumKey(dynamic value,
      {String? className, List<String>? keys}) {
    try {
      final inMap = MetadataCastingUtils.isMap<String, dynamic>(value);
      final key = inMap.keys.first;
      if (keys != null && !keys.contains(key)) {
        throw MessageException("Invalid enum key.", details: {
          "key": key,
          "excepted": keys.join(", "),
          "runtime": className,
        });
      }
      return key;
    } catch (e) {
      throw MessageException("Invalid enum key.",
          details: {"value": value, "runtime": className});
    }
  }

  static T getScaleEnumValue<T>(Map<String, dynamic> json, String key,
      {String? className}) {
    final value = json[key];
    if (value is! T) {
      throw MessageException("Invalid enum values.", details: {
        "excepted": "$T",
        "value": value,
        "key": key,
        "runtime": className
      });
    }
    return value;
  }
}
