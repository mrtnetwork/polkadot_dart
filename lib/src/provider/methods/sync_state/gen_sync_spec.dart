import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the json-serialized chainspec running the node, with a sync state.
/// https://polkadot.js.org/docs/substrate/rpc/#syncstate
class SubstrateRequestSyncStateGenSyncSpec
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestSyncStateGenSyncSpec(this.raw);
  final bool raw;

  /// sync_state_genSyncSpec
  @override
  String get rpcMethod => SubstrateRequestMethods.genSyncSpec.value;

  @override
  List<dynamic> toJson() {
    return [raw];
  }
}
