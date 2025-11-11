import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:example/examples/json_rpc_example.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

void main() async {
  /// Define constants for network format and threshold
  const int networkSS58 = SS58Const.genericSubstrate;
  const int threshold = 4;
  final sponser = SubstratePrivateKey.fromPrivateKey(
      keyBytes: BytesUtils.fromHexString(
          "032d3f756c0f96422f82fc5f8e02cfa5ebd87a3a368b4b81b095cf84f26334e8"),
      algorithm: SubstrateKeyAlgorithm.ed25519);
  final sponserAddress = sponser.toAddress(ss58Format: networkSS58);

  List<SubstratePrivateKey> privateKeys = List.generate(
      threshold + 1,
      (i) => SubstratePrivateKey.fromSeed(
            seedBytes: QuickCrypto.sha256Hash(
                BigintUtils.toBytes(BigInt.from(i + 1), length: 32)),
          ));

  /// List of signer addresses
  final signerAddresses =
      privateKeys.map((e) => e.toAddress(ss58Format: networkSS58)).toList();

  /// Create a multisig address from signer addresses and threshold
  final multiSigAddress = BaseSubstrateAddress.createMultiSigAddress(
      addresses: signerAddresses,
      threshold: threshold,
      ss58Format: networkSS58);

  /// Set up the provider with the RPC service
  final provider =
      SubstrateProvider(SubstrateHttpService("http://localhost:8001"));

  final currentMetadata = await provider
      .request(const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(15));

  /// Load API metadata
  final api = currentMetadata!.toApi();

  final fucent =
      await SubstrateTransactionBuilder.buildSignAndWatchTransactionStaticAsync(
          owner: sponserAddress,
          signer: sponser,
          calls: SubstrateTransactionSubmitableParams(calls: [
            ...signerAddresses.map((e) {
              final transfer = BalancesCallPalletTransferKeepAlive(
                  dest: e, amount: AmountConverter.kusama.toUnit("25"));
              return SubstrateEncodedCallParams(
                  pallet: transfer.pallet.name,
                  method: transfer.type.method,
                  bytes: transfer.encodeCall(
                    extrinsic: api.metadataWithExtrinsic(),
                  ));
            }),
            () {
              final transfer = BalancesCallPalletTransferKeepAlive(
                  dest: multiSigAddress,
                  amount: AmountConverter.kusama.toUnit("25"));
              return SubstrateEncodedCallParams(
                  pallet: transfer.pallet.name,
                  method: transfer.type.method,
                  bytes: transfer.encodeCall(
                      extrinsic: api.metadataWithExtrinsic()));
            }()
          ]),
          provider: MetadataWithProvider(
              provider: provider, metadata: api.metadataWithExtrinsic()));
  if (!fucent.status.isSuccess) {
    return;
  }

  final transfer = BalancesCallPalletTransferKeepAlive(
      dest: sponserAddress, amount: AmountConverter.kusama.toUnit('2'));
  final msigTx = SubstrateEncodedCallParams(
      pallet: transfer.pallet.name,
      method: transfer.type.method,
      bytes: transfer.encodeCall(extrinsic: api.metadataWithExtrinsic()));
  final weight = await SubstrateTransactionBuilder.dryRunTransaction(
      owner: multiSigAddress,
      calls: SubstrateTransactionSubmitableParams(calls: [msigTx]),
      provider: MetadataWithProvider(
          provider: provider, metadata: api.metadataWithExtrinsic()),
      xcmVersion: XCMVersion.v4);
  final info = await SubstrateQuickStorageApi.multisig.multisigs(
      address: multiSigAddress,
      callHashTx: QuickCrypto.blake2b256Hash(msigTx.bytes),
      api: api,
      rpc: provider);
  MultisigExtrinsicInfo? maybeTimepoint = info?.when;
  List<BaseSubstrateAddress> signers = signerAddresses;
  int approved = 0;
  if (info != null) {
    signers =
        signerAddresses.where((e) => !info.approvals.contains(e)).toList();
    approved = info.approvals.length;
  }
  privateKeys = List.generate(
      signers.length,
      (i) => privateKeys.firstWhere(
          (e) => e.toAddress(ss58Format: networkSS58) == signers[i]));

  for (int i = 0; i < signers.length; i++) {
    final address = signers[i];
    final otherSignatories = SubstrateAddressUtils.otherSignatories(
        addresses: signerAddresses, signer: address);
    final tx = switch (threshold) {
      1 => MultisigCallPalletAsMultiThreshold1(
          otherSignatories: otherSignatories, call: msigTx.bytes),
      _ => switch (approved + 1 == threshold) {
          false => MultisigCallPalletApproveAsMulti.fromCall(
              threshold: threshold,
              otherSignatories: otherSignatories,
              call: msigTx.bytes,
              maybeTimepoint: maybeTimepoint,
              maxWeight: weight.queryFeeInfo.weight),
          true => MultisigCallPalletAsMulti(
              threshold: threshold,
              otherSignatories: otherSignatories,
              call: msigTx.bytes,
              maybeTimepoint: maybeTimepoint,
              maxWeight: weight.queryFeeInfo.weight)
        }
    };

    final status = await SubstrateTransactionBuilder
        .buildSignAndWatchTransactionStaticAsync(
            owner: address,
            signer: privateKeys[i],
            calls: SubstrateTransactionSubmitableParams(calls: [
              SubstrateEncodedCallParams(
                  pallet: tx.pallet.name,
                  method: tx.type.name,
                  bytes: tx.encodeCall(extrinsic: api.metadataWithExtrinsic()))
            ]),
            provider: MetadataWithProvider(
                provider: provider, metadata: api.metadataWithExtrinsic()));
    if (!status.status.isSuccess) {
      return;
    }
    if (approved == 0) {
      final multisigDetails = await SubstrateQuickStorageApi.multisig.multisigs(
          address: multiSigAddress,
          callHashTx: QuickCrypto.blake2b256Hash(msigTx.bytes),
          api: api,
          rpc: provider);
      assert(multisigDetails != null, "mulitisg not found.");
      maybeTimepoint = multisigDetails?.when;
    }
    approved++;
    if (approved == threshold) {
      break;
    }
  }
}
