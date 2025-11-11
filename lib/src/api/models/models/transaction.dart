import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/utils/utils.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/extrinsic/extrinsic.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';

class SubstrateEncodedCallParams {
  final String pallet;
  final String method;
  final List<int> bytes;
  SubstrateEncodedCallParams({
    required this.pallet,
    required this.method,
    required List<int> bytes,
  }) : bytes = bytes.asImmutableBytes;
}

/// Asset config for paying Substrate tx fees, converts to native if convertAssetPayment API exists.
class SubstrateTransactionChargeAssetTxPayment {
  /// Asset identifier used for fee payment.
  final Object assetId;

  /// Asset location; for calculate fee in native asset.
  final XCMMultiLocation? assetLocation;

  /// Native asset location for fee conversion reference. for calculate fee in native asset.
  final XCMMultiLocation? nativeAssetLocation;

  const SubstrateTransactionChargeAssetTxPayment(
      {required this.assetId,
      required this.assetLocation,
      required this.nativeAssetLocation});
}

/// Submitable tx params, supports batching and asset-based fee payment.
class SubstrateTransactionSubmitableParams {
  /// Encoded calls; multiple calls use BatchAll for execution.
  final List<SubstrateEncodedCallParams> calls;

  /// Fee payment config if paying in non-native asset.
  final SubstrateTransactionChargeAssetTxPayment? chargeAssetTxPayment;

  final List<int>? metadataHash;

  SubstrateTransactionSubmitableParams({
    required List<SubstrateEncodedCallParams> calls,
    this.chargeAssetTxPayment,
    List<int>? metadataHash,
  })  : calls = calls.immutable,
        metadataHash = metadataHash?.asImmutableBytes;
}

class TransactionBuilderParams {
  final TransactionSubmitionBlock? submitionBlock;
  final String? genesisHash;
  final int? specVersion;
  final int? transactionVesrion;
  final BigInt? tip;
  final int txExpireEra;
  final BigInt? nonce;
  const TransactionBuilderParams.defaultParams()
      : txExpireEra = SubstrateConstant.defaultMortalLength,
        genesisHash = null,
        submitionBlock = null,
        specVersion = null,
        transactionVesrion = null,
        tip = null,
        nonce = null;
  TransactionBuilderParams({
    this.genesisHash,
    this.submitionBlock,
    this.specVersion,
    this.transactionVesrion,
    this.nonce,
    this.txExpireEra = SubstrateConstant.defaultMortalLength,
    this.tip,
  });
}

class SubstrateSubmitableTransactionPayload {
  final List<int> methodBytes;
  final List<int>? assetId;
  final List<int>? metadataHash;
  final int? mode;
  final int specVersion;
  final int transactionVersion;
  final BigInt tip;
  final BigInt nonce;
  final TransactionSubmitionBlock block;
  final String genesisHash;
  final List<int> payloadBytes;
  final BaseDynamicExtrinsicBuilder builder;
  final BaseSubstrateAddress owner;

  SubstrateSubmitableTransactionPayload({
    required List<int> methodBytes,
    required this.specVersion,
    required this.tip,
    required this.transactionVersion,
    required this.nonce,
    required this.block,
    required this.genesisHash,
    required this.owner,
    required List<int> payloadBytes,
    List<int>? assetId,
    required this.builder,
    this.mode,
    List<int>? metadataHash,
  })  : methodBytes = methodBytes.asImmutableBytes,
        payloadBytes = payloadBytes.asImmutableBytes,
        assetId = assetId?.asImmutableBytes,
        metadataHash = metadataHash?.immutable;

  List<int> serialzeSign() {
    if (payloadBytes.length >
        TransactionPalyloadConst.requiredHashDigestLength) {
      return QuickCrypto.blake2b256Hash(payloadBytes);
    }
    return payloadBytes;
  }
}

