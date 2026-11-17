import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/variant_deprecation_info.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class EnumDeprecationInfo
    extends SubstrateSerialization<Map<int, Map<String, dynamic>>> {
  final Map<int, VariantDeprecationInfo> deprecatedVariants;
  EnumDeprecationInfo(Map<int, VariantDeprecationInfo> deprecatedVariants)
    : deprecatedVariants = deprecatedVariants.immutable;

  factory EnumDeprecationInfo.deserializeJson(Map<dynamic, dynamic> json) {
    return EnumDeprecationInfo(
      json.map(
        (k, v) => MapEntry(
          (k as int),
          VariantDeprecationInfo.deserializeJson(
            (v as Map).cast<String, dynamic>(),
          ),
        ),
      ),
    );
  }

  bool get hasDeprecatedVariants => deprecatedVariants.isNotEmpty;
  bool isVariantDeprecated(int variantIndex) =>
      deprecatedVariants.containsKey(variantIndex);

  @override
  CustomLayout<Map<String, dynamic>, Map<int, Map<String, dynamic>>> layout({
    String? property,
  }) {
    return SubstrateMetadataLayouts.enumDeprecationInfoV16(property: property);
  }

  @override
  Map<int, Map<String, dynamic>> serializeJson({String? property}) {
    return {
      for (final e in deprecatedVariants.entries)
        e.key: e.value.serializeJsonVariant(),
    };
  }
}
