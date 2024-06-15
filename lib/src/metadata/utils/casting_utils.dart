import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si.dart';

typedef Method<T> = Function();

class MetadataCastingUtils {
  static List<T> hasList<T>(
      {required Object? value,
      int? lookupId,
      Si1TypeDefsIndexesConst? type,
      int? length}) {
    final isList = nullOnException(() => (value as List).cast<T>());
    if (isList != null) {
      if (length != null && isList.length != length) {
        throw MetadataException("Incorrect Array length.", details: {
          "excepted": length,
          "length": isList.length,
          "lookup_id": lookupId,
          "type": type?.name,
          "value": value.runtimeType,
        });
      }
      return isList;
    }

    throw MetadataException("Invalid list provided", details: {
      "type": type?.name,
      "lookup_id": lookupId,
      "value": value.runtimeType,
    });
  }

  static T? nullOnException<T>(T? Function() t, {T? defaultValue}) {
    try {
      return t();
    } catch (e) {
      return defaultValue;
    }
  }

  static Object? getValue({
    required Object? value,
    required Si1TypeDefsIndexesConst type,
    required bool fromTemplate,
    required int lookupId,
    PrimitiveTypes? primitive,
  }) {
    Object? val = fromTemplate
        ? _getTemolateValue(value: value, lookupId: lookupId, type: type)
        : value;
    switch (type) {
      case Si1TypeDefsIndexesConst.compact:
      case Si1TypeDefsIndexesConst.composite:
      case Si1TypeDefsIndexesConst.variant:
      case Si1TypeDefsIndexesConst.option:
        return val;
      default:
        val = nullOnException(
          () => _getValue(
              value: val,
              type: type,
              fromTemplate: fromTemplate,
              lookupId: lookupId,
              primitive: primitive),
        );
        break;
    }
    if (val == null) {
      throw MetadataException("Invalid value provided.", details: {
        "value": value,
        "type": primitive?.name ?? type.name,
        "lookup_id": lookupId,
        "from_template": fromTemplate,
      });
    }
    return val;
  }

  static Object? _getValue({
    required Object? value,
    required Si1TypeDefsIndexesConst type,
    required bool fromTemplate,
    required int lookupId,
    PrimitiveTypes? primitive,
  }) {
    switch (type) {
      case Si1TypeDefsIndexesConst.sequence:
      case Si1TypeDefsIndexesConst.tuple:
      case Si1TypeDefsIndexesConst.array:
        return _isList(value, primitive: primitive);
      case Si1TypeDefsIndexesConst.bitSequence:
        return _isList(value, primitive: PrimitiveTypes.u8);

      case Si1TypeDefsIndexesConst.historicMetaCompat:
        throw UnimplementedError("HistoricMetaCompat does not implement.");
      case Si1TypeDefsIndexesConst.primitive:
        return _primitiveOrNull(primitive: primitive, value: value);
      default:
        return null;
    }
  }

  static Map<K, V> isMap<K, V>(Object? value,
      {String? property, String? type}) {
    final Map<K, V>? map = mapOrNull<K, V>(value);
    if (map == null) {
      throw MetadataException("Invalid Map value.",
          details: {"property": property, "type": type, "value": value});
    }
    return map;
  }

  static Object? _getTemolateValue(
      {required Object? value,
      required int lookupId,
      required Si1TypeDefsIndexesConst type}) {
    final map = mapOrNull<String, dynamic>(value);
    if (map?.containsKey("value") ?? false) {
      return map!["value"];
    }
    throw MetadataException(
        "Invalid data provided for encoding. Template value should be map and contains 'value' ",
        details: {"value": value, "type": type.name, "lookup": lookupId});
  }

  static String getVariantKey(Object? value, {String? property, String? type}) {
    if (value is Map && value["key"] is String) {
      return value["key"];
    }
    throw MetadataException(
        "Invalid Template value for variant. Template must be a map and contains key key with variant name",
        details: {"property": property, "type": type, "value": value});
  }

