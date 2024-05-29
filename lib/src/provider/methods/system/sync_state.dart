import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/system/sync_state.dart';

/// Returns the state of the syncing of the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemSyncState
    extends SubstrateRPCRequest<Map<String, dynamic>, SyncStateResponse> {
  const SubstrateRPCSystemSyncState();

  /// system_syncState
  @override
  String get rpcMethod => SubstrateRPCMethods.syncState.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SyncStateResponse onResonse(Map<String, dynamic> result) {
    return SyncStateResponse.fromJson(result);
  }
}
