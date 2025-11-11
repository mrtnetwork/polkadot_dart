import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/signer.dart';
import 'package:polkadot_dart/src/substrate.dart';

typedef ONLOOKUPBLOCKEVENT<T extends Object> = T? Function(
    String blockHash,
    int blockId,
    SubstrateBlockResponse blockExtrinsics,
    SubstrateGroupEvents events);

final class SubstrateTransactionBuilder {
  static List<int> _getCallBytes(
      {required SubstrateTransactionSubmitableParams calls,
      required MetadataWithProvider provider}) {
    if (calls.calls.length == 1) {
      return calls.calls.first.bytes;
    }
    if (!provider.metadata.api.metadata.callMethodExists(
        SubtrateMetadataPallet.utility.name,
        SubtrateMetadataUtilityMethods.batch.name)) {
      throw DartSubstratePluginException("Unsuported batch transaction.");
    }
    return provider.metadata.api.encodeCall(
        palletNameOrIndex: SubtrateMetadataPallet.utility.name,
        value: {
          SubtrateMetadataUtilityMethods.batch.name:
              calls.calls.map((e) => LookupRawParam(bytes: e.bytes)).toList()
        });
  }

  /// Builds a Substrate transaction payload; ready for signing.
  static Future<SubstrateSubmitableTransactionPayload> buildTransactionStatic(
      {required BaseSubstrateAddress owner,
      TransactionBuilderParams params =
          const TransactionBuilderParams.defaultParams(),
      required SubstrateTransactionSubmitableParams calls,
      required MetadataWithProvider provider}) async {
    if (calls.chargeAssetTxPayment != null &&
        !provider.metadata.extrinsic.chargeAssetTxPayment) {
      throw DartSubstratePluginException(
          "Network does not support ChargeAssetTxPayment fee.");
    }
    if (calls.calls.isEmpty) {
      throw DartSubstratePluginException(
          "At least one call required for create transaction.");
    }
    final List<int> methodBytes =
        _getCallBytes(calls: calls, provider: provider);
    final SubstrateBlockHash genesis = await () async {
      final gnesis = params.genesisHash;
      if (gnesis != null) return SubstrateBlockHash.hash(gnesis);
      final genesisHash = await provider.provider
          .request(const SubstrateRequestChainGetBlockHash<String?>(number: 0));
      if (genesisHash == null) {
        throw DartSubstratePluginException(
            "Unexpected null response when fetching genesis block hash.");
      }
      return SubstrateBlockHash.hash(genesisHash);
    }();

    final TransactionSubmitionBlock submitionBlock = await () async {
      final submitionBlock = params.submitionBlock;
      if (submitionBlock != null) return submitionBlock;
      final blockHash = await provider.provider
          .request(const SubstrateRequestChainChainGetFinalizedHead());
      final blockHeader = await provider.provider
          .request(SubstrateRequestChainChainGetHeader(atBlockHash: blockHash));
      final era = blockHeader.toMortalEra(period: params.txExpireEra);
      return TransactionSubmitionBlock(
          blockHash: SubstrateBlockHash.hash(blockHash),
          era: era,
          blockNumber: blockHeader.number);
    }();
    final BigInt nonce = await () async {
      final nonce = params.nonce;
      if (nonce != null) return nonce;
      return await SubstrateQuickStorageApi.system.nonce(
          address: owner, rpc: provider.provider, api: provider.metadata.api);
    }();
    final runtimeVersion = provider.metadata.api.runtimeVersion();
    final int specVersion = params.specVersion ?? runtimeVersion.specVersion;
    final int transactionVersion =
        params.transactionVesrion ?? runtimeVersion.transactionVersion;
    final extrinsic = DynamicExtrinsicBuilder(
        era: submitionBlock.era,
        nonce: nonce,
        specVersion: specVersion,
        transactionVersion: transactionVersion,
        genesis: genesis.bytes,
        mortality: submitionBlock.blockHash.bytes,
        tip: params.tip,
        metadataHash: calls.metadataHash,
        chargeAssetTxPayment: calls.chargeAssetTxPayment?.assetId,
        metadataFields: provider.metadata.extrinsic);

    final extrinsicBytes =
        extrinsic.encodeExtrinsicPayload(provider.metadata.api);
    List<int>? assetIdBytes;
    if (calls.chargeAssetTxPayment != null) {
      assetIdBytes = extrinsic.encodeAssetId(provider.metadata.api);
    }
    return SubstrateSubmitableTransactionPayload(
        methodBytes: methodBytes,
        specVersion: specVersion,
        tip: params.tip ?? BigInt.zero,
        transactionVersion: transactionVersion,
        assetId: assetIdBytes,
        nonce: nonce,
        block: submitionBlock,
        genesisHash: genesis.toHex(),
        payloadBytes: [...methodBytes, ...extrinsicBytes],
        builder: extrinsic,
        owner: owner);
  }

