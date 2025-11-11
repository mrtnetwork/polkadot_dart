import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/layouts/layouts.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/generic/models/module_error.dart';
import 'package:polkadot_dart/src/models/modesl.dart';
import 'package:polkadot_dart/src/provider/methods/methods.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateRuntimeApis {
  xcmPaymentApi("XcmPaymentApi", "6ff52ee858e6c5bd", [1]),
  ethereumRuntimeRPCApi("EthereumRuntimeRPCApi", "582211f65bb14b89", [6]),
  dryRunApi("DryRunApi", "91b1c8b16328eb92", [1, 2]),
  assetConversionApi("AssetConversionApi", "8a8047a53a8277ec", [1]);

  final String name;
  final String hash;
  final List<int> versions;
  const SubstrateRuntimeApis(this.name, this.hash, this.versions);

  String buildMethodName(String method) {
    return "${name}_$method";
  }
}

abstract class SubstrateRuntimeApiMethods {
  abstract final String method;
}

typedef ONRUNTIMECALL<T extends Object?> = Future<T> Function(bool useApi);

abstract class SubstrateRuntimeApi {
  const SubstrateRuntimeApi();
  SubstrateRuntimeApis get api;
  int getApiVersion(MetadataApi api) {
    final runtime = api.runtimeVersion();
    return runtime.apis
        .firstWhere(
          (e) => StringUtils.hexEqual(e.apiId, this.api.hash),
          orElse: () => throw DartSubstratePluginException(
              "Runtime api not available.",
              details: {"api": this.api.name}),
        )
        .version;
  }

  bool methodExists(
      {required SubstrateRuntimeApiMethods method, required MetadataApi api}) {
    final exists = api.metadata
        .runtimeMethodExists(this.api.name, methodName: method.method);
    if (exists) return true;
    final runtime = api.runtimeVersion();
    final runtimeApi = runtime.apis.firstWhereNullable(
        (e) => StringUtils.hexEqual(e.apiId, this.api.hash));
    return this.api.versions.contains(runtimeApi?.version);
  }

  bool methodsExists(
      {required List<SubstrateRuntimeApiMethods> methods,
      required MetadataApi api}) {
    final exists = methods.every((e) =>
        api.metadata.runtimeMethodExists(this.api.name, methodName: e.method));
    if (exists) return true;
    final runtime = api.runtimeVersion();
    final runtimeApi = runtime.apis.firstWhereNullable(
        (e) => StringUtils.hexEqual(e.apiId, this.api.hash));
    return this.api.versions.contains(runtimeApi?.version);
  }

  Future<T> callRuntimeApiInternal<T extends Object?>(
      {required SubstrateRuntimeApiMethods method,
      required MetadataApi api,
      required SubstrateProvider provider,
      List<Object?> params = const []}) async {
    // final exists = api.metadata
    //     .runtimeMethodExists(this.api.name, methodName: method.method);
    // if (exists) {
    //   return await api.runtimeCall<T>(
    //       apiName: this.api.name,
    //       methodName: method.method,
    //       params: params,
    //       rpc: provider,
    //       fromTemplate: false);
    // }
    final types = SubstrateRuntimeApiConstants.apis[method.method];
    if (types == null) {
      throw DartSubstratePluginException("Runtime api not available.",
          details: {"api": this.api.name});
    }
    final runtime = api.runtimeVersion();
    final runtimeApi = runtime.apis.firstWhere(
      (e) => StringUtils.hexEqual(e.apiId, this.api.hash),
      orElse: () => throw DartSubstratePluginException(
          "Runtime api not available.",
          details: {"api": this.api.name}),
    );
    if (!this.api.versions.contains(runtimeApi.version)) {
      throw DartSubstratePluginException("Unsupported runtime api version.",
          details: {
            "api": this.api.name,
            "method": method.method,
            "version": runtimeApi.version
          });
    }

    final encode = types
        .inputBuilder(api, runtimeApi.version)
        .serializeHex(params, prefix: "0x");
    final result = await provider.request(SubstrateRequestStateCall(
        method: this.api.buildMethodName(method.method), data: encode));

    return types
        .outputBuilder(api, runtimeApi.version)
        .deserialize(result)
        .value;
  }
}