  static Object? _primitiveOrNull({PrimitiveTypes? primitive, Object? value}) {
    try {
      if (primitive == null) return null;
      switch (primitive) {
        case PrimitiveTypes.i128:
        case PrimitiveTypes.i256:
        case PrimitiveTypes.i64:
        case PrimitiveTypes.u128:
        case PrimitiveTypes.u256:
        case PrimitiveTypes.u64:
        case PrimitiveTypes.i8:
        case PrimitiveTypes.i32:
        case PrimitiveTypes.i16:
        case PrimitiveTypes.u8:
        case PrimitiveTypes.u32:
        case PrimitiveTypes.u16:
          return castingIntegerValue(value: value, type: primitive);
        case PrimitiveTypes.charType:
          return castingIntegerValue(value: value, type: PrimitiveTypes.u32);
        case PrimitiveTypes.strType:
          if (value is String) return value;
          break;
        case PrimitiveTypes.boolType:
          if (value is bool) {
            return value;
          }
          break;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static List _isList(
    Object? value, {
    String? typneName,
    int? length,
    PrimitiveTypes? primitive,
  }) {
    List? castValue;

    switch (primitive) {
      case PrimitiveTypes.i128:
      case PrimitiveTypes.i256:
      case PrimitiveTypes.i64:
      case PrimitiveTypes.u128:
      case PrimitiveTypes.u256:
      case PrimitiveTypes.u64:
        castValue =
            castListOrNull<int>(value)?.map((e) => BigInt.from(e)).toList();
        castValue ??= castListOrNull<BigInt>(value);
        break;
      case PrimitiveTypes.i8:
      case PrimitiveTypes.i32:
      case PrimitiveTypes.i16:
      case PrimitiveTypes.u8:
        castValue = bytesOrNull(value);
        break;
      case PrimitiveTypes.u32:
      case PrimitiveTypes.u16:
      case PrimitiveTypes.charType:
        castValue =
            castListOrNull<BigInt>(value)?.map((e) => e.toInt()).toList();
        castValue ??= castListOrNull<int>(value);
        break;
      case PrimitiveTypes.strType:
        castValue = castListOrNull<String>(value);
        break;
      case PrimitiveTypes.boolType:
        castValue = castListOrNull<bool>(value);
        break;
      default:
        castValue = castListOrNull(value);
        break;
    }
    if (castValue == null || length != null && castValue.length != length) {
      throw MetadataException("Invalid List value.", details: {
        "value": value,
        "type": typneName,
        "length": length,
      });
    }
    return castValue;
  }

  static List<int> isBytes(
    Object? value, {
    String? property,
    String? type,
  }) {
    final toBytes = bytesOrNull(value);
    if (toBytes != null) return toBytes;
    throw MetadataException("Invalid bytes value.",
        details: {"value": value, "type": type, "property": property});
  }

  static Object castingIntegerValue(
      {required Object? value,
      required PrimitiveTypes type,
      String? property}) {
    final sign = type.name.startsWith("I");
    final bitLength = int.parse(type.name.substring(1));
    bool isBigInt = bitLength > 48;
    if (isBigInt) {
      return _castBigint(
          value: value, sign: sign, bitLength: bitLength, property: property);
    }
    return _castInt(
        value: value, sign: sign, bitLength: bitLength, property: property);
  }

  static BigInt _castBigint({
    required Object? value,
    required bool sign,
    required int bitLength,
    String? property,
  }) {
    try {
      if (value is BigInt) {
        if (isBigint(value, sign: sign, bitLength: bitLength)) {
          return value;
        }
      } else if (value is int) {
        final toBigint = BigInt.from(value);
        if (isBigint(toBigint, sign: sign, bitLength: bitLength)) {
          return toBigint;
        }
      }
      // ignore: empty_catches
    } catch (e) {}
    throw LayoutException("Invalid value for type Bigint",
        details: {"sign": sign, "bitLength": bitLength, "property": property});
  }

  static int _castInt({
    required Object? value,
    required bool sign,
    required int bitLength,
    String? property,
  }) {
    try {
      if (value is int) {
        if (isInt(value, sign: sign, bitLength: bitLength)) {
          return value;
        }
      } else if (value is BigInt && value.isValidInt) {
        final intValue = value.toInt();
        if (isInt(intValue, sign: sign, bitLength: bitLength)) {
          return intValue;
        }
      }
      // ignore: empty_catches
    } catch (e) {}
    throw LayoutException("Invalid value for type int", details: {
      "sign": sign,
      "bitLength": bitLength,
      "property": property,
      "value": value,
    });
  }

  static List<T>? castListOrNull<T>(Object? value) {
    if (value is! List) return null;
    try {
      return value.cast<T>();
    } catch (e) {
      return null;
    }
  }

  static List<int>? bytesOrNull<T>(Object? value) {
    try {
      if (value is String) {
        return BytesUtils.tryFromHexString(value);
      }
      final List<int>? bytes = castListOrNull(value);
      BytesUtils.validateBytes(bytes!);
      return bytes;
    } catch (e) {
      return null;
    }
  }

  static Map<K, V>? mapOrNull<K, V>(Object? value) {
    if (value is! Map) return null;
    try {
      return value.cast<K, V>();
    } catch (e) {
      return null;
    }
  }

  static bool isBigint(dynamic data, {bool sign = false, int? bitLength}) {
    if (data is BigInt) {
      if (bitLength != null) {
        if (data.bitLength > bitLength) return false;
      }
      if (!sign && data.isNegative) return false;
      return true;
    }
    return false;
  }

  static bool isInt(dynamic data, {bool sign = false, int? bitLength}) {
    if (data is int) {
      if (bitLength != null) {
        if (data.bitLength > bitLength) return false;
      }
      if (!sign && data.isNegative) return false;
      return true;
    }
    return false;
  }

  static int validateU8(int value, {int? max}) {
    if (isInt(value, bitLength: 8)) {
      if (max == null || value <= max) return value;
    }
    throw MessageException("Invalid integer provided for U8.",
        details: {"value": value, "max": max});
  }

  static List<int> validateBytesLength(List<int> bytes,
      {int? except, int? min, String? error}) {
    BytesUtils.validateBytes(bytes);
    if (except != null && bytes.length == except) {
      return bytes;
    } else if (min != null && bytes.length >= min) {
      return bytes;
    } else if (min == null && except == null) {
      return bytes;
    }
    throw MessageException(error ?? "Invalid bytes length.",
        details: {"length": bytes.length, "excepted": except});
  }
}
