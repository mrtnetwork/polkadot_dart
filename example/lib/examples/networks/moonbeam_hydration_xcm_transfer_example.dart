// ignore_for_file: avoid_print

import 'package:blockchain_utils/utils/utils.dart';
import 'package:example/examples/networks/helpers.dart';
import 'package:on_chain/ethereum/src/rpc/rpc.dart';
import 'package:on_chain/solidity/contract/fragments.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class MySubstrateNetworkApiDefaultParams
    extends SubstrateNetworkApiDefaultParams {
  MySubstrateNetworkApiDefaultParams(super.provider, {super.evmParams});
  @override
  Future<SubstrateProvider> loadProvider(BaseSubstrateNetwork network) async {
    switch (network) {
      case PolkadotNetwork.polkadotAssetHub:
        return createLocalProvider(8000);
      case PolkadotNetwork.hydration:
        return createLocalProvider(8001);
      case PolkadotNetwork.acala:
        return createLocalProvider(8002);
      case PolkadotNetwork.moonbeam:
        return createLocalProvider(8003);
      case PolkadotNetwork.polkadot:
        return createLocalProvider(8004);
    }
    throw Exception("Invalid network");
  }
}

class EvmDefaultParams extends SubstrateEvmNetworkControllerParams {
  List<String>? _rpcMethods;
  EthereumProvider? _provider;
  final _lock = SafeAtomicLock();
  @override
  Future<RESPONSE> ethCall<RESPONSE extends Object?>(
      {required SubstrateEthereumAddress contract,
      required EvmFunctionAbi<RESPONSE> function,
      required MetadataWithProvider provider,
      List<Object>? params}) async {
    /// ethereum call not supported by chopsticks
    if (_provider == null) {
      if (_rpcMethods == null) {
        await _lock.run(() async {
          final rpcMethods = await provider.provider
              .request(const SubstrateRequestRpcMethods());
          final methods = rpcMethods.methods;
          if (methods.contains(EthereumMethods.call.value)) {
            _provider = EthereumProvider(provider.provider.rpc);
          }
          _rpcMethods = methods;
        });
      }
    }
    final ethProvider = _provider;
    final func = AbiFunctionFragment.fromJson(function.abi);
    if (ethProvider != null) {
      final result = await ethProvider.request(EthereumRequestFunctionCall(
          contractAddress: contract.address,
          function: func,
          params: params ?? []));
      return function.parser(result.cast());
    }

    final result = await SubstrateQuickRuntimeApi.ethereumRuntimeRPCApis.call(
        api: provider.metadata.api,
        rpc: provider.provider,
        from: SubstrateAddressUtils.zeroAddress,
        to: SubstrateEthereumAddress(contract.address),
        inputs: func.encode(params ?? []),
        gasLmit: BigInt.one);
    final ok = result.ok;
    if (ok == null || !ok.exitReason.isSucceed) {
      throw Exception();
    }
    final value =
        AbiFunctionFragment.fromJson(function.abi).decodeOutput(ok.value);
    return function.parser(value.cast());
  }
}

