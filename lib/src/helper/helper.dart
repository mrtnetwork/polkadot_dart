import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/keypair/keypair.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

// Helper class for Substrate transactions
class SubstrateHelper {
  // Decimal values for KSM and DOT
  static final BigRational _ksmDecimal = BigRational(BigInt.from(10).pow(12));
  static final BigRational _dotDecimal = BigRational(BigInt.from(10).pow(10));

  // Convert amount to KSM
  static BigInt toKSM(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _ksmDecimal).toBigInt();
  }

  // Convert KSM amount to string
  static String fromKSM(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _ksmDecimal).toDecimal(digits: 12);
  }

  // Convert amount to DOT
  static BigInt toDOT(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _dotDecimal).toBigInt();
  }

  // Convert DOT amount to string
  static String fromDOT(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _dotDecimal).toDecimal(digits: 10);
  }

  // Convert amount to WSD
  static BigInt toWSD(String amount) {
    return toKSM(amount);
  }

  // Convert WSD amount to string
  static String fromWSD(BigInt amount) {
    return fromKSM(amount);
  }

  // Calculate transaction hash
  static List<int> txHash(List<int> callBytes) {
    return QuickCrypto.blake2b256Hash(callBytes);
  }

  // Create a transaction
  static Extrinsic createTransaction({
    required String blockHash,
    required String genesisHash,
    required List<int> methodBytes,
    required int nonce,
    required int specVersion,
    required int transactionVersion,
    required SubstrateBaseEra era,
    SubstratePrivateKey? signer,
    int extrinsicVersion = SubstrateConstant.currentExtrinsicVersion,
  }) {
    final payload = TransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: methodBytes,
      nonce: nonce,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      tip: BigInt.zero,
    );

    ExtrinsicSignature? signature;
    if (signer != null) {
      final SubstrateMultiSignature multiSignature =
          signer.multiSignature(payload.serialzeSign());
      signature = ExtrinsicSignature(
        signature: multiSignature,
        address: signer.toAddress().toMultiAddress(),
        era: era,
        tip: BigInt.zero,
        nonce: nonce,
      );
    }

    return Extrinsic(
        signature: signature,
        methodBytes: methodBytes,
        version: extrinsicVersion);
  }
}
