import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'json_rpc_example.dart';

void main() async {
  final provider = SubstrateProvider(
      SubstrateHttpService("https://archive.perseverance.chainflip.io"));
  final VersionedMetadata? metadata = await provider
      .request(const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(15));

  List<int> seedBytes = BytesUtils.fromHexString(
      "241c27160517b75a04e29b560c50dde37ec564aed7ac5552862c80b0f956f460");
  final privateKey = SubstrateEthereumPrivateKey.fromBytes(seedBytes);

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

  final tmp = {
    "type": "Enum",
    "key": "transfer_allow_death",
    "value": {
      "type": "Map",
      "value": {
        "dest": {
          "value": SubstrateEthereumAddress(
                  "0x64a01564edB3e4a914DE27EE7758198bfFedDEdE")
              .toBytes()
        },
        "value": {"type": "U128", "value": SubstrateHelper.toWSD("5")}
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
  final method = api.encodeCall(
      palletNameOrIndex: "balances", value: tmp, fromTemplate: true);
  final payload = MoonbeamTransactionPayload(
    blockHash: SubstrateBlockHash.hash(blockHash),
    era: era,
    genesisHash: SubstrateBlockHash.hash(genesisHash),
    method: method,
    nonce: nonce,
    specVersion: version.specVersion,
    transactionVersion: version.transactionVersion,
  );
  final signature = privateKey.multiSignature(payload.serialzeSign());
  final extrinsic = payload.toExtrinsic(signature: signature, signer: signer);
  await provider.request(
      SubstrateRequestAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
}

/// https://assethub-westend.subscan.io/extrinsic/0x80009aaf23ec484cb1e89a738d7f4862b95ce8d819f9cc8ab26343389c393ad4?tab=xcm_transfer