void main() async {
  print("🚀 Starting cross-chain XCM transfer simulation...");
  final ethereumParams = EvmDefaultParams();
  // Initialize local network provider
  final param = MySubstrateNetworkApiDefaultParams(
      (network) async => throw UnimplementedError(),
      evmParams: ethereumParams);

  // Define origin and destination networks
  const origin = PolkadotNetwork.moonbeam;
  const destinationNetwork = PolkadotNetwork.hydration;

  // Create owner and destination addresses
  final owner = createAccount(origin);
  final destinationAddress = createAccount(destinationNetwork);
  // print("owner $owner");
  // return;
  print("🧩 Origin: ${origin.networkName}");
  print("🧩 Destination: ${destinationNetwork.networkName}");
  print("👤 Owner address: $owner");
  print("🎯 Destination address: $destinationAddress");

  // Build network controllers
  final moonbeamController =
      SubstrateNetworkControllerFinder.buildApi(network: origin, params: param);
  final hydrationController = SubstrateNetworkControllerFinder.buildApi(
      network: destinationNetwork, params: param);

  // Load network assets and balances
  print("🔍 Fetching network assets and balances...");
  final hydrationAssets = await hydrationController.getAssets();
  final moonbeamAccountAssets =
      await moonbeamController.getAccountAssets(address: owner);

  final sharedAssets = moonbeamAccountAssets.findShareAssets(hydrationAssets);
  final canPayFee =
      moonbeamAccountAssets.findShareAssets(hydrationAssets, canPayFee: true);

  // Filter assets that can be transferred
  print(
      "🔎 Filtering assets transferable between ${origin.networkName} and ${destinationNetwork.networkName}...");
  List<BaseSubstrateNetworkAsset> canTransfer =
      await moonbeamController.filterReceiveAssets(
          assets: sharedAssets.map((e) => e.origin).toList(), origin: origin);
  canTransfer = await hydrationController.filterReceiveAssets(
      assets: canTransfer, origin: origin);
  final glmr =
      moonbeamAccountAssets.findBalance(moonbeamController.defaultNativeAsset);

  if (glmr == null) {
    print("❌ Missing balance for GLMR in Moonbeam account.");
    return;
  }

  assert(glmr.free > BigInt.zero, "Insufficient balance: GLMR=${glmr.free}");

  // Determine which asset can pay the destination fee
  BaseSubstrateNetworkAsset feeAsset() {
    if (canPayFee
        .any((e) => e.origin == moonbeamController.defaultNativeAsset)) {
      return moonbeamController.defaultNativeAsset;
    }
    throw Exception("❌ Cannot pay fee on destination network.");
  }

  // Define transfer assets
  final transferAssets = [
    SubstrateXCMTransferAsset(
        amount: glmr.free ~/ BigInt.from(10), asset: glmr.asset),
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
  final transfer = await moonbeamController.xcmTransfer(params: transferParams);

  // Simulate XCM transfer (dry-run)
  print("🧪 Running dry-run simulation for XCM transfer...");
  final simulate = await moonbeamController.dryRunXcmTransfer(
      owner: owner,
      encodedParams: transfer,
      creationParams: transferParams,
      onRequestController: (network) async => switch (network) {
            PolkadotNetwork.polkadotAssetHub => moonbeamController,
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
          amount.asset == moonbeamController.defaultNativeAsset,
          "Unexpected local delivery fee asset '${amount.asset?.symbol}', expected native asset '${moonbeamController.defaultNativeAsset.symbol}'",
        );
        if (amount.asset != moonbeamController.defaultNativeAsset) {
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
  final localDryRun = await moonbeamController.dryRunTransaction(
      owner: owner, params: transfer);
  assert(localDryRun.dryRun == null || localDryRun.dryRun!.success,
      "Local dry-run failed: ${localDryRun.dryRun?.cast<SubstrateDispatchResultError>().error.type}");
  localFee += localDryRun.queryFeeInfo.partialFee;

  // Format fee outputs
  final localFeeStr = AmountConverter(
          decimals: moonbeamController.defaultNativeAsset.decimals ?? 0)
      .toAmount(localFee);
  final destFeeStr =
      AmountConverter(decimals: fee.decimals ?? 0).toAmount(destinationFee);

  if (isPartLocalFee) {
    print(
        "⚠️ Partial local fee: $localFeeStr ${moonbeamController.defaultNativeAsset.symbol} (some deliveries may not be supported)");
  } else {
    print(
        "✅ Total local fee: $localFeeStr ${moonbeamController.defaultNativeAsset.symbol}");
  }

  if (isPartDestinationFee) {
    print(
        "⚠️ Partial destination fee: $destFeeStr ${fee.symbol} (some deliveries may not be supported)");
  } else {
    print("✅ Total destination fee: $destFeeStr ${fee.symbol}");
  }

  // Submit transaction
  print("🚀 Submitting transaction to ${origin.networkName}...");
  final submit = await moonbeamController.submitXCMTransaction(
    owner: owner,
    params: transfer,
    destinationChainController: hydrationController,
    signer: createOwnerKeyPair(origin),
    onDestinationChainEvent: (event) => print(
        "🌐 Destination chain status: ${event.status}, deposits: ${event.deposits.map((e) => e.toJson()).toList()}"),
    onUpdateTransactionStatus: (event) => print(
        "📡 Local chain status: ${event.status}, block: ${event.blockNumber}"),
    onTransactionSubmited: (txId, blockNumber) =>
        print("📝 Transaction submitted: $txId"),
  );

  await submit.toList();

  print("🎉 XCM transfer simulation and submission complete!");
}
