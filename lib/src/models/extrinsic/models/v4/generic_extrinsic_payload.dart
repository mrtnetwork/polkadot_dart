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

abstract class BaseTransactionPayload<ADDRESS extends BaseSubstrateAddress>
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
      {required SubstrateMultiSignature signature, required ADDRESS signer}) {
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
      {required SubstrateMultiSignature signature, required ADDRESS signer}) {
    return Extrinsic(
        signature: toExtrinsicSignature(signature: signature, signer: signer),
        methodBytes: method);
  }
}

class TransactionPayload extends BaseTransactionPayload<SubstrateAddress> {
  final int mode;
  final List<int>? metadataHash;

  TransactionPayload(
      {required super.blockHash,
      required super.era,
      required super.genesisHash,
      required super.method,
      required super.nonce,
      required super.specVersion,
      required super.transactionVersion,
      this.mode = 0,
      super.tip,
      List<int>? metadataHash})
      : metadataHash = metadataHash?.asImmutableBytes;

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.payloadV4(property: property);
  @override
  ExtrinsicSignature toExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required BaseSubstrateAddress signer}) {
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
      ...super.scaleJsonSerialize(property: property),
      "mode": mode,
      "metadataHash": metadataHash,
    };
  }
}

class AssetTransactionPayload extends TransactionPayload {
  final List<int>? asset;
  AssetTransactionPayload(
      {required super.blockHash,
      required super.era,
      required super.genesisHash,
      required super.method,
      required super.nonce,
      required super.specVersion,
      required super.transactionVersion,
      super.mode = 0,
      super.tip,
      super.metadataHash,
      List<int>? asset})
      : asset = asset?.immutable;

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.assetPayoad(property: property);
  @override
  AssetExtrinsicSignature toExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required BaseSubstrateAddress signer}) {
    return AssetExtrinsicSignature(
        signature: signature,
        address: signer.toMultiAddress(),
        era: era,
        tip: BigInt.zero,
        nonce: nonce,
        mode: mode,
        asset: asset);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {...super.scaleJsonSerialize(property: property), "asset": asset};
  }
}

class LegacyTransactionPayload
    extends BaseTransactionPayload<SubstrateAddress> {
  LegacyTransactionPayload(
      {required super.blockHash,
      required super.era,
      required super.genesisHash,
      required super.method,
      required super.nonce,
      required super.specVersion,
      required super.transactionVersion,
      super.tip});
}

class MoonbeamTransactionPayload
    extends BaseTransactionPayload<MoonbeamAddress> {
  final int mode;
  final List<int>? metadataHash;

  MoonbeamTransactionPayload(
      {required super.blockHash,
      required super.era,
      required super.genesisHash,
      required super.method,
      required super.nonce,
      required super.specVersion,
      required super.transactionVersion,
      this.mode = 0,
      super.tip,
      List<int>? metadataHash})
      : metadataHash = metadataHash?.asImmutableBytes;

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.payloadV4(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      ...super.scaleJsonSerialize(property: property),
      "mode": mode,
      "metadataHash": metadataHash,
    };
  }

  @override
  MoonbeamExtrinsicSignature toExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required MoonbeamAddress signer}) {
    return MoonbeamExtrinsicSignature(
        signature: signature,
        address: signer.toMultiAddress(),
        era: era,
        tip: tip,
        nonce: nonce);
  }
}
