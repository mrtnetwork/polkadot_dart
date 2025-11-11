import 'package:blockchain_utils/bip/address/eth_addr.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/models/generic/models/account_id.dart';
import 'package:polkadot_dart/src/models/generic/models/multi_address.dart';

import 'address_utils.dart';
import 'ss58_constant.dart';

enum SubstrateAddressType {
  ethereum(EthAddrConst.addrLenBytes),
  substrate(SubstrateAddressUtils.addressBytesLength);

  final int lengthInBytes;
  const SubstrateAddressType(this.lengthInBytes);

  bool get isEthereum => this == ethereum;
  bool get isSubstrate => this == substrate;
}

abstract class BaseSubstrateAddress {
  SubstrateAddressType get type;

  final String address;

  /// hexadecimal version of address
  final String rawAddress;

  const BaseSubstrateAddress._(this.address, this.rawAddress);

  /// Converts the address to a list of bytes.
  List<int> toBytes();

  String toHex() => BytesUtils.toHexString(toBytes());

  SubstrateMultiAddress toMultiAddress();

  factory BaseSubstrateAddress(String address) {
    if (StringUtils.isHexBytes(address)) {
      return SubstrateEthereumAddress(address);
    }
    return SubstrateAddress(address);
  }
  factory BaseSubstrateAddress.fromBytes(List<int> bytes,
      {int ss58Format = SS58Const.genericSubstrate}) {
    if (bytes.length == SubstrateAddressUtils.addressBytesLength) {
      return SubstrateAddress.fromBytes(bytes);
    }
    return SubstrateEthereumAddress.fromBytes(bytes);
  }

  factory BaseSubstrateAddress.fromPublicKey({
    required List<int> publicKeyBytes,
    required SubstrateKeyAlgorithm algorithm,
    int ss58Format = SS58Const.genericSubstrate,
  }) {
    return switch (algorithm) {
      SubstrateKeyAlgorithm.ecdsa ||
      SubstrateKeyAlgorithm.ed25519 ||
      SubstrateKeyAlgorithm.sr25519 =>
        SubstrateAddress.fromPublicKey(
            algorithm: algorithm,
            publicKeyBytes: publicKeyBytes,
            ss58Format: ss58Format),
      SubstrateKeyAlgorithm.ethereum =>
        SubstrateEthereumAddress.fromPublicKey(publicKeyBytes),
    };
  }

  /// Factory constructor to create a multi-signature SubstrateAddress.
  ///
  /// Creates an address from a list of Substrate addresses with a specified threshold.
  ///
  /// [addresses] is the list of Substrate addresses.
  /// [threshold] is the required number of signatures.
  /// [ss58Format] is the SS58 format identifier.
  factory BaseSubstrateAddress.createMultiSigAddress(
      {required List<BaseSubstrateAddress> addresses,
      required int threshold,
      int? ss58Format,
      int maxSignatories =
          SubstrateAddressUtils.defaultMaxMultisigSignatories}) {
    return SubstrateAddressUtils.createMultiSigAddress(
        addresses: addresses,
        threshold: threshold,
        ss58Format: ss58Format,
        maxSignatories: maxSignatories);
  }

  T cast<T extends BaseSubstrateAddress>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

/// Represents a Substrate blockchain address with various factory constructors
/// to initialize an address from different key types and functionalities to
/// manipulate and encode/decode addresses.
class SubstrateAddress extends BaseSubstrateAddress {
  /// The SS58 format identifier.
  final int ss58Format;

  /// Private constructor for initializing a SubstrateAddress.
  const SubstrateAddress._(super.address, this.ss58Format, super.rawAddress)
      : super._();

