import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class PalletCallMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  abstract final int type;
  const PalletCallMetadata();
}

class PalletCallMetadataV14 extends PalletCallMetadata {
  @override
  final int type;
  const PalletCallMetadataV14(this.type);
  PalletCallMetadataV14.deserializeJson(Map<String, dynamic> json)
      : type = json["type"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletCallMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"type": type};
  }
}

abstract class BaseMetadataInterface {
  Layout typeDefLayout(PortableRegistry registry, dynamic value,
      {String? property, int? id});
  String showTemplate(PortableRegistry registry);
  LayoutDecodeResult decode(PortableRegistry registry, List<int> bytes);
}