class _DryRunResultUtils {
  static List<String> getExecutionResultErrorParts(Map<String, dynamic> error) {
    List<String> errors = [error.keys.first];
    final val = error.values.first;
    if (val is Map<String, dynamic>) {
      errors.addAll(getExecutionResultErrorParts(val));
    }
    return errors;
  }
}

enum DispatchResultType {
  ok("Ok"),
  err("Err");

  bool get isOk => this == ok;
  final String method;
  const DispatchResultType(this.method);
  static DispatchResultType fromJson(Map<String, dynamic>? json) {
    return values.firstWhere(
      (e) => e.method == json?.keys.firstOrNull,
      orElse: () =>
          throw DartSubstratePluginException("Invalid DispatchResult json."),
    );
  }
}

abstract class DispatchResultWithPostInfo {
  final DispatchResultType type;
  Map<String, dynamic> toJson();
  const DispatchResultWithPostInfo({required this.type});
  factory DispatchResultWithPostInfo.fromJson(Map<String, dynamic> json,
      {ONEVENTDISPATCHERROR? onParseModuleError}) {
    final type = DispatchResultType.fromJson(json);
    return switch (type) {
      DispatchResultType.err => DispatchResultWithPostInfoErr.fromJson(
          json[type.method],
          onParseModuleError: onParseModuleError),
      DispatchResultType.ok =>
        DispatchResultWithPostInfoOk.fromJson(json[type.method])
    };
  }
  static Layout buildDispatchLayout(
      {required MetadataApi metadata, String? property}) {
    final id = metadata.typeByPathTail("Result");
    if (id == null) {
      throw DartSubstratePluginException(
          "Failed to build dispatch result layout. type not found.");
    }
    final varinatins = metadata.getTypeDefination<Si1TypeDefVariant>(id);
    final errr = varinatins.variants.firstWhere(
      (e) => e.name == "Err",
      orElse: () => throw DartSubstratePluginException(
          "Failed to build dispatch result layout. type not found."),
    );
    final oK = varinatins.variants.firstWhere(
      (e) => e.name == "Ok",
      orElse: () => throw DartSubstratePluginException(
          "Failed to build dispatch result layout. type not found."),
    );
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              DispatchResultWithPostInfoOk.layout(property: property),
          property: oK.name,
          index: oK.index),
      LazyVariantModel(
          layout: ({property}) => DispatchResultWithPostInfoErr.layout(
              metadata: metadata, property: property),
          property: errr.name,
          index: errr.index),
    ], useKeyAndValue: false, property: property);
    // LazyVariantModel(layout: layout, property: property, index: index)
  }

  T cast<T extends DispatchResultWithPostInfo>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

class DispatchResultWithPostInfoOk extends DispatchResultWithPostInfo {
  final SubstrateWeightV2? actualWeight;
  final bool paysFee;
  DispatchResultWithPostInfoOk(
      {required this.actualWeight, required this.paysFee})
      : super(type: DispatchResultType.ok);

  factory DispatchResultWithPostInfoOk.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? actualWeight =
        MetadataUtils.parseOptional(json["actual_weight"]);
    final Map<String, dynamic> paysFee = json["pays_fee"];
    return DispatchResultWithPostInfoOk(
        actualWeight: actualWeight == null
            ? null
            : SubstrateWeightV2.deserializeJson(actualWeight),
        paysFee: paysFee.containsKey("Yes"));
  }

  static Layout layout({String? property}) {
    return LayoutConst.struct([
      MetadataUtils.optionalLayout(
          ({property}) => SubstrateWeightV2.layout_(property: property),
          property: "actual_weight"),
      LayoutConst.rustEnum([
        LayoutConst.none(property: "Yes"),
        LayoutConst.none(property: "No"),
      ], property: "pays_fee", useKeyAndValue: false),
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.method: {
        "actual_weight": MetadataUtils.toOptionalJson(actualWeight),
        "pays_fee": {paysFee ? "Yes" : "No": null}
      }
    };
  }
}

