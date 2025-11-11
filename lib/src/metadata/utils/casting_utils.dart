import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si.dart';

class MetadataCastingUtils {
  static List<T> asList<T>(
      {required Object? value,
      int? lookupId,
      Si1TypeDefsIndexesConst? type,
      int? length}) {
    final isList = nullOnException(() => (value as List).cast<T>());
    if (isList != null) {
      if (length != null && isList.length != length) {
        throw MetadataException("Incorrect Array length.", details: {
          "expected": length,
          "length": isList.length,
          "lookup_id": lookupId,
          "type": type?.name,
          "value": value.runtimeType
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
    required int id,
    required PortableRegistry registry,
    PrimitiveTypes? primitive,
  }) {
    Object? val = value;
    if (fromTemplate) {
      val = _getTemplateValue(value: value, id: id, type: type);
    }
    if (value is LookupRawParam) {
      final decode = registry
          .type(id)
          .type
          .serializationLayout(registry)
          .deserialize(value.bytes);
      assert(decode.consumed == value.bytes.length,
          "decode failed ${decode.consumed} ${decode.value} $id");
      val = decode.value;
    }
    switch (type) {
      case Si1TypeDefsIndexesConst.compact:
      case Si1TypeDefsIndexesConst.composite:
      case Si1TypeDefsIndexesConst.variant:
        return val;
      default:
        val = nullOnException(
          () => _getValue(
              value: val,
              type: type,
              fromTemplate: fromTemplate,
              lookupId: id,
              primitive: primitive),
        );
        break;
    }
    if (val == null) {
      throw MetadataException("Invalid value provided.", details: {
        "value": value,
        "type": primitive?.name ?? type.name,
        "lookup_id": id,
        "from_template": fromTemplate,
      });
    }
    return val;
  }

  static Object? _getValue(
      {required Object? value,
      required Si1TypeDefsIndexesConst type,
      required bool fromTemplate,
      required int lookupId,
      PrimitiveTypes? primitive}) {
    switch (type) {
      case Si1TypeDefsIndexesConst.sequence:
      case Si1TypeDefsIndexesConst.tuple:
      case Si1TypeDefsIndexesConst.array:
        return _isList(value, primitive: primitive);
      case Si1TypeDefsIndexesConst.bitSequence:
        return _isList(value, primitive: PrimitiveTypes.u8);

      case Si1TypeDefsIndexesConst.historicMetaCompat:
        throw MetadataException("HistoricMetaCompat does not implement.");
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

  static Object? _getTemplateValue(
      {required Object? value,
      required int id,
      required Si1TypeDefsIndexesConst type}) {
    final map = mapOrNull<String, dynamic>(value);
    if (map?.containsKey("value") ?? false) {
      return map!["value"];
    }
    throw MetadataException(
        "Invalid data provided for encoding. Template value should be map and contains 'value' ",
        details: {"value": value, "type": type.name, "lookup": id});
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

  static List _isList(Object? value,
      {String? typneName, int? length, PrimitiveTypes? primitive}) {
    List? castValue;

    switch (primitive) {
      case PrimitiveTypes.i128:
      case PrimitiveTypes.i256:
      case PrimitiveTypes.i64:
      case PrimitiveTypes.u128:
      case PrimitiveTypes.u256:
      case PrimitiveTypes.u64:
        castValue = castListOrNull<BigInt>(value);
        castValue ??=
            castListOrNull<int>(value)?.map((e) => BigInt.from(e)).toList();

        break;
      case PrimitiveTypes.i8:
      case PrimitiveTypes.i32:
      case PrimitiveTypes.i16:
        castValue ??= castListOrNull<int>(value);
      case PrimitiveTypes.u8:
        castValue = bytesOrNull(value);
        break;
      case PrimitiveTypes.u32:
      case PrimitiveTypes.u16:
      case PrimitiveTypes.charType:
        castValue = castListOrNull<int>(value);
        castValue ??=
            castListOrNull<BigInt>(value)?.map((e) => e.toInt()).toList();

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
      throw MetadataException("Invalid List value.",
          details: {"value": value, "type": typneName, "length": length});
    }
    return castValue;
  }

  static List<int> isBytes(Object? value, {String? property, String? type}) {
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
    final bool isBigInt = bitLength > 48;
    if (isBigInt) {
      return _castBigint(
          value: value, sign: sign, bitLength: bitLength, property: property);
    }
    return _castInt(
        value: value, sign: sign, bitLength: bitLength, property: property);
  }

  static BigInt _castBigint(
      {required Object? value,
      required bool sign,
      required int bitLength,
      String? property}) {
    final bigValue = BigintUtils.tryParse(value, allowHex: false);
    if (bigValue != null &&
        isBigint(bigValue, sign: sign, bitLength: bitLength)) {
      return bigValue;
    }
    throw MetadataException("Invalid value for type Bigint",
        details: {"sign": sign, "bitLength": bitLength, "property": property});
  }

  static int _castInt(
      {required Object? value,
      required bool sign,
      required int bitLength,
      String? property}) {
    final intValue = IntUtils.tryParse(value, allowHex: false);
    if (intValue != null && isInt(intValue, sign: sign, bitLength: bitLength)) {
      return intValue;
    }
    throw MetadataException("Invalid value for type int", details: {
      "sign": sign,
      "bitLength": bitLength,
      "property": property,
      "value": value
    });
  }

  static List<T>? castListOrNull<T>(Object? value) {
    if (value is! List) return null;
    try {
      return value.cast<T>();
    } catch (_) {
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
    } catch (_) {
      return null;
    }
  }

  static Map<K, V>? mapOrNull<K, V>(Object? value) {
    if (value is! Map) return null;
    try {
      return value.cast<K, V>();
    } catch (_) {
      return null;
    }
  }

  static bool isBigint(BigInt data, {bool sign = false, int? bitLength}) {
    if (bitLength != null) {
      if (data.bitLength > bitLength) return false;
    }
    if (!sign && data.isNegative) return false;
    return true;
  }

  static bool isInt(int data, {bool sign = false, int? bitLength}) {
    if (bitLength != null) {
      if (data.bitLength > bitLength) return false;
    }
    if (!sign && data.isNegative) return false;
    return true;
  }

  static int validateU8(int value, {int? max}) {
    if (isInt(value, bitLength: 8)) {
      if (max == null || value <= max) return value;
    }
    throw DartSubstratePluginException("Invalid integer provided for U8.",
        details: {"value": value, "max": max});
  }

  static List<int> validateBytesLength(List<int> bytes,
      {int? except, int? min}) {
    BytesUtils.validateBytes(bytes);
    if (except != null && bytes.length == except) {
      return bytes;
    } else if (min != null && bytes.length >= min) {
      return bytes;
    } else if (min == null && except == null) {
      return bytes;
    }
    throw DartSubstratePluginException("Invalid bytes length.",
        details: {"length": bytes.length, "expected": except});
  }
}
