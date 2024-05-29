import 'package:blockchain_utils/blockchain_utils.dart';

class SubstrateHelper {
  static final BigRational _wsdDecimal = BigRational(BigInt.from(10).pow(12));

  static BigInt toWsd(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _wsdDecimal).toBigInt();
  }

  static String fromWsd(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _wsdDecimal).toDecimal(digits: 6);
  }
}
