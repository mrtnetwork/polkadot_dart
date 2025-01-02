import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'public_key.dart';

/// Class representing an Moonbeam private key, allowing for cryptographic operations and key-related functionality.
class MoonbeamPrivateKey {
  /// Private constructor for creating an instance of [MoonbeamPrivateKey] with a given private key.
  const MoonbeamPrivateKey._(this._privateKey);

  /// The underlying ECDSA private key.
  final Secp256k1PrivateKeyEcdsa _privateKey;

  /// Creates an [MoonbeamPrivateKey] instance from a hexadecimal private key string.
  factory MoonbeamPrivateKey(String privateKeyHex) {
    return MoonbeamPrivateKey.fromBytes(
        BytesUtils.fromHexString(privateKeyHex));
  }

  /// Creates an [MoonbeamPrivateKey] instance from a list of bytes representing the private key.
  factory MoonbeamPrivateKey.fromBytes(List<int> keyBytes) {
    try {
      final Secp256k1PrivateKeyEcdsa key =
          Secp256k1PrivateKeyEcdsa.fromBytes(keyBytes);
      return MoonbeamPrivateKey._(key);
    } catch (e) {
      throw DartSubstratePluginException("invalid moonbeam private key",
          details: {"keyBytes": BytesUtils.tryToHexString(keyBytes)});
    }
  }

  /// Retrieves the raw bytes of the private key.
  List<int> toBytes() {
    return _privateKey.raw;
  }

  /// Converts the private key to a hexadecimal string.
  String toHex() {
    return BytesUtils.toHexString(toBytes());
  }

  /// Retrieves the corresponding Moonbeam public key.
  MoonbeamPublicKey publicKey() {
    return MoonbeamPublicKey.fromBytes(_privateKey.publicKey.compressed);
  }

  /// Signs a transaction digest using the private key.
  ///
  /// Optionally, [hashMessage] can be set to false to skip hashing the message before signing.
  ETHSignature sign(List<int> transactionDigest, {bool hashMessage = true}) {
    final ethsigner = ETHSigner.fromKeyBytes(toBytes());
    final sign = ethsigner.sign(transactionDigest, hashMessage: hashMessage);
    return sign;
  }

  /// Signs a personal message (eth_personalsign) using the private key and returns the signature as a hexadecimal string.
  ///
  /// Optionally, [payloadLength] can be set to specify the payload length for the message.
  String signPersonalMessage(List<int> message, {int? payloadLength}) {
    final ethsigner = ETHSigner.fromKeyBytes(toBytes());
    final sign =
        ethsigner.signProsonalMessage(message, payloadLength: payloadLength);
    return BytesUtils.toHexString(sign);
  }

  SubstrateMultiSignature multiSignature(List<int> digest) {
    final signature = sign(digest).toBytes();
    return SubstrateMultiSignature(SubstrateEcdsaSignature(signature));
  }

  MoonbeamAddress toAddress() {
    return publicKey().toAddress();
  }
}
