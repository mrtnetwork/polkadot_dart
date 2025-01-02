import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Check current migration state.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateTrieMigrationStatus
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestStateTrieMigrationStatus({this.atBlockHash});

  final String? atBlockHash;

  /// state_trieMigrationStatus
  @override
  String get rpcMethod => SubstrateRequestMethods.trieMigrationStatus.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
