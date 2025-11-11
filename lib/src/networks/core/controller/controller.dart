import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/signer.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/networks/constants/constants.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/assets.dart';
import 'package:polkadot_dart/src/networks/utils/helper.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';
import 'package:polkadot_dart/src/networks/utils/xcm.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

/// Base controller for managing assets and transfers on a Substrate network.
///
/// ⚠️ Methods in this class that end with `Internal` are intended for
/// internal operations only. They should **not** be used directly unless
/// you fully understand their purpose and behavior.
abstract mixin class BaseSubstrateNetworkController<
    IDENTIFIER extends Object?,
    ASSET extends BaseSubstrateNetworkAsset,
    NETWORK extends BaseSubstrateNetwork> {
  /// Controller parameters.
  abstract final SubstrateNetworkControllerParams params;

  /// The network this controller manages.
  NETWORK get network;

  /// Default native asset of the network.
  ASSET get defaultNativeAsset;

  /// Relay chain asset for the network.
  late final GenericBaseSubstrateNativeAsset relayAsset = network.relayAsset;

  /// Filters a list of assets that can be transferred to a destination network.
  Future<List<R>>
      filterTransferableAssets<R extends BaseSubstrateNetworkAsset>({
    required List<R> assets,
    required BaseSubstrateNetwork destination,
  }) async {
    return SubstrateNetworkControllerXCMTransferBuilder
        .filterTransferableAssets(
      assets: assets,
      destination: destination,
      network: network,
      disableDot: SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(destination),
      disabledRoutes: [],
    );
  }

  /// Filters a list of assets that can be received from an origin network.
  Future<List<R>> filterReceiveAssets<R extends BaseSubstrateNetworkAsset>({
    required List<R> assets,
    required BaseSubstrateNetwork origin,
  }) async {
    return SubstrateNetworkControllerXCMTransferBuilder.filterReceivedAssets(
      assets: assets,
      origin: origin,
      network: network,
      disableDot: SubstrateNetworkControllerConstants.disabledDotReserve
          .contains(network),
    );
  }

  /// Gets the free balance of the native asset for a given address.
  Future<SubstrateAccountAssetBalance<ASSET>?> getNativeAssetFreeBalance(
      BaseSubstrateAddress address);

  /// Gets the list of network assets, optionally filtered by known asset IDs.
  Future<List<ASSET>> getAssetsInternal({List<IDENTIFIER>? knownAssetIds});

  /// Gets account asset balances for a given address.
  Future<List<SubstrateAccountAssetBalance<ASSET>>> getAccountAssetsInternal({
    required BaseSubstrateAddress address,
    List<IDENTIFIER>? knownAssetIds,
    List<ASSET>? knownAssets,
  });

  /// Internal method to perform an XCM transfer to a parachain.
  Future<SubstrateXCMCallPallet> xcmTransferToParaInternal({
    required SubstrateXCMTransferParams params,
    required MetadataWithProvider provider,
    ONREQUESTNETWORKPROVIDER? onControllerRequest,
  });

  /// Internal method to perform an XCM transfer to a relay.
  Future<SubstrateXCMCallPallet> xcmTransferToRelayInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    if (network.role.isRelay) {
      throw SubstrateNetworkControllerConstants.transferDisabled;
    }
    if (network.role.isSystem) {
      return SubstrateNetworkControllerXCMTransferBuilder.createXCMTransfer(
          params: params,
          provider: provider,
          network: network,
          method: XCMCallPalletMethod.limitedTeleportAssets,
          pallet: SubtrateMetadataPallet.polkadotXcm);
    }
    return SubstrateNetworkControllerXCMTransferBuilder
        .transferAssetsThroughUsingTypeAndThen(
            params: params,
            provider: provider,
            network: network,
            onEstimateFee: onControllerRequest);
  }

  /// Internal method to perform an XCM transfer to a system chain.
  Future<SubstrateXCMCallPallet> xcmTransferToSystemInternal(
      {required SubstrateXCMTransferParams params,
      required MetadataWithProvider provider,
      ONREQUESTNETWORKPROVIDER? onControllerRequest});

  Future<MetadataWithProvider> metadata() {
    return params.loadMetadata(network);
  }

  /// Fetches all network assets, optionally filtered by known asset IDs.
  Future<SubstrateNetworkAssets<ASSET>> getAssets(
      {List<Object>? knownAssetIds}) async {
    final assets = await params.storage.get(onFetch: getAssetsInternal);
    if (knownAssetIds == null) {
      return SubstrateNetworkAssets(
          assets: [defaultNativeAsset, ...assets], network: network);
    }
    final filterAssets = knownAssetIds
        .map((e) => assets.firstWhereNullable((a) => a.identifierEqual(e)))
        .whereType<ASSET>()
        .toList();
    return SubstrateNetworkAssets(assets: filterAssets, network: network);
  }

  /// Fetches all account asset balances, optionally including native balance.
  Future<SubstrateNetworkAccountBalances<ASSET>> getAccountAssets(
      {required BaseSubstrateAddress address,
      List<Object>? knownAssetIds,
      List<ASSET>? knownAssets,
      bool nativeBalance = true}) async {
    final ids =
        SubstrateNetworkControllerAssetQueryHelper.toAssetId<IDENTIFIER>(
            knownAssetIds);
    List<SubstrateAccountAssetBalance<ASSET>> balances =
        await getAccountAssetsInternal(
            address: address, knownAssetIds: ids, knownAssets: knownAssets);
    if (nativeBalance) {
      final nBalance = await getNativeAssetFreeBalance(address);
      if (nBalance != null) {
        balances = [nBalance, ...balances];
      }
    }
    return SubstrateNetworkAccountBalances(
        balances: balances, network: network);
  }

  /// Prepares an XCM transfer to a different network, returning encoded call params.
  Future<SubstrateXCMTransferEncodedParams<SubstrateXCMCallPallet>> xcmTransfer(
      {required SubstrateXCMTransferParams params,
      ONREQUESTNETWORKPROVIDER? onControllerRequest}) async {
    final provider = await metadata();
    if (params.destinationNetwork.relaySystem != network.relaySystem) {
      throw DartSubstratePluginException(
          "XCM transfer not allowed between chains using different relay systems.");
    }
    if (params.destinationNetwork == network) {
      throw DartSubstratePluginException(
          "XCM transfer not allowed within the same network.");
    }
    try {
      params.assets.cast<ASSET>();
    } catch (_) {
      throw DartSubstratePluginException("Invalid network assets.", details: {
        "excpected": "$ASSET",
        "assets": params.assets.map((e) => e.runtimeType).join(",")
      });
    }
    final NETWORK destination = params.destinationNetwork as NETWORK;
    SubstrateXCMCallPallet transfer = switch (destination.role) {
      SubstrateConsensusRole.system => await xcmTransferToSystemInternal(
          params: params,
          provider: provider,
          onControllerRequest: onControllerRequest),
      SubstrateConsensusRole.relay => await xcmTransferToRelayInternal(
          params: params,
          provider: provider,
          onControllerRequest: onControllerRequest),
      SubstrateConsensusRole.parachain => await xcmTransferToParaInternal(
          params: params,
          provider: provider,
          onControllerRequest: onControllerRequest),
    };

    return SubstrateXCMTransferEncodedParams(
        transfer: transfer,
        pallet: transfer.pallet.name,
        method: transfer.type.method,
        params: params,
        bytes: transfer.encodeCall(extrinsic: provider.metadata));
  }

  /// Creates a local asset transfer encoded call.
  Future<SubstrateTransferEncodedParams<SubstrateCallPallet>> assetTransfer(
      {required SubstrateLocalTransferAssetParams params}) async {
    if (!network.allowLocalTransfer) {
      throw DartSubstratePluginException(
          "Local asset transfers are currently disabled on this network.",
          details: {"network": network.networkName});
    }
    final provider = await this.params.loadMetadata(network);
    return SubstrateNetworkControllerLocalAssetTransferBuilder
        .createLocalTransfer(params: params, metadata: provider.metadata);
  }

  /// Creates a native/system asset transfer encoded call.
  Future<SubstrateTransferEncodedParams<SubstrateCallPallet>> nativeTransfer(
      {required SubstrateNativeAssetTransferParams params}) async {
    final provider = await this.params.loadMetadata(network);
    return SubstrateNetworkControllerLocalAssetTransferBuilder
        .createLocalTransfer(
            params: SubstrateLocalTransferAssetParams(
              asset: null,
              destinationAddress: params.destinationAddress,
              amount: params.amount,
              keepAlive: params.keepAlive,
              method: params.method,
            ),
            metadata: provider.metadata);
  }

  /// create and Submit native/system asset transfer transaction and optionally tracks events.
  /// Returns a stream that can be cancelled to stop tracking at any time.
  ///
  /// Parameters:
  /// - [owner]: Account submitting the transaction.
  /// - [params]: Encoded local asset transfer parameters (from [nativeTransfer]).
  /// - [signer]: Signer to sign the transaction.
  /// - [onTransactionSubmited]: Callback when transaction is submitted on the current network.
  /// - [onUpdateTransactionStatus]: Callback when transaction is included in a block on the current network.
  /// - [chargeAssetTxPaymentAssetId]: Pay excution fee by asset. only work if network support paying fee by asset. otherwise failed.
  Future<Future<Stream<void>>> createSignAndSubmitNativeTransfer({
    required SubstrateNativeAssetTransferParams params,
    required BaseSubstrateAddress owner,
    required SubstrateTransactionSigner signer,
    void Function(String txId, int blockNumber)? onTransactionSubmited,
    void Function(SubtrateTransactionSubmitionResult? event)?
        onUpdateTransactionStatus,
    ASSET? chargeAssetTxPaymentAssetId,
  }) async {
    final transfer = await nativeTransfer(params: params);
    return submitTransaction(
        owner: owner,
        params: transfer,
        signer: signer,
        onUpdateTransactionStatus: onUpdateTransactionStatus,
        onTransactionSubmited: onTransactionSubmited,
        chargeAssetTxPaymentAssetId: chargeAssetTxPaymentAssetId);
  }

  /// create and Submit local asset transfer transaction and optionally tracks events.
  /// Returns a stream that can be cancelled to stop tracking at any time.
  ///
  /// Parameters:
  /// - [owner]: Account submitting the transaction.
  /// - [params]: Encoded local asset transfer parameters (from [assetTransfer]).
  /// - [signer]: Signer to sign the transaction.
  /// - [onTransactionSubmited]: Callback when transaction is submitted on the current network.
  /// - [onUpdateTransactionStatus]: Callback when transaction is included in a block on the current network.
  /// - [chargeAssetTxPaymentAssetId]: Pay excution fee by asset. only work if network support paying fee by asset. otherwise failed.
  Future<Future<Stream<void>>> createSignAndSubmitAssetTransfer({
    required SubstrateLocalTransferAssetParams params,
    required BaseSubstrateAddress owner,
    required SubstrateTransactionSigner signer,
    void Function(String txId, int blockNumber)? onTransactionSubmited,
    void Function(SubtrateTransactionSubmitionResult? event)?
        onUpdateTransactionStatus,
    ASSET? chargeAssetTxPaymentAssetId,
  }) async {
    final transfer = await assetTransfer(params: params);
    return submitTransaction(
        owner: owner,
        params: transfer,
        signer: signer,
        onUpdateTransactionStatus: onUpdateTransactionStatus,
        onTransactionSubmited: onTransactionSubmited,
        chargeAssetTxPaymentAssetId: chargeAssetTxPaymentAssetId);
  }

  /// create and Submits an XCM transaction and optionally tracks events on the destination chain.
  /// Returns a stream that can be cancelled to stop tracking at any time.
  ///
  /// Parameters:
  /// - [owner]: Account submitting the transaction.
  /// - [params]: Encoded XCM transfer parameters (from [xcmTransfer]).
  /// - [signer]: Signer to sign the transaction.
  /// - [onTransactionSubmited]: Callback when transaction is submitted on the current network.
  /// - [onUpdateTransactionStatus]: Callback when transaction is included in a block on the current network.
  /// - [chargeAssetTxPaymentAssetId]: Pay excution fee by asset. only work if network support paying fee by asset. otherwise failed.
  Future<Future<Stream<void>>> createSignAndSubmitXcmTransfer({
    required SubstrateXCMTransferParams params,
    required BaseSubstrateAddress owner,
    required SubstrateTransactionSigner signer,
    void Function(String txId, int blockNumber)? onTransactionSubmited,
    void Function(SubtrateTransactionSubmitionResult? event)?
        onUpdateTransactionStatus,
    ASSET? chargeAssetTxPaymentAssetId,
    BaseSubstrateNetworkController? destinationChainController,
  }) async {
    final transfer = await xcmTransfer(params: params);
    return submitXCMTransaction(
        owner: owner,
        params: transfer,
        signer: signer,
        onUpdateTransactionStatus: onUpdateTransactionStatus,
        onTransactionSubmited: onTransactionSubmited,
        destinationChainController: destinationChainController,
        chargeAssetTxPaymentAssetId: chargeAssetTxPaymentAssetId);
  }

  SubstrateTransactionChargeAssetTxPayment? _buildChargeAssetTxPaymentAssetId(
      ASSET? chargeAssetTxPaymentAssetId) {
    if (chargeAssetTxPaymentAssetId == null) return null;
    // if (chargeAssetTxPaymentAssetId != null) {
    final identifier = chargeAssetTxPaymentAssetId.asChargeTxPaymentAssetId(
        network: network, version: network.defaultXcmVersion);
    if (identifier == null) {
      throw DartSubstratePluginException(
          "Cannot pay transaction fee using the provided asset.");
    }
    return SubstrateTransactionChargeAssetTxPayment(
        assetId: identifier,
        assetLocation: chargeAssetTxPaymentAssetId
            .tryGetlocalizedLocation(
                version: network.defaultXcmVersion, reserveNetwork: network)
            ?.location,
        nativeAssetLocation: defaultNativeAsset
            .getlocalizedLocation(
                version: network.defaultXcmVersion, reserveNetwork: network)
            .location);
  }

  /// Submits an XCM transaction and optionally tracks events on the destination chain.
  /// Returns a stream that can be cancelled to stop tracking at any time.
  ///
  /// Parameters:
  /// - [owner]: Account submitting the transaction.
  /// - [params]: Encoded XCM transfer parameters (from `xcmTransfer`).
  /// - [transaction]: Pre-signed transaction, if available.
  /// - [signer]: Signer to sign the transaction if [transaction] is not provided.
  /// - [destinationChainController]: Controller to track events on the destination chain.
  /// - [onTransactionSubmited]: Callback when transaction is submitted on the current network.
  /// - [onUpdateTransactionStatus]: Callback when transaction is included in a block on the current network.
  /// - [onDestinationChainEvent]: Callback for events on the destination chain if [destinationChainController] is provided.
  /// - [chargeAssetTxPaymentAssetId]: Pay excution fee by asset. only work if network support paying fee by asset. otherwise failed.
  Future<Stream<void>> submitXCMTransaction({
    required BaseSubstrateAddress owner,
    required SubstrateXCMTransferEncodedParams params,
    SubstrateSubmitableTransaction? transaction,
    SubstrateTransactionSigner? signer,
    BaseSubstrateNetworkController? destinationChainController,
    ASSET? chargeAssetTxPaymentAssetId,
    void Function(String txId, int blockNumber)? onTransactionSubmited,
    void Function(SubtrateTransactionSubmitionResult event)?
        onUpdateTransactionStatus,
    void Function(SubstrateXCMTransctionTrackerResult event)?
        onDestinationChainEvent,
  }) async {
    final StreamController<void> controller = StreamController();
    final provider = await metadata();
    if (transaction == null) {
      if (signer == null) {
        throw DartSubstratePluginException(
            "Failed to sign transaction. missing signer.");
      }

      transaction =
          await SubstrateTransactionBuilder.buildAndSignTransactionStatic(
              owner: owner,
              params: TransactionBuilderParams(genesisHash: network.genesis),
              signer: signer,
              calls: SubstrateTransactionSubmitableParams(
                  calls: [params],
                  chargeAssetTxPayment: _buildChargeAssetTxPaymentAssetId(
                      chargeAssetTxPaymentAssetId)),
              provider: provider);
    }
    final bool canTrack = destinationChainController != null;
    MetadataWithProvider? destinationProvider;
    int? destinationBlockId;
    if (canTrack) {
      destinationProvider = await destinationChainController.metadata();
      final finalizeHead = await destinationProvider.provider
          .request(SubstrateRequestChainChainGetFinalizedHead());
      final currentBlock = await destinationProvider.provider
          .request(SubstrateRequestChainGetBlock(atBlockHash: finalizeHead));
      destinationBlockId = currentBlock.block.header.number;
    }

    final stream =
        await SubstrateTransactionBuilder.submitExtrinsicAndWatchStatic(
            extrinsic: transaction,
            provider: provider,
            onSubmitxtrinsic: onTransactionSubmited);
    StreamSubscription? sub;
    void close() {
      sub?.cancel();
      sub = null;
      if (!controller.isClosed) controller.close();
    }

    void stratTracking() {
      stream.listen(
        (result) {
          final callBack = onUpdateTransactionStatus;
          if (callBack != null) callBack(result);
          if (!canTrack || !result.status.isSuccess) {
            close();
            return;
          }
          final messageId =
              SubstrateNetworkControllerUtils.findSendXCMMessageId(
                  events: SubstrateGroupEvents(events: result.txEvents!),
                  network: network,
                  transferPallet: params.transfer.pallet);
          if (messageId == null) {
            final callBack = onDestinationChainEvent;
            if (callBack != null) {
              callBack(SubstrateXCMTransctionTrackerResult(
                status: SubstrateXCMTransctionTrackerStatus.error,
              ));
            }
            close();
            return;
          }

          void track(
              {required int blockId,
              required BaseSubstrateNetworkController controller,
              required MetadataWithProvider provider,
              required String msgId}) {
            final onDestinationResult =
                SubstrateTransactionBuilder.loockupBlockStream(
                    blockId: blockId,
                    onBlockEvents:
                        (blockHash, blockId, blockExtrinsics, events) {
                      return SubstrateNetworkControllerUtils
                          .findProcessedXCMMessage(
                              events: events,
                              params: params,
                              id: msgId,
                              blockNumber: blockId);
                    },
                    provider: provider);
            sub = onDestinationResult.listen(
              (event) {
                final callBack = onDestinationChainEvent;
                if (callBack != null) {
                  callBack(event);
                }
                close();
              },
              onError: (e, s) {
                final callBack = onDestinationChainEvent;
                if (callBack != null) {
                  callBack(SubstrateXCMTransctionTrackerResult(
                      status: e == SubstrateLookupBlockExceptionConst.notFound
                          ? SubstrateXCMTransctionTrackerStatus.notFound
                          : SubstrateXCMTransctionTrackerStatus.error));
                }
                close();
              },
            );
          }

          if (destinationBlockId != null) {
            track(
                blockId: destinationBlockId,
                controller: destinationChainController,
                provider: destinationProvider!,
                msgId: messageId);
          } else {
            close();
          }
        },
        onError: (e) {
          if (!controller.isClosed) controller.addError(e);
          close();
        },
      );
    }

    controller.onListen = stratTracking;
    return controller.stream
        .asBroadcastStream(onCancel: (subscription) => close());
  }

  /// Submits an transaction and optionally tracks events.
  /// Returns a stream that can be cancelled to stop tracking at any time.
  ///
  /// Parameters:
  /// - [owner]: Account submitting the transaction.
  /// - [params]: Encoded transfer parameters (from [assetTransfer], [nativeTransfer], [xcmTransfer]).
  /// - [transaction]: Pre-signed transaction, if available.
  /// - [signer]: Signer to sign the transaction if [transaction] is not provided.
  /// - [onTransactionSubmited]: Callback when transaction is submitted on the current network.
  /// - [onUpdateTransactionStatus]: Callback when transaction is included in a block on the current network.
  /// - [chargeAssetTxPaymentAssetId]: Pay excution fee by asset. only work if network support paying fee by asset. otherwise failed.
  Future<Stream<void>> submitTransaction({
    required BaseSubstrateAddress owner,
    required SubstrateEncodedCallParams params,
    SubstrateSubmitableTransaction? transaction,
    SubstrateTransactionSigner? signer,
    ASSET? chargeAssetTxPaymentAssetId,
    void Function(String txId, int blockNumber)? onTransactionSubmited,
    void Function(SubtrateTransactionSubmitionResult event)?
        onUpdateTransactionStatus,
  }) async {
    final StreamController<void> controller = StreamController();
    final provider = await metadata();
    if (transaction == null) {
      if (signer == null) {
        throw DartSubstratePluginException(
            "Failed to sign transaction. missing signer.");
      }
      transaction =
          await SubstrateTransactionBuilder.buildAndSignTransactionStatic(
              owner: owner,
              signer: signer,
              fakeSignature: false,
              calls: SubstrateTransactionSubmitableParams(
                  calls: [params],
                  chargeAssetTxPayment: _buildChargeAssetTxPaymentAssetId(
                      chargeAssetTxPaymentAssetId)),
              provider: provider);
    }
    final stream =
        await SubstrateTransactionBuilder.submitExtrinsicAndWatchStatic(
            extrinsic: transaction,
            provider: provider,
            onSubmitxtrinsic: onTransactionSubmited);
    StreamSubscription<SubtrateTransactionSubmitionResult>? sub;
    void close() {
      if (!controller.isClosed) controller.close();
      sub?.cancel();
      sub = null;
    }

    void stratTracking() {
      sub = stream.listen((result) {
        final callBack = onUpdateTransactionStatus;
        if (callBack != null) callBack(result);
        close();
      }, onError: (e) {
        if (!controller.isClosed) {
          controller.addError(e);
          close();
        }
      });
    }

    controller.onListen = stratTracking;
    return controller.stream
        .asBroadcastStream(onCancel: (subscription) => close());
  }

  /// Simulates a single Substrate transaction call to estimate fees and execution outcome.
  Future<SubstrateTransactionDryRunResult> dryRunTransaction({
    required BaseSubstrateAddress owner,
    required SubstrateEncodedCallParams params,
    SubstrateTransactionSigner? signer,
    ASSET? chargeAssetTxPaymentAssetId,
  }) async {
    final provider = await metadata();

    return await SubstrateTransactionBuilder.dryRunTransaction(
        provider: provider,
        owner: owner,
        signer: signer,
        xcmVersion: network.defaultXcmVersion,
        params: TransactionBuilderParams(
            genesisHash: network.genesis, nonce: BigInt.zero),
        calls: SubstrateTransactionSubmitableParams(
            calls: [params],
            chargeAssetTxPayment: _buildChargeAssetTxPaymentAssetId(
                chargeAssetTxPaymentAssetId)));
  }

  /// Performs a dry-run simulation of an XCM transfer.
  ///
  /// Simulates the transaction from the [network] network to the [SubstrateXCMTransferParams.destinationNetwork] and reserves networks,
  ///
  /// [onRequestController] is a callback used to fetch a network controller if needed
  /// for calculating fees or other operations on the destination or reserve chains.
  /// Returns a [SubstrateTransactionXCMSimulateResult] containing the simulation result,
  /// or null if the simulation cannot be performed.
  Future<SubstrateTransactionXCMSimulateResult?> dryRunXcmTransfer({
    required BaseSubstrateAddress owner,
    required SubstrateEncodedCallParams encodedParams,
    required SubstrateXCMTransferParams creationParams,
    required ONREQUESTNETWORKCONTROLLER onRequestController,
  }) async {
    return await SubstrateNetworkControllerXCMTransferBuilder.dryRunXcm(
      owner: owner,
      destination: creationParams.destinationNetwork,
      origin: network,
      transfer: encodedParams,
      destinationFee:
          creationParams.assets.elementAt(creationParams.feeIndex).asset,
      onRequestController: (network) async {
        if (network == this.network) return this;
        return onRequestController(network);
      },
    );
  }
}
