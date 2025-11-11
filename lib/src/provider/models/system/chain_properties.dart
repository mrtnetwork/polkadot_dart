import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';

class ChainProperties {
  final int? ss58Format;
  final List<ChainPropertiesToken> tokens;
  const ChainProperties({required this.ss58Format, required this.tokens});
  factory ChainProperties.fromJson(Map<String, dynamic> json) {
    try {
      final decimals = json["tokenDecimals"];
      final tokenSymbol = json["tokenSymbol"];
      if (tokenSymbol is String) {
        return ChainProperties(
            ss58Format: IntUtils.tryParse(json["ss58Format"]),
            tokens: [
              ChainPropertiesToken(
                  decimals: IntUtils.parse(json["tokenDecimals"]),
                  tokenSymbol: tokenSymbol)
            ]);
      }
      if (decimals is List && tokenSymbol is List) {
        if (decimals.length == tokenSymbol.length) {
          return ChainProperties(
              ss58Format: IntUtils.tryParse(json["ss58Format"]),
              tokens: List.generate(
                  tokenSymbol.length,
                  (index) => ChainPropertiesToken(
                      decimals: IntUtils.parse(decimals[index]),
                      tokenSymbol: tokenSymbol[index])));
        }
      }
    } catch (_) {}
    return ChainProperties(ss58Format: null, tokens: []);
  }

  Map<String, dynamic> toJson() {
    if (ss58Format == null && tokens.isEmpty) {
      return {};
    }
    return {
      "ss58Format": ss58Format,
      "tokenDecimals": tokens.length > 1
          ? tokens.map((e) => e.decimals).toList()
          : tokens.firstOrNull?.decimals,
      "tokenSymbol": tokens.length > 1
          ? tokens.map((e) => e.tokenSymbol).toList()
          : tokens.firstOrNull?.tokenSymbol
    };
  }

  @override
  String toString() {
    return "ChainProperties${toJson()}";
  }
}

class ChainPropertiesToken {
  final int decimals;
  final String tokenSymbol;
  const ChainPropertiesToken(
      {required this.decimals, required this.tokenSymbol});
}