class DispatchResultWithPostInfoErr extends DispatchResultWithPostInfo {
  final SubstrateWeightV2? actualWeight;
  final bool paysFee;
  final Map<String, dynamic> errorJson;
  final List<String> errorTypes;
  final Map<String, dynamic>? description;
  DispatchResultWithPostInfoErr({
    required this.actualWeight,
    required this.paysFee,
    required Map<String, dynamic> errorJson,
    required this.errorTypes,
    this.description,
  })  : errorJson = errorJson.immutable,
        super(type: DispatchResultType.err);
  static Layout layout({required MetadataApi metadata, String? property}) {
    return LayoutConst.struct([
      LayoutConst.struct([
        MetadataUtils.optionalLayout(
            ({property}) => SubstrateWeightV2.layout_(property: property),
            property: "actual_weight"),
        LayoutConst.rustEnum([
          LayoutConst.none(property: "Yes"),
          LayoutConst.none(property: "No"),
        ], property: "pays_fee", useKeyAndValue: false),
      ], property: "post_info"),
      metadata.typeLayoutByPathTail("DispatchError", property: "error")
    ], property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.method: {
        "post_info": {
          "actual_weight":
              MetadataUtils.toOptionalJson(actualWeight?.serializeJson()),
          "pays_fee": {paysFee ? "Yes" : "No": null},
        },
        "error": errorJson,
        "description": description
      }
    };
  }

  factory DispatchResultWithPostInfoErr.fromJson(Map<String, dynamic> json,
      {ONEVENTDISPATCHERROR? onParseModuleError}) {
    final Map<String, dynamic> postInfo = json["post_info"];
    final Map<String, dynamic>? actualWeight =
        MetadataUtils.parseOptional(postInfo["actual_weight"]);
    final Map<String, dynamic> paysFee = postInfo["pays_fee"];
    final Map<String, dynamic> error = json["error"];
    final errors = _DryRunResultUtils.getExecutionResultErrorParts(error);
    Map<String, dynamic>? descriptions;
    if (onParseModuleError != null &&
        error.containsKey(SubstrateEventConst.module)) {
      final err = ModuleError.tryFromJson(error[SubstrateEventConst.module]);
      if (err != null) {
        descriptions = onParseModuleError(err);
      }
    }

    return DispatchResultWithPostInfoErr(
        actualWeight: actualWeight == null
            ? null
            : SubstrateWeightV2.deserializeJson(actualWeight),
        paysFee: paysFee.containsKey("Yes"),
        errorJson: error,
        errorTypes: errors,
        description: descriptions);
  }
}

