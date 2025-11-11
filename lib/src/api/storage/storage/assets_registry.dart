import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageAssetsRegistryMethods {
  idByLocations("IdByLocations"),
  registryInfoByIds("RegistryInfoByIds");

  final String method;
  const SubstrateStorageAssetsRegistryMethods(this.method);
}

/// safexcmversion
class SubstrateStorageAssetsRegistry extends SubstrateStorageApi {
  const SubstrateStorageAssetsRegistry();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.assetsRegistry;
  Future<List<QueryStorageFullResponse<BigInt>>> idByLocations(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, int>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetsRegistryMethods.idByLocations.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: BigInt.from(response));
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      registryInfoByIds(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetsRegistryMethods.registryInfoByIds.name,
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
}
