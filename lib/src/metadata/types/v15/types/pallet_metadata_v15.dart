import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/pallet/metadata.dart';

class PalletMetadataV15 extends PalletMetadata {
  final List<String> docs;
  PalletMetadataV15.deserializeJson(super.json)
      : docs = List<String>.unmodifiable(json["docs"]),
        super.deserializeJson();
  PalletMetadataV15(
      {required super.name,
      required super.constants,
      required super.index,
      super.calls,
      super.errors,
      super.events,
      super.storage,
      required List<String> docs})
      : docs = List<String>.unmodifiable(docs);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletMetadataV15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {...super.scaleJsonSerialize(property: property), "docs": docs};
  }
}
