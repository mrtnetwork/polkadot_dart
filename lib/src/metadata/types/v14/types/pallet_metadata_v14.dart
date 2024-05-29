import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'pallet_call_metadata_v14.dart';
import 'pallet_constant_metadata_v14.dart';
import 'pallet_error_metadata_v14.dart';
import 'pallet_event_metadata_v14.dart';
import 'pallet_storage_metadata_v14.dart';

class PalletMetadataV14 extends SubstrateSerialization<Map<String, dynamic>> {
  final String name;
  final PalletStorageMetadataV14? storage;
  final PalletCallMetadataV14? calls;
  final PalletEventMetadataV14? events;
  final List<PalletConstantMetadataV14> constants;
  final PalletErrorMetadataV14? errors;
  final int index;
  PalletMetadataV14({
    required this.name,
    this.storage,
    this.calls,
    this.events,
    required List<PalletConstantMetadataV14> constants,
    this.errors,
    required this.index,
  }) : constants = List<PalletConstantMetadataV14>.unmodifiable(constants);
  PalletMetadataV14.deserializeJson(Map<String, dynamic> json)
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
