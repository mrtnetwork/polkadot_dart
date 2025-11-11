import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'json_rpc_example.dart';

void main() async {
  final provider = SubstrateProvider(
      SubstrateHttpService("https://westmint-rpc.dwellir.com:443"));
  final VersionedMetadata? metadata = await provider
      .request(const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(15));

  List<int> seedBytes = BytesUtils.fromHexString(
      "241c27160517b75a04e29b560c50dde37ec564aed7ac5552862c80b0f956f460");
  final privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.ed25519);

  final signer = privateKey.toAddress();

  final api = metadata!.toApi();

  final version = api.runtimeVersion();

  final genesisHash = await provider
      .request(const SubstrateRequestChainGetBlockHash<String>(number: 0));

  final blockHash = await provider
      .request(const SubstrateRequestChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRequestChainChainGetHeader(atBlockHash: blockHash));
  final era = blockHeader.toMortalEra();

  final nextAsset = await api.getStorageRequest(
      request: GetStorageRequest<int, int>(
          palletNameOrIndex: "Assets", methodName: "NextAssetId"),
      rpc: provider,
      fromTemplate: false);
  final createAssetsTemplate = {
    "type": "Enum",
    "key": "create",
    "value": {
      "type": "Map",
      "value": {
        "id": {"type": "U32", "value": nextAsset},
        "admin": {
          "key": "Id",
          "value": {"type": "[U8;32]", "value": signer.toBytes()},
        },
        "min_balance": {"type": "U128", "value": BigInt.one}
      }
    },
  };

  final nonce = await api.getStorageRequest(
      request: GetStorageRequest<int, Map<String, dynamic>>(
          palletNameOrIndex: "System",
          methodName: "account",
          inputs: signer.toBytes(),
          onJsonResponse: (response, _, __) => response["nonce"]),
      rpc: provider,
      fromTemplate: false);

  final method = List<int>.unmodifiable(api.encodeCall(
      palletNameOrIndex: "assets",
      value: createAssetsTemplate,
      fromTemplate: true));
  final payload = AssetTransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: method,
      nonce: nonce,
      specVersion: version.specVersion,
      transactionVersion: version.transactionVersion,
      tip: BigInt.zero);

  final sig = privateKey.multiSignature(payload.serialzeSign());

  final signature = AssetExtrinsicSignature(
      signature: sig,
      address: signer.toMultiAddress(),
      era: era,
      tip: BigInt.zero,
      nonce: nonce);
  final extrinsic = Extrinsic(signature: signature, methodBytes: method);
  await provider.request(
      SubstrateRequestAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
}

//// https://assethub-westend.subscan.io/extrinsic/0x214832ced6ba10f6b643749f0549ed1b71bd49bc753067cce1251eee1756a1fe?tab=xcm_transfer
