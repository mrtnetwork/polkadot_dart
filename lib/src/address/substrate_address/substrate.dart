import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/generic/models/account_id.dart';
import 'package:polkadot_dart/src/models/generic/models/multi_address.dart';
import 'address_utils.dart';
import 'ss58_constant.dart';

abstract class BaseSubstrateAddress {
  final String address;

  const BaseSubstrateAddress._(this.address);

  /// Converts the address to a list of bytes.
  List<int> toBytes();

  SubstrateMultiAddress toMultiAddress();

  factory BaseSubstrateAddress(String address) {
    if (StringUtils.isHexBytes(address)) {
      return SubstrateEthereumAddress(address);
    }
    return SubstrateAddress(address);
  }
}

/// Represents a Substrate blockchain address with various factory constructors
/// to initialize an address from different key types and functionalities to
/// manipulate and encode/decode addresses.
class SubstrateAddress extends BaseSubstrateAddress {
  /// The SS58 format identifier.
  final int ss58Format;

  /// Private constructor for initializing a SubstrateAddress.
  const SubstrateAddress._(super.address, this.ss58Format) : super._();

  /// Factory constructor to create a SubstrateAddress from an address string.
  ///
  /// Decodes the address using the specified SS58 format.
  ///
  /// [address] is the address string.
  /// [ss58Format] is an optional SS58 format identifier.
  factory SubstrateAddress(String address, {int? ss58Format}) {
    final decode = SubstrateGenericAddrDecoder()
        .decodeAddWithSS58(address, {"ss58_format": ss58Format});
    return SubstrateAddress._(address, decode.item2);
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
    return SubstrateAddress._(address, ss58Format);
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
    return SubstrateAddress._(address, ss58Format);
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
    return SubstrateAddress._(address, ss58Format);
  }

  /// Factory constructor to create a SubstrateAddress from raw bytes.
  ///
  /// Encodes the bytes using the specified SS58 format.
  ///
  /// [bytes] is the list of raw bytes.
  /// [ss58Format] is the SS58 format identifier (default is generic substrate format).
  factory SubstrateAddress.fromBytes(List<int> bytes,
      {int ss58Format = SS58Const.genericSubstrate}) {
    return SubstrateAddress._(
        SS58Encoder.encode(bytes, ss58Format), ss58Format);
  }

  /// Factory constructor to create a multi-signature SubstrateAddress.
  ///
  /// Creates an address from a list of Substrate addresses with a specified threshold.
  ///
  /// [addresses] is the list of Substrate addresses.
  /// [thresHold] is the required number of signatures.
  /// [ss58Format] is the SS58 format identifier.
  factory SubstrateAddress.createMultiSigAddress(
      {required List<SubstrateAddress> addresses,
      required int thresHold,
      required int ss58Format}) {
    return SubstrateAddressUtils.createMultiSigAddress(
        addresses: addresses, thresHold: thresHold, ss58Format: ss58Format);
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
}

/// Represents a Substrate blockchain address with various factory constructors
/// to initialize an address from different key types and functionalities to
/// manipulate and encode/decode addresses.
class SubstrateEthereumAddress extends BaseSubstrateAddress {
  /// Private constructor for initializing a SubstrateEthereumAddress.
  const SubstrateEthereumAddress._(super.address) : super._();

  factory SubstrateEthereumAddress.fromPublicKey(List<int> bytes) {
    try {
      final addr = EthAddrEncoder().encodeKey(bytes);
      return SubstrateEthereumAddress._(addr);
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
      return SubstrateEthereumAddress._(checksumAddress);
    } catch (e) {
      throw DartSubstratePluginException("Invalid moonbeam address bytes.",
          details: {
            "addressBytes": BytesUtils.tryToHexString(addressBytes),
            "error": e.toString()
          });
    }
  }
  factory SubstrateEthereumAddress(String address) {
    try {
      final checksumAddress = EthAddrUtils.toChecksumAddress(address);
      return SubstrateEthereumAddress._(checksumAddress);
    } catch (e) {
      throw DartSubstratePluginException("Invalid moonbeam address.",
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
