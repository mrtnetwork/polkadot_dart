import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';

import 'private_key.dart';

/// Represents a public key in the Substrate framework.
class SubstratePublicKey {
  /// The underlying Substrate instance.
  final Substrate _substrate;

  /// Constructs a [SubstratePublicKey] instance from a Substrate object.
  const SubstratePublicKey._(this._substrate, this.algorithm);

  /// Constructs a [SubstratePublicKey] from a byte array.
  factory SubstratePublicKey.fromBytes({
    required List<int> pubkeyBytes,
    SubstrateKeyAlgorithm algorithm = SubstrateKeyAlgorithm.sr25519,
  }) {
    final substrate =
        Substrate.fromPublicKey(pubkeyBytes, algorithm.defaultCoin);
    return SubstratePublicKey._(substrate, algorithm);
  }

  /// Retrieves the algorithm used for the public key.
  final SubstrateKeyAlgorithm algorithm;

  /// Derives a new public key from the current one using the provided [path].
  SubstratePublicKey derive(String path) {
    final derive = _substrate.derivePath(path);
    return SubstratePublicKey._(derive, algorithm);
  }

  /// Converts the public key to bytes.
  List<int> toBytes() {
    return List<int>.from(_substrate.publicKey.compressed);
  }

  /// Converts the public key to hexadecimal string.
  String tohex({bool upperCase = false}) {
    return BytesUtils.toHexString(toBytes(),
        lowerCase: !upperCase, prefix: "0x");
  }

  /// Verifies a given message and signature using the public key.
  bool verify(List<int> message, List<int> signature) {
    final verifier = SubstrateVerifier.fromSubstrate(_substrate);
    return verifier.verify(message, signature);
  }

  /// Verifies a given message and VRF (Verifiable Random Function) signature using the public key.
  bool vrfVerify(List<int> message, List<int> vrfSign,
      {List<int>? context, List<int>? extra}) {
    final verifier = SubstrateVerifier.fromSubstrate(_substrate);
    return verifier.vrfVerify(message, vrfSign, context: context, extra: extra);
  }

  /// Converts the public key to a Substrate address.
  SubstrateAddress toAddress({int ss58Format = SS58Const.genericSubstrate}) {
    return SubstrateAddress(
        _substrate.publicKey.toSS58Address(ss58Format: ss58Format),
        ss58Format: ss58Format);
  }
}
