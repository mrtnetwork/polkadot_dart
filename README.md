# Polkadot Dart

This package offers comprehensive substrate interactions, allowing you to create, sign, and send transactions with ECDSA, ED25519, and SR25519. You can also query metadata, execute runtime calls, and utilize JSON-RPC for seamless blockchain operations.

With advanced cryptography support, the SDK enables robust address generation, signing, vrfsigning, verification, and key derivation for Substrate cryptographic algorithms. It also handles data efficiently, providing seamless encoding and decoding of various data formats.

This package is designed to work with Substrate metadata. It does not provide a user interface but focuses on encoding and decoding data with basic types such as JSON, List, BigInt, int, and more.

To effectively use this package, you should have a solid understanding of Substrate metadata. It provides a powerful and flexible toolkit for developers who need to handle various data formats and cryptographic operations within the Substrate ecosystem.

## Live application
 - An example of using a package can be found [here](https://mrtnetwork.github.io/substrate/)

## Futures

- **Transaction Management**
  - Create, sign, and verify transactions using multiple key types: ECDSA, ED25519, and SR25519.
  - Support for generating and managing addresses for ECDSA, ED25519, and SR25519 keys.
  - Introducing multi-signature (multi-sig) address feature for enhanced transaction security.

- **Metadata Support**
  - Full support for Substrate metadata versions V14 and V15.

- **JSON-RPC**
  - Comprehensive JSON-RPC support for seamless interaction with blockchain nodes.

- **Runtime Calls**
  - Execute runtime calls to interact with the blockchain's runtime environment.

- **Storage Queries**
  - Perform storage queries to retrieve and manipulate blockchain data.

- **Data Handling**
  - Encode and decode.

### Metadata and template

You can encode your metadata type using two methods: input the data as the standard metadata itself or use the template option to enter the data.

The following example will show how both methods work.

- Use Template

```dart

  final metadata = VersionedMetadata<MetadataV15>.fromBytes(
          BytesUtils.fromHexString(westendV15))
      .metadata;
  final api = MetadataApi(metadata);
  final template = api.getCallTemplate("Balances");
  /// print template and paste in blow
  final templateJson = template.buildJsonTemplateAsString();
  final receiver =
      SubstrateAddress("5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43");
  Map<String, dynamic> transferTemplate = {
    /// For enums, we have a key and value. We simply use one of the variant keys as the key and copy its value.
    /// We only need the key and value for enums, and only the value for other types. You can delete everything except these keys.
    "type": "Enum",
    "key": null,
    "value": null,
    "variants": {
      "transfer_allow_death": {
        "type": "Map",
        "value": {
          "dest": {
            "type": "Enum",
            "key": null,
            "value": null,
            "variants": {
              "Id": {"type": "[U8;32]", "value": null},
              "Index": {"type": "Tuple()", "value": null},
              "Raw": {"type": "Vec<U8>", "value": null},
              "Address32": {"type": "[U8;32]", "value": null},
              "Address20": {"type": "[U8;20]", "value": null}
            }
          },
          "value": {"type": "U128", "value": null}

          /// ... other balances method
        }
      },
    }
  };

  /// This template is ready for encoding. It represents a transfer operation where `transfer_allow_death` is the key for an enum type.
  /// Inside the enum, there's a map with keys `dest` and `value`.
  /// The `dest` key represents the destination, encoded as an enum with the key `Id` and a value obtained from `receiver.toBytes()`.
  /// The `value` key represents the amount to transfer, encoded as a `U128`.
  transferTemplate = {
    "type": "Enum",
    "key": "transfer_allow_death",
    "value": {
      "type": "Map",
      "value": {
        "dest": {
          "type": "Enum",
          "key": "Id",
          "value": {"value": receiver.toBytes()},
        },
        "value": {"value": BigInt.parse("1" * 13)}
      }
    }
  };

  /// After defining the `transferTemplate`, encode the method related to the `transfer_allow_death` transaction.
  final encode = api.encodeCall(
      palletNameOrIndex: "Balances",
      value: transferTemplate,
      fromTemplate: true);

  /// Encoded method:
  /// 040000ce74a4facc6eba97f01d694688311e590565bbd4d301f03e11c1ae7c35e718650bc71162b30201
  ```
  
- Use Standard metadata

``` dart
  /// you should check metadata json for correct template
  final transferTemplate = {
    "transfer_allow_death": {
      "dest": {"Id": receiver.toBytes()},
      "value": BigInt.parse("1" * 13)
    }
  };
  final encode = api.encodeCall(
      palletNameOrIndex: "Balances",
      value: transferTemplate,
      fromTemplate: false);

```

### Examples

#### Transfer

- transfer

```dart
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

```

- xcm transfer

```dart
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

```

#### Query

```dart

  /// Setting up the provider to connect to the Substrate node.
  final provider =
      SubstrateProvider(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  /// Parsing the metadata and initializing the Metadata API.
  final metadata = VersionedMetadata<MetadataV14>.fromBytes(
          BytesUtils.fromHexString(metadataV14))
      .metadata;
  final api = MetadataApi(metadata);

  /// Defining Substrate addresses for testing.
  final addr =
      SubstrateAddress("5EepAwmzpwn2PK45i3og3emvXs4NFnqzHu4T2VbUGhvkU4yB");
  final addr2 =
      SubstrateAddress("5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43");

  /// Retrieving input and output templates for cheking.
  final template = api.getStorageInputTemplate("System", "account");
  final output = api.getStorageOutputTemplate("System", "account");

  /// Querying single account information.
  final accountInfoSingleResult = await api.getStorage(
    request: QueryStorageRequest<Map<String, dynamic>?>(
        palletNameOrIndex: "System",
        methodName: "account",
        input: addr.toBytes(),
        identifier: 0),
    rpc: provider,
    fromTemplate: false,
  );

  /// Constructing storage query requests for multiple accounts.
  final rAccOne = QueryStorageRequest<Map<String, dynamic>>(
      palletNameOrIndex: "System",
      methodName: "account",
      input: addr.toBytes(),
      identifier: 0);
  final rAccTwo = QueryStorageRequest<Map<String, dynamic>>(
      palletNameOrIndex: "System",
      methodName: "account",
      input: addr2.toBytes(),
      identifier: 1);

  /// Querying storage for multiple accounts.
  final accountInfoMultipleResult = await api.queryStorageAt(
      requestes: [rAccOne, rAccTwo], rpc: provider, fromTemplate: false);
  final account1Info = accountInfoMultipleResult.getResult(1);

  /// Querying storage in a specific block range.
  final queryRange = await api.queryStorage(
      requestes: [rAccOne, rAccTwo],
      rpc: provider,
      fromBlock:
          "0x316ed44e1bb758de18a0307eac10cfaedf9d4eef1f7a383fb7ba1bd9270d3938",
      toBlock:
          "0x9afc2fbf7a31dc2f0adeedad895966c6dd6015e0dc540cf2b93c2e54fbf5afa7",
      fromTemplate: false);

  /// Iterating through query results within the specified block range.
  for (int i = 0; i < queryRange.length; i++) {
    final blockResponse = queryRange[i];
    final results = blockResponse.getResult(1);
  }

```

#### Runtime API

```dart
  /// Setting up the provider to connect to the Westend Substrate node.
  final provider =
      SubstrateProvider(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  /// Parsing the metadata and initializing the Metadata API.
  final metadata = VersionedMetadata<MetadataV15>.fromBytes(
      BytesUtils.fromHexString(westendV15));
  final api = MetadataApi(metadata.metadata);

  /// Retrieving runtime metadata at version 15.
  final version = await api.runtimeCall(
      apiName: "Metadata",
      methodName: "metadata_at_version",
      params: [15],
      rpc: provider,
      fromTemplate: false);

  /// Defining a Substrate address for account operations.
  final addr =
      SubstrateAddress("5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43");

  /// Retrieving the account nonce for the specified address.
  final accountNonce = await api.runtimeCall(
      apiName: "AccountNonceApi",
      methodName: "account_nonce",
      params: [
        {"type": "[U8;32]", "value": addr.toBytes()}
      ],
      rpc: provider,
      fromTemplate: true);

```

#### JSON-RPC

```dart

/// Custom implementation of Substrate HTTP service.
class SubstrateHttpService with SubstrateServiceProvider {
  SubstrateHttpService(this.url,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  final String url;
  final Client client;
  final Duration defaultTimeOut;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SubstrateRequestDetails params,
      {Duration? timeout}) async {
    final response = await client
        .post(params.toUri(url), headers: params.headers, body: params.body())
        .timeout(timeout ?? defaultTimeOut);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
/// Creating a provider with custom Substrate HTTP service.
final provider =
    SubstrateProvider(MySubstrateHttpSerivce("https://westend-rpc.polkadot.io"));

/// Retrieving genesis hash from the blockchain.
final genesisHash =
    await provider.request(const SubstrateRequestChainGetBlockHash(number: 0));

/// Retrieving finalized block hash from the blockchain.
final blockHash =
    await provider.request(const SubstrateRequestChainChainGetFinalizedHead());

/// Retrieving block header using the block hash.
final blockHeader = await provider
    .request(SubstrateRequestChainChainGetHeader(atBlockHash: blockHash));


```

#### Addresses and KeyManagment

```dart
  // Creating a seed for generating a private key.
  List<int> seedBytes = BytesUtils.fromHexString(
      "4bc884e0eb595d3c71dc4c62305380a43d7a820b9cf69753232196b34486a27c");

  // Generating a Substrate private key using SR25519 algorithm.
  SubstratePrivateKey privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.sr25519);

  // Generating a Substrate private key using Ed25519 algorithm.
  privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.ed25519);

  // Generating a Substrate private key using Secp256k1 algorithm.
  privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.secp256k1);

  // Obtaining the public key from the private key.
  final pubKey = privateKey.toPublicKey();

  // Obtaining the address from the public key.
  final address = pubKey.toAddress();

  // Signing a digest using the private key.
  final sign = privateKey.sign(digest);

  // Verifying a message signature using the public key.
  final verify = pubKey.verify(message, signature);

  // Generating a VRF signature using the private key.
  final vrfSign = privateKey.vrfSign(message);

  // Verifying a VRF signature using the public key.
  final vrfVerify = pubKey.verify(message, signature);

  // Deriving a child key from the private key.
  final derive = privateKey.derive("//mrtnetwork");

```

## Resources

- Comprehensive Testing: All functionalities have been thoroughly tested, ensuring reliability and accuracy.

## Contributing

Contributions are welcome! Please follow these guidelines:

- Fork the repository and create a new branch.
- Make your changes and ensure tests pass.
- Submit a pull request with a detailed description of your changes.

## Feature requests and bugs

Please file feature requests and bugs in the issue tracker.
