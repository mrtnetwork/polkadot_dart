import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Adds the supplied directives to the current log filter
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemAddLogFilter
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemAddLogFilter(this.directives);
  final String directives;

  /// system_addLogFilter
  @override
  String get rpcMethod => SubstrateRPCMethods.addLogFilter.value;

  @override
  List<dynamic> toJson() {
    return [directives];
  }
}
