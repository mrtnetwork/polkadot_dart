# Polkadot Dart

This package offers comprehensive substrate interactions, allowing you to create, sign, and send transactions with ECDSA, ED25519, and SR25519. You can also query metadata, execute runtime calls, and utilize JSON-RPC for seamless blockchain operations.

With advanced cryptography support, the SDK enables robust address generation, signing, vrfsigning, verification, and key derivation for Substrate cryptographic algorithms. It also handles data efficiently, providing seamless encoding and decoding of various data formats.

This package is designed to work with Substrate metadata. It does not provide a user interface but focuses on encoding and decoding data with basic types such as JSON, List, BigInt, int, and more.

To effectively use this package, you should have a solid understanding of Substrate metadata. It provides a powerful and flexible toolkit for developers who need to handle various data formats and cryptographic operations within the Substrate ecosystem.

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

  /// Setting up the provider to connect to the Substrate node.
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  /// Requesting metadata from the blockchain to determine its version.
  final requestMetadata =
      await provider.request(const SubstrateRPCRuntimeGetMetadata(15));
  final metadata = requestMetadata!.metadata as MetadataV15;

  /// Generating a private key from a seed and deriving the corresponding address.
  List<int> seedBytes = BytesUtils.fromHexString(
      "4bc884e0eb595d3c71dc4c62305380a43d7a820b9cf69753232196b34486a27c");
  final privateKey = SubstratePrivateKey.fromSeed(
      seedBytes: seedBytes, algorithm: SubstrateKeyAlgorithm.sr25519);

  /// Deriving the address corresponding to the private key.
  final signer = privateKey.toAddress();

  /// Destination address for the transaction.
  final destination =
      SubstrateAddress("5EepAwmzpwn2PK45i3og3emvXs4NFnqzHu4T2VbUGhvkU4yB");

  /// Initializing metadata API for further interaction.
  final api = MetadataApi(metadata);

  /// Retrieving runtime version information.
  final version = api.runtimeVersion();
  final int transactionVersion = version["transaction_version"];
  final int specVersion = version["spec_version"];

  /// Retrieving genesis hash and finalized block hash.
  final genesisHash =
      await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));
  final blockHash =
      await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));
  final era = blockHeader.toMortalEra();

  /// Retrieving account information to determine the nonce for the transaction.
  final accountInfo = await api.getStorage(
      request: QueryStorageRequest<Map<String, dynamic>>(
          palletNameOrIndex: "System",
          methodName: "account",
          input: signer.toBytes(),
          identifier: 0),
      rpc: provider,
      fromTemplate: false);
  final int nonce = accountInfo.result["nonce"];

  /// Constructing the transfer payload.
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
        "value": {"type": "U128", "value": SubstrateHelper.toWsd("0.1")}
      }
    },
  };
  final method = api.encodeCall(
      palletNameOrIndex: "balances", value: tmp, fromTemplate: true);

  /// Constructing the transaction payload.
  final payload = TransactionPayload(
      blockHash: SubstrateBlockHash.hash(blockHash),
      era: era,
      genesisHash: SubstrateBlockHash.hash(genesisHash),
      method: method,
      nonce: nonce,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      tip: BigInt.zero);

  /// Signing the transaction.
  final sig = privateKey.multiSignature(payload.serialize());

  /// Constructing the extrinsic with the signature for submission.
  final signature = ExtrinsicSignature(
      signature: sig,
      address: signer.toMultiAddress(),
      era: era,
      tip: BigInt.zero,
      nonce: nonce);
  final extrinsic = Extrinsic(signature: signature, methodBytes: method);

  /// Submitting the extrinsic to the blockchain.
  final hash = await provider.request(
      SubstrateRPCAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));


```

- stacking

like previously we just encoded staking bond method

```dart

  final tmp = {
    "type": "Enum",
    "key": "bond",
    "value": {
      "type": "Map",
      "value": {
        "value": {"type": "U128", "value": SubstrateHelper.toWsd("2")},
        "payee": {
          "type": "Enum",
          "key": "Controller",
          "value": null,
        }
      }
    },
  };
  final method = List<int>.unmodifiable(api.encodeCall(
      palletNameOrIndex: "staking", value: tmp, fromTemplate: true));

```

#### Query

```dart

  /// Setting up the provider to connect to the Substrate node.
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

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
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

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
class MySubstrateHttpSerivce with SubstrateRPCService {
  MySubstrateHttpSerivce(this.url,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  /// URL of the Substrate node.
  @override
  final String url;

  /// HTTP client for making requests.
  final Client client;

  /// Default timeout duration for requests.
  final Duration defaultTimeOut;

  /// Method to make a Substrate RPC call.
  @override
  Future<Map<String, dynamic>> call(SubstrateRequestDetails params,
      [Duration? timeout]) async {
    // Making a POST request to the Substrate node.
    final response = await client
        .post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: params.toRequestBody())
        .timeout(timeout ?? defaultTimeOut);

    // Parsing the response data.
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data;
  }
}

/// Creating a provider with custom Substrate HTTP service.
final provider =
    SubstrateRPC(MySubstrateHttpSerivce("https://westend-rpc.polkadot.io"));

/// Retrieving genesis hash from the blockchain.
final genesisHash =
    await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));

/// Retrieving finalized block hash from the blockchain.
final blockHash =
    await provider.request(const SubstrateRPCChainChainGetFinalizedHead());

/// Retrieving block header using the block hash.
final blockHeader = await provider
    .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));


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
