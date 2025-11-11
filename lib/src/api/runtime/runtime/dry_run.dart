import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

enum SubstrateRuntimeApiDryRunMethods implements SubstrateRuntimeApiMethods {
  dryRunCall("dry_run_call"),
  dryRunXcm("dry_run_xcm");

  @override
  final String method;
  const SubstrateRuntimeApiDryRunMethods(this.method);
}

/// safexcmversion
class SubstrateRuntimeApiDryRun extends SubstrateRuntimeApi {
  SubstrateRuntimeApiDryRun();
  Future<SubstrateDispatchResult<CallDryRunEffects>> dryRunCall(
      {required BaseSubstrateAddress owner,
      required List<int> callBytes,
      required MetadataApi api,
      required SubstrateProvider rpc,
      XCMMultiLocation? xcmLocation,
      required XCMVersion version}) async {
    final origin = switch (xcmLocation) {
      final XCMMultiLocation location => SubstrateDryRunCllOriginPolkadotXcm(
          SubstrateDryRunCllOriginPolkadotXcmXcm(location)),
      _ => SubstrateDryRunCllOriginSystem(
          SubstrateDryRunCllOriginSystemSigned(address: owner))
    };
    const method = SubstrateRuntimeApiDryRunMethods.dryRunCall;
    final apiVerson = getApiVersion(api);
    final call = api.decodeCall(callBytes);
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        api: api,
        method: method,
        provider: rpc,
        params: [
          origin.toJson(),
          call.toJson(),
          if (apiVerson > 1) version.version
        ]);
    return SubstrateDispatchResult.fromJson<CallDryRunEffects,
            Map<String, dynamic>>(
        result,
        (result) => CallDryRunEffects.fromJson(result,
            onParseModuleError: (error) => api.metadata
                .decodeErrorWithDescription("${error.index}", error.error)));
  }

  Future<SubstrateDispatchResult<XcmDryRunEffects>> dryRunXcm({
    required XCMVersionedLocation originlocation,
    required XCMVersionedXCM xcm,
    required MetadataApi api,
    required SubstrateProvider rpc,
  }) async {
    const method = SubstrateRuntimeApiDryRunMethods.dryRunXcm;
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        api: api,
        method: method,
        provider: rpc,
        params: [originlocation.toJson(), xcm.toJson()]);
    return SubstrateDispatchResult.fromJson<XcmDryRunEffects,
            Map<String, dynamic>>(
        result,
        (result) => XcmDryRunEffects.fromJson(result,
            onParseModuleError: (error) => api.metadata
                .decodeErrorWithDescription("${error.index}", error.error)));
  }

  @override
  SubstrateRuntimeApis get api => SubstrateRuntimeApis.dryRunApi;
}