  /// Factory constructor to create a SubstrateAddress from an address string.
  ///
  /// Decodes the address using the specified SS58 format.
  ///
  /// [address] is the address string.
  /// [ss58Format] is an optional SS58 format identifier.
  factory SubstrateAddress(String address, {int? ss58Format}) {
    final decode = SubstrateGenericAddrDecoder()
        .decodeAddWithSS58(address, {"ss58_format": ss58Format});
    return SubstrateAddress._(
        address, decode.item2, BytesUtils.toHexString(decode.item1));
  }

  factory SubstrateAddress.fromPublicKey({
    required List<int> publicKeyBytes,
    required SubstrateKeyAlgorithm algorithm,
    int ss58Format = SS58Const.genericSubstrate,
  }) {
    return switch (algorithm) {
      SubstrateKeyAlgorithm.ecdsa => SubstrateAddress.fromEcdsa(publicKeyBytes),
      SubstrateKeyAlgorithm.ed25519 =>
        SubstrateAddress.fromEddsa(publicKeyBytes),
      SubstrateKeyAlgorithm.sr25519 =>
        SubstrateAddress.fromSr25519(publicKeyBytes),
      _ => throw DartSubstratePluginException("Unsuported public key.",
          details: {"algorithm": algorithm.name})
    };
  }

  /// Factory constructor to create a SubstrateAddress from ECDSA key bytes.
  ///
  /// Encodes the key bytes using the specified SS58 format.
  ///
  /// [bytes] is the list of key bytes.
  /// [ss58Format] is the SS58 format identifier (default is generic substrate format).
  factory SubstrateAddress.fromEcdsa(List<int> bytes,
      {int ss58Format = SS58Const.genericSubstrate}) {
    final address = SubstrateSecp256k1AddrEncoder()
        .encodeKey(bytes, {"ss58_format": ss58Format});
    return SubstrateAddress._(address, ss58Format,
        BytesUtils.toHexString(SS58Decoder.decode(address).item2));
  }

  /// Factory constructor to create a SubstrateAddress from EdDSA key bytes.
  ///
  /// Encodes the key bytes using the specified SS58 format.
  ///
  /// [bytes] is the list of key bytes.
  /// [ss58Format] is the SS58 format identifier (default is generic substrate format).
  factory SubstrateAddress.fromEddsa(List<int> bytes,
      {int ss58Format = SS58Const.genericSubstrate}) {
    final address = SubstrateEd25519AddrEncoder()
        .encodeKey(bytes, {"ss58_format": ss58Format});
    return SubstrateAddress._(address, ss58Format,
        BytesUtils.toHexString(SS58Decoder.decode(address).item2));
  }

  /// Factory constructor to create a SubstrateAddress from Sr25519 key bytes.
  ///
  /// Encodes the key bytes using the specified SS58 format.
  ///
  /// [bytes] is the list of key bytes.
  /// [ss58Format] is the SS58 format identifier (default is generic substrate format).
  factory SubstrateAddress.fromSr25519(List<int> bytes,
      {int ss58Format = SS58Const.genericSubstrate}) {
    final address = SubstrateSr25519AddrEncoder()
        .encodeKey(bytes, {"ss58_format": ss58Format});
    return SubstrateAddress._(address, ss58Format,
        BytesUtils.toHexString(SS58Decoder.decode(address).item2));
  }

  /// Factory constructor to create a SubstrateAddress from raw bytes.
  ///
  /// Encodes the bytes using the specified SS58 format.
  ///
  /// [bytes] is the list of raw bytes.
  /// [ss58Format] is the SS58 format identifier (default is generic substrate format).
  factory SubstrateAddress.fromBytes(List<int> bytes,
      {int ss58Format = SS58Const.genericSubstrate}) {
    if (bytes.length != SubstrateAddressUtils.addressBytesLength) {
      throw DartSubstratePluginException("Invalid address length.", details: {
        "expected": SubstrateAddressUtils.addressBytesLength,
        "length": bytes.length
      });
    }
    return SubstrateAddress._(SS58Encoder.encode(bytes, ss58Format), ss58Format,
        BytesUtils.toHexString(bytes));
  }

