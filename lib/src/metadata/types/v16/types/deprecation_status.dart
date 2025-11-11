import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum DeprecationStatusTypes {
  notDeprecated,
  deprecatedWithoutNote,
  deprecated;

  static DeprecationStatusTypes fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class DeprecationStatus extends SubstrateVariantSerialization {
  final DeprecationStatusTypes type;
  const DeprecationStatus._(this.type);

  factory DeprecationStatus.deserialize(List<int> bytes, {String? property}) {
    final decode = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_(property: property));
    return DeprecationStatus.deserializeJson(decode);
  }
  factory DeprecationStatus.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = DeprecationStatusTypes.fromName(decode.variantName);
    switch (type) {
      case DeprecationStatusTypes.deprecated:
        return MetadataStatusDeprecated.deserializeJson(decode.value);
      case DeprecationStatusTypes.notDeprecated:
        return MetadataStatusNotDeprecated();
      case DeprecationStatusTypes.deprecatedWithoutNote:
        return MetadataStatusDeprecatedWithoutNote();
    }
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return SubstrateMetadataLayouts.depecratedStatusV16(property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
}

class MetadataStatusDeprecated extends DeprecationStatus {
  /// Note explaining the deprecation
  final String note;

  /// Optional value for denoting version when the deprecation occurred.
  final String? since;
  const MetadataStatusDeprecated({required this.note, required this.since})
      : super._(DeprecationStatusTypes.deprecated);

  factory MetadataStatusDeprecated.deserializeJson(Map<String, dynamic> json) {
    return MetadataStatusDeprecated(note: json["note"], since: json["since"]);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.depecratedV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"note": note, "since": since};
  }
}

class MetadataStatusNotDeprecated extends DeprecationStatus {
  const MetadataStatusNotDeprecated()
      : super._(DeprecationStatusTypes.notDeprecated);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.noArgs();
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}

class MetadataStatusDeprecatedWithoutNote extends DeprecationStatus {
  const MetadataStatusDeprecatedWithoutNote()
      : super._(DeprecationStatusTypes.deprecatedWithoutNote);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.noArgs();
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}
