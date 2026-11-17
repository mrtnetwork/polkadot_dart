# Polkadot examples (local Chopsticks fork of Westend Asset Hub)

The examples run against a fork of the live chain state — same pallets,
metadata and runtime — while funding accounts for free, so they are
deterministic and never touch mainnet.

Start the fork (needs `chopsticks` on PATH):

```sh
chopsticks -c ./chopsticks.yml
```

It exposes JSON-RPC on `http://127.0.0.1:8001`. Then, from the example package:

```sh
dart run lib/examples/polkadot/transfer.dart
dart run lib/examples/polkadot/assets.dart
dart run lib/examples/polkadot/multisig.dart
```
