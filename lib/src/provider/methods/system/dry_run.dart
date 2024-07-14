import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Dry run an extrinsic at a given block
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemDryRun
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCSystemDryRun({required this.extrinsic, this.atBlockHash});
  final String extrinsic;
  final String? atBlockHash;

  /// system_dryRun
  @override
  String get rpcMethod => SubstrateRPCMethods.dryRun.value;

  @override
  List<dynamic> toJson() {
    return [extrinsic, atBlockHash];
  }
}
