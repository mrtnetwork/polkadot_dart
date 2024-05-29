import 'package:blockchain_utils/binary/binary.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/layout/layout.dart';
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
  /// [thressHold] is the required number of signatures to approve a transaction.
  /// [ss58Format] is the SS58 format identifier for the resulting address.
  ///
  /// Throws a [MessageException] if the addresses have different SS58 formats,
  /// if the threshold is invalid, or if the addresses list is empty.
  static SubstrateAddress createMultiSigAddress(
      {required List<SubstrateAddress> addresses,
      required int thressHold,
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
    if (thressHold <= 0 ||
        thressHold > addresses.length ||
        thressHold > mask16) {
      throw MessageException(
          "The number of accounts that must approve. Must be U16 and greater than 0 and less than or equal to the total number of addresses.",
          details: {
            "thressHold": thressHold,
            "addressesLength": addresses.length
          });
    }

    // Check if the addresses list is empty
    if (addresses.isEmpty) {
      throw MessageException("The addresses must not be empty.", details: {
        "thressHold": thressHold,
        "addressesLength": addresses.length
      });
    }

    // Convert addresses to bytes and sort them
    List<List<int>> addressBytes = List<List<int>>.unmodifiable(
        addresses.map((e) => List<int>.unmodifiable(e.toBytes())).toList()
          ..sort((a, b) => BytesUtils.compareBytes(a, b)));

    // Encode the length and threshold to bytes
    final lenBytes =
        LayoutSerializationUtils.compactIntToBytes(addressBytes.length);
    final thressHoldBytes = LayoutConst.u16().serialize(thressHold);

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
}
