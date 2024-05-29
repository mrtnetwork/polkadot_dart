import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns the runtime metadata.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetMetadata extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCStateGetMetadata({this.atBlockHash});

  final String? atBlockHash;

  /// state_getMetadata
  @override
  String get rpcMethod => SubstrateRPCMethods.getMetadata.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
