import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Check current migration state.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateTrieMigrationStatus
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCStateTrieMigrationStatus({this.atBlockHash});

  final String? atBlockHash;

  /// state_trieMigrationStatus
  @override
  String get rpcMethod => SubstrateRPCMethods.trieMigrationStatus.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
