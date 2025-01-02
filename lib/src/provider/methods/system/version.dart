import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the version of the node.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemVersion extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemVersion();

  /// system_version
  @override
  String get rpcMethod => SubstrateRequestMethods.version.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
