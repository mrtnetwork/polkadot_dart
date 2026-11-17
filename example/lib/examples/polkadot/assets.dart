/// Asset transfer against a local Chopsticks fork of Westend Asset Hub.
///
/// Demonstrates the Assets pallet: create an asset, mint units, then transfer
/// a non-native asset between accounts. Run a fork first (see README.md):
///   chopsticks -c ./chopsticks.yml
/// then:
///   dart run lib/examples/polkadot/assets.dart
library;

import 'package:polkadot_dart/polkadot_dart.dart';

import 'node.dart';

Future<void> main() async {
  print('Polkadot — asset transfer (Westend Asset Hub fork)');
  print(field('rpc', polkadotRpcUrl));
  print(field('network', polkadotNetwork.networkName));

  final provider = SubstrateProvider(PolkadotHttpService());
  final meta = await loadMetadata(provider);

  final owner = polkadotAccount(0);
  final ownerAddr = owner.toAddress(ss58Format: polkadotSs58);
  final destination = polkadotAddress(1);
  print(field('owner', ownerAddr.address));
  print(field('destination', destination.address));

  // Native token pays for fees; fund the owner generously.
  await ensureFunded(meta, ownerAddr, minimum: oneUnit * BigInt.from(1000));

  // Asset Hub's Assets pallet uses an auto-incrementing id allocator, so
  // `create` only accepts the current NextAssetId. Reading it keeps the
  // example repeatable against a fresh fork.
  final assetId = await nextAssetId(meta);
  const mintAmount = 1000000;
  const transfer = 500;
  print(field('asset id', '$assetId'));

  // 1. Create the asset.
  final create = rawCall(
    meta,
    pallet: 'Assets',
    method: 'create',
    value: {
      'id': assetId,
      'admin': {'Id': ownerAddr.toBytes()},
      'min_balance': 1,
    },
  );
  final createResult = await send(
    meta,
    owner: ownerAddr,
    signer: owner,
    call: create,
  );
  if (createResult == null) {
    print('create asset failed');
    return;
  }
  print(field('created asset', 'block ${createResult.blockNumber}'));

  // 2. Mint units to the owner.
  final mint = rawCall(
    meta,
    pallet: 'Assets',
    method: 'mint',
    value: {
      'id': assetId,
      'beneficiary': {'Id': ownerAddr.toBytes()},
      'amount': mintAmount,
    },
  );
  final mintResult =
      await send(meta, owner: ownerAddr, signer: owner, call: mint);
  if (mintResult == null) {
    print('mint failed');
    return;
  }
  print(field('minted', '$mintAmount units'));

  // 3. Transfer units to the destination (typed call class).
  final transferCall = AssetsCallPalletTransfer(
    id: assetId,
    target: destination,
    amount: BigInt.from(transfer),
  );
  final transferResult = await send(
    meta,
    owner: ownerAddr,
    signer: owner,
    call: SubstrateEncodedCallParams(
      pallet: transferCall.pallet.name,
      method: transferCall.type.method,
      bytes: transferCall.encodeCall(extrinsic: meta.metadata),
    ),
  );
  if (transferResult == null) {
    print('asset transfer failed');
    return;
  }
  print(field('transferred', '$transfer units'));
  print(field('included in block', '${transferResult.blockNumber}'));

  final ownerBalance = await assetBalance(
    meta,
    address: ownerAddr,
    assetId: assetId,
  );
  final destBalance = await assetBalance(
    meta,
    address: destination,
    assetId: assetId,
  );
  print(field('owner asset balance', '${ownerBalance ?? 0}'));
  print(field('dest asset balance', '${destBalance ?? 0}'));
}
