import 'package:polkadot_dart/src/metadata/types/versioned/pallet/metadata.dart';

class PalletMetadataV14 extends PalletMetadata {
  PalletMetadataV14(
      {required super.name,
      super.storage,
      super.calls,
      super.events,
      required super.constants,
      super.errors,
      required super.index});
  PalletMetadataV14.deserializeJson(super.json) : super.deserializeJson();
}
