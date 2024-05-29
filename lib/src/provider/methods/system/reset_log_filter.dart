import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Resets the log filter to Substrate defaults
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemResetLogFilter extends SubstrateRPCRequest<Null, Null> {
  const SubstrateRPCSystemResetLogFilter();

  /// system_resetLogFilter
  @override
  String get rpcMethod => SubstrateRPCMethods.resetLogFilter.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  Null onResonse(Null result) {
    return null;
  }
}
