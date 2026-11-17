// ignore_for_file: avoid_print
// Generic XCM-in: hub asset by id -> chain. Usage: <networkName> <port> <hubPort> <relayPort> <assetId|'DOT'>
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

Future<void> main(List<String> args) async {
  final want = args[0].toLowerCase();
  final port = int.parse(args[1]);
  final hubPort = int.parse(args[2]);
  final relayPort = int.parse(args[3]);
  final assetSel = args[4];
  final network = BaseSubstrateNetwork.values.firstWhere(
    (e) => e.networkName.toLowerCase() == want,
  );
  SubstrateNetworkControllerParams mk(int p) =>
      SubstrateNetworkApiDefaultParams(
        (n) async => SubstrateProvider(HttpSubstrateService('http://localhost:$p')),
      );
  final t = SubstrateNetworkControllerFinder.buildApi(network: network, params: mk(port));
  final hub = SubstrateNetworkControllerFinder.buildApi(network: network.assetHub, params: mk(hubPort));
  final relay = SubstrateNetworkControllerFinder.buildApi(network: network.relayChain, params: mk(relayPort));
  final hubA0 = _key(network.assetHub, 0).toAddress() as SubstrateAddress;
  final a0 = (_key(network, 0).toAddress() as SubstrateAddress).toSS58(network.ss58);

  final hubAccts = await hub.getAccountAssets(address: hubA0).timeout(
    const Duration(seconds: 420),
  );
  final chainAssets = await t.getAssets().timeout(const Duration(seconds: 420));
  final shared = hubAccts.findShareAssets(chainAssets);
  print('shared=${shared.length}');
  BaseSubstrateNetworkAsset? sel;
  for (final s in shared) {
    final id = '${s.origin.identifier}';
    if (assetSel == 'DOT') {
      if (s.origin.symbol == 'DOT' && s.origin.decimals == 10) sel = s.origin;
    } else if (id == assetSel) {
      sel = s.origin;
    }
  }
  if (sel == null) {
    print('SKIP asset $assetSel not shared');
    exit(0);
  }
  var can = await hub.filterReceiveAssets(
    assets: shared.map((e) => e.origin).toList(),
    origin: network.assetHub,
  );
  can = await t.filterReceiveAssets(assets: can, origin: network.assetHub);
  print('transferable=${can.length} sel-allowed=${can.any((e) => e == sel)}');
  if (!can.any((e) => e == sel)) {
    print('SKIP filtered out');
    exit(0);
  }
  final amt = BigInt.from(10).pow(sel.decimals ?? 6);
  final p = SubstrateXCMTransferParams(
    assets: [SubstrateXCMTransferAsset(amount: amt, asset: sel)],
    destinationNetwork: network,
    destinationAddress: a0,
    feeIndex: 0,
    origin: network.assetHub,
  );
  final enc = await hub.xcmTransfer(params: p);
  final sim = await hub.dryRunXcmTransfer(
    owner: hubA0,
    encodedParams: enc,
    creationParams: p,
    onRequestController: (n) async => switch (n) {
      _ when n == network.assetHub => hub,
      _ when n == network => t,
      _ when n == network.relayChain => relay,
      _ => SubstrateNetworkControllerFinder.buildApi(network: n, params: mk(hubPort)),
    },
  );
  print('dry=${sim?.dryRun.success}');
  await (await hub.submitXCMTransaction(
    owner: hubA0,
    params: enc,
    destinationChainController: t,
    signer: _key(network.assetHub, 0),
    onTransactionSubmited: (id, b) => print('tx $id@$b'),
    onDestinationChainEvent: (e) => print(
      'dest ${e.status} ${e.deposits.map((d) => d.toJson()).toList()}',
    ),
  )).toList();
  final chainAccts = await t.getAccountAssets(address: a0).timeout(
    const Duration(seconds: 420),
  );
  for (final b in chainAccts.balances) {
    if ('${b.asset.identifier}' == assetSel || (assetSel == 'DOT' && b.asset.symbol == 'DOT')) {
      print('arrived ${b.asset.symbol} id=${b.asset.identifier} free=${b.free}');
    }
  }
  print('DONE');
  exit(0);
}
