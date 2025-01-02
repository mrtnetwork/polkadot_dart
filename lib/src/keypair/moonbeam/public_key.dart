import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/exception/exception.dart';

/// Class representing an Moonbeam public key, providing methods for conversion, verification, and address generation.
class MoonbeamPublicKey {
  /// Private constructor for creating an instance of [MoonbeamPublicKey] with a given public key.
  MoonbeamPublicKey._(this._publicKey);

  /// The underlying ECDSA public key.
  final Secp256k1PublicKeyEcdsa _publicKey;

  /// Creates an [MoonbeamPublicKey] instance from a list of bytes representing the public key.
  factory MoonbeamPublicKey.fromBytes(List<int> keyBytes) {
    try {
      final pubKey = Secp256k1PublicKeyEcdsa.fromBytes(keyBytes);
      return MoonbeamPublicKey._(pubKey);
    } catch (e) {
      throw DartSubstratePluginException("invalid public key",
          details: {"input": BytesUtils.toHexString(keyBytes)});
    }
  }

  /// Creates an [MoonbeamPublicKey] instance from a hexadecimal public key string.
  factory MoonbeamPublicKey(String pubHex) {
    return MoonbeamPublicKey.fromBytes(BytesUtils.fromHexString(pubHex));
  }

  /// Retrieves the raw bytes of the public key.
  List<int> toBytes([PubKeyModes mode = PubKeyModes.compressed]) {
    if (mode == PubKeyModes.uncompressed) {
      return _publicKey.uncompressed;
    }
    return _publicKey.compressed;
  }

  /// Converts the public key to a hexadecimal string.
  String toHex([PubKeyModes mode = PubKeyModes.compressed]) {
    return BytesUtils.toHexString(toBytes(mode));
  }

  /// Converts the public key to an Moonbeam address.
  MoonbeamAddress toAddress() {
    return MoonbeamAddress.fromPublicKey(toBytes());
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

  static MoonbeamPublicKey? getPublicKey(
      List<int> messageDigest, List<int> signature,
      {bool hashMessage = true, int? payloadLength}) {
    final verifier = ETHVerifier.getPublicKey(messageDigest, signature,
        hashMessage: hashMessage, payloadLength: payloadLength);
    if (verifier == null) return null;
    final pubKey = Secp256k1PublicKeyEcdsa.fromBytes(verifier.point.toBytes());
    return MoonbeamPublicKey._(pubKey);
  }
}
