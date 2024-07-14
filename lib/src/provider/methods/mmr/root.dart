import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Get the MMR root hash for the current best block.
/// https://polkadot.js.org/docs/substrate/rpc/#mmr
class SubstrateRPCMMRRoot extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCMMRRoot({this.atBlockHash});

  final String? atBlockHash;

  /// mmr_root
  @override
  String get rpcMethod => SubstrateRPCMethods.root.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
