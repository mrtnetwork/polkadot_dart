import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the node name
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemName extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemName();

  /// system_name
  @override
  String get rpcMethod => SubstrateRequestMethods.name.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
