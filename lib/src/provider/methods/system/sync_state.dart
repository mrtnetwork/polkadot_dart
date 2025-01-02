import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/system/sync_state.dart';

/// Returns the state of the syncing of the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemSyncState
    extends SubstrateRequest<Map<String, dynamic>, SyncStateResponse> {
  const SubstrateRequestSystemSyncState();

  /// system_syncState
  @override
  String get rpcMethod => SubstrateRequestMethods.syncState.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SyncStateResponse onResonse(Map<String, dynamic> result) {
    return SyncStateResponse.fromJson(result);
  }
}
