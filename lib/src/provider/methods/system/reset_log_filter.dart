import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Resets the log filter to Substrate defaults
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemResetLogFilter
    extends SubstrateRequest<Null, Null> {
  const SubstrateRequestSystemResetLogFilter();

  /// system_resetLogFilter
  @override
  String get rpcMethod => SubstrateRequestMethods.resetLogFilter.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  Null onResonse(Null result) {
    return null;
  }
}
