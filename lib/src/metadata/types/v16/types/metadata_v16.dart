import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/imp/metadata_interface.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/v15/v15.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/pallet_metadata_v16.dart';
import 'package:polkadot_dart/src/metadata/types/v16/types/runtime_api_method_metadata_v16.dart';

import 'extrinsic_metadata_v16.dart';
import 'runtime_api_metadata_v16.dart';

class MetadataV16 extends SubstrateMetadata<Map<String, dynamic>>
    with LatestMetadataInterface {
  /// Type registry containing all types used in the metadata.
  final PortableRegistryV14 lookup;

  /// Metadata of all the pallets.
  @override
  final Map<int, PalletMetadataV16> pallets;

  /// Metadata of the extrinsic.
  @override
  final ExtrinsicMetadataV16 extrinsic;

  /// Metadata of the Runtime API.
  @override
  final List<RuntimeApiMetadataV16> apis;

  /// The outer enums types as found in the runtime.
  final OuterEnums15 outerEnums;

  /// Allows users to add custom types to the metadata.
  final CustomMetadata15 custom;
  MetadataV16(
      {required this.lookup,
      required List<PalletMetadataV16> pallets,
      required this.extrinsic,
      required List<RuntimeApiMetadataV16> apis,
      required this.outerEnums,
      required this.custom})
      : pallets = Map.fromEntries(pallets.map(
            (e) => MapEntry<int, PalletMetadataV16>(e.index, e))).immutable,
        apis = apis.immutable;
  MetadataV16.deserializeJson(Map<String, dynamic> json)
      : lookup = PortableRegistryV14.deserializeJson(json["lookup"]),
        pallets = Map.fromEntries((json["pallets"] as List).map((e) {
          final decode = PalletMetadataV16.deserializeJson(e);
          return MapEntry(decode.index, decode);
        })).immutable,
        extrinsic = ExtrinsicMetadataV16.deserializeJson(json["extrinsic"]),
        apis = (json["apis"] as List)
            .map((e) => RuntimeApiMetadataV16.deserializeJson(e))
            .toImutableList,
        outerEnums = OuterEnums15.deserializeJson(json["outerEnums"]),
        custom = CustomMetadata15.deserializeJson(json["custom"]);
  factory MetadataV16.fromBytes(List<int> bytes, {String? property}) {
    final decode = SubstrateMetadataLayouts.metadataV16(property: property)
        .deserialize(bytes)
        .value;
    return MetadataV16.deserializeJson(decode);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.metadataV16(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "lookup": lookup.scaleJsonSerialize(),
      "pallets": pallets.values.map((e) => e.scaleJsonSerialize()).toList(),
      "extrinsic": extrinsic.scaleJsonSerialize(),
      "outerEnums": outerEnums.scaleJsonSerialize(),
      "apis": apis.map((e) => e.scaleJsonSerialize()).toList(),
      "custom": custom.scaleJsonSerialize()
    };
  }

  @override
  PortableRegistry get registry => lookup;

  @override
  int get version => MetadataConstant.v16;

  @override
  List<String> getRuntimeApis() {
    return apis.map((e) => e.name).toList();
  }

  RuntimeApiMetadataV16 _getRuntimeApi(String apiName) {
    final api = apis.firstWhere(
      (element) => element.name.toLowerCase() == apiName.toLowerCase(),
      orElse: () => throw MetadataException("Api does not eixst.",
          details: {"apis": getRuntimeApis().join(", ")}),
    );
    return api;
  }

  RuntimeApiMethodMetadataV16 _getRuntimeMethod(
      String apiName, String methodName) {
    final api = apis.firstWhere(
      (element) => element.name.toLowerCase() == apiName.toLowerCase(),
      orElse: () => throw MetadataException("Api does not eixst.",
          details: {"apis": getRuntimeApis().join(", ")}),
    );
    final method = api.methods.firstWhere(
      (element) => element.name.toLowerCase() == methodName.toLowerCase(),
      orElse: () => throw MetadataException("Method does not eixst.", details: {
        "Api": api.name,
        "Methods": api.methods.map((e) => e.name).join(", "),
      }),
    );
    return method;
  }

  @override
  List<String> getRuntimeApiMethods(String apiName) {
    final api = apis.firstWhere(
      (element) => element.name.toLowerCase() == apiName.toLowerCase(),
      orElse: () => throw MetadataException("Api does not eixst.",
          details: {"apis": getRuntimeApis().join(", ")}),
    );
    return api.methods.map((e) => e.name).toList();
  }

  @override
  String getRuntimeApiMethod(String apiName, String methodName) {
    final api = _getRuntimeApi(apiName);
    final method = _getRuntimeMethod(apiName, methodName);
    return "${api.name}_${method.name}";
  }

  @override
  List<int> getRutimeApiInputLookupIds(String apiName, String methodName) {
    final api = _getRuntimeMethod(apiName, methodName);
    return api.inputs.map((e) => e.type).toList();
  }

  @override
  int getRutimeOutputLookupId(String apiName, String methodName) {
    final api = _getRuntimeMethod(apiName, methodName);
    return api.output;
  }

  @override
  bool get isSupportMetadataHash {
    return extrinsic.transactionExtensions.any((e) =>
        e.identifier == MetadataConstant.checkMetadataHashExtensionIdentifier);
  }

  @override
  List<TransactionExtrinsicInfo> extrinsicInfo() {
    // print(extrinsic.scaleJsonSerialize());
    // print(extrinsic.transactionExtensions.length);
    // throw UnimplementedError();
    // // return TransactionExtrinsicInfo(
    // //     extrinsic: extrinsic,
    // //     payloadExtrinsic: payloadExtrinsic,
    // //     addressType: addressType,
    // //     signatureType: signatureType,
    // //     version: version);
    final List<TransactionExtrinsicInfo> extrinsics = [];
    for (final i in extrinsic.versions) {
      final extrinsic = TransactionExtrinsicInfo(
          version: i,
          callType: null,
          addressType: this.extrinsic.addressType,
          signatureType: this.extrinsic.signatureType,
          extrinsic: [
            ...this
                .extrinsic
                .transactionExtensions
                .map((e) => ExtrinsicTypeInfo(id: e.type, name: e.identifier))
          ],
          payloadExtrinsic: [
            ...this
                .extrinsic
                .transactionExtensions
                .map((e) => ExtrinsicTypeInfo(id: e.type, name: e.identifier)),
            ...this.extrinsic.transactionExtensions.map(
                (e) => ExtrinsicTypeInfo(id: e.implicit, name: e.identifier))
          ]);
      extrinsics.add(extrinsic);
    }
    return extrinsics;
  }
}
