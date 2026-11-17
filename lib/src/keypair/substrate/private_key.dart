import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';

import 'public_key.dart';

/// Represents a private key in the Substrate framework.
class SubstratePrivateKey
    extends BaseSubstratePrivateKey<SubstrateAddress, SubstratePublicKey> {
  /// The underlying Substrate instance.
  final Substrate substrate;

  /// Constructs a [SubstratePrivateKey] instance from a Substrate object.
  const SubstratePrivateKey._(this.substrate, this.algorithm);

  /// Generates a [SubstratePrivateKey] from a seed.
  factory SubstratePrivateKey.fromSeed({
    required List<int> seedBytes,
    SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519,
  }) {
    final substrate = Substrate.fromSeed(
      seedBytes,
      algorithm.substrateCoinInfo,
    );
    return SubstratePrivateKey._(substrate, algorithm);
  }

  /// Constructs a [SubstratePrivateKey] from a private key.
  factory SubstratePrivateKey.fromPrivateKey({
    required List<int> keyBytes,
    SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519,
  }) {
    final substrate = Substrate.fromPrivateKey(
      keyBytes,
      algorithm.substrateCoinInfo,
    );
    return SubstratePrivateKey._(substrate, algorithm);
  }

  /// Constructs a [SubstratePrivateKey] from a seed and path.
  factory SubstratePrivateKey.fromSeedAndPath({
    required List<int> seedBytes,
    required String path,
    SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519,
  }) {
    final substrate = Substrate.fromSeedAndPath(
      seedBytes,
      path,
      algorithm.substrateCoinInfo,
    );
    return SubstratePrivateKey._(substrate, algorithm);
  }

  /// Retrieves the algorithm used for the private key.
  @override
  final SubstrateKeyAlgorithm algorithm;

  /// Derives a new private key from the current one using the provided [path].
  SubstratePrivateKey derive(String path) {
    final derive = substrate.derivePath(path);
    return SubstratePrivateKey._(derive, algorithm);
  }

  /// Converts the private key to bytes.
  @override
  SecretBytes toBytes() {
    return substrate.priveKey.toBytes();
  }

  /// Converts the private key to hexadecimal string.
  @override
  String toHex({bool upperCase = false}) {
    return BytesUtils.toHexString(
      toBytes(),
      lowerCase: !upperCase,
      prefix: "0x",
    );
  }

  /// Converts the private key to a public key.
  @override
  SubstratePublicKey toPublicKey() {
    return SubstratePublicKey.fromBytes(
      pubkeyBytes: substrate.publicKey.toBytes(),
      algorithm: algorithm,
    );
  }

  /// Converts the private key to a Substrate address.
  @override
  SubstrateAddress toAddress({int ss58Format = SS58Const.genericSubstrate}) {
    return toPublicKey().toAddress(ss58Format: ss58Format);
  }

  /// Signs a given digest using the private key.
  @override
  BuBytes sign(List<int> digest) {
    return substrate.priveKey.toBytes().useValue((k) {
      final signer = SubstrateSigner.fromBytes(k, substrate.type);
      try {
        return signer.sign(digest).encoded;
      } finally {
        signer.dispose();
      }
    }, zero: true);
  }

  /// Signs a given message using VRF (Verifiable Random Function) and the private key.
  List<int> vrfSign(List<int> message, {List<int>? context, List<int>? extra}) {
    return substrate.priveKey.toBytes().useValue((k) {
      final signer = SubstrateSigner.fromBytes(k, substrate.type);
      try {
        return signer.vrfSign(message, context: context, extra: extra).encoded;
      } finally {
        signer.dispose();
      }
    }, zero: true);
  }

  /// Verifies a given message and signature using the public key derived from the private key.
  @override
  bool verify(List<int> message, List<int> signature) {
    return toPublicKey().verify(message, signature);
  }

  /// Verifies a given message and VRF (Verifiable Random Function) signature using the public key derived from the private key.
  bool vrfVerify(
    List<int> message,
    List<int> vrfSign, {
    List<int>? context,
    List<int>? extra,
  }) {
    switch (algorithm) {
      case SubstrateKeyAlgorithm.sr25519:
        final signer = SubstrateSr25519Signer.fromKeyBytes(toBytes());
        return signer.vrfVerify(
          message,
          vrfSign,
          context: context,
          extra: extra,
        );
      default:
        return toPublicKey().vrfVerify(
          message,
          vrfSign,
          context: context,
          extra: extra,
        );
    }
  }

  /// Generates a multi-signature using the private key.
  SubstrateMultiSignature multiSignature(List<int> digest) {
    final signature = sign(digest);
    final SubstrateBaseSignature substrateSignature;
    switch (algorithm) {
      case SubstrateKeyAlgorithm.ed25519:
        substrateSignature = SubstrateED25519Signature(signature);
        break;
      case SubstrateKeyAlgorithm.ecdsa:
        substrateSignature = SubstrateEcdsaSignature(signature);
        break;
      case SubstrateKeyAlgorithm.sr25519:
        substrateSignature = SubstrateSr25519Signature(signature);
        break;
      default:
        throw BuError(DefaultErrorType.invalidArgument, 
          "Invalid algorithm ${algorithm.name}: expected ed25519, sr25519 or ecdsa.",
          details: {"algorithm": algorithm.name},
        );
    }
    return SubstrateMultiSignature(substrateSignature);
  }

  @override
  String toString() {
    return "publicKey: ${toPublicKey().toHex()}";
  }

  @override
  void dispose() {
    substrate.dispose();
  }
}
