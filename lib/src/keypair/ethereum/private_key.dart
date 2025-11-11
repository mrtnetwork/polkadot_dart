import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';

import 'public_key.dart';

/// Class representing an ethereum private key, allowing for cryptographic operations and key-related functionality.
class SubstrateEthereumPrivateKey extends BaseSubstratePrivateKey<
    SubstrateEthereumAddress, SubstrateEthereumPublicKey> {
  /// Private constructor for creating an instance of [SubstrateEthereumPrivateKey] with a given private key.
  const SubstrateEthereumPrivateKey._(this._privateKey);

  /// The underlying ECDSA private key.
  final Secp256k1PrivateKey _privateKey;

  /// Creates an [SubstrateEthereumPrivateKey] instance from a hexadecimal private key string.
  factory SubstrateEthereumPrivateKey(String privateKeyHex) {
    return SubstrateEthereumPrivateKey.fromBytes(
        BytesUtils.fromHexString(privateKeyHex));
  }

  /// Creates an [SubstrateEthereumPrivateKey] instance from a list of bytes representing the private key.
  factory SubstrateEthereumPrivateKey.fromBytes(List<int> keyBytes) {
    try {
      final Secp256k1PrivateKey key = Secp256k1PrivateKey.fromBytes(keyBytes);
      return SubstrateEthereumPrivateKey._(key);
    } catch (e) {
      throw DartSubstratePluginException("invalid ecdsa private key",
          details: {"keyBytes": BytesUtils.tryToHexString(keyBytes)});
    }
  }

  /// Retrieves the raw bytes of the private key.
  @override
  List<int> toBytes() {
    return _privateKey.raw;
  }

  /// Converts the private key to a hexadecimal string.
  @override
  String toHex({bool upperCase = false}) {
    return BytesUtils.toHexString(toBytes(), lowerCase: !upperCase);
  }

  /// Retrieves the corresponding ethereum public key.
  @override
  SubstrateEthereumPublicKey toPublicKey() {
    return SubstrateEthereumPublicKey.fromBytes(
        _privateKey.publicKey.compressed);
  }

  /// Signs a transaction digest using the private key.
  ///
  /// Optionally, [hashMessage] can be set to false to skip hashing the message before signing.
  @override
  List<int> sign(List<int> transactionDigest, {bool hashMessage = true}) {
    final ethsigner = ETHSigner.fromKeyBytes(toBytes());
    final sign =
        ethsigner.signConst(transactionDigest, hashMessage: hashMessage);
    return sign.toBytes();
  }

  /// Signs a personal message (eth_personalsign) using the private key and returns the signature as a hexadecimal string.
  ///
  /// Optionally, [payloadLength] can be set to specify the payload length for the message.
  String signPersonalMessage(List<int> message, {int? payloadLength}) {
    final ethsigner = ETHSigner.fromKeyBytes(toBytes());
    final sign = ethsigner.signProsonalMessageConst(message,
        payloadLength: payloadLength);
    return BytesUtils.toHexString(sign);
  }

  SubstrateMultiSignature multiSignature(List<int> digest) {
    final signature = sign(digest);
    return SubstrateMultiSignature(SubstrateEcdsaSignature(signature));
  }

  @override
  SubstrateEthereumAddress toAddress() {
    return toPublicKey().toAddress();
  }

  SubstrateAddress toSS58Address() {
    return toPublicKey().toSS58Address();
  }

  @override
  SubstrateKeyAlgorithm get algorithm => SubstrateKeyAlgorithm.ethereum;

  @override
  bool verify(List<int> message, List<int> signature) {
    return toPublicKey().verify(message, signature);
  }
}