class CallDryRunEffects {
  final DispatchResultWithPostInfo executionResult;
  final SubstrateGroupEvents events;
  final XCMVersionedXCM? localXcm;
  final List<(XCMVersionedLocation, List<XCMVersionedXCM>)> forwardXcms;
  const CallDryRunEffects({
    required this.events,
    required this.executionResult,
    required this.localXcm,
    required this.forwardXcms,
  });
  factory CallDryRunEffects.fromJson(Map<String, dynamic> json,
      {ONEVENTDISPATCHERROR? onParseModuleError}) {
    final Map<String, dynamic>? localXcm =
        MetadataUtils.parseOptional(json["local_xcm"]);
    return CallDryRunEffects(
      events: SubstrateGroupEvents(
          events: (json["emitted_events"] as List)
              .map((e) => SubstrateEvent.fromJson(e,
                  onDispatchError: onParseModuleError))
              .toList()),
      executionResult: DispatchResultWithPostInfo.fromJson(
          json["execution_result"],
          onParseModuleError: onParseModuleError),
      localXcm: localXcm == null ? null : XCMVersionedXCM.fromJson(localXcm),
      forwardXcms: (json["forwarded_xcms"] as List)
          .map((e) => (
                XCMVersionedLocation.fromJson(Map<String, dynamic>.from(e[0])),
                (e[1] as List).map((e) => XCMVersionedXCM.fromJson(e)).toList()
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "execution_result": executionResult.toJson(),
      "emitted_events": events.toJson(),
      "local_xcm": localXcm?.toJson(),
      "forwarded_xcms": forwardXcms
          .map((e) => [e.$1.toJson(), e.$2.map((e) => e.toJson()).toList()])
          .toList()
    };
  }
}

enum OutcomeType {
  complete("Complete"),
  incomplete("Incomplete"),
  error("Error");

  bool get isComplete => this == complete;

  final String method;
  const OutcomeType(this.method);
  static OutcomeType fromJson(Map<String, dynamic>? json) {
    return values.firstWhere(
      (e) => e.method == json?.keys.firstOrNull,
      orElse: () =>
          throw DartSubstratePluginException("Invalid OutcomeType json."),
    );
  }
}

abstract class OutcomeResult {
  final OutcomeType type;
  Map<String, dynamic> toJson();
  const OutcomeResult({required this.type});
  factory OutcomeResult.fromJson(Map<String, dynamic> json,
      {ONEVENTDISPATCHERROR? onParseModuleError}) {
    final type = OutcomeType.fromJson(json);
    return switch (type) {
      OutcomeType.complete => OutcomeResultComplete.fromJson(json[type.method]),
      OutcomeType.incomplete =>
        OutcomeResultIncomplete.fromJson(json[type.method]),
      OutcomeType.error => OutcomeResultErr.fromJson(json[type.method]),
    };
  }
  T cast<T extends OutcomeResult>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

class OutcomeResultComplete extends OutcomeResult {
  final SubstrateWeightV2 actualWeight;
  OutcomeResultComplete({required this.actualWeight})
      : super(type: OutcomeType.complete);
  factory OutcomeResultComplete.fromJson(Map<String, dynamic> json) {
    return OutcomeResultComplete(
      actualWeight: SubstrateWeightV2.deserializeJson(json),
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.method: actualWeight.serializeJson()};
  }
}

class OutcomeResultIncomplete extends OutcomeResult {
  final SubstrateWeightV2 used;
  final Map<String, dynamic> errorJson;
  final List<String> errorTypes;
  OutcomeResultIncomplete(
      {required this.used, required this.errorJson, required this.errorTypes})
      : super(type: OutcomeType.incomplete);
  factory OutcomeResultIncomplete.fromJson(Map<String, dynamic> json) {
    final errors =
        _DryRunResultUtils.getExecutionResultErrorParts(json["error"]);
    return OutcomeResultIncomplete(
        used: SubstrateWeightV2.deserializeJson(json["used"]),
        errorJson: json["error"],
        errorTypes: errors);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.method: {"used": used.serializeJson(), "error": errorJson}
    };
  }
}

class OutcomeResultErr extends OutcomeResult {
  final Map<String, dynamic> errorJson;
  final List<String> errorTypes;
  OutcomeResultErr({required this.errorJson, required this.errorTypes})
      : super(type: OutcomeType.error);
  factory OutcomeResultErr.fromJson(Map<String, dynamic> json) {
    final errors = _DryRunResultUtils.getExecutionResultErrorParts(json);
    return OutcomeResultErr(errorJson: json, errorTypes: errors);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.method: errorJson};
  }
}

class XcmDryRunEffects {
  final OutcomeResult executionResult;
  final SubstrateGroupEvents events;
  final List<(XCMVersionedLocation, List<XCMVersionedXCM>)> forwardXcms;
  bool get isComplete => executionResult.type.isComplete;
  SubstrateWeightV2? get weight {
    return switch (isComplete) {
      false => null,
      true => executionResult.cast<OutcomeResultComplete>().actualWeight
    };
  }

