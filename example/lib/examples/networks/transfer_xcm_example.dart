// ignore_for_file: avoid_print

import 'package:blockchain_utils/utils/utils.dart';
import 'package:example/examples/networks/helpers.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class MySubstrateNetworkApiDefaultParams
    extends SubstrateNetworkApiDefaultParams {
  MySubstrateNetworkApiDefaultParams(super.provider);
  @override
  Future<SubstrateProvider> loadProvider(BaseSubstrateNetwork network) async {
    switch (network) {
      case PolkadotNetwork.polkadotAssetHub:
        return createLocalProvider(8000);
      case PolkadotNetwork.hydration:
        return createLocalProvider(8001);
      case PolkadotNetwork.acala:
        return createLocalProvider(8002);
      case PolkadotNetwork.polkadot:
        return createLocalProvider(8003);
    }
    throw Exception("Invalid network");
  }
}

void main() async {
  print("🚀 Starting cross-chain XCM transfer simulation...");

  // Initialize local network provider
  final param = MySubstrateNetworkApiDefaultParams(
    (network) async => createLocalProvider(8003),
  );

  // Define origin and destination networks
  const origin = PolkadotNetwork.polkadotAssetHub;
  const destinationNetwork = PolkadotNetwork.hydration;

  // Create owner and destination addresses
  final owner = createAccount(origin);
  final destinationAddress = createAccount(destinationNetwork);

  print("🧩 Origin: ${origin.networkName}");
  print("🧩 Destination: ${destinationNetwork.networkName}");
  print("👤 Owner address: $owner");
  print("🎯 Destination address: $destinationAddress");

  // Build network controllers
  final assetHubController =
      SubstrateNetworkControllerFinder.buildApi(network: origin, params: param);
  final hydrationController = SubstrateNetworkControllerFinder.buildApi(
      network: destinationNetwork, params: param);

  // Load network assets and balances
  print("🔍 Fetching network assets and balances...");
  final hydrationAssets = await hydrationController.getAssets();
  final assetHubAccountAssets =
      await assetHubController.getAccountAssets(address: owner);

  final sharedAssets = assetHubAccountAssets.findShareAssets(hydrationAssets);
  final canPayFee =
      assetHubAccountAssets.findShareAssets(hydrationAssets, canPayFee: true);

  // Filter assets that can be transferred
  print(
      "🔎 Filtering assets transferable between ${origin.networkName} and ${destinationNetwork.networkName}...");
  List<BaseSubstrateNetworkAsset> canTransfer =
      await assetHubController.filterReceiveAssets(
          assets: sharedAssets.map((e) => e.origin).toList(), origin: origin);
  canTransfer = await hydrationController.filterReceiveAssets(
      assets: canTransfer, origin: origin);
  final queriableAssets =
      SubstrateNetworkAssets(assets: canTransfer, network: origin);

  // Check for valid reverse mapping (1 reserve per asset group)
  final sameReverse = queriableAssets.sameReserve();
  final targetReverse = sameReverse[1];
  final usdt = targetReverse.symbol("USDt");
  final usdc = targetReverse.symbol("USDC");

  if (usdc == null || usdt == null) {
    print("❌ Missing USDt or USDC asset in the transferable group.");
    return;
  }

  final usdtBalance = assetHubAccountAssets.findBalance(usdt);
  final usdcBalance = assetHubAccountAssets.findBalance(usdc);

  if (usdcBalance == null || usdtBalance == null) {
    print("❌ Missing balance for USDt or USDC in asset hub account.");
    return;
  }

  assert(
    usdcBalance.free > BigInt.zero && usdtBalance.free > BigInt.zero,
    "Insufficient balance: USDC=${usdcBalance.free}, USDt=${usdtBalance.free}",
  );

  // Determine which asset can pay the destination fee
  BaseSubstrateNetworkAsset feeAsset() {
    if (canPayFee.any((e) => e.origin == usdc)) return usdc;
    if (canPayFee.any((e) => e.origin == usdt)) return usdt;
    throw Exception("❌ Cannot pay fee on destination network.");
  }

  // Define transfer assets
  final transferAssets = [
    SubstrateXCMTransferAsset(
        amount: usdtBalance.free ~/ BigInt.from(10), asset: usdt),
    SubstrateXCMTransferAsset(
        amount: usdcBalance.free ~/ BigInt.from(10), asset: usdc)
  ];

  final fee = feeAsset();
  final int feeIndex = transferAssets.indexWhere((e) => e.asset == fee);
  assert(!feeIndex.isNegative,
      "Fee asset ${fee.symbol} not found among transfer assets.");

  print("💸 Selected fee asset: ${fee.symbol}");
  print("📦 Preparing XCM transfer params...");

  // Build transfer parameters
  final transferParams = SubstrateXCMTransferParams(
      assets: transferAssets,
      destinationNetwork: destinationNetwork,
      destinationAddress: destinationAddress,
      feeIndex: feeIndex,
      origin: origin);

  // Encode transfer transaction
  final transfer = await assetHubController.xcmTransfer(params: transferParams);

  // Simulate XCM transfer (dry-run)
  print("🧪 Running dry-run simulation for XCM transfer...");
  final simulate = await assetHubController.dryRunXcmTransfer(
      owner: owner,
      encodedParams: transfer,
      creationParams: transferParams,
      onRequestController: (network) async => switch (network) {
            PolkadotNetwork.polkadotAssetHub => assetHubController,
            PolkadotNetwork.hydration => hydrationController,
            _ => SubstrateNetworkControllerFinder.buildApi(
                network: network, params: param)
          });

  BigInt localFee = BigInt.zero;
  BigInt destinationFee = BigInt.zero;
  bool isPartLocalFee = false;
  bool isPartDestinationFee = false;

  if (simulate != null) {
    if (!simulate.dryRun.success) {
      throw simulate.dryRun.cast<SubstrateDispatchResultError>().error.type;
    }

    // Parse local delivery fee
    for (final i in simulate.localDeliveryFees) {
      final dv = i.result;
      if (dv == null) {
        isPartLocalFee = true;
        continue;
      }

      assert(
        dv.success,
        "Local delivery fee query failed: ${dv.cast<SubstrateDispatchResultError>().error.type}",
      );

      for (final amount in i.amounts) {
        assert(
          amount.asset == assetHubController.defaultNativeAsset,
          "Unexpected local delivery fee asset '${amount.asset?.symbol}', expected native asset '${assetHubController.defaultNativeAsset.symbol}'",
        );
        if (amount.asset != assetHubController.defaultNativeAsset) {
          isPartLocalFee = true;
          continue;
        }
        localFee += amount.amount;
      }
    }

    // Parse destination delivery fee
    for (final i in simulate.externalXcm) {
      final dryRun = i.xcmDryRun;
      if (dryRun == null) {
        isPartDestinationFee = true;
        continue;
      }

      if (!dryRun.success && !(dryRun.ok?.isComplete ?? false)) {
        print(
            "❌ Simulation failed on destination network '${i.network?.networkName}'.");
        throw dryRun.cast<SubstrateDispatchResultError>().error.type;
      }

      final weightToFee = i.weightToFee;
      if (weightToFee != null) {
        assert(weightToFee.success,
            "Weight-to-fee conversion failed on '${i.network?.networkName}': ${weightToFee.cast<SubstrateDispatchResultError>().error.type}");
        destinationFee += weightToFee.ok!;
      } else {
        isPartDestinationFee = true;
      }

      for (final dv in i.deleveriesFee) {
        for (final amount in dv.amounts) {
          assert(amount.asset == fee,
              "Unexpected destination delivery fee asset '${amount.asset?.symbol}' on '${i.network?.networkName}', expected '${fee.symbol}'. The network may not support asset conversion.");
          if (amount.asset != fee) {
            isPartDestinationFee = true;
            continue;
          }
          destinationFee += amount.amount;
        }
      }
    }
  }

  // Local transaction dry-run
  print("🧮 Estimating local transaction fee...");
  final localDryRun = await assetHubController.dryRunTransaction(
      owner: owner, params: transfer);
  assert(localDryRun.dryRun == null || localDryRun.dryRun!.success,
      "Local dry-run failed: ${localDryRun.dryRun?.cast<SubstrateDispatchResultError>().error.type}");
  localFee += localDryRun.queryFeeInfo.partialFee;

  // Format fee outputs
  final localFeeStr = AmountConverter(
          decimals: assetHubController.defaultNativeAsset.decimals ?? 0)
      .toAmount(localFee);
  final destFeeStr =
      AmountConverter(decimals: fee.decimals ?? 0).toAmount(destinationFee);

  if (isPartLocalFee) {
    print(
        "⚠️ Partial local fee: $localFeeStr ${assetHubController.defaultNativeAsset.symbol} (some deliveries may not be supported)");
  } else {
    print(
        "✅ Total local fee: $localFeeStr ${assetHubController.defaultNativeAsset.symbol}");
  }

  if (isPartDestinationFee) {
    print(
        "⚠️ Partial destination fee: $destFeeStr ${fee.symbol} (some deliveries may not be supported)");
  } else {
    print("✅ Total destination fee: $destFeeStr ${fee.symbol}");
  }

  // Submit transaction
  print("🚀 Submitting transaction to ${origin.networkName}...");
  final submit = await assetHubController.submitXCMTransaction(
    owner: owner,
    params: transfer,
    destinationChainController: hydrationController,
    signer: createOwnerKeyPair(origin),
    onDestinationChainEvent: (event) => print(
        "🌐 Destination chain status: ${event.status}, deposits: ${event.deposits.map((e) => e.toJson()).toList()}"),
    onUpdateTransactionStatus: (event) => print(
        "📡 Local chain status: ${event.status}, block: ${event.blockNumber}"),
    onTransactionSubmited: (txId, blockNumber) => print(
        "📝 Transaction submitted: $txId (finalized in block $blockNumber)"),
  );

  await submit.toList();

  print("🎉 XCM transfer simulation and submission complete!");
}
