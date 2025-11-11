import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/models/generic/models/block_hash.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

import 'generic_extrinsic.dart';
import 'generic_extrinsic_signature.dart';

class TransactionPalyloadConst {
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
  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);

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
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "method": method,
      "era": era.serializeJson(),
      "nonce": nonce,
      "tip": tip ?? BigInt.zero,
      "specVersion": specVersion,
      "transactionVersion": transactionVersion,
      "genesisHash": genesisHash.serializeJson(),
      "blockHash": blockHash.serializeJson()
    };
  }

  /// the bytes must be sign
  List<int> serialzeSign({String? property}) {
    final digest = serialize(property: property);
    if (digest.length > TransactionPalyloadConst.requiredHashDigestLength) {
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
  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),

      /// signatureType
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),

      /// additional signed (need in payload)
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
      LayoutConst.optional(LayoutConst.fixedBlob32(), property: "metadataHash"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);
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
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      ...super.serializeJson(property: property),
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

  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.optional(LayoutConst.blob(LayoutConst.greedy()),
          property: "asset"),
      LayoutConst.u8(property: "mode"),
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
      LayoutConst.optional(LayoutConst.fixedBlob32(), property: "metadataHash"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);
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
  Map<String, dynamic> serializeJson({String? property}) {
    return {...super.serializeJson(property: property), "asset": asset};
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
    extends BaseTransactionPayload<SubstrateEthereumAddress> {
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
      TransactionPayload.layout_(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      ...super.serializeJson(property: property),
      "mode": mode,
      "metadataHash": metadataHash,
    };
  }

  @override
  EthereumExtrinsicSignature toExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required SubstrateEthereumAddress signer}) {
    return EthereumExtrinsicSignature(
        signature: signature,
        address: signer.toMultiAddress(),
        era: era,
        tip: tip,
        nonce: nonce);
  }
}
