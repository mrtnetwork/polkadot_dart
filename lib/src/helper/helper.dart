import 'package:blockchain_utils/blockchain_utils.dart';

class SubstrateHelper {
  static final BigRational _ksmDecimal = BigRational(BigInt.from(10).pow(12));
  static final BigRational _dotDecimal = BigRational(BigInt.from(10).pow(10));

  static BigInt toKSM(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _ksmDecimal).toBigInt();
  }

  static String fromKSM(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _ksmDecimal).toDecimal(digits: 12);
  }

  static BigInt toDOT(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _dotDecimal).toBigInt();
  }

  static String fromDOT(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _dotDecimal).toDecimal(digits: 10);
  }

  static BigInt toWSD(String amount) {
    return toKSM(amount);
  }

  static String fromWSD(BigInt amount) {
    return fromKSM(amount);
  }

  static List<int> txHash(List<int> callBytes) {
    return QuickCrypto.blake2b256Hash(callBytes);
  }
}
