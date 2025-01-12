import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/layout/byte/byte_handler.dart';
import 'package:polkadot_dart/src/exception/exception.dart';

mixin JsonSerialization {
  Map<String, dynamic> toJson();
  @override
  String toString() {
    return "$runtimeType${toJson()}";
  }
}

abstract class SubstrateSerialization<T> {
  const SubstrateSerialization();

  static LayoutDecodeResult deserialize(
      {required List<int> bytes, required Layout layout, required int offset}) {
    final reader = LayoutByteReader(bytes);
    final decodeBytes = layout.decode(reader, offset: offset);
    return decodeBytes;
  }

  List<int> serialize({String? property}) {
    final scaleLayout = layout();
    final LayoutByteWriter data = LayoutByteWriter(scaleLayout.span);
    final size =
        scaleLayout.encode(scaleJsonSerialize(property: property), data);
    if (scaleLayout.span < 0) {
      return data.sublist(0, size);
    }
    return data.toBytes();
  }

  Layout<T> layout({String? property});

  T scaleJsonSerialize({String? property});

  String toHex({String? prefix, bool lowerCase = true}) {
    return BytesUtils.toHexString(serialize(),
        lowerCase: lowerCase, prefix: prefix);
  }

  @override
  String toString() {
    return "$runtimeType${scaleJsonSerialize()}";
  }
}

class SubstrateVariantDecodeResult {
  final Map<String, dynamic> result;
  String get variantName => result['key'];
  Map<String, dynamic> get value => result['value'];
  SubstrateVariantDecodeResult(Map<String, dynamic> result)
      : result = result.immutable;

  @override
  String toString() {
    return '$variantName: $value';
  }
}

abstract class SubstrateVariantSerialization
    extends SubstrateSerialization<Map<String, dynamic>> {
  const SubstrateVariantSerialization();
  static SubstrateVariantDecodeResult toVariantDecodeResult(
      Map<String, dynamic> json) {
    if (json['key'] is! String || !json.containsKey('value')) {
      throw const DartSubstratePluginException(
          'Invalid variant layout. only use enum layout to deserialize with `SubstrateVariantSerialization.deserialize` method.');
    }
    return SubstrateVariantDecodeResult(json);
  }

  static Map<String, dynamic> deserialize(
      {required List<int> bytes,
      required Layout<Map<String, dynamic>> layout}) {
    final json = layout.deserialize(bytes).value;
    if (json['key'] is! String || !json.containsKey('value')) {
      throw const DartSubstratePluginException(
          'Invalid variant layout. only use enum layout to deserialize with `SubstrateVariantSerialization.deserialize` method.');
    }
    return json;
  }

  String get variantName;
  Layout<Map<String, dynamic>> createVariantLayout({String? property});
  Map<String, dynamic> toVariantScaleJsonSerialize() {
    return {variantName: scaleJsonSerialize()};
  }

  List<int> serializeVariant({String? property}) {
    final scaleLayout = createVariantLayout(property: property);
    return scaleLayout.serialize(toVariantScaleJsonSerialize());
  }
}