  const XcmDryRunEffects({
    required this.events,
    required this.executionResult,
    required this.forwardXcms,
  });
  factory XcmDryRunEffects.fromJson(Map<String, dynamic> json,
      {ONEVENTDISPATCHERROR? onParseModuleError}) {
    return XcmDryRunEffects(
      events: SubstrateGroupEvents(
          events: (json["emitted_events"] as List)
              .map((e) => SubstrateEvent.fromJson(e,
                  onDispatchError: onParseModuleError))
              .toList()),
      executionResult: OutcomeResult.fromJson(json["execution_result"]),
      forwardXcms: (json["forwarded_xcms"] as List)
          .map((e) => (
                XCMVersionedLocation.fromJson(Map<String, dynamic>.from(e[0])),
                (e[1] as List).map((e) => XCMVersionedXCM.fromJson(e)).toList()
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "emitted_events": events.toJson(),
      "execution_result": executionResult.toJson(),
      "forwarded_xcms": forwardXcms
          .map((e) => [e.$1.toJson(), e.$2.map((e) => e.toJson()).toList()])
          .toList()
    };
  }
}

typedef ONDISPATCHSUCCESS<OK, RESULT extends Object?> = OK Function(
    RESULT result);

abstract class SubstrateDispatchResult<OK extends Object?> {
  final DispatchResultType type;
  final Map<String, dynamic> result;
  const SubstrateDispatchResult({required this.type, required this.result});
  T cast<T extends SubstrateDispatchResult>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  OK? get ok => null;

  static Layout buildDispatchLayout(
      {required MetadataApi metadata, required LayoutFunc onOk}) {
    final id = metadata.typeByPathTail("Result");
    if (id == null) throw DartSubstratePluginException("message");
    final varinatins = metadata.getTypeDefination<Si1TypeDefVariant>(id);
    final errr = varinatins.variants.firstWhere(
      (e) => e.name == "Err",
      orElse: () => throw DartSubstratePluginException(
          "Failed to build dispatch result layout. type not found."),
    );
    final oK = varinatins.variants.firstWhere(
      (e) => e.name == "Ok",
      orElse: () => throw DartSubstratePluginException(
          "Failed to build dispatch result layout. type not found."),
    );
    return LayoutConst.lazyEnum([
      LazyVariantModel(layout: onOk, property: oK.name, index: oK.index),
      LazyVariantModel(
          layout: ({property}) =>
              SubstrateDispatchResultError.layout(property: property),
          property: errr.name,
          index: errr.index),
    ], useKeyAndValue: false);
    // LazyVariantModel(layout: layout, property: property, index: index)
  }

  static SubstrateDispatchResult<OK>
      fromJson<OK extends Object?, RESULT extends Object?>(
          Map<String, dynamic> json, ONDISPATCHSUCCESS<OK, RESULT> onOk) {
    final type = DispatchResultType.fromJson(json);

    return switch (type) {
      DispatchResultType.err => SubstrateDispatchResultError<OK>.fromJson(json),
      DispatchResultType.ok => SubstrateDispatchResultSuccess<OK>(
          ok: onOk(json.valueAs<RESULT>(DispatchResultType.ok.method)),
          result: json)
    };
  }

  Map<String, dynamic> toJson() {
    return {type.method: result};
  }

  bool get success => ok != null;
}

class SubstrateDispatchResultSuccess<OK extends Object?>
    extends SubstrateDispatchResult<OK> {
  @override
  final OK ok;
  const SubstrateDispatchResultSuccess(
      {required this.ok, required super.result})
      : super(type: DispatchResultType.ok);
}

class SubstrateDispatchResultError<OK extends Object?>
    extends SubstrateDispatchResult<OK> {
  final XcmPaymentApiDispatchErrorType error;
  const SubstrateDispatchResultError(
      {required this.error, required super.result})
      : super(type: DispatchResultType.err);
  factory SubstrateDispatchResultError.fromJson(Map<String, dynamic> json) {
    return SubstrateDispatchResultError(
        error: XcmPaymentApiDispatchErrorType.fromJson(
            json.valueAs(DispatchResultType.err.method)),
        result: json);
  }

  static Layout layout({String? property}) {
    return LayoutConst.lazyEnum(
        List.generate(
          20,
          (index) {
            final item =
                XcmPaymentApiDispatchErrorType.values.elementAtOrNull(index);
            return LazyVariantModel(
              layout: ({property}) => LayoutConst.none(property: property),
              property:
                  item?.type ?? XcmPaymentApiDispatchErrorType.unknown.type,
              index: index,
            );
          },
        ),
        property: property,
        useKeyAndValue: false);
  }
}

class QuotePriceParams {
  final bool includeFee;
  final BigInt amount;
  final XCMMultiLocation assetA;
  final XCMMultiLocation assetB;
  const QuotePriceParams(
      {required this.includeFee,
      required this.amount,
      required this.assetA,
      required this.assetB});
}

enum XcmPaymentApiDispatchErrorType {
  unimplemented('Unimplemented'),
  versionedConversionFailed('VersionedConversionFailed'),
  weightNotComputable('WeightNotComputable'),
  unhandledXcmVersion("UnhandledXcmVersion"),
  assetNotFound('AssetNotFound'),
  unroutable('Unroutable'),
  noProviders('NoProviders'),
  unknown('Unknown');

  final String type;

  const XcmPaymentApiDispatchErrorType(this.type);
  static XcmPaymentApiDispatchErrorType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? XcmPaymentApiDispatchErrorType.unknown;
  }

  static XcmPaymentApiDispatchErrorType fromType(String? type) {
    final result = values.firstWhereNullable((e) => e.type == type);
    return result ?? XcmPaymentApiDispatchErrorType.unknown;
  }
}

enum SubstrateDryRunCllOriginType {
  system("system"),
  polkadotXcm("PolkadotXcm"),
  cumulusXcm("CumulusXcm"),
  origins("Origins");

