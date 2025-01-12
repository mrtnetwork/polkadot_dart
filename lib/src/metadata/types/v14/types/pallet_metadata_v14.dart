import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_call_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_constant_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_error_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_event_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_storage_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/pallet/metadata.dart';

class PalletMetadataV14 extends PalletMetadata<
    PalletStorageMetadataV14,
    PalletCallMetadataV14,
    PalletEventMetadataV14,
    PalletConstantMetadataV14,
    PalletErrorMetadataV14> {
  @override
  final PalletStorageMetadataV14? storage;

  @override
  final PalletCallMetadataV14? calls;

  @override
  final PalletEventMetadataV14? events;
  @override
  final List<PalletConstantMetadataV14> constants;

  @override
  final PalletErrorMetadataV14? errors;

  PalletMetadataV14(
      {required super.name,
      required this.storage,
      this.calls,
      this.events,
      required List<PalletConstantMetadataV14> constants,
      this.errors,
      required super.index})
      : constants = constants.immutable,
        super(docs: null);
  PalletMetadataV14.deserializeJson(super.json)
      : storage = json["storage"] == null
            ? null
            : PalletStorageMetadataV14.deserializeJson(json["storage"]),
        constants = List.unmodifiable((json["constants"] as List)
            .map((e) => PalletConstantMetadataV14.deserializeJson(e))),
        calls = json["calls"] == null
            ? null
            : PalletCallMetadataV14.deserializeJson(json["calls"]),
        events = json["events"] == null
            ? null
            : PalletEventMetadataV14.deserializeJson(json["events"]),
        errors = json["errors"] == null
            ? null
            : PalletErrorMetadataV14.deserializeJson(json["errors"]),
        super.deserializeJson();
}
