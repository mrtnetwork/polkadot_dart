import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/models/models/storage.dart';
import 'package:polkadot_dart/src/models/generic/models/events.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

extension ExtEventHelper on MetadataApi {
  Future<QueryStorageResult<T>> getEvents<T>(
    IProvider<IServiceProvider, SubstrateRequestDetails> rpc, {
    String? palletIdOrIndex,
    String? atBlockHash,
  }) async {
    final MethodStorageKey storageKey = generateEventStorageKey();
    final rpcMethod = SubstrateRequestGetStorage(
      storageKey.keyHex,
      atBlockHash: atBlockHash,
    );
    final response = await rpc.request(rpcMethod);
    if (response == null) {
      return QueryStorageResult(
        storageKey: StorageKey(
          prefix: storageKey,
          key: storageKey.keyHex,
          inputs: [],
        ),
        result: null as T,
      );
    }
    final List<int> eventBytes = BytesUtils.fromHexString(response);
    final events = decodeEvent(palletNameOrIndex: "0", bytes: eventBytes);
    return QueryStorageResult(
      storageKey: StorageKey(
        prefix: storageKey,
        key: storageKey.keyHex,
        inputs: [],
      ),
      result: events,
    );
  }

  Future<List<SubstrateEvent>> getSystemEvents(
    IProvider<IServiceProvider, SubstrateRequestDetails> rpc, {
    String? palletIdOrIndex,
    String? atBlockHash,
  }) async {
    final MethodStorageKey prefix = generateEventStorageKey();
    final StorageKey storageKey = StorageKey(
      prefix: prefix,
      key: prefix.keyHex,
      inputs: [],
    );
    final rpcMethod = SubstrateRequestGetStorage(
      storageKey.key,
      atBlockHash: atBlockHash,
    );
    final response = await rpc.request(rpcMethod);
    if (response == null) {
      return [];
    }
    final List<int> eventBytes = BytesUtils.fromHexString(response);
    final decodeEvents = decodeEvent<List>(
      palletNameOrIndex: "0",
      bytes: eventBytes,
    );
    final events =
        decodeEvents
            .map(
              (e) => SubstrateEvent.fromJson(
                e,
                onDispatchError: (error) {
                  return metadata.decodeErrorWithDescription(
                    "${error.index}",
                    error.error,
                  );
                },
              ),
            )
            .toList();
    if (palletIdOrIndex != null) {
      return events.where((e) => e.pallet == palletIdOrIndex).toList();
    }
    return events;
  }
}