  /// Simulates a Substrate transaction for fee/weight estimation.
  static Future<SubstrateTransactionDryRunResult> dryRunTransaction({
    required BaseSubstrateAddress owner,
    TransactionBuilderParams params =
        const TransactionBuilderParams.defaultParams(),
    required SubstrateTransactionSubmitableParams calls,
    required MetadataWithProvider provider,
    XCMVersion xcmVersion = XCMVersion.v3,
    SubstrateTransactionSigner? signer,
  }) async {
    final extrinsic = await buildAndSignTransactionStatic(
        owner: owner,
        calls: calls,
        provider: provider,
        params: params,
        signer: signer,
        fakeSignature: true);

    final feeInfo = await provider.provider.request(
        SubstrateRequestRuntimeTransactionPaymentApiQueryInfo.fromExtrinsic(
            exirceBytes: extrinsic.serialize()));
    SubstrateDispatchResult<CallDryRunEffects>? dryRun;
    if (SubstrateQuickRuntimeApi.dryRun.methodExists(
        method: SubstrateRuntimeApiDryRunMethods.dryRunCall,
        api: provider.metadata.api)) {
      dryRun = await SubstrateQuickRuntimeApi.dryRun.dryRunCall(
          owner: owner,
          callBytes: _getCallBytes(calls: calls, provider: provider),
          api: provider.metadata.api,
          rpc: provider.provider,
          version: xcmVersion);
    }
    final chargeAssetTxPayment = calls.chargeAssetTxPayment;
    final nativeLocation = chargeAssetTxPayment?.nativeAssetLocation;
    final assetLocation = chargeAssetTxPayment?.assetLocation;
    BigInt? fee;
    if (chargeAssetTxPayment == null) {
      fee = feeInfo.partialFee;
    } else if (nativeLocation != null &&
        assetLocation != null &&
        SubstrateQuickRuntimeApi.assetConversion.methodExists(
            method: SubstrateRuntimeApiAssetConversionMethods
                .quotePriceExactTokensForTokens,
            api: provider.metadata.api)) {
      fee = await SubstrateQuickRuntimeApi.assetConversion
          .quotePriceTokensForExactTokens(
              params: QuotePriceParams(
                  includeFee: true,
                  amount: feeInfo.partialFee,
                  assetA: assetLocation,
                  assetB: nativeLocation),
              api: provider.metadata.api,
              rpc: provider.provider);
    }
    return SubstrateTransactionDryRunResult(
        queryFeeInfo: feeInfo, dryRun: dryRun, fee: fee);
  }

  /// Builds and sign Substrate transaction payload;.
  static Future<SubstrateSubmitableTransaction> buildAndSignTransactionStatic({
    required BaseSubstrateAddress owner,
    TransactionBuilderParams params =
        const TransactionBuilderParams.defaultParams(),
    required SubstrateTransactionSubmitableParams calls,
    required MetadataWithProvider provider,
    SubstrateTransactionSigner? signer,
    SubstrateKeyAlgorithm? fakeSignatureAlgorithm,
    bool fakeSignature = false,
  }) async {
    final payload = await buildTransactionStatic(
        owner: owner, calls: calls, provider: provider, params: params);
    return await signTransactionStatic(
        payload: payload,
        provider: provider,
        fakeSignatureAlgorithm: fakeSignatureAlgorithm,
        signer: signer,
        fakeSignature: fakeSignature);
  }

