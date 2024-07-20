import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'json_rpc_example.dart';

void main() async {
  /// Setting up the provider to connect to the Substrate node.
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  /// Requesting metadata from the blockchain to determine its version.
  final requestMetadata = await provider
      .request(const SubstrateRPCRuntimeMetadataGetMetadataAtVersion(15));
  final metadata = requestMetadata!.metadata as MetadataV15;

  /// Generating a private key from a seed and deriving the corresponding address.
  List<int> seedBytes = BytesUtils.fromHexString(
      "4bc884e0eb595d3c71dc4c62305380a43d7a820b9cf69753232196b34486a27c");
  final privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.sr25519);

  /// Deriving the address corresponding to the private key.
  final signer = privateKey.toAddress();

  /// Destination address for the transaction.
  final destination =
      SubstrateAddress("5FeHntLqsucHn1CZuAsLceAN2FJhwbonP6goHzo4dWVzW33T");

  /// Initializing metadata API for further interaction.
  final api = MetadataApi(metadata);

  /// Retrieving runtime version information.
  final version = api.runtimeVersion();

  /// Retrieving genesis hash and finalized block hash.
  final genesisHash =
      await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));
  final blockHash =
      await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));
  final era = blockHeader.toMortalEra();

  /// Retrieving account information to determine the nonce for the transaction.
  final accountInfo = await api.getStorage(
      request: QueryStorageRequest<Map<String, dynamic>>(
          palletNameOrIndex: "System",
          methodName: "account",
          input: signer.toBytes(),
          identifier: 0),
      rpc: provider,
      fromTemplate: false);
  final int nonce = accountInfo.result["nonce"];

  /// Constructing the transfer payload.
  final tmp = {
    "type": "Enum",
    "key": "transfer_allow_death",
    "value": {
      "type": "Map",
      "value": {
        "dest": {
          "key": "Id",
          "value": {"type": "[U8;32]", "value": destination.toBytes()},
        },
        "value": {"type": "U128", "value": SubstrateHelper.toWSD("5")}
      }
    },
  };
  final method = api.encodeCall(
      palletNameOrIndex: "balances", value: tmp, fromTemplate: true);

  /// Constructing the transaction payload.
  final payload = TransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: method,
      nonce: nonce,
      specVersion: version.specVersion,
      transactionVersion: version.transactionVersion,
      tip: BigInt.zero);

  /// Signing the transaction.
  final sig = privateKey.multiSignature(payload.serialzeSign());

  /// Constructing the extrinsic with the signature for submission.
  final signature = ExtrinsicSignature(
      signature: sig,
      address: signer.toMultiAddress(),
      era: era,
      tip: BigInt.zero,
      nonce: nonce);
  final extrinsic = Extrinsic(signature: signature, methodBytes: method);

  /// Submitting the extrinsic to the blockchain.
  await provider.request(
      SubstrateRPCAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
}

/// https://westend.subscan.io/extrinsic/0xdb7c22ac4f66fda76e053ce06dc56bda9f67bf9e2ce9311adff693e5614955c6