  const SubstrateDryRunCllOriginType(this.type);
  final String type;
  static SubstrateDryRunCllOriginType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

enum SubstrateDryRunCllOriginSystemType {
  root("Root"),
  signed("Signed"),
  none("None"),
  authorized("Authorized");

  const SubstrateDryRunCllOriginSystemType(this.type);
  final String type;
  static SubstrateDryRunCllOriginSystemType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract class BaseSubstrateDryRunCllOrigin {
  final SubstrateDryRunCllOriginType type;
  const BaseSubstrateDryRunCllOrigin({required this.type});
  Map<String, dynamic> toJson();
}

/// system
abstract class BaseSubstrateDryRunCllOriginSystem {
  final SubstrateDryRunCllOriginSystemType type;
  const BaseSubstrateDryRunCllOriginSystem({required this.type});
  Map<String, dynamic> toJson();
}

class SubstrateDryRunCllOriginSystemRoot
    extends BaseSubstrateDryRunCllOriginSystem {
  const SubstrateDryRunCllOriginSystemRoot()
      : super(type: SubstrateDryRunCllOriginSystemType.root);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class SubstrateDryRunCllOriginSystemSigned
    extends BaseSubstrateDryRunCllOriginSystem {
  final BaseSubstrateAddress address;
  const SubstrateDryRunCllOriginSystemSigned({required this.address})
      : super(type: SubstrateDryRunCllOriginSystemType.signed);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: address.toBytes()};
  }
}

class SubstrateDryRunCllOriginSystemNone
    extends BaseSubstrateDryRunCllOriginSystem {
  const SubstrateDryRunCllOriginSystemNone()
      : super(type: SubstrateDryRunCllOriginSystemType.none);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class SubstrateDryRunCllOriginSystemAuthorized
    extends BaseSubstrateDryRunCllOriginSystem {
  const SubstrateDryRunCllOriginSystemAuthorized()
      : super(type: SubstrateDryRunCllOriginSystemType.none);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

enum SubstrateDryRunCllOriginPolkadotXcmType {
  xcm("Xcm"),
  response("Response");

  const SubstrateDryRunCllOriginPolkadotXcmType(this.type);
  final String type;
  static SubstrateDryRunCllOriginPolkadotXcmType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract class BaseSubstrateDryRunCllOriginPolkadotXcm {
  final SubstrateDryRunCllOriginPolkadotXcmType type;
  Map<String, dynamic> toJson();
  const BaseSubstrateDryRunCllOriginPolkadotXcm({required this.type});
}

class SubstrateDryRunCllOriginPolkadotXcmXcm
    extends BaseSubstrateDryRunCllOriginPolkadotXcm {
  final XCMMultiLocation location;
  const SubstrateDryRunCllOriginPolkadotXcmXcm(this.location)
      : super(type: SubstrateDryRunCllOriginPolkadotXcmType.xcm);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: location.toJson()};
  }
}

class SubstrateDryRunCllOriginPolkadotXcmResponse
    extends BaseSubstrateDryRunCllOriginPolkadotXcm {
  final XCMMultiLocation location;
  const SubstrateDryRunCllOriginPolkadotXcmResponse(this.location)
      : super(type: SubstrateDryRunCllOriginPolkadotXcmType.response);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: location.toJson()};
  }
}

enum SubstrateDryRunCllOriginCumulusXcmType {
  relay("Relay"),
  siblingParachain("SiblingParachain");

