// ignore_for_file: avoid_print
// Targeted: USDT hub -> Astar (vs DOT which errored on dest).
import 'dart:async';
import 'dart:io';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class HttpSubstrateService with SubstrateServiceProvider {
  HttpSubstrateService(this.url);
  final String url;
  final HttpClient _client = HttpClient();
  @override
  Future<SubstrateServiceResponse> doRequest(
    SubstrateRequestDetails params, {
    Duration? timeout,
  }) async {
    final req = await _client.postUrl(params.encodeUrl(url));
    params.headers.forEach((k, v) => req.headers.set(k, v));
    final body = params.encodeBody();
    if (body != null) req.add(body);
    final resp = await req.close().timeout(
      timeout ?? const Duration(seconds: 300),
    );
    final bytes = await resp.fold<List<int>>(
      [],
      (p, e) => p..addAll(e),
    );
    return params.toResponse(bytes, statusCode: resp.statusCode);
  }
}

BaseSubstratePrivateKey _key(BaseSubstrateNetwork n, int idx) {
  const m =
      'link stand brass velvet hobby jelly hundred auto soap certain way kingdom';
  final seed = Bip39SeedGenerator(Mnemonic.fromString(m)).generate();
  final w = Bip44.fromSeed(seed, Bip44Coins.polkadotEd25519Slip).purpose.coin
      .account(0)
      .change(Bip44Changes.chainExt)
      .addressIndex(idx);
  return SubstratePrivateKey.fromPrivateKey(
    keyBytes: w.privateKey.toBytes(),
    algorithm: SubstrateKeyAlgorithm.ed25519,
  );
}

Future<void> main() async {
  SubstrateNetworkControllerParams mk(int p) =>
      SubstrateNetworkApiDefaultParams(
        (n) async => SubstrateProvider(HttpSubstrateService('http://localhost:$p')),
      );
  const origin = PolkadotNetwork.polkadotAssetHub;
  const destNet = PolkadotNetwork.astar;
  final hub = SubstrateNetworkControllerFinder.buildApi(network: origin, params: mk(8021));
  final astar = SubstrateNetworkControllerFinder.buildApi(network: destNet, params: mk(8010));
  final relay = SubstrateNetworkControllerFinder.buildApi(
    network: PolkadotNetwork.polkadot,
    params: mk(8023),
  );
  final owner = SubstrateAddress('13qNZSBNnmcwELq1JsYq5QjUpMukJHVgiZJi56eZHKTLEUuG');
  final destAddr = SubstrateAddress('13qNZSBNnmcwELq1JsYq5QjUpMukJHVgiZJi56eZHKTLEUuG').toSS58(destNet.ss58);

  final hubAccts = await hub.getAccountAssets(address: owner).timeout(
    const Duration(seconds: 420),
  );
  final usdtBal = hubAccts.balances.firstWhere(
    (b) => '${b.asset.identifier}' == '1984',
  );
  print('usdt balance=${usdtBal.free}');
  final p = SubstrateXCMTransferParams(
    assets: [SubstrateXCMTransferAsset(amount: BigInt.from(1000000), asset: usdtBal.asset)],
    destinationNetwork: destNet,
    destinationAddress: destAddr,
    feeIndex: 0,
    origin: origin,
  );
  final enc = await hub.xcmTransfer(params: p);
  print('encoded');
  final sim = await hub.dryRunXcmTransfer(
    owner: owner,
    encodedParams: enc,
    creationParams: p,
    onRequestController: (n) async => switch (n) {
      PolkadotNetwork.polkadotAssetHub => hub,
      PolkadotNetwork.astar => astar,
      PolkadotNetwork.polkadot => relay,
      _ => SubstrateNetworkControllerFinder.buildApi(network: n, params: mk(8021)),
    },
  );
  print('dry success=${sim?.dryRun.success}');
  await (await hub.submitXCMTransaction(
    owner: owner,
    params: enc,
    destinationChainController: astar,
    signer: _key(origin, 0),
    onTransactionSubmited: (id, b) => print('tx $id@$b'),
    onDestinationChainEvent: (e) => print(
      'dest ${e.status} ${e.deposits.map((d) => d.toJson()).toList()}',
    ),
  )).toList();
  final aa = await astar.getAccountAssets(address: destAddr).timeout(
    const Duration(seconds: 420),
  );
  for (final b in aa.balances) {
    print('astar ${b.asset.symbol} id=${b.asset.identifier} free=${b.free}');
  }
  print('DONE');
  exit(0);
}
