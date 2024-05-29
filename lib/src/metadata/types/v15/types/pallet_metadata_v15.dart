import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_constant_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_metadata_v14.dart';

class PalletMetadataV15 extends PalletMetadataV14 {
  final List<String> docs;
  PalletMetadataV15.deserializeJson(Map<String, dynamic> json)
      : docs = List<String>.unmodifiable(json["docs"]),
        super.deserializeJson(json);
  PalletMetadataV15(
      {required String name,
      required List<PalletConstantMetadataV14> constants,
      required int index,
      required List<String> docs})
      : docs = List<String>.unmodifiable(docs),
        super(name: name, constants: constants, index: index);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletMetadataV15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {...super.scaleJsonSerialize(property: property), "docs": docs};
  }
}
