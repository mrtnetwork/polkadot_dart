import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Provides a way to trace the re-execution of a single block
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateTraceBlock
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCStateTraceBlock(
      {required this.block, this.targets, this.storageKeys, this.methods});
  final String block;
  final List<String>? targets;
  final List<String>? storageKeys;
  final List<String>? methods;

  /// state_traceBlock
  @override
  String get rpcMethod => SubstrateRPCMethods.traceBlock.value;

  @override
  List<dynamic> toJson() {
    return [block, targets, storageKeys, methods];
  }
}
