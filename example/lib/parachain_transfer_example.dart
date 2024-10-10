import 'package:example/json_rpc_example.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

/// https://rococo-rpc.polkadot.io
/// /rococo-asset-hub-rpc.polkadot.io
/// [System, Babe, Timestamp, Indices, Balances, TransactionPayment, Authorship, Staking, Offences, Historical, Session, Grandpa, AuthorityDiscovery, Utility, Identity, Recovery, Vesting, Scheduler, Preimage, Sudo, Proxy, Multisig, ElectionProviderMultiPhase, VoterList, NominationPools, FastUnstake, ConvictionVoting, Referenda, Origins, Whitelist, Treasury, ParachainsOrigin, Configuration, ParasShared, ParaInclusion, ParaInherent, ParaScheduler, Paras, Initializer, Dmp, Hrmp, ParaSessionInfo, ParasDisputes, ParasSlashing, OnDemandAssignmentProvider, CoretimeAssignmentProvider, Registrar, Slots, ParasSudoWrapper, Auctions, Crowdloan, AssignedSlots, Coretime, XcmPallet, MessageQueue, AssetRate, RootTesting, Beefy, Mmr, BeefyMmrLeaf, IdentityMigrator]
void main() async {
  final provider = SubstrateRPC(
      SubstrateHttpService("https://sys.ibp.network/bridgehub-westend"));
  final VersionedMetadata metadata =
      await provider.request(const SubstrateRPCStateGetMetadata());

  List<int> seedBytes = List<int>.filled(32, 12);
  final privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.sr25519);

  // final chainInfo = await provider.request(SubstrateRPCSystemProperties());

  // print(privateKey.algorithm.cuve);
  // return;
  final privateKey2 = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.secp256k1);

  /// 5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43
  final signer = privateKey.toAddress();

  final destination = privateKey2.toAddress();

  final api = metadata.toApi();

  final version = api.runtimeVersion();

  final genesisHash = await provider
      .request(const SubstrateRPCChainGetBlockHash<String>(number: 0));
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

  // print("account $accountInfo");
  // return;
  final int nonce = accountInfo.result["nonce"];

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
        "value": {"type": "U128", "value": SubstrateHelper.toWSD("0.1")}
      }
    },
  };
  final method = List<int>.unmodifiable(api.encodeCall(
      palletNameOrIndex: "balances", value: tmp, fromTemplate: true));
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
      SubstrateRPCAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
}

/// https://westend.subscan.io/extrinsic/0xdb7c22ac4f66fda76e053ce06dc56bda9f67bf9e2ce9311adff693e5614955c6
