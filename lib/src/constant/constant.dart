import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/signer/signer.dart';

class SubstrateConstant {
  static const int currentExtrinsicVersion = 4;
  static const int blockHashBytesLength = QuickCrypto.sha256DigestSize;
  static const int accountIdLengthInBytes = 32;
  static const int accountId20LengthInBytes = 20;

  static const int signatureLength = QuickCrypto.sha512DeigestLength;
  static const int ecdsaSignatureLength = ETHSignerConst.ethSignatureLength +
      ETHSignerConst.ethSignatureRecoveryIdLength;
  static const int bitSigned = 128;
  static const int bitUnsigned = 0;
  static int callIndexBytesLength = 2;

  static const int defaultMortalLength = 55;
}
