import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/ss58_constant.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';

/// Class representing an Ethereum public key, providing methods for conversion, verification, and address generation.
class SubstrateEthereumPublicKey
    extends BaseSubstratePublicKey<SubstrateEthereumAddress> {
  /// Private constructor for creating an instance of [SubstrateEthereumPublicKey] with a given public key.
  SubstrateEthereumPublicKey(this.publicKey);

  /// The underlying ECDSA public key.
  final Secp256k1PublicKey publicKey;

  /// Creates a [SubstrateEthereumPublicKey] instance from a list of bytes representing the public key.
  factory SubstrateEthereumPublicKey.fromBytes(List<int> keyBytes) {
    try {
      final pubKey = Secp256k1PublicKey.fromBytes(keyBytes);
      return SubstrateEthereumPublicKey(pubKey);
    } catch (e) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "Invalid ethereum public key.",
        details: {"input": BytesUtils.toHexString(keyBytes)},
      );
    }
  }

  /// Retrieves the raw bytes of the public key.
  @override
  BuBytes toBytes([CryptoKeyEncoding mode = CryptoKeyEncoding.base]) {
    return publicKey.toBytes(mode: mode);
  }

  /// Converts the public key to a hexadecimal string.
  @override
  String toHex({
    bool upperCase = false,
    CryptoKeyEncoding mode = CryptoKeyEncoding.base,
  }) {
    return BytesUtils.toHexString(toBytes(mode), lowerCase: !upperCase);
  }

  /// Converts the public key to an ethereum address.
  @override
  SubstrateEthereumAddress toAddress() {
    return SubstrateEthereumAddress.fromPublicKey(toBytes());
  }

  SubstrateAddress toSS58Address({
    int ss58Format = SS58Const.genericSubstrate,
  }) {
    return SubstrateAddress.fromBytes(
      QuickCrypto.blake2b256Hash([...StringUtils.encode("evm:"), ...toBytes()]),
      ss58Format: ss58Format,
    );
  }

  @override
  String toString() {
    return toHex();
  }

  /// Verifies the signature of a personal message (eth_personalsign) using the public key.
  ///
  /// Optionally, [hashMessage] can be set to false to skip hashing the message before verification.
  /// Optionally, [payloadLength] can be set to specify the payload length for the message.
  bool verifyPersonalMessage(
    List<int> messageDigest,
    List<int> signature, {
    bool hashMessage = true,
    int? payloadLength,
  }) {
    final verifier = ETHVerifier(Secp256k1Verifier(publicKey));
    return verifier.verifyPersonalMessage(
      messageDigest,
      signature,
      hashMessage: hashMessage,
      payloadLength: payloadLength,
    );
  }

  @override
  SubstrateKeyAlgorithm get algorithm => SubstrateKeyAlgorithm.ethereum;

  @override
  bool verify(List<int> message, List<int> signature) {
    final verifier = ETHVerifier(Secp256k1Verifier(publicKey));
    return verifier.verify(message, signature);
  }
}
