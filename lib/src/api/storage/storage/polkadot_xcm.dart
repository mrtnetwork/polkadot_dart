import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStoragePolkadotXCMMethods {
  safeXcmVersion("SafeXcmVersion");

  final String method;
  const SubstrateStoragePolkadotXCMMethods(this.method);
}

/// safexcmversion
class SubstrateStoragePolkadotXCM extends SubstrateStorageApi {
  const SubstrateStoragePolkadotXCM();
  Future<XCMVersion?> safeXCMVersion(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    return api.getStorageRequest(
        rpc: rpc,
        request: GetStorageRequest<XCMVersion?, int>(
            onJsonResponse: (response, bytes, storageKey) =>
                XCMVersion.fromVersion(response),
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStoragePolkadotXCMMethods.safeXcmVersion.method));
  }

  Future<List<QueryStorageFullResponse<int?>>> versions(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request:
            GetStreamStorageEntriesRequest<QueryStorageFullResponse<int?>, int>(
                palletNameOrIndex: this.api.name,
                methodName: "SupportedVersion",
                onJsonResponse: (response, responseBytes, storageKey) {
                  return QueryStorageFullResponse(
                      storageKey: storageKey,
                      responseBytes: responseBytes,
                      response: response);
                }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  @override
  SubstrateStorageApis get api => SubstrateStorageApis.polkadotXcm;
}
