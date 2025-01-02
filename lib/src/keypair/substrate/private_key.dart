import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';

import 'public_key.dart';

class SubstrateKeyAlgorithm {
  final EllipticCurveTypes curve;
  final String name;
  const SubstrateKeyAlgorithm._(this.curve, this.name);
  static const SubstrateKeyAlgorithm sr25519 =
      SubstrateKeyAlgorithm._(EllipticCurveTypes.sr25519, "sr25519");
  static const SubstrateKeyAlgorithm secp256k1 =
      SubstrateKeyAlgorithm._(EllipticCurveTypes.secp256k1, "secp256k1");
  static const SubstrateKeyAlgorithm ed25519 =
      SubstrateKeyAlgorithm._(EllipticCurveTypes.ed25519, "ed25519");

  static const List<SubstrateKeyAlgorithm> values = [
    sr25519,
    secp256k1,
    ed25519
  ];

  SubstrateCoins get defaultCoin {
    switch (this) {
      case SubstrateKeyAlgorithm.sr25519:
        return SubstrateCoins.polkadotSr25519;
      case SubstrateKeyAlgorithm.ed25519:
        return SubstrateCoins.polkadotEd25519;
      case SubstrateKeyAlgorithm.secp256k1:
        return SubstrateCoins.polkadotSecp256k1;
      default:
        throw UnimplementedError();
    }
  }
}

/// Represents a private key in the Substrate framework.
class SubstratePrivateKey {
  /// The underlying Substrate instance.
  final Substrate _substrate;

  /// Constructs a [SubstratePrivateKey] instance from a Substrate object.
  const SubstratePrivateKey._(this._substrate, this.algorithm);

  /// Generates a [SubstratePrivateKey] from a seed.
  factory SubstratePrivateKey.fromSeed({
    required List<int> seedBytes,
    SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519,
  }) {
    final substrate = Substrate.fromSeed(seedBytes, algorithm.defaultCoin);
    return SubstratePrivateKey._(substrate, algorithm);
  }

  /// Constructs a [SubstratePrivateKey] from a private key.
  factory SubstratePrivateKey.fromPrivateKey({
    required List<int> keyBytes,
    SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519,
  }) {
    final substrate = Substrate.fromPrivateKey(keyBytes, algorithm.defaultCoin);
    return SubstratePrivateKey._(substrate, algorithm);
  }

  /// Constructs a [SubstratePrivateKey] from a seed and path.
  factory SubstratePrivateKey.fromSeedAndPath(
      {required List<int> seedBytes,
      required String path,
      SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519}) {
    final substrate =
        Substrate.fromSeedAndPath(seedBytes, path, algorithm.defaultCoin);
    return SubstratePrivateKey._(substrate, algorithm);
  }

  /// Retrieves the algorithm used for the private key.
  final SubstrateKeyAlgorithm algorithm;

  /// Derives a new private key from the current one using the provided [path].
  SubstratePrivateKey derive(String path) {
    final derive = _substrate.derivePath(path);
    return SubstratePrivateKey._(derive, algorithm);
  }

  /// Converts the private key to bytes.
  List<int> toBytes() {
    return List<int>.from(_substrate.priveKey.raw);
  }

  /// Converts the private key to hexadecimal string.
  String tohex({bool upperCase = false}) {
    return BytesUtils.toHexString(toBytes(),
        lowerCase: !upperCase, prefix: "0x");
  }

  /// Converts the private key to a public key.
  SubstratePublicKey toPublicKey() {
    return SubstratePublicKey.fromBytes(
        pubkeyBytes: _substrate.publicKey.compressed, algorithm: algorithm);
  }

  /// Converts the private key to a Substrate address.
  SubstrateAddress toAddress({int ss58Format = SS58Const.genericSubstrate}) {
    return toPublicKey().toAddress(ss58Format: ss58Format);
  }

  /// Signs a given digest using the private key.
  List<int> sign(List<int> digest) {
    final signer = SubstrateSigner.fromSubstrate(_substrate);
    return signer.sign(digest);
  }

  /// Signs a given message using VRF (Verifiable Random Function) and the private key.
  List<int> vrfSign(
    List<int> message, {
    List<int>? context,
    List<int>? extra,
  }) {
    final signer = SubstrateSigner.fromSubstrate(_substrate);
    return signer.vrfSign(message, context: context, extra: extra);
  }

  /// Verifies a given message and signature using the public key derived from the private key.
  bool verify(List<int> message, List<int> signature) {
    return toPublicKey().verify(message, signature);
  }

  /// Verifies a given message and VRF (Verifiable Random Function) signature using the public key derived from the private key.
  bool vrfVerify(List<int> message, List<int> vrfSign,
      {List<int>? context, List<int>? extra}) {
    return toPublicKey()
        .vrfVerify(message, vrfSign, context: context, extra: extra);
  }

  /// Generates a multi-signature using the private key.
  SubstrateMultiSignature multiSignature(List<int> digest) {
    final signature = sign(digest);
    final SubstrateBaseSignature substrateSignature;
    switch (algorithm) {
      case SubstrateKeyAlgorithm.ed25519:
        substrateSignature = SubstrateED25519Signature(signature);
        break;
      case SubstrateKeyAlgorithm.secp256k1:
        substrateSignature = SubstrateEcdsaSignature(signature);
        break;
      default:
        substrateSignature = SubstrateSr25519Signature(signature);
        break;
    }
    return SubstrateMultiSignature(substrateSignature);
  }

  @override
  String toString() {
    return "publicKey: ${toPublicKey().tohex()}";
  }
}
