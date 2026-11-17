import 'package:blockchain_utils/chain/signer/signer.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/binary/src/binary_operation.dart';

/// Protocol-level constants (key/hash/signature lengths, weight limits).
class SubstrateConstant {
  static const int blockHashBytesLength = QuickCrypto.sha256DigestSize;
  static const int accountIdLengthInBytes = 32;
  static const int accountId20LengthInBytes = 20;
  static const int ethereumAddressLength = 20;
  static const int signatureLength = QuickCrypto.sha512DigestLength;
  static const int ecdsaSignatureLength =
      CryptoSignerConst.ecdsaSignatureWithRecoveryIdLength;
  static const int bitSigned = 128;
  static const int bitUnsigned = 0;
  static const int defaultMortalLength = 55;
  static BigInt get maxWeightRefTime => BinaryOps.maxU64;
}
