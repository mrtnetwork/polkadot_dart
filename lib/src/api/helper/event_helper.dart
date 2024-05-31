import 'package:blockchain_utils/binary/utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/models/response.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

extension EventHelper on MetadataApi {
  Future<QueryStorageResult<T>> getEvents<T>(SubstrateRPC rpc,
      {String? palletIdOrIndex, String? atBlockHash}) async {
    final List<int> storageKeyBytes = generateEventStorageKey();
    final String storageKey =
        BytesUtils.toHexString(storageKeyBytes, prefix: "0x");
    final rpcMethod =
        SubstrateRPCGetStorage(storageKey, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    if (response == null) {
      return QueryStorageResult(storageKey: storageKey, result: null as T);
    }
    final List<int> eventBytes = BytesUtils.fromHexString(response);
    final events = decodeEvent(palletNameOrIndex: "0", bytes: eventBytes);
    return QueryStorageResult(storageKey: storageKey, result: events);
  }
}
