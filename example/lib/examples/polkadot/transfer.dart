/// Native balance transfer against a local Chopsticks fork of Westend Asset Hub.
///
/// Run a fork first (see README.md):
///   chopsticks -c ./chopsticks.yml
/// then:
///   dart run lib/examples/polkadot/transfer.dart
library;


import 'package:polkadot_dart/polkadot_dart.dart';

import 'node.dart';

Future<void> main() async {
  print('Polkadot — native transfer (Westend Asset Hub fork)');
  print(field('rpc', polkadotRpcUrl));
  print(field('network', polkadotNetwork.networkName));

  final provider = SubstrateProvider(PolkadotHttpService());
  final meta = await loadMetadata(provider);

  final owner = polkadotAccount(0);
  final ownerAddr = owner.toAddress(ss58Format: polkadotSs58);
  final destination = polkadotAddress(1);
  print(field('owner', ownerAddr.address));
  print(field('destination', destination.address));

  // Fund the owner so it can pay for the transfer and its fee.
  await ensureFunded(meta, ownerAddr, minimum: oneUnit * BigInt.from(1000));
  print(field('owner balance', '${formatUnits(await freeBalance(meta, ownerAddr))} WND'));

  final destBefore = await freeBalance(meta, destination);
  print(field('dest before', '${formatUnits(destBefore)} WND'));

  // Build the call: balances.transfer_keep_alive(dest, amount).
  final call = BalancesCallPalletTransferKeepAlive(
    dest: destination,
    amount: transferAmount,
  );
  final calls = SubstrateTransactionSubmitableParams(
    calls: [
      SubstrateEncodedCallParams(
        pallet: call.pallet.name,
        method: call.type.method,
        bytes: call.encodeCall(extrinsic: meta.metadata),
      ),
    ],
  );

  // Estimate the fee before sending.
  final dry = await SubstrateTransactionBuilder.dryRunTransaction(
    owner: ownerAddr,
    calls: calls,
    provider: meta,
    signer: owner,
  );
  print(
    field('estimated fee', '${formatUnits(dry.fee ?? BigInt.zero)} WND'),
  );

  // Sign and submit, waiting for the transaction to be included in a block.
  final result =
      await SubstrateTransactionBuilder.buildSignAndWatchTransactionStaticAsync(
        owner: ownerAddr,
        signer: owner,
        calls: calls,
        provider: meta,
        onSubmitxtrinsic: (txId, blockNumber) {
          print(field('submitted', txId));
        },
      );

  if (!result.status.isSuccess) {
    print('Transfer failed: ${result.status.name}');
    return;
  }
  print(field('included in block', '${result.blockNumber}'));
  print(field('tx hash', result.transactionHash));

  final destAfter = await freeBalance(meta, destination);
  final ownerAfter = await freeBalance(meta, ownerAddr);
  print(field('dest after', '${formatUnits(destAfter)} WND'));
  print(field('owner after', '${formatUnits(ownerAfter)} WND'));
  print(field('received', '${formatUnits(destAfter - destBefore)} WND'));
}