class SubstrateSubmitableTransaction {
  final SubstrateSubmitableTransactionPayload? payload;
  final List<int>? signature;
  final List<int> extrinsic;
  SubstrateSubmitableTransaction(
      {this.payload, List<int>? signature, required List<int> extrinsic})
      : extrinsic = extrinsic.asImmutableBytes,
        signature = signature?.asImmutableBytes;
  SubstrateSubmitableTransaction.build(
      {this.payload,
      required List<int>? signature,
      required List<int> extrinsic,
      required int version,
      required List<int> callBytes})
      : signature = signature?.asImmutableBytes,
        extrinsic = _serialize(
            extrinsicVersion: version,
            extrinsic: extrinsic,
            callBytes: callBytes,
            signature: signature);
  static List<int> _serialize(
      {required int extrinsicVersion,
      required List<int> extrinsic,
      required List<int> callBytes,
      List<int>? signature}) {
    final signed = signature != null;
    final version = (extrinsicVersion |
        (signed ? SubstrateConstant.bitSigned : SubstrateConstant.bitUnsigned));
    final encode = [version, ...extrinsic, ...callBytes];
    return encode.asImmutableBytes;
  }

  List<int> serialize({bool encodeLength = true}) {
    if (encodeLength) {
      final length = LayoutSerializationUtils.encodeLength(extrinsic);
      return [...length, ...extrinsic];
    }
    return extrinsic;
  }

  String serializeHex({bool encodeLength = true}) {
    return BytesUtils.toHexString(serialize(), prefix: '0x');
  }

  String txId() {
    return BytesUtils.toHexString(QuickCrypto.blake2b256Hash(serialize()),
        prefix: "0x");
  }
}

class TransactionSubmitionBlock {
  final SubstrateBlockHash blockHash;
  final MortalEra era;
  final int blockNumber;
  const TransactionSubmitionBlock(
      {required this.blockHash, required this.era, required this.blockNumber});
}

enum SubtrateTransactionSubmitionStatus {
  success,

  notFound,

  failed;

  bool get isSuccess => this == success;
}

class SubtrateTransactionSubmitionResult {
  final SubtrateTransactionSubmitionStatus status;

  /// The extrinsic associated with the transaction.
  final String extrinsic;

  /// The hash of the transaction.
  final String transactionHash;

  /// The block in which the transaction was included.
  final String? block;

  /// The block number of the transaction.
  final int? blockNumber;

  final int? extrinsicIndex;

  /// A list of events related to the transaction.
  final SubstrateGroupEvents? blockEvents;

  List<SubstrateEvent>? get txEvents => blockEvents?.events
      .where((e) => e.applyExtrinsic == extrinsicIndex)
      .toList();

  SubtrateTransactionSubmitionResult.notFount({
    required this.extrinsic,
    required this.transactionHash,
  })  : blockEvents = null,
        block = null,
        blockNumber = null,
        extrinsicIndex = null,
        status = SubtrateTransactionSubmitionStatus.notFound;

  factory SubtrateTransactionSubmitionResult(
      {required SubstrateGroupEvents events,
      required String block,
      required String extrinsic,
      required int blockNumber,
      required int extrinsicIndex,
      required String transactionHash}) {
    final txEvents =
        events.events.where((e) => e.applyExtrinsic == extrinsicIndex).toList();
    final systemEvent =
        txEvents.where((e) => e.pallet == SubstrateEventConst.system);
    final success = systemEvent
        .every((e) => e.method != SubstrateEventConst.extrinsicFailed);
    return SubtrateTransactionSubmitionResult._(
        blockEvents: events,
        block: block,
        extrinsic: extrinsic,
        blockNumber: blockNumber,
        extrinsicIndex: extrinsicIndex,
        transactionHash: transactionHash,
        status: (success
            ? SubtrateTransactionSubmitionStatus.success
            : SubtrateTransactionSubmitionStatus.failed));
  }

  /// Constructor for initializing all the fields.
  SubtrateTransactionSubmitionResult._(
      {required SubstrateGroupEvents this.blockEvents,
      required String this.block,
      required this.extrinsic,
      required int this.blockNumber,
      required int this.extrinsicIndex,
      required this.transactionHash,
      required this.status});

  Map<String, dynamic> toJson() {
    return {
      "status": status.name,
      "extrinsic": extrinsic,
      "tx_id": transactionHash,
      "block": block,
      "block_number": blockNumber,
      "extrinsic_index": extrinsicIndex,
      "block_events": blockEvents?.events.map((e) => e.toJson()).toList(),
    };
  }
}
