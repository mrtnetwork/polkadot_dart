/// 2-of-3 multisig against a local Chopsticks fork of Westend Asset Hub.
///
/// A multisig address is derived from three signers. Any two of them must
/// approve before funds can leave it. This example opens the multisig with the
/// first approval, then completes it with the second — which dispatches the
/// inner transfer. Run a fork first (see README.md):
///   chopsticks -c ./chopsticks.yml
/// then:
///   dart run lib/examples/polkadot/multisig.dart
library;

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'node.dart';

Future<void> main() async {
  print('Polkadot — 2-of-3 multisig (Westend Asset Hub fork)');
  print(field('rpc', polkadotRpcUrl));
  print(field('network', polkadotNetwork.networkName));

  final provider = SubstrateProvider(PolkadotHttpService());
  final meta = await loadMetadata(provider);

  // Three signers; any two must approve a spend from the multisig.
  final signers = [polkadotAccount(0), polkadotAccount(1), polkadotAccount(2)];
  final signerAddrs =
      signers.map((e) => e.toAddress(ss58Format: polkadotSs58)).toList();
  const threshold = 2;
  final multisig = BaseSubstrateAddress.createMultiSigAddress(
    addresses: signerAddrs,
    threshold: threshold,
    ss58Format: polkadotSs58,
  );
  final recipient = polkadotAddress(3);

  print(field('signers', ''));
  for (var i = 0; i < signerAddrs.length; i++) {
    print('    $i ${signerAddrs[i].address}');
  }
  print(field('multisig', multisig.address));
  print(field('recipient', recipient.address));

  // Fund the signers (fees + deposits) and the multisig (so it can spend).
  for (final signer in signerAddrs) {
    await ensureFunded(meta, signer, minimum: oneUnit * BigInt.from(100));
  }
  await ensureFunded(meta, multisig, minimum: oneUnit * BigInt.from(1000));

  // The call the multisig will execute: transfer funds to the recipient.
  final inner = BalancesCallPalletTransferKeepAlive(
    dest: recipient,
    amount: transferAmount,
  );
  final innerBytes = inner.encodeCall(extrinsic: meta.metadata);
  final callHash = QuickCrypto.blake2b256Hash(innerBytes);
  final innerCall = SubstrateEncodedCallParams(
    pallet: inner.pallet.name,
    method: inner.type.method,
    bytes: innerBytes,
  );

  // max_weight must cover the inner call's execution weight.
  final dry = await SubstrateTransactionBuilder.dryRunTransaction(
    owner: multisig,
    calls: SubstrateTransactionSubmitableParams(calls: [innerCall]),
    provider: meta,
  );
  final maxWeight = dry.queryFeeInfo.weight;

  final recipientBefore = await freeBalance(meta, recipient);
  print(field('recipient before', '${formatUnits(recipientBefore)} WND'));

  // 1. First approval (signer 0): opens the multisig, stores the proposal.
  final first = MultisigCallPalletAsMulti(
    threshold: threshold,
    otherSignatories: SubstrateAddressUtils.otherSignatories(
      addresses: signerAddrs,
      signer: signerAddrs[0],
    ),
    call: innerBytes,
    maxWeight: maxWeight,
  );
  final firstResult = await send(
    meta,
    owner: signerAddrs[0],
    signer: signers[0],
    call: SubstrateEncodedCallParams(
      pallet: first.pallet.name,
      method: first.type.method,
      bytes: first.encodeCall(extrinsic: meta.metadata),
    ),
  );
  if (firstResult == null) {
    print('first approval failed');
    return;
  }
  print(field('approval 1', 'block ${firstResult.blockNumber}'));

  // Read the pending multisig (approvals + timepoint) from storage.
  final pending = await SubstrateQuickStorageApi.multisig.multisigs(
    address: multisig,
    callHashTx: callHash,
    api: meta.metadata.api,
    rpc: meta.provider,
  );
  print(field('pending approvals', '${pending?.approvals.length ?? 0}'));

  // 2. Second approval (signer 1): reaches the threshold and dispatches.
  final second = MultisigCallPalletAsMulti(
    threshold: threshold,
    otherSignatories: SubstrateAddressUtils.otherSignatories(
      addresses: signerAddrs,
      signer: signerAddrs[1],
    ),
    maybeTimepoint: pending?.when,
    call: innerBytes,
    maxWeight: maxWeight,
  );
  final secondResult = await send(
    meta,
    owner: signerAddrs[1],
    signer: signers[1],
    call: SubstrateEncodedCallParams(
      pallet: second.pallet.name,
      method: second.type.method,
      bytes: second.encodeCall(extrinsic: meta.metadata),
    ),
  );
  if (secondResult == null) {
    print('second approval failed');
    return;
  }
  print(field('approval 2', 'block ${secondResult.blockNumber}'));

  final recipientAfter = await freeBalance(meta, recipient);
  print(field('recipient after', '${formatUnits(recipientAfter)} WND'));
  print(field(
      'received', '${formatUnits(recipientAfter - recipientBefore)} WND'));
}
