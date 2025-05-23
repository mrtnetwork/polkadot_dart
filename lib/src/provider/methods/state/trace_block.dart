import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Provides a way to trace the re-execution of a single block
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateTraceBlock
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestStateTraceBlock(
      {required this.block, this.targets, this.storageKeys, this.methods});
  final String block;
  final List<String>? targets;
  final List<String>? storageKeys;
  final List<String>? methods;

  /// state_traceBlock
  @override
  String get rpcMethod => SubstrateRequestMethods.traceBlock.value;

  @override
  List<dynamic> toJson() {
    return [block, targets, storageKeys, methods];
  }
}
