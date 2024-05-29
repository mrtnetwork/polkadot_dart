import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/imp/metadata_interface.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/portable_registry.dart';
import 'extrinsic_metadata_v14.dart';
import 'pallet_metadata_v14.dart';

class MetadataV14 extends SubstrateMetadata<Map<String, dynamic>>
    with LatestMetadataInterface {
  final PortableRegistryV14 lookup;
  @override
  final Map<int, PalletMetadataV14> pallets;
  final ExtrinsicMetadataV14 extrinsic;
  final int type;
  MetadataV14(
      {required this.lookup,
      required List<PalletMetadataV14> pallets,
      required this.extrinsic,
      required this.type})
      : pallets = Map<int, PalletMetadataV14>.unmodifiable(
            Map.fromEntries(pallets.map((e) => MapEntry(e.index, e))));
  MetadataV14.deserializeJson(Map<String, dynamic> json)
      : lookup = PortableRegistryV14.deserializeJson(json["lookup"]),
        pallets = Map<int, PalletMetadataV14>.unmodifiable(
            Map.fromEntries((json["pallets"] as List).map((e) {
          final decode = PalletMetadataV14.deserializeJson(e);
          return MapEntry(decode.index, decode);
        }))),
        extrinsic = ExtrinsicMetadataV14.deserializeJson(json["extrinsic"]),
        type = json["type"];
  factory MetadataV14.fromBytes(List<int> bytes, {String? property}) {
    final decode = SubstrateMetadataLayouts.metadataV14(property: property)
        .deserialize(bytes)
        .value;
    return MetadataV14.deserializeJson(decode);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.metadataV14(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "lookup": lookup.scaleJsonSerialize(),
      "pallets": pallets.values.map((e) => e.scaleJsonSerialize()).toList(),
      "extrinsic": extrinsic.scaleJsonSerialize(),
      "type": type
    };
  }

  @override
  PortableRegistry get registry => lookup;

  @override
  int get version => MetadataConstant.v14;
}
