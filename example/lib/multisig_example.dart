import 'package:polkadot_dart/polkadot_dart.dart';
import 'json_rpc_example.dart';

/// https://github.com/paritytech/txwrapper-core/blob/main/packages/txwrapper-examples/multisig/src/multisig.ts#L321
void main() async {
  /// Define constants for network format and threshold
  const int networkSS58 = SS58Const.genericSubstrate;
  const int thresHold = 2;

  /// Generate an unmodifiable list of seed bytes
  final List<int> seedBytes =
      List.unmodifiable(List.generate(32, (index) => index * 2));

  /// Create a substrate wallet using the generated seed bytes and SR25519 algorithm
  final substrateWallet = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.sr25519);

  /// Derive keys for Alice, Bob, and Charlie
  final alice = substrateWallet.derive("//alice");
  final bob = substrateWallet.derive("//bob");
  final charlie = substrateWallet.derive("//charlie");

  /// Generate SS58 addresses for Alice, Bob, and Charlie
  final aliceAddress = alice.toAddress(ss58Format: networkSS58);
  final bobAddress = bob.toAddress(ss58Format: networkSS58);
  final charlieAddress = charlie.toAddress(ss58Format: networkSS58);

  /// List of signer addresses
  final signerAddresses = [aliceAddress, bobAddress, charlieAddress];

  /// Define destination address
  final destination = SubstrateAddress(
      "5FeHntLqsucHn1CZuAsLceAN2FJhwbonP6goHzo4dWVzW33T",

      /// add network format to ensure the destination address is related to the current network
      ss58Format: networkSS58);

  /// 5GQSRESwfR2c9x6pPeWcx7kC5as1PKCr7HkEUpJj7b4n1g9U
  /// Create a multisig address from signer addresses and threshold
  final multiSigAddress = SubstrateAddress.createMultiSigAddress(
      addresses: signerAddresses,
      thresHold: thresHold,
      ss58Format: networkSS58);

  /// Set up the provider with the RPC service
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  final currentMetadata = await provider
      .request(const SubstrateRPCRuntimeMetadataGetMetadataAtVersion(15));

  /// Load API metadata
  final api = currentMetadata!.toApi();

  /// Fetch the genesis hash
  final String genesisHash =
      await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));

  /// Fetch the latest finalized block hash
  String blockHash =
      await provider.request(const SubstrateRPCChainChainGetFinalizedHead());

  /// Fetch the block header using the block hash
  SubstrateHeaderResponse blockHeader = await provider
      .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));

  /// Get the runtime version from the API
  final runtime = api.runtimeVersion();

  /// Retrieve the call template for the 'transfer_allow_death' method from the 'Balances' pallet
  /// using the getCallTemplate function, and store it as a JSON string in the 'callMethod' variable.
  ///
  /// final transferAllowDeath =
  ///     api.getCallTemplate("Balances").buildJsonTemplateAsString();

  final amount = BigInt.parse("1${"0" * 12}");

  /// Define the destination address for the transaction
  final Map<String, dynamic> callMethod = {
    "transfer_allow_death": {
      "dest": {"Id": destination.toBytes()},
      "value": amount
    }
  };

  /// Encode the call for a multisig transaction
  final unsignedTXMultiEncodedMethod = api.encodeCall(
      palletNameOrIndex: "Balances", fromTemplate: false, value: callMethod);

  /// Map the 'Balances' pallet to the constructed transfer method call.
  /// The 'runtimeMethod' map associates the 'Balances' pallet with the 'callMethod' map,
  /// which contains the 'transfer_allow_death' method and its parameters.
  final Map<String, dynamic> runtimeMethod = {"Balances": callMethod};

  /// Compute the call transaction hash
  /// - `unsignedTXMultiEncodedMethod` is the encoded method call that needs to be hashed.
  /// - `methodHash` will store the resulting hash of the transaction (substrate use blake2b256Hash for that)
  final callHash = SubstrateHelper.txHash(unsignedTXMultiEncodedMethod);

  FrameSupportDispatchPerDispatchClass weight =
      await api.queryBlockWeight(provider, atBlockHash: blockHash);

  /// select the mandatory of block weight for the transaction
  SpWeightsWeightV2Weight maxWeight = weight.mandatory;

  /// Get other sorted signatories excluding Alice
  final otherSignatoriesSortedExAlice = SubstrateAddressUtils.otherSignatories(
      addresses: signerAddresses, signer: aliceAddress);

  final approveAsMulti = api.approveAsMulti(
      thresHold: thresHold,
      otherSignatories: otherSignatoriesSortedExAlice,
      callHash: callHash,
      maxWeight: maxWeight);

  /// Fetch Alice's account information
  final aliceAccount =
      await api.getAccountInfo(address: aliceAddress, rpc: provider);

  /// Create the payload for Alice's approval
  final signedTxApproveAsMulti = SubstrateHelper.createTransaction(
      blockHash: blockHash,
      genesisHash: genesisHash,
      methodBytes: approveAsMulti,
      nonce: aliceAccount.nonce,
      specVersion: runtime.specVersion,
      transactionVersion: runtime.transactionVersion,
      era: blockHeader.toMortalEra(),
      signer: alice);

  /// Submit Alice's approval extrinsic
  await provider.request(SubstrateRPCAuthorSubmitExtrinsic(
      signedTxApproveAsMulti.toHex(prefix: "0x")));

  /// Wait for 10 seconds
  await Future.delayed(const Duration(seconds: 35));

  /// Get other sorted signatories excluding Bob
  final otherSignatoriesSortedExBob = SubstrateAddressUtils.otherSignatories(
      addresses: signerAddresses, signer: bobAddress);

  /// Fetch multisig details
  final multisigDetails = await api.getMultisigs(
      multisigaddress: multiSigAddress, callHashTx: callHash, rpc: provider);

  /// Extract multisig call index and height
  final int multisigCallIndex = multisigDetails!["when"]["index"];
  final int multisigCallHeight = multisigDetails["when"]["height"];

  /// Fetch Bob's account information
  final bobAccount =
      await api.getAccountInfo(address: bobAddress, rpc: provider);

  final asMultiEncode = api.encodeAsMulti(
      thresHold: thresHold,
      otherSignatories: otherSignatoriesSortedExBob,
      call: runtimeMethod,
      maxWeight: maxWeight,
      maybeTimepoint: MultisigTimepoint(
          height: multisigCallHeight, index: multisigCallIndex));

  /// Create the payload for Bob's multisig execution
  final asMulti = SubstrateHelper.createTransaction(
      blockHash: blockHash,
      genesisHash: genesisHash,
      methodBytes: asMultiEncode,
      nonce: bobAccount.nonce,
      specVersion: runtime.specVersion,
      transactionVersion: runtime.transactionVersion,
      era: blockHeader.toMortalEra(),
      signer: bob);

  /// Submit Bob's multisig execution extrinsic
  await provider
      .request(SubstrateRPCAuthorSubmitExtrinsic(asMulti.toHex(prefix: "0x")));

  /// Link to the transaction on subscan
  /// https://westend.stg.subscan.io/extrinsic/0x486158426559b12f6cebecd55e9ab07796331a5083d81e5a0eff7a9cbdf50563
}
