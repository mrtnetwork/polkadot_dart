// ignore_for_file: avoid_print

import 'package:example/examples/networks/helpers.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

// Main entry point (async because of async blockchain calls)
void main() async {
  // Choose the target Polkadot-based network
  const network = PolkadotNetwork.hydration;
  print("🌐 Selected network: $network");

  // Create owner and destination accounts
  final owner = createAccount(network);
  final destination = createAccount(network, addressIndex: 1);
  print("👤 Owner address: ${owner.address}");
  print("🎯 Destination address: ${destination.address}");

  // Initialize the controller (network API + local provider)
  print("🔧 Initializing network controller...");
  final controller = SubstrateNetworkControllerFinder.buildApi(
    network: network,
    params: SubstrateNetworkApiDefaultParams(
      (network) async => createLocalProvider(8001),
    ),
  );
  print("✅ Controller initialized successfully");

  // Fetch the account's balances
  print("💰 Fetching account balances for ${owner.address}...");
  final balances = await controller.getAccountAssets(address: owner);
  if (balances.assets.isEmpty) {
    print("⚠️ No assets found for this account.");
    return;
  }

  // Try to locate a specific token (USDT)
  final asset = balances.symbol("USDT");
  if (asset == null) {
    print("❌ USDT asset not found on this network.");
    return;
  }

  // Get balance information for the selected asset
  final assetBalance = balances.findBalance(asset);
  print("💵 USDT Balance: ${assetBalance?.free ?? 0}");

  // Ensure the account has enough balance to send
  if (assetBalance == null || assetBalance.free <= BigInt.zero) {
    print("⚠️ Insufficient USDT balance. Cannot proceed with transfer.");
    return;
  }

  // Prepare a transfer transaction (sending 1/25th of the free balance)
  final transferAmount = assetBalance.free ~/ BigInt.from(25);
  print(
      "✉️ Preparing transfer of $transferAmount USDT to ${destination.address}...");
  final tx = await controller.assetTransfer(
    params: SubstrateLocalTransferAssetParams(
      destinationAddress: destination,
      asset: assetBalance.asset,
      amount: transferAmount,
    ),
  );

  // Simulate (dry run) the transaction to estimate fees and check validity
  print("🧪 Simulating transaction (dry run)...");
  final simulate = await controller.dryRunTransaction(owner: owner, params: tx);
  assert(simulate.dryRun != null || simulate.dryRun!.success);
  print("💸 Estimated fee: ${simulate.queryFeeInfo.serializeJson()}");

  // Submit the transaction to the network
  print("🚀 Submitting transaction...");
  final submit = await controller.submitTransaction(
    owner: owner,
    params: tx,
    signer: createOwnerKeyPair(network),
    onUpdateTransactionStatus: (event) =>
        print("📦 Transaction found in block: ${event.extrinsicIndex}"),
    onTransactionSubmited: (txId, blockNumber) => print(
        "✅ Transaction submitted successfully! ID: $txId, Block: $blockNumber"),
  );

  await submit.toList();
  print("🎉 Transaction flow complete!");
}