  /// Signs a Substrate transaction; uses fake signature if [signer] is null or [fakeSignature] is true.
  static Future<SubstrateSubmitableTransaction> signTransactionStatic({
    required SubstrateSubmitableTransactionPayload payload,
    required MetadataWithProvider provider,
    SubstrateTransactionSigner? signer,
    bool fakeSignature = false,
    SubstrateKeyAlgorithm? fakeSignatureAlgorithm,
    List<int>? encodedSignature,
  }) async {
    if (encodedSignature != null) {
      return payload.builder.createFinalExtrinsic(
          callBytes: payload.methodBytes,
          api: provider.metadata.api,
          owner: payload.owner,
          encodedSignature: encodedSignature);
    }
    final digest = payload.serialzeSign();
    List<int>? signature;
    if (signer != null && !fakeSignature) {
      signature = await signer.signAsync(digest);
    }

    final algorithm = signer?.algorithm ??
        fakeSignatureAlgorithm ??
        payload.builder.metadataFields.crypto.cryptoAlgoritms.firstWhere(
          (e) => e == SubstrateKeyAlgorithm.ecdsa,
          orElse: () =>
              payload.builder.metadataFields.crypto.cryptoAlgoritms.first,
        );
    signature ??= List<int>.filled(algorithm.signatureLength, 1);
    return payload.builder.createFinalExtrinsic(
        callBytes: payload.methodBytes,
        api: provider.metadata.api,
        owner: payload.owner,
        algorithm: algorithm,
        signature: signature);
  }

  /// Builds, signs, and sends a Substrate transaction in one step.
  static Future<String> buildSignAndSendTransactionStatic({
    required BaseSubstrateAddress owner,
    required SubstrateTransactionSigner signer,
    required SubstrateTransactionSubmitableParams calls,
    required MetadataWithProvider provider,
    TransactionBuilderParams params =
        const TransactionBuilderParams.defaultParams(),
  }) async {
    final payload = await buildTransactionStatic(
        owner: owner, calls: calls, params: params, provider: provider);

    final signedTx = await signTransactionStatic(
        payload: payload, signer: signer, provider: provider);
    final txId = await provider.provider.request(
        SubstrateRequestAuthorSubmitExtrinsic(signedTx.serializeHex()));
    return txId;
  }

  /// Builds, signs, and submits a Substrate transaction while streaming status updates.
  static Future<Stream<SubtrateTransactionSubmitionResult>>
      buildSignAndWatchTransactionStatic({
    required BaseSubstrateAddress owner,
    required SubstrateTransactionSigner signer,
    required SubstrateTransactionSubmitableParams calls,
    required MetadataWithProvider provider,
    TransactionBuilderParams params =
        const TransactionBuilderParams.defaultParams(),
  }) async {
    final payload = await buildTransactionStatic(
        owner: owner, calls: calls, params: params, provider: provider);

    final signedTx = await signTransactionStatic(
        payload: payload, signer: signer, provider: provider);
    return submitExtrinsicAndWatchStatic(
        extrinsic: signedTx, provider: provider);
  }

  /// Builds, signs, and submits a Substrate transaction, returning the final async result.
  static Future<SubtrateTransactionSubmitionResult>
      buildSignAndWatchTransactionStaticAsync({
    required BaseSubstrateAddress owner,
    required SubstrateTransactionSigner signer,
    required SubstrateTransactionSubmitableParams calls,
    required MetadataWithProvider provider,
    void Function(String txId, int blocId)? onSubmitxtrinsic,
    TransactionBuilderParams params =
        const TransactionBuilderParams.defaultParams(),
    int maxRetryEachBlock = 20,
    int blockCount = 50,
    int Function()? onLookupMoreBlock,
  }) async {
    final payload = await buildTransactionStatic(
        owner: owner, calls: calls, params: params, provider: provider);

    final signedTx = await signTransactionStatic(
        payload: payload, signer: signer, provider: provider);
    return submitExtrinsicAndWatchStaticAsync(
        extrinsic: signedTx,
        provider: provider,
        onSubmitxtrinsic: onSubmitxtrinsic,
        maxRetryEachBlock: maxRetryEachBlock,
        blockCount: blockCount,
        onLookupMoreBlock: onLookupMoreBlock);
  }

