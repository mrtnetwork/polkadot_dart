import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
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
  /// Throws a [DartSubstratePluginException] if the addresses have different SS58 formats,
  /// if the threshold is invalid, or if the addresses list is empty.
  static SubstrateAddress createMultiSigAddress(
      {required List<SubstrateAddress> addresses,
      required int thresHold,
      required int ss58Format}) {
    // Check if any address has a different SS58 format
    final hasDifferentSS58 =
        addresses.any((element) => element.ss58Format != ss58Format);
    if (hasDifferentSS58) {
      throw DartSubstratePluginException(
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
      throw DartSubstratePluginException(
          "The number of accounts that must approve. Must be U16 and greater than 0 and less than or equal to the total number of addresses.",
          details: {
            "thresHold": thresHold,
            "addressesLength": addresses.length
          });
    }

    // Check if the addresses list is empty
    if (addresses.isEmpty) {
      throw DartSubstratePluginException("The addresses must not be empty.",
          details: {
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
  static List<BaseSubstrateAddress> sortedAddress(
      List<BaseSubstrateAddress> address) {
    return List.from(address)
      ..sort((a, b) => BytesUtils.compareBytes(a.toBytes(), b.toBytes()));
  }

  static List<BaseSubstrateAddress> otherSignatories(
      {required List<BaseSubstrateAddress> addresses,
      required BaseSubstrateAddress signer}) {
    final sorted = sortedAddress(addresses);
    return sorted..removeWhere((element) => element == signer);
  }

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
