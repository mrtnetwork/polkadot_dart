// ignore_for_file: avoid_print

import 'package:example/examples/networks/helpers.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

void main() async {
  const network = PolkadotNetwork.hydration;
  final owner = createAccount(network);
  final destination = createAccount(network, addressIndex: 1);
  final controller = SubstrateNetworkControllerFinder.buildApi(
      network: network,
      params: SubstrateNetworkApiDefaultParams(
        (network) async => createLocalProvider(8001),
      ));
  final balance = await controller.getNativeAssetFreeBalance(owner);
  print("balance: ${balance?.free}");
  if (balance == null) return;
  final tx = await controller.nativeTransfer(
      params: SubstrateNativeAssetTransferParams(
          destinationAddress: destination,
          amount: balance.free ~/ BigInt.from(25)));
  final simulate = await controller.dryRunTransaction(owner: owner, params: tx);
  assert(simulate.dryRun != null || simulate.dryRun!.success);
  print("fee ${simulate.queryFeeInfo.serializeJson()}");
  final submit = await controller.submitTransaction(
    owner: owner,
    params: tx,
    signer: createOwnerKeyPair(network),
    onUpdateTransactionStatus: (event) =>
        print("tx find in block: ${event.extrinsicIndex}"),
    onTransactionSubmited: (txId, blockNumber) =>
        print("tx submited $txId $blockNumber"),
  );
  await submit.toList();
}
