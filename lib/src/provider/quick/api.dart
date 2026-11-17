import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

/// Quick client API: one method per metadata-independent RPC call used by
/// the wallet and the swap client.
///
/// Design follows `SubstrateQuickClientApi`: consumers depend on this mixin
/// instead of raw request classes. Only calls that need no chain metadata
/// live here — storage queries, runtime calls and extrinsic building stay
/// in `lib/src/api` (`MetadataApi`, `SubstrateQuickStorageApi`,
/// `SubstrateTransactionBuilder`), which take any `rpc` provider.
///
/// Wallet/swap parity notes (base-native adaptations):
/// - Null-tolerant reads (`getBlockHash`, `systemProperties`) return null
///   instead of throwing; the wallet's `serverUnexpectedResponse` mapping
///   stays at the call site.
/// - Composed flows needing wallet types (`broadcastTransaction` with
///   block capture, `transactionBlockRequirment`, metadata negotiation)
///   stay in the wallet/swap: they are built from these primitives.
/// - Paginated storage iteration and subscription streams stay out (no
///   followable-cursor helper here).
mixin SubstrateQuickClientApi {
  /// Substrate JSON-RPC provider.
  IProvider<IServiceProvider, SubstrateRequestDetails> get provider;

  /// Block hash at [atNumber], or latest when omitted (null when the node
  /// has no such block).
  Future<String?> getBlockHash({int? atNumber}) {
    return provider.request(
      SubstrateRequestChainGetBlockHash(number: atNumber),
    );
  }

  /// Hash of the highest finalized block.
  Future<String> getFinalizedHead() {
    return provider.request(
      const SubstrateRequestChainChainGetFinalizedHead(),
    );
  }

  /// Header at [atBlockHash], or latest when omitted.
  Future<SubstrateHeaderResponse> getBlockHeader({String? atBlockHash}) {
    return provider.request(
      SubstrateRequestChainChainGetHeader(atBlockHash: atBlockHash),
    );
  }

  /// Block (header + extrinsics) at [atBlockHash], or latest when omitted.
  Future<SubstrateGetBlockResponse> getBlock({String? atBlockHash}) {
    return provider.request(
      SubstrateRequestChainGetBlock(atBlockHash: atBlockHash),
    );
  }

  /// Chain properties (token decimals/symbol, ss58 format).
  Future<ChainProperties> systemProperties() {
    return provider.request(SubstrateRequestSystemProperties());
  }

  /// Chain name (e.g. `Polkadot`).
  Future<String> systemChain() {
    return provider.request(SubstrateRequestSystemChain());
  }

  /// Submits a hex-encoded extrinsic, returning its hash.
  Future<String> submitExtrinsic(String extrinsicHex) {
    return provider.request(
      SubstrateRequestAuthorSubmitExtrinsic(extrinsicHex),
    );
  }

  /// Fee details for raw [extrinsic] bytes (no metadata needed).
  Future<QueryFeeDetails> queryFeeDetails({required List<int> extrinsic}) {
    return provider.request(
      SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails.fromExtrinsic(
        extrinsicBytes: extrinsic,
      ),
    );
  }

  /// Fee info for raw [extrinsic] bytes (no metadata needed).
  Future<QueryFeeInfo> queryFeeInfo({required List<int> extrinsic}) {
    return provider.request(
      SubstrateRequestRuntimeTransactionPaymentApiQueryInfo.fromExtrinsic(
        extrinsicBytes: extrinsic,
      ),
    );
  }

  /// RPC methods served by the node.
  Future<RpcMethods> rpcMethods() {
    return provider.request(SubstrateRequestRpcMethods());
  }

  /// Supported metadata versions (for metadata negotiation).
  Future<List<int>> metadataVersions() {
    return provider.request(
      const SubstrateRequestRuntimeMetadataGetVersions(),
    );
  }
}
