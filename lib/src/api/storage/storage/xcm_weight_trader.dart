import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageXCMWeightTraderMethods {
  supportedAssets("SupportedAssets");

  final String method;
  const SubstrateStorageXCMWeightTraderMethods(this.method);
}

/// safexcmversion
class SubstrateStorageXCMWeightTrader extends SubstrateStorageApi {
  const SubstrateStorageXCMWeightTrader();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.xcmWeightTrader;
  Future<List<QueryStorageFullResponse<(bool, BigInt)>>> supportedAssets(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<(bool, BigInt)>, List>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageXCMWeightTraderMethods.supportedAssets.method,
            onJsonResponse: (response, responseBytes, storageKey) {
              try {
                return QueryStorageFullResponse(
                    storageKey: storageKey,
                    responseBytes: responseBytes,
                    response: (response.elementAt(0), response.elementAt(1)));
              } catch (_) {
                throw DartSubstratePluginException(
                    "Unxpected xcmWeightTrader supported assets response");
              }
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }
}
