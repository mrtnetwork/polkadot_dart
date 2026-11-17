import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/quick/api.dart';

/// Quick client: high-level metadata-independent RPC calls with unified
/// result types. See [SubstrateQuickClientApi].
abstract class SubstrateQuickClient with SubstrateQuickClientApi {
  const SubstrateQuickClient();
}

/// Default [SubstrateQuickClientApi]: one Substrate JSON-RPC endpoint.
class DefaultSubstrateQuickClient extends SubstrateQuickClient {
  @override
  final IProvider<IServiceProvider, SubstrateRequestDetails> provider;

  const DefaultSubstrateQuickClient(this.provider);
}
