import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'json_rpc_example.dart';

void main() async {
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));
  final VersionedMetadata metadata =
      await provider.request(const SubstrateRPCStateGetMetadata());
  // final metadata =
  //     VersionedMetadata<MetadataV14>.fromBytes(BytesUtils.fromHexString(mt))
  //         .metadata;

  List<int> seedBytes = BytesUtils.fromHexString(
      "4bc884e0eb595d3c71dc4c62305380a43d7a820b9cf69753232196b34486a27c");
  final privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.sr25519);

  /// 5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43
  final signer = privateKey.toAddress();

  final api = metadata.toApi();

  final version = api.runtimeVersion();

  final genesisHash =
      await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));
  final blockHash =
      await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));
  final era = blockHeader.toMortalEra();

  final accountInfo = await api.getStorage(
      request: QueryStorageRequest<Map<String, dynamic>>(
          palletNameOrIndex: "System",
          methodName: "account",
          input: signer.toBytes(),
          identifier: 0),
      rpc: provider,
      fromTemplate: false);

  final int nonce = accountInfo.result["nonce"];
  final tmp = {
    "type": "Enum",
    "key": "bond",
    "value": {
      "type": "Map",
      "value": {
        "value": {"type": "U128", "value": SubstrateHelper.toWSD("2")},
        "payee": {
          "type": "Enum",
          "key": "Controller",
          "value": null,
        }
      }
    },
  };
  final method = List<int>.unmodifiable(api.encodeCall(
      palletNameOrIndex: "staking", value: tmp, fromTemplate: true));
  final payload = TransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: method,
      nonce: nonce,
      specVersion: version.specVersion,
      transactionVersion: version.transactionVersion,
      tip: BigInt.zero);

  final sig = privateKey.multiSignature(payload.serialize());

  final signature = ExtrinsicSignature(
      signature: sig,
      address: signer.toMultiAddress(),
      era: era,
      tip: BigInt.zero,
      nonce: nonce);
  final extrinsic = Extrinsic(signature: signature, methodBytes: method);
  await provider.request(
      SubstrateRPCAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
}

/// https://westend.subscan.io/extrinsic/0x64e79836cacc80414b42a374da4d16f6771c7dd5854f061d396cf4b7d116dd43
