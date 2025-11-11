import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/pallet/metadata.dart';

import 'deprecation_status.dart';
import 'pallet_assosiate_type_metadata.dart';
import 'pallet_call_metadata_v16.dart';
import 'pallet_constant_v16.dart';
import 'pallet_error_v16.dart';
import 'pallet_event_v16.dart';
import 'storage_metadata_v16.dart';

class PalletMetadataV16 extends PalletMetadata<
    PalletStorageMetadataV16,
    PalletCallMetadataV16,
    PalletEventMetadataV16,
    PalletConstantMetadataV16,
    PalletErrorMetadataV16> {
  @override
  final PalletStorageMetadataV16? storage;
  @override
  final PalletCallMetadataV16? calls;
  @override
  final PalletEventMetadataV16? events;
  @override
  final PalletErrorMetadataV16? errors;

  @override
  final List<PalletConstantMetadataV16> constants;

  /// Config's trait associated types.
  final List<PalletAssociatedTypeMetadata> associatedTypes;

  /// Deprecation info
  final DeprecationStatus deprecationInfo;
  PalletMetadataV16.deserializeJson(super.json)
      : storage = json["storage"] == null
            ? null
            : PalletStorageMetadataV16.deserializeJson(json["storage"]),
        calls = json["calls"] == null
            ? null
            : PalletCallMetadataV16.deserializeJson(json["calls"]),
        constants = (json["constants"] as List)
            .map((e) => PalletConstantMetadataV16.deserializeJson(e))
            .toImutableList,
        associatedTypes = (json["associated_types"] as List)
            .map((e) => PalletAssociatedTypeMetadata.deserializeJson(e))
            .toImutableList,
        events = json["events"] == null
            ? null
            : PalletEventMetadataV16.deserializeJson(json["events"]),
        errors = json["errors"] == null
            ? null
            : PalletErrorMetadataV16.deserializeJson(json["errors"]),
        deprecationInfo =
            DeprecationStatus.deserializeJson(json["deprecation_info"]),
        super.deserializeJson();
  PalletMetadataV16(
      {required super.name,
      required List<PalletConstantMetadataV16> constants,
      required List<PalletAssociatedTypeMetadata> associatedTypes,
      required super.index,
      this.calls,
      this.errors,
      this.events,
      this.storage,
      required this.deprecationInfo,
      required List<String> super.docs})
      : constants = constants.immutable,
        associatedTypes = associatedTypes.immutable;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletMetadataV16(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      ...super.serializeJson(property: property),
      "docs": docs ?? <String>[],
      "associated_types":
          associatedTypes.map((e) => e.serializeJson()).toList(),
      "deprecation_info": deprecationInfo.serializeJsonVariant()
    };
  }
}
