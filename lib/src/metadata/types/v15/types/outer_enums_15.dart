import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class OuterEnums15 extends SubstrateSerialization<Map<String, dynamic>> {
  /// The type of the outer `RuntimeCall` enum.
  final int callType;

  /// The type of the outer `RuntimeEvent` enum.
  final int eventType;

  /// The module error type of the
  /// [`DispatchError::Module`](https://docs.rs/sp-runtime/24.0.0/sp_runtime/enum.DispatchError.html#variant.Module) variant.
  ///
  /// The `Module` variant will be 5 scale encoded bytes which are normally decoded into
  /// an `{ index: u8, error: [u8; 4] }` struct. This type ID points to an enum type which instead
  /// interprets the first `index` byte as a pallet variant, and the remaining `error` bytes as the
  /// appropriate `pallet::Error` type. It is an equally valid way to decode the error bytes, and
  /// can be more informative.
  ///
  /// # Note
  ///
  /// - This type cannot be used directly to decode `sp_runtime::DispatchError` from the
  ///   chain. It provides just the information needed to decode `sp_runtime::DispatchError::Module`.
  /// - Decoding the 5 error bytes into this type will not always lead to all of the bytes being consumed;
  ///   many error types do not require all of the bytes to represent them fully.
  final int errorType;
  const OuterEnums15(
      {required this.callType,
      required this.errorType,
      required this.eventType});
  OuterEnums15.deserializeJson(Map<String, dynamic> json)
      : callType = json["callType"],
        eventType = json["eventType"],
        errorType = json["errorType"];
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.outerEnums15(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "callType": callType,
      "eventType": eventType,
      "errorType": errorType
    };
  }
}
