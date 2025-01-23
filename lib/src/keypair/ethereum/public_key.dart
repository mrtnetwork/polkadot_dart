import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';

/// Class representing an ethereum public key, providing methods for conversion, verification, and address generation.
class SubstrateEthereumPublicKey
    extends BaseSubstratePublicKey<SubstrateEthereumAddress> {
  /// Private constructor for creating an instance of [SubstrateEthereumPublicKey] with a given public key.
  SubstrateEthereumPublicKey._(this._publicKey);

  /// The underlying ECDSA public key.
  final Secp256k1PublicKeyEcdsa _publicKey;

  /// Creates an [SubstrateEthereumPublicKey] instance from a list of bytes representing the public key.
  factory SubstrateEthereumPublicKey.fromBytes(List<int> keyBytes) {
    try {
      final pubKey = Secp256k1PublicKeyEcdsa.fromBytes(keyBytes);
      return SubstrateEthereumPublicKey._(pubKey);
    } catch (e) {
      throw DartSubstratePluginException("Invalid ethereum public key.",
          details: {"input": BytesUtils.toHexString(keyBytes)});
    }
  }

  /// Creates an [SubstrateEthereumPublicKey] instance from a hexadecimal public key string.
  factory SubstrateEthereumPublicKey(String pubHex) {
    return SubstrateEthereumPublicKey.fromBytes(
        BytesUtils.fromHexString(pubHex));
  }

  /// Retrieves the raw bytes of the public key.
  @override
  List<int> toBytes([PubKeyModes mode = PubKeyModes.compressed]) {
    if (mode == PubKeyModes.uncompressed) {
      return _publicKey.uncompressed;
    }
    return _publicKey.compressed;
  }

  /// Converts the public key to a hexadecimal string.
  @override
  String toHex(
      {bool upperCase = false, PubKeyModes mode = PubKeyModes.compressed}) {
    return BytesUtils.toHexString(toBytes(mode), lowerCase: !upperCase);
  }

  /// Converts the public key to an ethereum address.
  @override
  SubstrateEthereumAddress toAddress() {
    return SubstrateEthereumAddress.fromPublicKey(toBytes());
  }

  @override
  String toString() {
    return toHex();
  }

  /// Verifies the signature of a personal message (eth_personalsign) using the public key.
  ///
  /// Optionally, [hashMessage] can be set to false to skip hashing the message before verification.
  /// Optionally, [payloadLength] can be set to specify the payload length for the message.
  bool verifyPersonalMessage(List<int> messageDigest, List<int> signature,
      {bool hashMessage = true, int? payloadLength}) {
    final verifier = ETHVerifier.fromKeyBytes(toBytes());
    return verifier.verifyPersonalMessage(messageDigest, signature,
        hashMessage: hashMessage, payloadLength: payloadLength);
  }

  static SubstrateEthereumPublicKey? getPublicKey(
      List<int> messageDigest, List<int> signature,
      {bool hashMessage = true, int? payloadLength}) {
    final verifier = ETHVerifier.getPublicKey(messageDigest, signature,
        hashMessage: hashMessage, payloadLength: payloadLength);
    if (verifier == null) return null;
    final pubKey = Secp256k1PublicKeyEcdsa.fromBytes(verifier.point.toBytes());
    return SubstrateEthereumPublicKey._(pubKey);
  }

  @override
  SubstrateKeyAlgorithm get algorithm => SubstrateKeyAlgorithm.ethereum;

  @override
  bool verify(List<int> message, List<int> signature) {
    final verifier = ETHVerifier.fromKeyBytes(toBytes());
    return verifier.verify(message, signature);
  }
}
