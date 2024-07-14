import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/system/chain_properties.dart';

/// Get a custom set of properties as a JSON object, defined in the chain spec.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemProperties
    extends SubstrateRPCRequest<Map<String, dynamic>, ChainProperties> {
  const SubstrateRPCSystemProperties();

  /// system_properties
  @override
  String get rpcMethod => SubstrateRPCMethods.properties.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  ChainProperties onResonse(Map<String, dynamic> result) {
    return ChainProperties.fromJson(result);
  }
}
