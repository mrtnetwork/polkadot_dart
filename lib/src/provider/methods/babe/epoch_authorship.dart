import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns data about which slots (primary or secondary) can be claimed in the current epoch with the keys in the keystore.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#babe
class SubstrateRequestBabeEepochAuthorship
    extends SubstrateRequest<dynamic, dynamic> {
  const SubstrateRequestBabeEepochAuthorship();

  /// babe_epochAuthorship
  @override
  String get rpcMethod => SubstrateRequestMethods.epochAuthorship.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
