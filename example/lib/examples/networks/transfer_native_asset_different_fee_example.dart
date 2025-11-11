// ignore_for_file: avoid_print

import 'package:example/examples/networks/helpers.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

void main() async {
  const network = PolkadotNetwork.polkadotAssetHub;
  final owner = createAccount(network);
  final destination = createAccount(network, addressIndex: 1);
  final controller = SubstrateNetworkControllerFinder.buildApi(
      network: network,
      params: SubstrateNetworkApiDefaultParams(
        (network) async => createLocalProvider(8000),
      ));
  final balances = await controller.getAccountAssets(address: owner);
  final accountBalance = await controller.getNativeAssetFreeBalance(owner);
  if (balances.assets.isEmpty ||
      accountBalance == null ||
      accountBalance.free <= BigInt.zero) {
    return;
  }
  final asset = balances.symbol("USDt");
  if (asset == null) return null;
  final assetBalance = balances.findBalance(asset);

  if (assetBalance == null ||
      assetBalance.free <= BigInt.zero ||
      !assetBalance.asset.chargeAssetTxPayment) {
    return;
  }
  final tx = await controller.nativeTransfer(
      params: SubstrateNativeAssetTransferParams(
          destinationAddress: destination,
          amount: accountBalance.free ~/ BigInt.from(25)));
  final simulate = await controller.dryRunTransaction(
      owner: owner,
      params: tx,
      chargeAssetTxPaymentAssetId: assetBalance.asset);
  assert(simulate.dryRun != null || simulate.dryRun!.success);
  final submit = await controller.submitTransaction(
    owner: owner,
    chargeAssetTxPaymentAssetId: assetBalance.asset,
    params: tx,
    signer: createOwnerKeyPair(network),
    onUpdateTransactionStatus: (event) =>
        print("status: ${event.status} ${event.block} ${event.extrinsicIndex}"),
    onTransactionSubmited: (txId, blockNumber) =>
        print("tx submited $txId $blockNumber"),
  );
  await submit.toList();
}
