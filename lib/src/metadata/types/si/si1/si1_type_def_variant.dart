import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/generic.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';

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
  Map<String, dynamic> serializeJson({String? property}) {
    return {"variants": variants.map((e) => e.serializeJson()).toList()};
  }

  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.variant;

  Map<String, dynamic> toJson() {
    return serializeJson();
  }

  @override
  String toString() {
    return "Si1TypeDefVariant${toJson()}";
  }

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id,
      {String? method}) {
    List<Si1Variant> variants = this.variants;
    if (method != null) {
      variants = variants
          .where((e) => e.name.toLowerCase() == method.toLowerCase())
          .toList();
    }
    return TypeTemlate(
        lookupId: id,
        type: typeName,
        children: variants.map((e) => e.typeTemplate(registry, id)).toList());
  }

  /// Checks the provided [value] and returns the correct data compared to the template or simple design,
  /// using the provided [registry], [fromTemplate] flag.
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
        id: self,
        registry: registry);

    String key;
    if (fromTemplate) {
      key = MetadataCastingUtils.getVariantKey(value);
    } else {
      if (data is String) {
        key = data;
        data = null;
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
    }
    final variant = variants.firstWhere(
      (element) => element.name == key,
      orElse: () => throw MetadataException(
          "Unable to find the current enum variant $key.",
          details: {
            "key": key,
            "variants": variants.map((e) => e.name).join(", ")
          }),
    );
    if (data is LookupRawParam) {
      data = MetadataCastingUtils.getValue(
          value: LookupRawParam(bytes: [variant.index, ...data.bytes]),
          type: typeName,
          fromTemplate: fromTemplate,
          id: self,
          registry: registry);
      final mapValue = MetadataCastingUtils.isMap<String, dynamic>(data);
      data = mapValue[variant.name];
    }
    return {
      key: variant.getValue(registry,
          value: data, fromTemplate: fromTemplate, self: self)
    };
  }

  List<String> get getVariantNames =>
      variants.map((e) => "${e.name} ").toList();

  @override
  MetadataTypeInfo typeInfo(PortableRegistry registry, int id) {
    return MetadataTypeInfoVariant(typeId: id, variants: variants, name: null);
  }

  @override
  int? typeByFieldName(PortableRegistry registry, int id, String name) {
    for (final i in variants) {
      if (i.name == name) {
        return id;
      }
      for (final f in i.fields) {
        if (f.name == name) {
          return f.type;
        }
      }
    }
    return null;
  }

  @override
  int? typeByName(PortableRegistry registry, int id, String name) {
    for (final i in variants) {
      for (final f in i.fields) {
        if (f.typeName == name) {
          return f.type;
        }
      }
    }
    return null;
  }

  @override
  Layout serializationLayout(PortableRegistry registry,
      {String? property, LookupDecodeParams? params}) {
    final layouts = variants
        .map((e) => LazyVariantModel(
            layout: ({property}) => e.serializationLayout(registry,
                property: property, params: params),
            property: e.name,
            index: e.index))
        .toList();
    return LayoutConst.lazyEnum(layouts,
        useKeyAndValue: false, property: property);
  }
}
