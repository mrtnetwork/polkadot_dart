import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'si1_variant.dart';

class Si1TypeDefVariant extends Si1TypeDef<Map<String, dynamic>> {
  final List<Si1Variant> variants;
  Si1TypeDefVariant(List<Si1Variant> variants)
      : variants = List<Si1Variant>.unmodifiable(variants);
  Si1TypeDefVariant.deserializeJson(Map<String, dynamic> json)
      : variants = List<Si1Variant>.unmodifiable((json["variants"] as List)
            .map((e) => Si1Variant.deserializeJson(e)));
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.si1TypeDefVariant(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"variants": variants.map((e) => e.scaleJsonSerialize()).toList()};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.variant;

  Map<String, dynamic> toJson() {
    return scaleJsonSerialize();
  }

  @override
  String toString() {
    return "Si1TypeDefVariant${toJson()}";
  }

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    final mapValue = MetadataUtils.isOf<Map<String, dynamic>>(value);

    if (mapValue.length != 1) {
      throw const MetadataException(
          "The provided map for enum must contain exactly one key");
    }
    final enumName = mapValue.keys.first;

    final variant = variants.firstWhere(
      (element) => element.name == enumName,
      orElse: () => throw MetadataException(
          "Unable to find the current enum variant.",
          details: {
            "key": enumName,
            "variants": variants.map((e) => e.name).join(", ")
          }),
    );
    final variantLayout = variant.typeDefLayout(registry, mapValue[enumName],
        property: variant.name);
    final unsudedVariants = variant.index == 0
        ? []
        : List.generate(variant.index,
            (index) => LayoutConst.none(property: "_Unsued$index"));
    return LayoutConst.rustEnum([
      ...unsudedVariants,
      variantLayout,
    ], property: property);
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    if (bytes.isEmpty) {
      throw const MetadataException("Invalid variant bytes");
    }
    final index = bytes[0];
    final variant = variants.firstWhere(
      (element) => element.index == index,
      orElse: () => throw MetadataException(
          "Unable to find the current enum variant index.",
          details: {
            "index": index,
            "indexes": variants.map((e) => e.index).join(", ")
          }),
    );
    final decode = variant.decode(registry, bytes.sublist(1));
    return LayoutDecodeResult(
        consumed: decode.consumed + 1, value: decode.value);
  }

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    return TypeTemlate(
        lookupId: id,
        type: typeName,
        children: variants.map((e) => e.typeTemplate(registry, id)).toList());
  }

  /// Checks the provided [value] and returns the correct data compared to the template or simple design,
  /// using the provided [registry], [fromTemplate] flag, and optional [property].
  @override
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self}) {
    Object? data = MetadataCastingUtils.getValue(
        value: value,
        type: typeName,
        fromTemplate: fromTemplate,
        lookupId: self);

    String key;
    if (fromTemplate) {
      key = MetadataCastingUtils.getVariantKey(value);
    } else {
      final mapValue = MetadataCastingUtils.isMap<String, dynamic>(data);

      if (mapValue.length != 1) {
        throw MetadataException(
            "The provided map for enum must contain exactly one key",
            details: {
              "value": value,
              "lookup_id": self,
              "from_template": fromTemplate,
            });
      }
      key = mapValue.keys.first;
      data = mapValue[key];
    }
    final variant = variants.firstWhere(
      (element) => element.name == key,
      orElse: () => throw MetadataException(
          "Unable to find the current enum variant.",
          details: {
            "key": key,
            "variants": variants.map((e) => e.name).join(", ")
          }),
    );
    return {
      key: variant.getValue(registry, value: data, fromTemplate: fromTemplate)
    };
  }

  List<String> get getVariantNames =>
      variants.map((e) => "${e.name} ").toList();
}
