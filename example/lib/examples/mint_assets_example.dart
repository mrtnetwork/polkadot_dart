import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:example/examples/json_rpc_example.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

void main() async {
  final provider = SubstrateProvider(
      SubstrateHttpService("https://westmint-rpc.dwellir.com:443"));
  final VersionedMetadata? metadata = await provider
      .request(const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(15));

  List<int> seedBytes = BytesUtils.fromHexString(
      "241c27160517b75a04e29b560c50dde37ec564aed7ac5552862c80b0f956f460");
  final privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.ed25519);

  // final chainInfo = await provider.request(SubstrateRequestSystemProperties());

  /// 5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43
  final signer = privateKey.toAddress();

  final api = metadata!.toApi();
  // print(StringUtils.fromJson(meta.extrinsic.scaleJsonSerialize()));

  final version = api.runtimeVersion();

  final genesisHash = await provider
      .request(const SubstrateRequestChainGetBlockHash<String>(number: 0));

  final blockHash = await provider
      .request(const SubstrateRequestChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRequestChainChainGetHeader(atBlockHash: blockHash));
  final era = blockHeader.toMortalEra();

  // final nextAsset = await api.getStorage(
  //     request: QueryStorageRequest<int>(
  //         palletNameOrIndex: "Assets",
  //         methodName: "NextAssetId",
  //         identifier: 0),
  //     rpc: provider,
  //     fromTemplate: false);
  // print("next assetid ${nextAsset.result}");
  final setAssetMetadata = {
    "type": "Enum",
    "key": "mint",
    "value": {
      "type": "Map",
      "value": {
        "id": {"type": "U32", "value": 50000055},
        "beneficiary": {
          "type": "Enum",
          "key": "Id",
          "value": {"type": "[U8;32]", "value": signer.toBytes()},
        },
        "amount": {"type": "U128", "value": SubstrateHelper.toWSD("200")}
      }
    },
  };

  final accountInfo = await api.getStorage(
      request: QueryStorageRequest<Map<String, dynamic>>(
          palletNameOrIndex: "System",
          methodName: "account",
          input: signer.toBytes(),
          identifier: 0),
      rpc: provider,
      fromTemplate: false);
  final int nonce = accountInfo.result["nonce"];
  final method = List<int>.unmodifiable(api.encodeCall(
      palletNameOrIndex: "assets",
      value: setAssetMetadata,
      fromTemplate: true));
  final payload = TransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: method,
      nonce: nonce,
      specVersion: version.specVersion,
      transactionVersion: version.transactionVersion,
      tip: BigInt.zero);

  final sig = privateKey.multiSignature(payload.serialzeSign());

  final signature = ExtrinsicSignature(
      signature: sig,
      address: signer.toMultiAddress(),
      era: era,
      tip: BigInt.zero,
      nonce: nonce);
  final extrinsic = Extrinsic(signature: signature, methodBytes: method);
  await provider.request(
      SubstrateRequestAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
}

/// https://assethub-westend.subscan.io/extrinsic/0x80009aaf23ec484cb1e89a738d7f4862b95ce8d819f9cc8ab26343389c393ad4?tab=xcm_transfer
