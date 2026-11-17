import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum VariantDeprecationInfoTypes {
  deprecatedWithoutNote,
  deprecated;

  static VariantDeprecationInfoTypes fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown VariantDeprecationInfoTypes name "$name".',
              ),
    );
  }
}

abstract class VariantDeprecationInfo extends SubstrateVariantSerialization {
  final VariantDeprecationInfoTypes type;
  const VariantDeprecationInfo._(this.type);

  factory VariantDeprecationInfo.deserialize(
    List<int> bytes, {
    String? property,
  }) {
    final decode = SubstrateVariantSerialization.deserialize(
      bytes: bytes,
      layout: layout_(property: property),
    );
    return VariantDeprecationInfo.deserializeJson(decode);
  }

  factory VariantDeprecationInfo.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = VariantDeprecationInfoTypes.fromName(decode.variantName);
    switch (type) {
      case VariantDeprecationInfoTypes.deprecated:
        return VariantDeprecated.deserializeJson(decode.value);
      case VariantDeprecationInfoTypes.deprecatedWithoutNote:
        return const VariantDeprecatedWithoutNote();
    }
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return SubstrateMetadataLayouts.variantDeprecationInfoV16(
      property: property,
    );
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
}

class VariantDeprecated extends VariantDeprecationInfo {
  final String note;
  final String? since;
  const VariantDeprecated({required this.note, required this.since})
    : super._(VariantDeprecationInfoTypes.deprecated);

  factory VariantDeprecated.deserializeJson(Map<String, dynamic> json) {
    return VariantDeprecated(note: json["note"], since: json["since"]);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.deprecatedV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"note": note, "since": since};
  }
}

class VariantDeprecatedWithoutNote extends VariantDeprecationInfo {
  const VariantDeprecatedWithoutNote()
    : super._(VariantDeprecationInfoTypes.deprecatedWithoutNote);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.noArgs();
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}
