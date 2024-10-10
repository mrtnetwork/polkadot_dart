import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/imp/metadata_interface.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/custom_metadata_v15.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/outer_enums_15.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/runtime_api_method_metadata_v15.dart';
import 'extrinsic_metadata_v15.dart';
import 'pallet_metadata_v15.dart';
import 'runtime_api_metadata_v15.dart';

class MetadataV15 extends SubstrateMetadata<Map<String, dynamic>>
    with LatestMetadataInterface {
  final PortableRegistryV14 lookup;
  @override
  final Map<int, PalletMetadataV15> pallets;
  final ExtrinsicMetadataV15 extrinsic;
  final int type;
  final List<RuntimeApiMetadataV15> apis;
  final OuterEnums15 outerEnums;
  final CustomMetadata15 custom;
  MetadataV15(
      {required this.lookup,
      required List<PalletMetadataV14> pallets,
      required this.extrinsic,
      required this.type,
      required List<RuntimeApiMetadataV15> apis,
      required this.outerEnums,
      required this.custom})
      : pallets = Map<int, PalletMetadataV15>.unmodifiable(
            Map.fromEntries(pallets.map((e) => MapEntry(e.index, e)))),
        apis = List<RuntimeApiMetadataV15>.unmodifiable(apis);
  MetadataV15.deserializeJson(Map<String, dynamic> json)
      : lookup = PortableRegistryV14.deserializeJson(json["lookup"]),
        pallets = Map<int, PalletMetadataV15>.unmodifiable(
            Map.fromEntries((json["pallets"] as List).map((e) {
          final decode = PalletMetadataV15.deserializeJson(e);
          return MapEntry(decode.index, decode);
        }))),
        extrinsic = ExtrinsicMetadataV15.deserializeJson(json["extrinsic"]),
        type = json["type"],
        apis = List<RuntimeApiMetadataV15>.unmodifiable((json["apis"] as List)
            .map((e) => RuntimeApiMetadataV15.deserializeJson(e))),
        outerEnums = OuterEnums15.deserializeJson(json["outerEnums"]),
        custom = CustomMetadata15.deserializeJson(json["custom"]);
  factory MetadataV15.fromBytes(List<int> bytes, {String? property}) {
    final decode = SubstrateMetadataLayouts.metadataV15(property: property)
        .deserialize(bytes)
        .value;
    return MetadataV15.deserializeJson(decode);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.metadataV15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "lookup": lookup.scaleJsonSerialize(),
      "pallets": pallets.values.map((e) => e.scaleJsonSerialize()).toList(),
      "extrinsic": extrinsic.scaleJsonSerialize(),
      "type": type,
      "outerEnums": outerEnums.scaleJsonSerialize(),
      "apis": apis.map((e) => e.scaleJsonSerialize()).toList(),
      "custom": custom.scaleJsonSerialize()
    };
  }

  @override
  PortableRegistry get registry => lookup;

  @override
  int get version => MetadataConstant.v15;

  @override
  List<String> getRuntimeApis() {
    return apis.map((e) => e.name).toList();
  }

  RuntimeApiMetadataV15 _getRuntimeApi(String apiName) {
    final api = apis.firstWhere(
      (element) => element.name.toLowerCase() == apiName.toLowerCase(),
      orElse: () => throw MetadataException("Api does not eixst.",
          details: {"apis": getRuntimeApis().join(", ")}),
    );
    return api;
  }

  RuntimeApiMethodMetadataV15 _getRuntimeMethod(
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
    return extrinsic.signedExtensions.any((e) =>
        e.identifier == MetadataConstant.checkMetadataHashExtensionIdentifier);
  }
}
