import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/models/extrinsic/layouts/v4.dart';
import 'package:polkadot_dart/src/models/generic/models/block_hash.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';
import 'generic_extrinsic_signature_v.dart';
import 'generic_extrinsic_v4.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';

class _TransactionPalyloadConst {
  static const int requiredHashDigestLength = 256;
}

class TransactionPayload extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateBlockHash blockHash;
  final SubstrateBaseEra era;
  final SubstrateBlockHash genesisHash;
  final List<int> method;
  final BigInt? tip;
  final int nonce;
  final int specVersion;
  final int transactionVersion;
  final int mode;
  final List<int>? metadataHash;
  TransactionPayload(
      {required this.blockHash,
      required this.era,
      required this.genesisHash,
      required List<int> method,
      required this.nonce,
      required this.specVersion,
      required this.transactionVersion,
      List<int>? metadataHash,
      this.mode = 0,
      this.tip})
      : method = BytesUtils.toBytes(method, unmodifiable: true),
        metadataHash = BytesUtils.tryToBytes(metadataHash, unmodifiable: true);

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.payloadV4(property: property);

  Extrinsic toExtrinsic(
      {required SubstrateMultiSignature signature,
      required SubstrateAddress signer}) {
    final signatureExtrinsic = ExtrinsicSignature(
        signature: signature,
        address: signer.toMultiAddress(),
        era: era,
        tip: BigInt.zero,
        nonce: nonce,
        mode: mode);
    return Extrinsic(signature: signatureExtrinsic, methodBytes: method);
  }

  /// the bytes must be sign
  List<int> serialzeSign({String? property}) {
    final digest = serialize(property: property);
    if (digest.length > _TransactionPalyloadConst.requiredHashDigestLength) {
      return QuickCrypto.blake2b256Hash(digest);
    }
    return digest;
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
