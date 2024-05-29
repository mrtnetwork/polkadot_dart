import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns the json-serialized chainspec running the node, with a sync state.
/// https://polkadot.js.org/docs/substrate/rpc/#syncstate
class SubstrateRPCSyncStateGenSyncSpec
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCSyncStateGenSyncSpec(this.raw);
  final bool raw;

  /// sync_state_genSyncSpec
  @override
  String get rpcMethod => SubstrateRPCMethods.genSyncSpec.value;

  @override
  List<dynamic> toJson() {
    return [raw];
  }
}
