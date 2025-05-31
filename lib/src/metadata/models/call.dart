import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class CallMethodInfo {
  final String name;
  final List<String> docs;
  final Si1Variant variant;
  CallMethodInfo({
    required this.variant,
    required String name,
    required List<String> docs,
  })  : docs =
            docs.map((e) => e.trim()).where((e) => e.isNotEmpty).toImutableList,
        name = MetadataTypeInfoUtils.toCamelCase(name)!;
}

class CallInfo {
  final int id;
  final String palletName;
  final List<CallMethodInfo> methods;
  const CallInfo(
      {required this.id, required this.palletName, required this.methods});
}

class PalletInfo {
  final String name;
  final CallInfo? calls;
  final List<ConstantInfo>? contants;
  final List<StorageInfo>? storage;
  final List<String>? docs;

  PalletInfo(
      {required this.name,
      this.calls,
      List<String>? docs,
      List<ConstantInfo>? contants,
      List<StorageInfo>? storage})
      : docs = docs?.emptyAsNull?.immutable,
        contants = contants?.emptyAsNull?.immutable,
        storage = storage?.emptyAsNull?.immutable;
}

class MetadataInfo {
  final List<PalletInfo> pallets;
  final List<RuntimeApiInfo>? apis;
  final List<TransactionExtrinsicInfo> extrinsic;
  MetadataInfo({
    required this.extrinsic,
    required List<PalletInfo> pallets,
    List<RuntimeApiInfo>? apis,
  })  : pallets = pallets.immutable,
        apis = apis?.emptyAsNull?.immutable;
}

class ConstantInfo {
  final String name;
  final Object? value;
  final List<String> docs;
  ConstantInfo({
    required String name,
    required this.value,
    required List<String> docs,
  })  : name = MetadataTypeInfoUtils.toCamelCase(name)!,
        docs =
            docs.map((e) => e.trim()).where((e) => e.isNotEmpty).toImutableList;
}

class StorageInfo {
  final String name;
  final List<String> docs;
  final int? inputLookupId;
  final String viewName;
  StorageInfo({
    required this.inputLookupId,
    required this.name,
    required List<String> docs,
  })  : docs =
            docs.map((e) => e.trim()).where((e) => e.isNotEmpty).toImutableList,
        viewName = MetadataTypeInfoUtils.toCamelCase(name)!;
}

class RuntimeApiInputInfo {
  final String name;
  final int lockupId;
  const RuntimeApiInputInfo({required this.name, required this.lockupId});
}

class RuntimeApiMethodInfo {
  final String name;
  final String viewName;
  final List<RuntimeApiInputInfo>? inputs;
  final List<String> docs;
  RuntimeApiMethodInfo(
      {required this.name,
      required List<RuntimeApiInputInfo>? inputs,
      required List<String> docs})
      : inputs = inputs?.emptyAsNull?.immutable,
        docs =
            docs.map((e) => e.trim()).where((e) => e.isNotEmpty).toImutableList,
        viewName = MetadataTypeInfoUtils.toCamelCase(name)!;
}

class RuntimeApiInfo {
  final String name;
  final List<RuntimeApiMethodInfo>? methods;
  final List<String> docs;
  RuntimeApiInfo({
    required this.name,
    required List<RuntimeApiMethodInfo> methods,
    required List<String> docs,
  })  : methods = methods.emptyAsNull?.immutable,
        docs =
            docs.map((e) => e.trim()).where((e) => e.isNotEmpty).toImutableList;
}

class ExtrinsicTypeInfo {
  final int id;
  final String? name;
  final Object? defaultValue;
  const ExtrinsicTypeInfo({required this.id, this.name, this.defaultValue});
}

class TransactionExtrinsicInfo {
  final int version;
  final int? callType;
  final int? addressType;
  final int? signatureType;
  final List<ExtrinsicTypeInfo> extrinsic;
  final List<ExtrinsicTypeInfo> payloadExtrinsic;
  const TransactionExtrinsicInfo(
      {required this.extrinsic,
      required this.payloadExtrinsic,
      required this.addressType,
      required this.signatureType,
      this.callType,
      required this.version});
}

class DecodeCallResult {
  final String palletName;
  final Map<String, dynamic> data;
  const DecodeCallResult({required this.palletName, required this.data});
  Map<String, dynamic> toJson() {
    return {palletName: data};
  }
}
