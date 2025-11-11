import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Reexecute the specified block_hash and gather statistics while doing so
/// https://polkadot.js.org/docs/substrate/rpc/#dev
class SubstrateRequestDevNewBlock extends SubstrateRequest<String, String> {
  final int? count;
  const SubstrateRequestDevNewBlock({this.count});

  /// dev_getBlockStats
  @override
  String get rpcMethod => SubstrateRequestMethods.devNewBlock.value;

  @override
  List<dynamic> toJson() {
    return [
      if (count != null) {"count": count}
    ];
  }
}
