import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageXCMPalletMethods {
  safeXcmVersion("SafeXcmVersion");

  final String method;
  const SubstrateStorageXCMPalletMethods(this.method);
}

/// safexcmversion
class SubstrateStorageXCMPallet extends SubstrateStorageApi {
  const SubstrateStorageXCMPallet();
  Future<XCMVersion> safeXCMVersion(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    return api.getStorageRequest(
        rpc: rpc,
        request: GetStorageRequest<XCMVersion, int>(
            onJsonResponse: (response, _, storageKey) =>
                XCMVersion.fromVersion(response),
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageXCMPalletMethods.safeXcmVersion.method));
  }

  @override
  SubstrateStorageApis get api => SubstrateStorageApis.xcmPallet;
}
