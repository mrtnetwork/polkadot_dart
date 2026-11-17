# Polkadot Dart

Dart SDK for Substrate networks: build, sign, and submit extrinsics with ECDSA, Ed25519, and sr25519 — metadata-driven calls (V14/V15/V16), storage queries, runtime APIs, staking, multisig, and versioned XCM transfers across 30+ networks.

This package is the continuation of the original
[mrtnetwork/polkadot_dart](https://github.com/mrtnetwork/polkadot_dart).

Live demo: [mrtnetwork.github.io/substrate](https://mrtnetwork.github.io/substrate/)

## Crypto engine: `blockchain_utils` dual backend

Key cryptography (ECDSA, Ed25519, sr25519 signing, VRF, key derivation) lives
in [`blockchain_utils`](https://github.com/mrtnetwork/blockchain_utils): pure
Dart by default, optional Rust backend (FFI on native, WASM on web). When set
(`blockchainUtils.setRustApi()`), all high-level crypto used here routes
through Rust. Rust core:
[mrtnetwork/blockchain-utils](https://github.com/mrtnetwork/blockchain-utils).

## Supported networks

| Ecosystem | Networks |
|---|---|
| Polkadot | Relay + system chains, Astar, Acala, Bifrost, Interlay, Phala, Moonbeam, Mythos, Hydration, AssetHub, … |
| Kusama | Relay + system chains, Shiden, Karura, Basilisk, Bifrost Kusama, Moonriver, Kintsugi, … |
| Westend | Relay, Penpal, system parachains |
| Paseo | Testnet relay, Hydration parachain |

`SubstrateNetworkControllerFinder` builds the right controller per network
(30+ supported) for transfers, balances, and XCM.

## Features

### Transactions & keys

| Area | Support |
|---|---|
| Keys | ECDSA, Ed25519, sr25519 — derive, sign, verify, VRF sign/verify |
| Addresses | SS58 for all key types, multisig addresses, `IAddress` integration |
| Extrinsics | Mortal/immortal eras, tips, nonce handling, dry-run + fee query, submit + status tracking |

### Metadata & encoding

| Area | Support |
|---|---|
| Versions | V14, V15, V16 |
| Calls | Template-driven or standard encoding, pallet-call deserialization |
| Types | Full SCALE codec (enums, tuples, vecs, options, compact ints, …) |
| Storage | Single/batch queries, range queries, key pagination |

### Queries & runtime

| Area | Support |
|---|---|
| RPC | Chain, state, system, author, payment, runtime-call endpoints |
| Runtime APIs | `Metadata`, `AccountNonceApi`, custom runtime calls |
| Assets | Account assets, balances, asset metadata |

### XCM

| Area | Support |
|---|---|
| Versions | V2, V3, V4, V5 versioned transfers |
| Flows | Fee estimation (local + destination delivery), dry-run, submit with destination tracking |
| Assets | Multi-asset transfers, fee-asset selection, receive filters |

## Examples

See [`example/`](https://github.com/mrtnetwork/polkadot_dart/tree/main/example)
(transfers, XCM transfers, storage queries, runtime calls, metadata
templates, key management).

## Testing

```sh
dart test            # unit + backend-parity suites
```

Backend-parity one-shot suites (`one_shot_suite.dart`, `test_backend.dart`)
exercise both the pure-Dart and Rust/WASM backends; XCM suites cover V2–V5.

## Contributing

Contributions are welcome! Please follow these guidelines:

- Fork the repository and create a new branch.
- Make your changes and ensure tests pass.
- Submit a pull request with a detailed description of your changes.

## Feature requests and bugs

Please file feature requests and bugs in the issue tracker.
