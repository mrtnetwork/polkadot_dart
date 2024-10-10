import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/block.dart';

/// Get header and body of a relay chain block.
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainGetBlock extends SubstrateRPCRequest<
    Map<String, dynamic>, SubstrateGetBlockResponse> {
  const SubstrateRPCChainGetBlock({this.atBlockHash});
  final String? atBlockHash;

  /// chain_getBlock
  @override
  String get rpcMethod => SubstrateRPCMethods.getBlock.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }

  @override
  SubstrateGetBlockResponse onResonse(Map<String, dynamic> result) {
    return SubstrateGetBlockResponse.fromJson(result);
  }
}
