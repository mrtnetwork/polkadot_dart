import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/models/extrinsic/layouts/v4.dart';
import 'package:polkadot_dart/src/models/generic/models/block_hash.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';
import 'generic_extrinsic_signature.dart';
import 'generic_extrinsic.dart';

class _TransactionPalyloadConst {
  static const int requiredHashDigestLength = 256;
}

abstract class BaseTransactionPayload
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateBlockHash blockHash;
  final SubstrateBaseEra era;
  final SubstrateBlockHash genesisHash;
  final List<int> method;
  final BigInt? tip;
  final int nonce;
  final int specVersion;
  final int transactionVersion;
  BaseTransactionPayload(
      {required this.blockHash,
      required this.era,
      required this.genesisHash,
      required List<int> method,
      required this.nonce,
      required this.specVersion,
      required this.transactionVersion,
      this.tip})
      : method = method.asImmutableBytes;

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.legacyPayloadV4(property: property);

  BaseExtrinsicSignature toExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required SubstrateAddress signer}) {
    return LegacyExtrinsicSignature(
        signature: signature,
        address: signer.toMultiAddress(),
        era: era,
        tip: BigInt.zero,
        nonce: nonce);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "method": method,
      "era": era.scaleJsonSerialize(),
      "nonce": nonce,
      "tip": tip ?? BigInt.zero,
      "specVersion": specVersion,
      "transactionVersion": transactionVersion,
      "genesisHash": genesisHash.scaleJsonSerialize(),
      "blockHash": blockHash.scaleJsonSerialize()
    };
  }

  /// the bytes must be sign
  List<int> serialzeSign({String? property}) {
    final digest = serialize(property: property);
    if (digest.length > _TransactionPalyloadConst.requiredHashDigestLength) {
      return QuickCrypto.blake2b256Hash(digest);
    }
    return digest;
  }

  Extrinsic toExtrinsic(
      {required SubstrateMultiSignature signature,
      required SubstrateAddress signer}) {
    return Extrinsic(
        signature: toExtrinsicSignature(signature: signature, signer: signer),
        methodBytes: method);
  }
}

class TransactionPayload extends BaseTransactionPayload {
  final int mode;
  final List<int>? metadataHash;

  TransactionPayload(
      {required SubstrateBlockHash blockHash,
      required SubstrateBaseEra era,
      required SubstrateBlockHash genesisHash,
      required List<int> method,
      required int nonce,
      required int specVersion,
      required int transactionVersion,
      this.mode = 0,
      BigInt? tip,
      List<int>? metadataHash})
      : metadataHash = metadataHash?.asImmutableBytes,
        super(
            blockHash: blockHash,
            era: era,
            genesisHash: genesisHash,
            method: method,
            nonce: nonce,
            specVersion: specVersion,
            transactionVersion: transactionVersion,
            tip: tip);

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.payloadV4(property: property);
  @override
  ExtrinsicSignature toExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required SubstrateAddress signer}) {
    return ExtrinsicSignature(
        signature: signature,
        address: signer.toMultiAddress(),
        era: era,
        tip: BigInt.zero,
        nonce: nonce,
        mode: mode);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "method": method,
      "era": era.scaleJsonSerialize(),
      "nonce": nonce,
      "tip": tip ?? BigInt.zero,
      "specVersion": specVersion,
      "transactionVersion": transactionVersion,
      "genesisHash": genesisHash.scaleJsonSerialize(),
      "blockHash": blockHash.scaleJsonSerialize(),
      "mode": mode,
      "metadataHash": metadataHash,
    };
  }
}

class LegacyTransactionPayload extends BaseTransactionPayload {
  LegacyTransactionPayload(
      {required SubstrateBlockHash blockHash,
      required SubstrateBaseEra era,
      required SubstrateBlockHash genesisHash,
      required List<int> method,
      required int nonce,
      required int specVersion,
      required int transactionVersion,
      BigInt? tip})
      : super(
            blockHash: blockHash,
            era: era,
            genesisHash: genesisHash,
            method: method,
            nonce: nonce,
            specVersion: specVersion,
            transactionVersion: transactionVersion,
            tip: tip);
}
