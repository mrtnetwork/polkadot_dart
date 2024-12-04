import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';

class _MultiSigAddressConst {
  static const List<int> multiSigAddressPrefix = [
    109,
    111,
    100,
    108,
    112,
    121,
    47,
    117,
    116,
    105,
    108,
    105,
    115,
    117,
    98,
    97
  ];
}

/// Utility class for operations related to Substrate addresses, including
/// creation of multi-signature addresses and sorting addresses.
class SubstrateAddressUtils {
  /// Creates a multi-signature address from a list of Substrate addresses.
  ///
  /// [addresses] is the list of Substrate addresses to include in the multi-signature.
  /// [thresHold] is the required number of signatures to approve a transaction.
  /// [ss58Format] is the SS58 format identifier for the resulting address.
  ///
  /// Throws a [MessageException] if the addresses have different SS58 formats,
  /// if the threshold is invalid, or if the addresses list is empty.
  static SubstrateAddress createMultiSigAddress(
      {required List<SubstrateAddress> addresses,
      required int thresHold,
      required int ss58Format}) {
    // Check if any address has a different SS58 format
    final hasDifferentSS58 =
        addresses.any((element) => element.ss58Format != ss58Format);
    if (hasDifferentSS58) {
      throw MessageException(
        "Some provided addresses have different ss58 format with provided ss58Format",
        details: {
          "ss58Format": ss58Format,
          "addresses": addresses.map((e) => e.address).join(", "),
          "addressSS58Formats": addresses.map((e) => e.ss58Format).join(", ")
        },
      );
    }

    // Validate the threshold
    if (thresHold <= 0 || thresHold > addresses.length || thresHold > mask16) {
      throw MessageException(
          "The number of accounts that must approve. Must be U16 and greater than 0 and less than or equal to the total number of addresses.",
          details: {
            "thresHold": thresHold,
            "addressesLength": addresses.length
          });
    }

    // Check if the addresses list is empty
    if (addresses.isEmpty) {
      throw MessageException("The addresses must not be empty.", details: {
        "thresHold": thresHold,
        "addressesLength": addresses.length
      });
    }

    // Convert addresses to bytes and sort them
    final List<List<int>> addressBytes = List<List<int>>.unmodifiable(
        addresses.map((e) => List<int>.unmodifiable(e.toBytes())).toList()
          ..sort((a, b) => BytesUtils.compareBytes(a, b)));

    // Encode the length and threshold to bytes
    final lenBytes =
        LayoutSerializationUtils.compactIntToBytes(addressBytes.length);
    final thressHoldBytes = LayoutConst.u16().serialize(thresHold);

    // Compute the hash for the multi-signature address
    final addressHash = QuickCrypto.blake2b256Hash([
      ..._MultiSigAddressConst.multiSigAddressPrefix,
      ...lenBytes,
      ...addressBytes.expand((element) => element),
      ...thressHoldBytes,
    ]);

    // Create and return the multi-signature address
    return SubstrateAddress.fromBytes(addressHash, ss58Format: ss58Format);
  }

  /// Sorts a list of Substrate addresses based on their byte representations.
  ///
  /// [address] is the list of Substrate addresses to sort.
  ///
  /// Returns a new list of Substrate addresses sorted by their byte values.
  static List<SubstrateAddress> sortedAddress(List<SubstrateAddress> address) {
    return List.from(address)
      ..sort((a, b) => BytesUtils.compareBytes(a.toBytes(), b.toBytes()));
  }

  static List<SubstrateAddress> otherSignatories(
      {required List<SubstrateAddress> addresses,
      required SubstrateAddress signer}) {
    final addressesSS58 = addresses.map((e) => e.ss58Format).toSet();
    if (addressesSS58.length != 1) {
      throw MessageException(
        "Some provided addresses have different ss58 format with provided ss58Format",
        details: {
          "addresses": addresses.map((e) => e.address).join(", "),
          "addressSS58Formats": addressesSS58.join(", ")
        },
      );
    }
    final sorted = sortedAddress(addresses);
    return sorted..removeWhere((element) => element == signer);
  }

  // const multisigModuleHash = xxhashAsHex('Multisig', 128);
  // const multisigStorageHash = xxhashAsHex('Multisigs', 128);
  // const multisigAddressHash = xxhashAsHex(
  //   keyring.decodeAddress(Ss58MultiSigAddress),
  //   64,
  // );
  // const multisigCallHash = blake2AsHex(callTxHashMulti, 128);
  // const multisigStorageKey = multisigModuleHash +
  //     multisigStorageHash.substring(2) +
  //     multisigAddressHash.substring(2) +
  //     multisigAddressInHex +
  //     multisigCallHash.substring(2) +
  //     callTxHashMulti.substring(2);

  static List<int> createMultisigStorageKey(
      {required SubstrateAddress multiSigAddress,
      required List<int> callTxHashMulti}) {
    final txHash = BytesUtils.toBytes(callTxHashMulti, unmodifiable: true);
    final List<int> moduleHash = MetadataUtils.createQueryPrefixHash(
        prefix: "Multisig", method: "Multisigs");
    final List<int> multisigAddressHash =
        QuickCrypto.twoX64(multiSigAddress.toBytes());
    final List<int> multisigCallHash = QuickCrypto.twoX128(txHash);
    return [
      ...moduleHash,
      ...multisigAddressHash,
      ...multiSigAddress.toBytes(),
      ...multisigCallHash,
      ...txHash
    ];
  }
}
