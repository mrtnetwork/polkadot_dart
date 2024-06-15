import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_option.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';

class MetadataUtils {
  static const List<String> optionPath = ["Option"];
  static ScaleTypeDef toOption(
      Si1TypeDef def, List<String> path, List<int?> params) {
    if (params.length == 1 &&
        params[0] != null &&
        CompareUtils.iterableIsEqual(path, optionPath)) {
      return TypeDefOption(params[0]!, def);
    }
    return def;
  }

  static List isList(dynamic value, {String? info}) {
    if (value is! List) {
      throw MetadataException("Invalid provided list.",
          details: {"info": info, "value": value.runtimeType.toString()});
    }
    return value;
  }

  static void hasLen(List list, int len, {String? info}) {
    if (list.length != len) {
      throw MetadataException("Invalid list len.",
          details: {"excepted": len, "length": list.length, "info": info});
    }
  }

  static List<T> isListOf<T>(List value, {String? info}) {
    try {
      return value.cast<T>();
    } catch (e) {
      throw MetadataException(
        "Invalid list provided for casting.",
        details: {
          "info": info,
          "valueType": value.runtimeType.toString(),
          "expectedType": T.toString()
        },
      );
    }
  }

  static T isOf<T>(Object? value, {String? info}) {
    if (value == null && null is T) return null as T;
    try {
      return value! as T;
    } catch (e) {
      throw MetadataException("Invalid $T provided for casting.", details: {
        "info": info,
        "valueType": value?.runtimeType.toString(),
        "expectedType": T.toString()
      });
    }
  }

  static bool validateOptionBytes(List<int> bytes,
      {Map<String, dynamic> infos = const {}}) {
    try {
      final decode = LayoutConst.u8().deserialize(bytes.sublist(0, 1)).value;
      if (decode == 0 || decode == 1) {
        return decode == 1;
      }
      // ignore: empty_catches
    } catch (e) {}
    throw MetadataException("Invalid Metadata option bytes.",
        details: {"excepted": "0, 1", ...infos});
  }

  static List<int> createQueryPrefixHash(
      {required String prefix, required String method}) {
    final prefixHash = QuickCrypto.twoX128(prefix.codeUnits);
    final methodHasn = QuickCrypto.twoX128(method.codeUnits);
    return [...prefixHash, ...methodHasn];
  }

  static const String _eventMethodName = "Events";

  static List<int> createEventPrefixHash({required String prefix}) {
    final prefixHash = QuickCrypto.twoX128(prefix.codeUnits);
    final methodHasn = QuickCrypto.twoX128(_eventMethodName.codeUnits);
    return [...prefixHash, ...methodHasn];
  }

  static const int _prefixBytesLength = QuickCrypto.twoX128DigestSize;
  static const int _queryMethodPrefixLength =
      _prefixBytesLength + _prefixBytesLength;
  static List<int> getQueryBytesFromStorageKey(
      {required List<int> queryBytes, required List<int> prefixHash}) {
    if (queryBytes.length < _queryMethodPrefixLength) {
      throw MetadataException(
          "Invalid query bytes. Query bytes must be at least $_queryMethodPrefixLength bytes",
          details: {"length": queryBytes.length});
    }

    final queryPrefix = queryBytes.sublist(0, _queryMethodPrefixLength);
    if (!BytesUtils.bytesEqual(queryBytes, prefixHash)) {
      throw MetadataException(
          "Invalid query bytes. Query bytes does not related to this storage",
          details: {"exceptedPrefix": prefixHash, "prefix": queryPrefix});
    }
    return queryBytes.sublist(_queryMethodPrefixLength);
  }

  static bool supportedTemplate(List<String> path) {
    if (path.isEmpty) return true;
    return !MetadataConstant.unsuportedTemplatePath.contains(path.last);
  }
}
