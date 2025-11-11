import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_call_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_constant_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_error_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_event_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_storage_metadata_v14.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class PalletMetadata<
        STORAGE extends PalletStorageMetadata,
        CALL extends PalletCallMetadata,
        EVENT extends PalletEventMetadata,
        CONSTANT extends PalletConstantMetadata,
        ERROR extends PalletErrorMetadata>
    extends SubstrateSerialization<Map<String, dynamic>> {
  /// Pallet name.
  final String name;

  /// Pallet storage metadata.
  abstract final STORAGE? storage;

  /// Pallet calls metadata.
  abstract final PalletCallMetadata? calls;

  /// Pallet event metadata.
  abstract final EVENT? events;

  /// Pallet constants metadata.
  abstract final List<CONSTANT> constants;

  /// Pallet error metadata.
  abstract final ERROR? errors;

  /// Define the index of the pallet, this index will be used for the encoding of pallet event,
  /// call and origin variants.
  final int index;

  final List<String>? docs;

  PalletMetadata({required this.name, required this.index, required this.docs});

  PalletMetadata.deserializeJson(Map<String, dynamic> json)
      : name = json["name"],
        index = json["index"],
        docs = (json["docs"] as List?)?.cast<String>().immutable;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.palletMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "name": name,
      "storage": storage?.serializeJson(),
      "calls": calls?.serializeJson(),
      "events": events?.serializeJson(),
      "constants": constants.map((e) => e.serializeJson()).toList(),
      "errors": errors?.serializeJson(),
      "index": index
    };
  }
}