  /// Submits a signed extrinsic and streams its submission status with optional callbacks and retry logic.
  static Future<Stream<SubtrateTransactionSubmitionResult>>
      submitExtrinsicAndWatchStatic(
          {required SubstrateSubmitableTransaction extrinsic,
          required MetadataWithProvider provider,
          void Function(String txId, int blocId)? onSubmitxtrinsic,
          int maxRetryEachBlock = 20,
          int blockCount = 50,
          int Function()? onLookupMoreBlock,
          Duration requestTimeout = const Duration(milliseconds: 200),
          Duration blockInterval = const Duration(seconds: 10)}) async {
    final finalizeHash = await provider.provider
        .request(SubstrateRequestChainChainGetFinalizedHead());
    final finalBlockHead = await provider.provider
        .request(SubstrateRequestChainGetBlock(atBlockHash: finalizeHash));
    final ext = extrinsic.serializeHex();
    final txId = await provider.provider
        .request(SubstrateRequestAuthorSubmitExtrinsic(ext));
    if (onSubmitxtrinsic != null) {
      onSubmitxtrinsic(txId, finalBlockHead.block.header.number);
    }
    return findEextrinsic(
        txId: txId,
        extrinsic: ext,
        blockCount: blockCount,
        blockId: finalBlockHead.block.header.number,
        maxRetryEachBlock: maxRetryEachBlock,
        onLookupMoreBlock: onLookupMoreBlock,
        provider: provider,
        requestTimeout: requestTimeout,
        blockInterval: blockInterval);
  }

  /// Submits a signed extrinsic and returns the final submission result asynchronously.
  static Future<SubtrateTransactionSubmitionResult>
      submitExtrinsicAndWatchStaticAsync({
    required SubstrateSubmitableTransaction extrinsic,
    required MetadataWithProvider provider,
    void Function(String txId, int blocId)? onSubmitxtrinsic,
    int maxRetryEachBlock = 20,
    int blockCount = 50,
    int Function()? onLookupMoreBlock,
    Duration requestTimeout = const Duration(milliseconds: 200),
  }) async {
    final Completer<SubtrateTransactionSubmitionResult> completer = Completer();
    final stream = await submitExtrinsicAndWatchStatic(
        extrinsic: extrinsic,
        provider: provider,
        blockCount: blockCount,
        maxRetryEachBlock: maxRetryEachBlock,
        onLookupMoreBlock: onLookupMoreBlock,
        onSubmitxtrinsic: onSubmitxtrinsic);
    stream.listen((event) {
      if (!completer.isCompleted) completer.complete(event);
    }, onError: (e) {
      if (!completer.isCompleted) completer.completeError(e);
    });
    return completer.future;
  }

  /// Streams submission results of a specific extrinsic in a given block, with retry support.
  static Stream<SubtrateTransactionSubmitionResult> findEextrinsic({
    required String txId,
    required String extrinsic,
    required int blockId,
    required MetadataWithProvider provider,
    int maxRetryEachBlock = 20,
    int blockCount = 50,
    Duration blockInterval = const Duration(seconds: 10),
    int Function()? onLookupMoreBlock,
    Duration requestTimeout = const Duration(milliseconds: 200),
  }) {
    return loockupBlockStream(
      blockId: blockId,
      provider: provider,
      blockInterval: blockInterval,
      maxRetryEachBlock: maxRetryEachBlock,
      blockCount: blockCount,
      onLookupMoreBlock: onLookupMoreBlock,
      requestTimeout: requestTimeout,
      onBlockEvents: (blockHash, blockId, blockExtrinsics, events) {
        final index = blockExtrinsics.findExtrinsicIndex(extrinsic);
        if (index == null) {
          return null;
        }
        return SubtrateTransactionSubmitionResult(
            events: events,
            block: blockHash,
            extrinsic: extrinsic,
            blockNumber: blockId,
            extrinsicIndex: index,
            transactionHash: txId);
      },
    ).handleError((_) {
      return SubtrateTransactionSubmitionResult.notFount(
          extrinsic: extrinsic, transactionHash: txId);
    }, test: (err) => err == SubstrateLookupBlockExceptionConst.blockNotFound);
  }

