import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/header.dart';

/// Retrieves the header for a specific block
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainChainGetHeader
    extends SubstrateRequest<Map<String, dynamic>, SubstrateHeaderResponse> {
  const SubstrateRequestChainChainGetHeader({this.atBlockHash});
  final String? atBlockHash;

  /// chain_getHeader
  @override
  String get rpcMethod => SubstrateRequestMethods.getHeader.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }

  @override
  SubstrateHeaderResponse onResonse(Map<String, dynamic> result) {
    return SubstrateHeaderResponse.fromJson(result);
  }
}
