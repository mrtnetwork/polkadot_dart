import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/models/generic/models/runtime_version.dart';

/// Interface providing methods for interacting with metadata in the Substrate framework.
mixin MetadataApiInterface {
  /// Returns the list of supported metadata versions.
  List<int> get supportedMetadataVersion =>
      MetadataConstant.supportedMetadataVersion;

  /// Retrieves the pallet index by name.
  int getPalletIndexByName(String name);

  /// Retrieves the pallet name by index.
  String getPalletNameByIndex(int index);

  /// Retrieves the template for a lookup.
  TypeTemlate getLookupTemplate(int id);

  /// Retrieves the template for a call.
  TypeTemlate getCallTemplate(String palletNameOrIndex);

  /// Encodes a call.
  List<int> encodeCall(
      {required String palletNameOrIndex,
      required Object? value,
      required bool fromTemplate});

  /// Encodes a lookup.
  List<int> encodeLookup(
      {required int id, required Object? value, required bool fromTemplate});

  /// Decodes a lookup.
  T decodeLookup<T>(int id, List<int> bytes);

  /// Decodes a call.
  T decodeCall<T>(List<int> bytes);

  /// Retrieves the constant value.
  T getConstant<T>(String palletNameOrIndex, String constantName);

  /// Retrieves all constants for a pallet.
  Map<String, dynamic> getConstants(String palletNameOrIndex);

  /// Retrieves the list of pallet names.
  List<String> getPalletNames();

  /// Retrieves the list of pallet indexes.
  List<int> getPalletIndexes();

  /// Retrieves the template for an event.
  TypeTemlate getEventTemplate({int? eventRecordLookupId});

  /// Retrieves the template for storage input.
  TypeTemlate? getStorageInputTemplate(
      String palletNameOrIndex, String methodName);

  /// Retrieves the template for storage output.
  TypeTemlate getStorageOutputTemplate(
      String palletNameOrIndex, String methodName);

  /// Encodes storage input.
  List<int> encodeStorageMethodInput({
    required String palletNameOrIndex,
    required String methodName,
    required bool fromTemplate,
    required Object? value,
  });

  /// Decodes storage input.
  T decodeStorageInput<T>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int> bytes});

  /// Decodes storage output.
  T decodeStorageResponse<T>(
      {required String palletNameOrIndex,
      required String methodName,
      List<int>? queryResponse});

  /// Generates a query storage key.
  List<int> getStorageKey({
    required String palletNameOrIndex,
    required String methodName,
    required bool fromTemplate,
    required Object? value,
  });

  /// Decodes a query storage key.
  T decodeQueryStorageKey<T>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int> bytes});

  /// Generates an event storage key.
  List<int> generateEventStorageKey();

  /// Decodes an event.
  T decodeEvent<T>(
      {String palletNameOrIndex = MetadataConstant.genericSystemPalletName,
      required List<int> bytes});

  /// Retrieves runtime version information.
  RuntimeVersion runtimeVersion();

  /// Retrieves the list of storage methods for a pallet.
  List<String> getPalletStorageMethods(String palletNameOrIndex);

  List<String> getRuntimeApis();

  List<String> getRuntimeApiMethods(String apiName);

  String getRuntimeApiMethod(String apiName, String methodName);
  List<int> getRuntimeApiInputLookupIds(String apiName, String methodName);

  int getRuntimeApiOutputLookupId(String apiName, String methodName);

  List<TypeTemlate> getRuntimeApiInputsTemplates(
      String apiName, String methodName);
  TypeTemlate getRuntimeApiOutputTemplate(String apiName, String methodName);

  List<int> encodeRuntimeApiInputs(
      {required String apiName,
      required String methodName,
      required List<Object?> params,
      bool fromTemplate = true});
  T decodeRuntimeApiOutput<T>(
      {required String apiName,
      required String methodName,
      required List<int> bytes});

  int getCallLookupId(String palletNameOrIndex);
}
