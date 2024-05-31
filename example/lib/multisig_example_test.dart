import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'json_rpc_example.dart';

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

  /// Derive and get address for the destination
  final destination = substrateWallet.derive("//destination").toAddress();

  /// Create a multisig address from signer addresses and threshold
  final multiSigAddress = SubstrateAddress.createMultiSigAddress(
      addresses: signerAddresses,
      thresHold: thresHold,
      ss58Format: networkSS58);

  /// Get other sorted signatories excluding Alice
  final otherSignatoriesSortedExAlice = SubstrateAddressUtils.otherSignatories(
      addresses: signerAddresses, signer: aliceAddress);

  /// Set up the provider with the RPC service
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  final currentMetadata =
      await provider.request(const SubstrateRPCStateGetMetadata());

  /// Load API metadata
  final api = currentMetadata.toApi();

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

  /// Define the transfer amount (1 unit with 12 decimal places)
  final amount = BigInt.parse("1${"0" * 12}");

  /// Construct the transfer method call
  final Map<String, dynamic> callMethod = {
    "transfer_allow_death": {
      "dest": {"Id": destination.toBytes()},
      "value": amount
    }
  };

  /// Map the runtime method
  final Map<String, dynamic> runtimeMethod = {"Balances": callMethod};

  /// Encode the call for a multisig transaction
  final unsignedTXMultiEncodedMethod = api.encodeCall(
      palletNameOrIndex: "balances", fromTemplate: false, value: callMethod);

  /// Compute the call transaction hash
  final callTxHashMulti = SubstrateHelper.txHash(unsignedTXMultiEncodedMethod);

  /// Define the maximum weight for the transaction
  final maxWeight = SpWeightsWeightV2Weight(
      refTime: BigInt.from(640000000),
      proofSize: BigInt.from(blockHeader.number));

  /// Fetch Alice's account information
  final aliceAccount =
      await api.getAccountInfo(address: aliceAddress, rpc: provider);

  /// Create the payload for Alice's approval
  final signedTxApproveAsMulti = createPayload(
      blockHash: blockHash,
      genesisHash: genesisHash,
      methodBytes: api.approveAsMulti(
          thresHold: thresHold,
          otherSignatories: otherSignatoriesSortedExAlice,
          callHash: callTxHashMulti,
          maxWeight: maxWeight),
      nonce: aliceAccount.nonce,
      specVersion: runtime.specVersion,
      transactionVersion: runtime.transactionVersion,
      era: blockHeader.toMortalEra(),
      signer: alice);

  /// Submit Alice's approval extrinsic
  await provider.request(SubstrateRPCAuthorSubmitExtrinsic(
      signedTxApproveAsMulti.toHex(prefix: "0x")));

  /// Wait for 10 seconds
  await Future.delayed(const Duration(seconds: 10));

  /// Get other sorted signatories excluding Bob
  final otherSignatoriesSortedExBob = SubstrateAddressUtils.otherSignatories(
      addresses: signerAddresses, signer: bobAddress);

  /// Fetch multisig details
  final multisigDetails = await api.getMultisigs(
      multisigaddress: multiSigAddress,
      callHashTx: callTxHashMulti,
      rpc: provider);

  /// Extract multisig call index and height
  final int multisigCallIndex = multisigDetails!["when"]["index"];
  final int multisigCallHeight = multisigDetails["when"]["height"];

  /// Fetch the latest finalized block hash again
  blockHash =
      await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
  blockHeader = await provider
      .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));

  /// Fetch Bob's account information
  final bobAccount =
      await api.getAccountInfo(address: bobAddress, rpc: provider);

  /// Create the payload for Bob's multisig execution
  final asMulti = createPayload(
      blockHash: blockHash,
      genesisHash: genesisHash,
      methodBytes: api.asMulti(
          thresHold: thresHold,
          otherSignatories: otherSignatoriesSortedExBob,
          call: runtimeMethod,
          maxWeight: maxWeight,
          maybeTimepoint: MultisigTimepoint(
              height: multisigCallHeight, index: multisigCallIndex)),
      nonce: bobAccount.nonce,
      specVersion: runtime.specVersion,
      transactionVersion: runtime.transactionVersion,
      era: blockHeader.toMortalEra(),
      signer: bob);

  /// Submit Bob's multisig execution extrinsic
  await provider
      .request(SubstrateRPCAuthorSubmitExtrinsic(asMulti.toHex(prefix: "0x")));

  /// Link to the transaction on subscan
  /// https://westend.subscan.io/extrinsic/0x1cf2d32ab0b7ed959eb125735e9cb4bb820f0f8abcf15297aadff88310fc3d31
}

Extrinsic createPayload(
    {required String blockHash,
    required String genesisHash,
    required List<int> methodBytes,
    required int nonce,
    required int specVersion,
    required int transactionVersion,
    required SubstrateBaseEra era,
    SubstratePrivateKey? signer}) {
  final payload = TransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: methodBytes,
      nonce: nonce,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      tip: BigInt.zero);

  ExtrinsicSignature? signature;
  if (signer != null) {
    final SubstrateMultiSignature multiSignature =
        signer.multiSignature(payload.serialize());
    signature = ExtrinsicSignature(
        signature: multiSignature,
        address: signer.toAddress().toMultiAddress(),
        era: era,
        tip: BigInt.zero,
        nonce: nonce);
  }

  return Extrinsic(signature: signature, methodBytes: methodBytes);
}
//// https://westend.subscan.io/extrinsic/0x1c9ceac97793e0b6289e69b8b8af877f41b8b1779abaef8318edcbc3b27eeb3d
