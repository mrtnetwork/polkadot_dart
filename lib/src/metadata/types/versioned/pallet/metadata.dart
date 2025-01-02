import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';

abstract class PalletMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final PalletStorageMetadataV14? storage;
  final PalletCallMetadataV14? calls;
  final PalletEventMetadataV14? events;
  final List<PalletConstantMetadataV14> constants;
  final PalletErrorMetadataV14? errors;
  final int index;
  PalletMetadata(
      {required this.name,
      required this.storage,
      required List<PalletConstantMetadataV14> constants,
      required this.events,
      required this.calls,
      required this.errors,
      required this.index})
      : constants = constants.immutable;

  PalletMetadata.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        storage = json["storage"] == null
            ? null
            : PalletStorageMetadataV14.deserializeJson(json["storage"]),
        calls = json["calls"] == null
            ? null
            : PalletCallMetadataV14.deserializeJson(json["calls"]),
        events = json["events"] == null
            ? null
            : PalletEventMetadataV14.deserializeJson(json["events"]),
        constants = List.unmodifiable((json["constants"] as List)
            .map((e) => PalletConstantMetadataV14.deserializeJson(e))),
        errors = json["errors"] == null
            ? null
            : PalletErrorMetadataV14.deserializeJson(json["errors"]),
        index = json["index"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "name": name,
      "storage": storage?.scaleJsonSerialize(),
      "calls": calls?.scaleJsonSerialize(),
      "events": events?.scaleJsonSerialize(),
      "constants": constants.map((e) => e.scaleJsonSerialize()).toList(),
      "errors": errors?.scaleJsonSerialize(),
      "index": index
    };
  }
}
