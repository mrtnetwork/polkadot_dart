import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/ss58_constant.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';

import 'public_key.dart';

/// Class representing an Ethereum private key, allowing for cryptographic operations and key-related functionality.
class SubstrateEthereumPrivateKey
    extends
        BaseSubstratePrivateKey<
          SubstrateEthereumAddress,
          SubstrateEthereumPublicKey
        > {
  /// Private constructor for creating an instance of [SubstrateEthereumPrivateKey] with a given private key.
  const SubstrateEthereumPrivateKey(this.privateKey);

  /// The underlying ECDSA private key.
  final Secp256k1PrivateKey privateKey;

  /// Creates a [SubstrateEthereumPrivateKey] instance from a list of bytes representing the private key.
  factory SubstrateEthereumPrivateKey.fromBytes(List<int> keyBytes) {
    try {
      final Secp256k1PrivateKey key = Secp256k1PrivateKey.fromBytes(keyBytes);
      return SubstrateEthereumPrivateKey(key);
    } catch (e) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "Invalid ECDSA private key.",
        details: {"keyBytes": BytesUtils.tryToHexString(keyBytes)},
      );
    }
  }

  /// Retrieves the raw bytes of the private key.
  @override
  SecretBytes toBytes() {
    return privateKey.toBytes();
  }

  /// Converts the private key to a hexadecimal string.
  @override
  String toHex({bool upperCase = false}) {
    return BytesUtils.toHexString(toBytes(), lowerCase: !upperCase);
  }

  /// Retrieves the corresponding ethereum public key.
  @override
  SubstrateEthereumPublicKey toPublicKey() {
    return SubstrateEthereumPublicKey(privateKey.publicKey);
  }

  /// Signs a transaction digest using the private key.
  ///
  /// Optionally, [hashMessage] can be set to false to skip hashing the message before signing.
  @override
  BuBytes sign(List<int> transactionDigest, {bool hashMessage = true}) {
    final ethsigner = ETHSigner(Secp256k1Signer(privateKey));
    final sign = ethsigner.sign(transactionDigest, hashMessage: hashMessage);
    return sign.encoded;
  }

  /// Signs a personal message (eth_personalsign) using the private key and returns the signature as a hexadecimal string.
  ///
  /// Optionally, [payloadLength] can be set to specify the payload length for the message.
  String signPersonalMessage(List<int> message, {int? payloadLength}) {
    final ethsigner = ETHSigner(Secp256k1Signer(privateKey));
    final sign = ethsigner.signPersonalMessage(
      message,
      payloadLength: payloadLength,
    );
    return sign.encoded.toHex();
  }

  SubstrateMultiSignature multiSignature(List<int> digest) {
    final signature = sign(digest);
    return SubstrateMultiSignature(SubstrateEcdsaSignature(signature));
  }

  @override
  SubstrateEthereumAddress toAddress() {
    return toPublicKey().toAddress();
  }

  SubstrateAddress toSS58Address({
    int ss58Format = SS58Const.genericSubstrate,
  }) {
    return toPublicKey().toSS58Address(ss58Format: ss58Format);
  }

  @override
  SubstrateKeyAlgorithm get algorithm => SubstrateKeyAlgorithm.ethereum;

  @override
  bool verify(List<int> message, List<int> signature) {
    return toPublicKey().verify(message, signature);
  }

  @override
  void dispose() {
    privateKey.dispose();
  }
}
