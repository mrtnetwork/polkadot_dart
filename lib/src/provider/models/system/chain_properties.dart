import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';

class ChainProperties {
  final int? ss58Format;
  final int tokenDecimals;
  final String tokenSymbol;
  const ChainProperties(
      {required this.ss58Format,
      required this.tokenDecimals,
      required this.tokenSymbol});
  factory ChainProperties.fromJson(Map<String, dynamic> json) {
    return ChainProperties(
        ss58Format: IntUtils.tryParse(json["ss58Format"]),
        tokenDecimals: IntUtils.parse(json["tokenDecimals"]),
        tokenSymbol: json["tokenSymbol"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "ss58Format": ss58Format,
      "tokenDecimals": tokenDecimals,
      "tokenSymbol": tokenSymbol
    };
  }

  @override
  String toString() {
    return "ChainProperties${toJson()}";
  }
}
