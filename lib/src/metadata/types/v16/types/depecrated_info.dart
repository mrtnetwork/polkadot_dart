import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';

enum DeprecationInfoTypes {
  notDeprecated,
  itemDeprecated,
  variantsDeprecated;

  static DeprecationInfoTypes fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw DartSubstratePluginException(
          'MetadataDeprecationInfo type not found.',
          details: {
            'name': name,
            'values': values.map((e) => e.name).join(', ')
          }),
    );
  }
}

abstract class MetadataDeprecationInfo extends SubstrateVariantSerialization {
  final DeprecationInfoTypes type;
  const MetadataDeprecationInfo._(this.type);

  factory MetadataDeprecationInfo.deserialize(List<int> bytes,
      {String? property}) {
    final decode = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_(property: property));
    return MetadataDeprecationInfo.deserializeJson(decode);
  }
  factory MetadataDeprecationInfo.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = DeprecationInfoTypes.fromName(decode.variantName);
    switch (type) {
      case DeprecationInfoTypes.variantsDeprecated:
        return MetadataVariantsDeprecated.deserializeJson(decode.value);
      case DeprecationInfoTypes.notDeprecated:
        return MetadataNotDeprecated();
      case DeprecationInfoTypes.itemDeprecated:
        return MetadataItemDeprecated.deserializeJson(decode.value);
    }
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return SubstrateMetadataLayouts.depecratedInfo(property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
}

/// Entry is partially deprecated.
class MetadataVariantsDeprecated extends MetadataDeprecationInfo {
  final Map<int, DeprecationStatus> depecreatedVariants;
  MetadataVariantsDeprecated(Map<int, DeprecationStatus> depecreatedVariants)
      : depecreatedVariants = depecreatedVariants.immutable,
        super._(DeprecationInfoTypes.variantsDeprecated);

  factory MetadataVariantsDeprecated.deserializeJson(
      Map<String, dynamic> json) {
    return MetadataVariantsDeprecated((json["depecreatedVariants"] as Map)
        .map((k, v) => MapEntry(k, DeprecationStatus.deserializeJson(v))));
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.variantsDeprecated(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      'depecreatedVariants': depecreatedVariants
          .map((k, v) => MapEntry(k, v.toVariantScaleJsonSerialize()))
    };
  }
}

/// Type is not deprecated
class MetadataNotDeprecated extends MetadataDeprecationInfo {
  const MetadataNotDeprecated() : super._(DeprecationInfoTypes.notDeprecated);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.noArgs();
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {};
  }
}

/// Entry is fully deprecated.
class MetadataItemDeprecated extends MetadataDeprecationInfo {
  final DeprecationStatus status;
  const MetadataItemDeprecated(this.status)
      : super._(DeprecationInfoTypes.itemDeprecated);
  factory MetadataItemDeprecated.deserializeJson(Map<String, dynamic> json) {
    return MetadataItemDeprecated(
        DeprecationStatus.deserializeJson(json['status']));
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.itemDeprecated(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {'status': status.toVariantScaleJsonSerialize()};
  }
}
