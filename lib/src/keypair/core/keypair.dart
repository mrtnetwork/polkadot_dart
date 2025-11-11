import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/signer.dart';

enum SubstrateKeyAlgorithm {
  sr25519(name: "Sr25519", value: 0),
  ecdsa(name: "Ecdsa", value: 1),
  ed25519(name: "Ed25519", value: 2),
  ethereum(name: "Ethereum", value: 3);

  const SubstrateKeyAlgorithm({required this.name, required this.value});

  static SubstrateKeyAlgorithm fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }

  final String name;
  final int value;
  EllipticCurveTypes get curve {
    return switch (this) {
      SubstrateKeyAlgorithm.ecdsa ||
      SubstrateKeyAlgorithm.ethereum =>
        EllipticCurveTypes.secp256k1,
      SubstrateKeyAlgorithm.ed25519 => EllipticCurveTypes.ed25519,
      SubstrateKeyAlgorithm.sr25519 => EllipticCurveTypes.sr25519
    };
  }

  CryptoCoins get coinInfo {
    switch (this) {
      case SubstrateKeyAlgorithm.sr25519:
        return SubstrateCoins.polkadotSr25519;
      case SubstrateKeyAlgorithm.ed25519:
        return SubstrateCoins.polkadotEd25519;
      case SubstrateKeyAlgorithm.ecdsa:
        return SubstrateCoins.polkadotSecp256k1;
      case SubstrateKeyAlgorithm.ethereum:
        return Bip44Coins.ethereum;
    }
  }

  SubstrateCoins get substrateCoinInfo {
    if (this == SubstrateKeyAlgorithm.ethereum) {
      throw DartSubstratePluginException(
          "Please use SubstrateEthereumPrivateKey or SubstrateEthereumPublickey for ethereum coin info.");
    }
    return coinInfo as SubstrateCoins;
  }

  int get signatureLength {
    return switch (this) {
      SubstrateKeyAlgorithm.ecdsa ||
      SubstrateKeyAlgorithm.ethereum =>
        SubstrateConstant.ecdsaSignatureLength,
      SubstrateKeyAlgorithm.ed25519 => SubstrateConstant.signatureLength,
      SubstrateKeyAlgorithm.sr25519 => SubstrateConstant.signatureLength,
    };
  }
}

abstract class BaseSubstratePublicKey<ADDRESS extends BaseSubstrateAddress> {
  abstract final SubstrateKeyAlgorithm algorithm;
  const BaseSubstratePublicKey();

  /// key bytes
  List<int> toBytes();

  /// convert to hex
  String toHex({bool upperCase = false});

  /// verify signature
  bool verify(List<int> message, List<int> signature);

  /// get address
  ADDRESS toAddress();
}

abstract class BaseSubstratePrivateKey<ADDRESS extends BaseSubstrateAddress,
        PUBLICKEY extends BaseSubstratePublicKey<ADDRESS>>
    with SubstrateTransactionSigner {
  const BaseSubstratePrivateKey();
  @override
  abstract final SubstrateKeyAlgorithm algorithm;

  /// key bytes
  List<int> toBytes();

  /// convert key to hex.
  String toHex({bool upperCase = false});

  /// sign
  List<int> sign(List<int> digest);

  /// verify signature
  bool verify(List<int> message, List<int> signature);

  /// address
  ADDRESS toAddress();

  /// get public key
  PUBLICKEY toPublicKey();

  @override
  Future<List<int>> signAsync(List<int> digest) async {
    return sign(digest);
  }
}