  /// Converts the address to a list of bytes.
  ///
  /// Decodes the address using the current SS58 format.
  @override
  List<int> toBytes() {
    final decode = SubstrateGenericAddrDecoder()
        .decodeAddWithSS58(address, {"ss58_format": ss58Format});
    return decode.item1;
  }

  /// Changes the address to a different SS58 format.
  ///
  /// [ss58Format] is the new SS58 format identifier.
  SubstrateAddress toSS58(int ss58Format) {
    if (ss58Format == this.ss58Format) return this;
    return SubstrateAddress.fromBytes(toBytes(), ss58Format: ss58Format);
  }

  /// Converts the address to a SubstrateMultiAddress.
  @override
  SubstrateMultiAddress toMultiAddress() {
    return SubstrateMultiAddress(toAccountId());
  }

  /// Converts the address to a SubstrateAccountId.
  SubstrateAccountId toAccountId() {
    return SubstrateAccountId(toBytes());
  }

  /// Converts the address to a SubstrateAccountIndex.
  SubstrateAccountIndex toAccountIndex() {
    return SubstrateAccountIndex(
        LayoutConst.u32().deserialize(toBytes()).value);
  }

  @override
  operator ==(other) {
    if (other is! SubstrateAddress) return false;
    return other.address == address && other.ss58Format == ss58Format;
  }

  @override
  int get hashCode => address.hashCode ^ ss58Format.hashCode;

  @override
  String toString() {
    return address;
  }

  @override
  SubstrateAddressType get type => SubstrateAddressType.substrate;
}

/// Represents a Substrate blockchain address with various factory constructors
/// to initialize an address from different key types and functionalities to
/// manipulate and encode/decode addresses.
class SubstrateEthereumAddress extends BaseSubstrateAddress {
  @override
  SubstrateAddressType get type => SubstrateAddressType.ethereum;

  /// Private constructor for initializing a SubstrateEthereumAddress.
  const SubstrateEthereumAddress._(super.address, super.rawAddress) : super._();

  factory SubstrateEthereumAddress.fromPublicKey(List<int> bytes) {
    try {
      final addr = EthAddrEncoder().encodeKey(bytes);
      return SubstrateEthereumAddress._(addr, StringUtils.normalizeHex(addr));
    } catch (e) {
      throw DartSubstratePluginException("Invalid ethereum public key bytes.",
          details: {
            "bytes": BytesUtils.tryToHexString(bytes),
            "error": e.toString()
          });
    }
  }
  factory SubstrateEthereumAddress.fromBytes(List<int> addressBytes) {
    try {
      final checksumAddress =
          EthAddrUtils.addressBytesToChecksumAddress(addressBytes);
      return SubstrateEthereumAddress._(
          checksumAddress, StringUtils.normalizeHex(checksumAddress));
    } catch (e) {
      throw DartSubstratePluginException("Invalid ethereum address bytes.",
          details: {
            "addressBytes": BytesUtils.tryToHexString(addressBytes),
            "error": e.toString()
          });
    }
  }
  factory SubstrateEthereumAddress(String address) {
    try {
      final checksumAddress = EthAddrUtils.toChecksumAddress(address);
      return SubstrateEthereumAddress._(
          checksumAddress, StringUtils.normalizeHex(checksumAddress));
    } catch (e) {
      throw DartSubstratePluginException("Invalid ethereum address.",
          details: {"address": address, "error": e.toString()});
    }
  }

  /// Converts the address to a list of bytes.
  @override
  List<int> toBytes() {
    final decode = EthAddrDecoder().decodeAddr(address);
    return decode;
  }

  /// Converts the address to a SubstrateMultiAddress.
  @override
  SubstrateMultiAddress toMultiAddress() {
    return SubstrateMultiAddress(SubstrateAccount20(toBytes()));
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! SubstrateEthereumAddress) return false;
    return other.address == address;
  }

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() {
    return address;
  }
}