  static Future<_LookupBlock<T>> _lockupBlockEvents<T extends Object>({
    required int blockId,
    required MetadataWithProvider provider,
    required ONLOOKUPBLOCKEVENT<T> onBlockEvents,
    required _LookupBlock<T> blockData,
  }) async {
    int? finalizeBlock = blockData.finalizeBlock;
    String? blockHash;
    if (finalizeBlock == null || blockId > finalizeBlock) {
      final finalizeHead = await provider.provider
          .request(SubstrateRequestChainChainGetFinalizedHead());
      final finalBlockHead = await provider.provider
          .request(SubstrateRequestChainGetBlock(atBlockHash: finalizeHead));
      finalizeBlock = finalBlockHead.block.header.number;
      if (blockId == finalizeBlock) {
        blockHash = finalizeHead;
      }
    }
    if (blockId > finalizeBlock) {
      throw SubstrateLookupBlockExceptionConst.blockNotFound;
    }
    blockHash ??= await provider.provider
        .request(SubstrateRequestChainGetBlockHash<String>(number: blockId));
    assert(blockHash != null);
    if (blockHash == null) {
      throw SubstrateLookupBlockExceptionConst.blockNotFound;
    }
    final block = await provider.provider
        .request(SubstrateRequestChainGetBlock(atBlockHash: blockHash));
    try {
      final events = await provider.metadata.api
          .getSystemEvents(provider.provider, atBlockHash: blockHash);
      final result = onBlockEvents(blockHash, block.block.header.number,
          block.block, SubstrateGroupEvents(events: events));
      return _LookupBlock(finalizeBlock, result);
    } on RPCError catch (_) {
      rethrow;
    } catch (e) {
      throw DartSubstratePluginException(e.toString());
    }
  }

  /// Streams events from a specific block, with retry and custom event handling support.
  static Stream<T> loockupBlockStream<T extends Object>(
      {Duration blockInterval = const Duration(seconds: 10),
      Duration requestTimeout = const Duration(milliseconds: 200),
      required int blockId,
      required MetadataWithProvider provider,
      required ONLOOKUPBLOCKEVENT<T> onBlockEvents,
      int Function()? onLookupMoreBlock,
      int maxRetryEachBlock = 20,
      int blockCount = 50}) {
    final controller = StreamController<T>();
    void closeController() {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    Future<void> startFetching() async {
      _LookupBlock<T> blockInfo = _LookupBlock(blockId, null);
      int id = blockId;
      int retry = maxRetryEachBlock;
      int count = blockCount;

      while (!controller.isClosed) {
        try {
          blockInfo = await _lockupBlockEvents(
              blockId: id,
              onBlockEvents: onBlockEvents,
              provider: provider,
              blockData: blockInfo);
          id++;
          count--;
          retry = maxRetryEachBlock;
          final response = blockInfo.response;
          if (response != null) {
            controller.add(response);
            closeController();
            return;
          } else {
            if (count <= 0) {
              if (onLookupMoreBlock != null) {
                count = onLookupMoreBlock();
              }
              if (count <= 0) {
                controller
                    .addError(SubstrateLookupBlockExceptionConst.notFound);
                closeController();
                return;
              }
            }
            await Future.delayed(requestTimeout);
          }
        } on DartSubstratePluginException catch (e) {
          if (e == SubstrateLookupBlockExceptionConst.blockNotFound) {
            retry--;
            if (retry <= 0) {
              controller.addError(e);
              closeController();
              return;
            }
            await Future.delayed(blockInterval);
          } else {
            controller.addError(e);
            closeController();
            return;
          }
        } catch (e) {
          controller.addError(e);
          closeController();
        }
      }
    }

    controller.onListen = startFetching;
    return controller.stream.asBroadcastStream(onCancel: (e) {
      controller.close();
    });
  }
}

class _LookupBlock<T> {
  final int? finalizeBlock;
  final T? response;
  const _LookupBlock(this.finalizeBlock, this.response);
}
