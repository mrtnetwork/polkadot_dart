import 'package:blockchain_utils/bip/address/eth_addr.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/ss58_constant.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

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
  static const int addressBytesLength = 32;
  // static const int ehtereumAddressBytesLength = 20;
  static const int minMultisigThreshold = 1;
  static const int defaultMaxMultisigSignatories = 100;

  static final SubstrateEthereumAddress zeroAddress =
      SubstrateEthereumAddress.fromBytes(
          List<int>.filled(EthAddrConst.addrLenBytes, 0));

  /// Creates a multi-signature address from a list of Substrate addresses.
  ///
  /// [addresses] is the list of Substrate addresses to include in the multi-signature.
  /// [threshold] is the required number of signatures to approve a transaction.
  /// [ss58Format] is the SS58 format identifier for the resulting address.
  ///
  /// Throws a [DartSubstratePluginException] if the addresses have different SS58 formats,
  /// if the threshold is invalid, or if the addresses list is empty.
  static BaseSubstrateAddress createMultiSigAddress(
      {required List<BaseSubstrateAddress> addresses,
      required int threshold,
      int? ss58Format,
      int maxSignatories = defaultMaxMultisigSignatories}) {
    if (maxSignatories <= 0 || maxSignatories > mask16) {
      throw DartSubstratePluginException(
        "MaxSignatories must be greater than 0 and not exceed $mask16.",
      );
    }
    // Validate the threshold
    if (threshold <= 0 ||
        threshold > addresses.length ||
        addresses.length > maxSignatories) {
      throw DartSubstratePluginException(
        "Threshold or number of addresses is out of range.",
        details: {
          "threshold": threshold,
          "addressesLength": addresses.length,
        },
      );
    }

    if (addresses.any((e) => e.type != SubstrateAddressType.substrate)) {
      throw DartSubstratePluginException("Unsuported address type.");
    }
    // Convert addresses to bytes and sort them
    final List<List<int>> addressBytes = List<List<int>>.unmodifiable(
        addresses.map((e) => List<int>.unmodifiable(e.toBytes())).toList()
          ..sort((a, b) => BytesUtils.compareBytes(a, b)));
    // Encode the length and threshold to bytes
    final lenBytes =
        LayoutSerializationUtils.compactIntToBytes(addressBytes.length);
    final thressHoldBytes = LayoutConst.u16().serialize(threshold);

    // Compute the hash for the multi-signature address
    final addressHash = QuickCrypto.blake2b256Hash([
      ..._MultiSigAddressConst.multiSigAddressPrefix,
      ...lenBytes,
      ...addressBytes.expand((element) => element),
      ...thressHoldBytes,
    ]);

    // Create and return the multi-signature address
    return SubstrateAddress.fromBytes(addressHash,
        ss58Format: ss58Format ?? SS58Const.genericSubstrate);
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
    final signerRawAddress = signer.toHex();
    final sorted = sortedAddress(addresses);
    return sorted
      ..removeWhere(
          (element) => StringUtils.hexEqual(element.toHex(), signerRawAddress));
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

  static SubstrateEthereumAddress? tryDecodeFromSolidityAddress(
      String address32) {
    final hex = StringUtils.strip0x(address32);
    if (hex.length != 64) return null;
    final prefix = hex.substring(0, 24);
    if (!RegExp(r'^0+$').hasMatch(prefix)) return null;
    final addrHex = hex.substring(24);
    return SubstrateEthereumAddress.fromBytes(
        BytesUtils.fromHexString(addrHex));
  }
}