  const SubstrateDryRunCllOriginCumulusXcmType(this.type);
  final String type;
  static SubstrateDryRunCllOriginCumulusXcmType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract class BaseSubstrateDryRunCllOriginCumulusXcm {
  final SubstrateDryRunCllOriginCumulusXcmType type;
  Map<String, dynamic> toJson();
  const BaseSubstrateDryRunCllOriginCumulusXcm({required this.type});
}

class SubstrateDryRunCllOriginCumulusXcmRelay
    extends BaseSubstrateDryRunCllOriginCumulusXcm {
  const SubstrateDryRunCllOriginCumulusXcmRelay()
      : super(type: SubstrateDryRunCllOriginCumulusXcmType.relay);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class SubstrateDryRunCllOriginCumulusXcmSiblingParachain
    extends BaseSubstrateDryRunCllOriginCumulusXcm {
  final int paraId;
  const SubstrateDryRunCllOriginCumulusXcmSiblingParachain(this.paraId)
      : super(type: SubstrateDryRunCllOriginCumulusXcmType.siblingParachain);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: paraId};
  }
}

enum SubstrateDryRunCallOriginType {
  stakingAdmin("StakingAdmin"),
  treasurer("Treasurer"),
  fellowshipAdmin("FellowshipAdmin"),
  generalAdmin("GeneralAdmin"),
  auctionAdmin("AuctionAdmin"),
  leaseAdmin("LeaseAdmin"),
  referendumCanceller("ReferendumCanceller"),
  referendumKiller("ReferendumKiller"),
  smallTipper("SmallTipper"),
  bigTipper("BigTipper"),
  smallSpender("SmallSpender"),
  mediumSpender("MediumSpender"),
  bigSpender("BigSpender"),
  whitelistedCaller("WhitelistedCaller"),
  fellowshipInitiates("FellowshipInitiates"),
  fellows("Fellows"),
  fellowshipExperts("FellowshipExperts"),
  fellowshipMasters("FellowshipMasters"),
  fellowship1Dan("Fellowship1Dan"),
  fellowship2Dan("Fellowship2Dan"),
  fellowship3Dan("Fellowship3Dan"),
  fellowship4Dan("Fellowship4Dan"),
  fellowship5Dan("Fellowship5Dan"),
  fellowship6Dan("Fellowship6Dan"),
  fellowship7Dan("Fellowship7Dan"),
  fellowship8Dan("Fellowship8Dan"),
  fellowship9Dan("Fellowship9Dan"),
  wishForChange("WishForChange");

  const SubstrateDryRunCallOriginType(this.type);
  final String type;

  static SubstrateDryRunCallOriginType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }
}

class SubstrateDryRunCllOriginSystem extends BaseSubstrateDryRunCllOrigin {
  final BaseSubstrateDryRunCllOriginSystem origin;
  const SubstrateDryRunCllOriginSystem(this.origin)
      : super(type: SubstrateDryRunCllOriginType.system);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: origin.toJson()};
  }
}

class SubstrateDryRunCllOriginPolkadotXcm extends BaseSubstrateDryRunCllOrigin {
  final BaseSubstrateDryRunCllOriginPolkadotXcm origin;
  const SubstrateDryRunCllOriginPolkadotXcm(this.origin)
      : super(type: SubstrateDryRunCllOriginType.polkadotXcm);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: origin.toJson()};
  }
}

class SubstrateDryRunCllOriginCumulusXcm extends BaseSubstrateDryRunCllOrigin {
  final BaseSubstrateDryRunCllOriginCumulusXcm origin;
  const SubstrateDryRunCllOriginCumulusXcm(this.origin)
      : super(type: SubstrateDryRunCllOriginType.cumulusXcm);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: origin.toJson()};
  }
}

class SubstrateDryRunCllOriginOrigins extends BaseSubstrateDryRunCllOrigin {
  final SubstrateDryRunCallOriginType origin;
  const SubstrateDryRunCllOriginOrigins(this.origin)
      : super(type: SubstrateDryRunCllOriginType.origins);

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {origin.type: null}
    };
  }
}

typedef ONSUBSTRATERUNTIMELAYOUTBUILDER = Layout Function(
    MetadataApi api, int version);

class SubstrateRuntimeApiLayoutBuilder {
  final ONSUBSTRATERUNTIMELAYOUTBUILDER inputBuilder;
  final ONSUBSTRATERUNTIMELAYOUTBUILDER outputBuilder;
  const SubstrateRuntimeApiLayoutBuilder(
      {required this.outputBuilder, required this.inputBuilder});
}
