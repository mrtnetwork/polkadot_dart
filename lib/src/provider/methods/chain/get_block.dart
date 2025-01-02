import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/block.dart';

/// Get header and body of a relay chain block.
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainGetBlock
    extends SubstrateRequest<Map<String, dynamic>, SubstrateGetBlockResponse> {
  const SubstrateRequestChainGetBlock({this.atBlockHash});
  final String? atBlockHash;

  /// chain_getBlock
  @override
  String get rpcMethod => SubstrateRequestMethods.getBlock.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }

  @override
  SubstrateGetBlockResponse onResonse(Map<String, dynamic> result) {
    return SubstrateGetBlockResponse.fromJson(result);
  }
}
