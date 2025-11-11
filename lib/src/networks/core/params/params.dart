import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/provider/methods/methods.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

/// Function type for fetching cached assets.
typedef ONFETCHCACHEDASSET<T extends BaseSubstrateNetworkAsset>
    = Future<List<T>> Function();
typedef ONREQUESTPROVIDER = Future<SubstrateProvider> Function(
    BaseSubstrateNetwork network);

/// Base parameters for Substrate network controllers.
abstract mixin class SubstrateNetworkControllerParams {
  /// Loads a provider for the given network.
  Future<SubstrateProvider> loadProvider(BaseSubstrateNetwork network);

  /// Loads metadata for the given network.
  Future<MetadataWithProvider> loadMetadata(BaseSubstrateNetwork network);

  /// Storage for cached network assets.
  abstract final BaseSubstrateCachedAssetStorage storage;

  /// Optional EVM parameters (for Moonbeam/Moonriver).
  abstract final SubstrateEvmNetworkControllerParams? evmParams;
}

/// Parameters for Ethereum-compatible Substrate networks (Moonbeam/Moonriver).
abstract mixin class SubstrateEvmNetworkControllerParams {
  /// Performs an Ethereum call to a smart contract.
  Future<RESPONSE> ethCall<RESPONSE extends Object?>({
    required SubstrateEthereumAddress contract,
    required EvmFunctionAbi<RESPONSE> function,
    required MetadataWithProvider provider,
    List<Object>? params,
  });
}

/// Default implementation of [SubstrateNetworkControllerParams] using a provider and optional storage.
class SubstrateNetworkApiDefaultParams
    implements SubstrateNetworkControllerParams {
  final ONREQUESTPROVIDER onRequestProvider;
  @override
  final BaseSubstrateCachedAssetStorage storage;
  @override
  final SubstrateEvmNetworkControllerParams? evmParams;

  final Map<BaseSubstrateNetwork, MetadataWithProvider> _cachedProvider = {};

  final _lock = SafeAtomicLock();

  SubstrateNetworkApiDefaultParams(this.onRequestProvider,
      {BaseSubstrateCachedAssetStorage? storage, this.evmParams})
      : storage = storage ??
            DefaultSubstrateCachedAssetStorage(interval: Duration.zero);

  Future<SubstrateMetadata?> _getRuntimeMetadata(
      SubstrateProvider provider) async {
    try {
      final metadata = await provider
          .request(const SubstrateRequestRuntimeMetadataGetMetadata());
      return metadata?.metadata;
    } on MetadataException {
      return null;
    }
  }

  Future<SubstrateMetadata?> _getMetadataApiAtVersion(
      {required SubstrateProvider provider, required int version}) async {
    try {
      final metadata = await provider.request(
          SubstrateRequestRuntimeMetadataGetMetadataAtVersion(version));
      return metadata?.metadata;
    } on MetadataException {
      return null;
    } on RPCError {
      return null;
    }
  }

  Future<MetadataApi> _getMetadataApi(
      SubstrateProvider provider, BaseSubstrateNetwork network) async {
    SubstrateMetadata<dynamic>? metadata;

    for (final i in MetadataConstant.supportedMetadataVersion) {
      metadata = await _getMetadataApiAtVersion(provider: provider, version: i);
      if (metadata != null) break;
    }
    metadata ??= await _getRuntimeMetadata(provider);
    if (metadata != null) {
      final api = MetadataApi(metadata as LatestMetadataInterface);
      return api;
    }

    throw const DartSubstratePluginException("Unsuported network metadata.");
  }

  Future<SubstrateProvider?> _checkProviderStatus(
      SubstrateProvider provider, String genesis) async {
    final blockHash = await provider
        .request(const SubstrateRequestChainGetBlockHash<String>(number: 0));
    if (StringUtils.hexEqual(blockHash, genesis)) {
      return provider;
    }
    return null;
  }

  @override
  Future<MetadataWithProvider> loadMetadata(
      BaseSubstrateNetwork network) async {
    return _lock.run(() async {
      final provider = _cachedProvider[network];
      if (provider != null) return provider;
      SubstrateProvider? activeProvider = await loadProvider(network);
      activeProvider =
          await _checkProviderStatus(activeProvider, network.genesis);
      if (activeProvider == null) {
        throw const DartSubstratePluginException(
            "Invalid provider: returned genesis hash does not match the network.");
      }
      final api = await _getMetadataApi(activeProvider, network);
      final networkProvider = MetadataWithProvider(
          provider: activeProvider,
          metadata: MetadataWithExtrinsic.fromMetadata(api));
      _cachedProvider[network] = networkProvider;
      return networkProvider;
    });
  }

  @override
  Future<SubstrateProvider> loadProvider(BaseSubstrateNetwork network) async {
    return onRequestProvider(network);
  }

  Future<void> clearCachedMetadata() async {
    return await _lock.run(() => _cachedProvider.clear());
  }
}

/// Base class for caching Substrate network assets.
abstract mixin class BaseSubstrateCachedAssetStorage {
  /// Returns cached assets or fetches them using [onFetch].
  Future<List<T>> get<T extends BaseSubstrateNetworkAsset>({
    required ONFETCHCACHEDASSET<T> onFetch,
    Duration? cachedTimeout,
  });
}

/// Default in-memory storage for Substrate network assets.
class DefaultSubstrateCachedAssetStorage
    implements BaseSubstrateCachedAssetStorage {
  final _lock = SafeAtomicLock();
  final Duration interval;
  List<BaseSubstrateNetworkAsset>? _assets;
  DateTime? _update;
  DefaultSubstrateCachedAssetStorage(
      {this.interval = const Duration(minutes: 10)});

  bool _shouldFetch({Duration? interval}) {
    interval ??= this.interval;
    final update = _update;
    if (update == null) return true;
    final expire = update.add(interval);
    if (expire.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  @override
  Future<List<T>> get<T extends BaseSubstrateNetworkAsset>(
      {required ONFETCHCACHEDASSET<T> onFetch, Duration? cachedTimeout}) {
    return _lock.run(() async {
      final fetch = _shouldFetch(interval: cachedTimeout);
      if (!fetch) return _assets!.cast<T>().toList();
      _assets = null;
      _assets = await onFetch();
      _update = DateTime.now();
      return _assets!.cast<T>().toList();
    });
  }

  /// Clears all cached assets.
  Future<void> clear() async {
    await _lock.run(
      () {
        _assets = null;
        _update = null;
      },
    );
  }
}
