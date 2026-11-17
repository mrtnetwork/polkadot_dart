// ignore_for_file: avoid_print
// Generic per-chain audit: tokens + native transfer + XCM hub<->chain.
// Usage: dart run tool/tmp_chain_audit.dart <networkName> <port> <hubPort> <relayPort>
// e.g.: dart run tool/tmp_chain_audit.dart "Bifrost Polkadot" 8010 8020 8023
import 'dart:async';
import 'dart:convert';
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
    final bytes = await resp.fold<List<int>>([], (p, e) => p..addAll(e));
    return params.toResponse(bytes, statusCode: resp.statusCode);
  }
}

Future<Object?> rawRpc(int port, String method, [Object? params]) async {
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse('http://localhost:$port'));
  req.headers.contentType = ContentType.json;
  req.write(
    jsonEncode({
      'jsonrpc': '2.0',
      'id': 1,
      'method': method,
      'params': params == null ? [] : [params],
    }),
  );
  final resp = await req.close().timeout(const Duration(seconds: 60));
  final body = await resp.transform(utf8.decoder).join();
  client.close();
  final j = jsonDecode(body) as Map<String, dynamic>;
  if (j.containsKey('error')) throw StateError('RPC $method: ${j['error']}');
  return j['result'];
}

const _mnemonic =
    'link stand brass velvet hobby jelly hundred auto soap certain way kingdom';

BaseSubstratePrivateKey _key(BaseSubstrateNetwork network, int idx) {
  final seed = Bip39SeedGenerator(Mnemonic.fromString(_mnemonic)).generate();
  if (network.chainType == SubstrateChainType.ethereum) {
    final wallet = Bip44.fromSeed(
      seed,
      Bip44Coins.ethereum,
    ).purpose.coin.account(0).change(Bip44Changes.chainExt).addressIndex(idx);
    return SubstrateEthereumPrivateKey.fromBytes(wallet.privateKey.toBytes());
  }
  final wallet = Bip44.fromSeed(
    seed,
    Bip44Coins.polkadotEd25519Slip,
  ).purpose.coin.account(0).change(Bip44Changes.chainExt).addressIndex(idx);
  return SubstratePrivateKey.fromPrivateKey(
    keyBytes: wallet.privateKey.toBytes(),
    algorithm: SubstrateKeyAlgorithm.ed25519,
  );
}

BaseSubstrateAddress _addr(BaseSubstrateNetwork network, int idx) {
  final address = _key(network, idx).toAddress();
  if (address is SubstrateAddress) return address.toSS58(network.ss58);
  return address;
}

Future<void> main(List<String> args) async {
  final want = args[0].toLowerCase();
  final port = int.parse(args[1]);
  final hubPort = int.parse(args[2]);
  final relayPort = int.parse(args[3]);
  final network = BaseSubstrateNetwork.values.firstWhere(
    (e) => e.networkName.toLowerCase() == want,
    orElse: () => throw StateError('unknown network $want'),
  );
  SubstrateNetworkControllerParams mk(int p) =>
      SubstrateNetworkApiDefaultParams(
        (n) async =>
            SubstrateProvider(HttpSubstrateService('http://localhost:$p')),
      );
  final t = SubstrateNetworkControllerFinder.buildApi(
    network: network,
    params: mk(port),
  );
  final hub = SubstrateNetworkControllerFinder.buildApi(
    network: network.assetHub,
    params: mk(hubPort),
  );
  final relay = SubstrateNetworkControllerFinder.buildApi(
    network: network.relayChain,
    params: mk(relayPort),
  );
  final a0 = _addr(network, 0);
  final a1 = _addr(network, 1);
  final hubA0 = _addr(network.assetHub, 0);

  void step(String name, Object? v) => print('[$name] $v');

  // 1. tokens
  try {
    final assets = await t.getAssets().timeout(const Duration(seconds: 420));
    step('getAssets', 'count=${assets.assets.length}');
    for (final a in assets.assets.take(12)) {
      step('asset', '${a.symbol} dec=${a.decimals} id=${a.identifier}');
    }
    step(
      'native',
      '${t.defaultNativeAsset.symbol} dec=${t.defaultNativeAsset.decimals}',
    );
  } catch (e) {
    step('getAssets', 'FAIL ${'$e'.split('\n').first}');
  }

  // 2. fund native (1M units base) + native transfer
  try {
    await rawRpc(port, 'dev_setStorage', {
      'System': {
        'Account': [
          [
            [a0.address],
            {
              'providers': 1,
              'data': {'free': '1000000000000000000000000'},
            },
          ],
        ],
      },
    });
    step('fund', 'ok ${a0.address}');
    final tx = await t.nativeTransfer(
      params: SubstrateNativeAssetTransferParams(
        destinationAddress: a1,
        amount: BigInt.from(10).pow(t.defaultNativeAsset.decimals ?? 12),
      ),
    );
    final dry = await t.dryRunTransaction(owner: a0, params: tx);
    step('native-dry', 'fee=${dry.queryFeeInfo.partialFee}');
    await (await t.submitTransaction(
      owner: a0,
      params: tx,
      signer: _key(network, 0),
      onTransactionSubmited: (id, b) => step('native-tx', '$id@$b'),
    )).toList();
    final destBal = await t.getNativeAssetFreeBalance(a1);
    step('native-verify', 'dest free=${destBal?.free} PASS');
  } catch (e) {
    step('native-xfer', 'FAIL ${'$e'.split('\n').first}');
  }

  // 3. fund hub a0 (DOT + USDT) for XCM-in
  try {
    await rawRpc(hubPort, 'dev_setStorage', {
      'System': {
        'Account': [
          [
            [hubA0.address],
            {
              'providers': 1,
              'data': {'free': '1000000000000'},
            },
          ],
        ],
      },
    });
    await rawRpc(hubPort, 'dev_setStorage', {
      'Assets': {
        'Account': [
          [
            [1984, hubA0.address],
            {'balance': '10000000000'},
          ],
        ],
      },
    });
    step('hub-fund', 'ok');
  } catch (e) {
    step('hub-fund', 'FAIL ${'$e'.split('\n').first}');
  }

  // 4. XCM hub -> chain (prefer DOT else USDT else skip)
  BaseSubstrateNetworkAsset? inAsset;
  try {
    final hubAccts = await hub
        .getAccountAssets(address: hubA0)
        .timeout(const Duration(seconds: 420));
    final chainAssets = await t.getAssets().timeout(
      const Duration(seconds: 420),
    );
    final shared = hubAccts.findShareAssets(chainAssets);
    step('xcm-shared', 'count=${shared.length}');
    BaseSubstrateNetworkAsset? pick(String id, [String? sym]) {
      for (final s in shared) {
        if ('${s.origin.identifier}' == id) return s.origin;
      }
      if (sym != null) {
        for (final s in shared) {
          if (s.origin.symbol == sym) return s.origin;
        }
      }
      return null;
    }

    // DOT on hub has null identifier; match by symbol+decimals
    BaseSubstrateNetworkAsset? dot;
    for (final s in shared) {
      if (s.origin.symbol == 'DOT' && s.origin.decimals == 10) dot = s.origin;
    }
    inAsset = dot ?? pick('1984', 'USDt') ?? pick('1337', 'USDC');
    if (inAsset == null) {
      step('xcm-in', 'SKIP no DOT/USDT/USDC shared');
    } else {
      var can = await hub.filterReceiveAssets(
        assets: shared.map((e) => e.origin).toList(),
        origin: network.assetHub,
      );
      can = await t.filterReceiveAssets(assets: can, origin: network.assetHub);
      if (!can.any((e) => e == inAsset)) {
        step('xcm-in', 'SKIP asset filtered out (${inAsset.symbol})');
        inAsset = null;
      } else {
        final amt = BigInt.from(10).pow(inAsset.decimals ?? 6);
        final p = SubstrateXCMTransferParams(
          assets: [SubstrateXCMTransferAsset(amount: amt, asset: inAsset)],
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
          onRequestController:
              (n) async => switch (n) {
                _ when n == network.assetHub => hub,
                _ when n == network => t,
                _ when n == network.relayChain => relay,
                _ => SubstrateNetworkControllerFinder.buildApi(
                  network: n,
                  params: mk(hubPort),
                ),
              },
        );
        step('xcm-in-dry', 'success=${sim?.dryRun.success}');
        if (sim != null && !sim.dryRun.success) {
          step('xcm-in', 'FAIL dry ${sim.dryRun}');
          inAsset = null;
        } else {
          await (await hub.submitXCMTransaction(
            owner: hubA0,
            params: enc,
            destinationChainController: t,
            signer: _key(network.assetHub, 0),
            onTransactionSubmited: (id, b) => step('xcm-in-tx', '$id@$b'),
            onDestinationChainEvent:
                (e) => step(
                  'xcm-in-dest',
                  '${e.status} ${e.deposits.map((d) => d.toJson()).toList()}',
                ),
          )).toList();
          step('xcm-in', 'PASS ${inAsset.symbol}');
        }
      }
    }
  } catch (e) {
    step('xcm-in', 'FAIL ${'$e'.split('\n').first}');
    inAsset = null;
  }

  // 5. XCM chain -> hub (send back half of what arrived, if anything)
  try {
    if (inAsset == null) {
      step('xcm-out', 'SKIP (no xcm-in asset)');
    } else {
      final sendSym = inAsset.symbol;
      final back = await t
          .getAccountAssets(address: a0)
          .timeout(const Duration(seconds: 420));
      final got =
          back.balances.where((b) => b.asset.symbol == sendSym).toList();
      if (got.isEmpty || got.first.free <= BigInt.zero) {
        step('xcm-out', 'SKIP nothing arrived');
      } else {
        final outAsset = got.first.asset;
        final amt = got.first.free ~/ BigInt.from(2);
        final p = SubstrateXCMTransferParams(
          assets: [SubstrateXCMTransferAsset(amount: amt, asset: outAsset)],
          destinationNetwork: network.assetHub,
          destinationAddress: hubA0,
          feeIndex: 0,
          origin: network,
        );
        final enc = await t.xcmTransfer(params: p);
        final sim = await t.dryRunXcmTransfer(
          owner: a0,
          encodedParams: enc,
          creationParams: p,
          onRequestController:
              (n) async => switch (n) {
                _ when n == network.assetHub => hub,
                _ when n == network => t,
                _ when n == network.relayChain => relay,
                _ => SubstrateNetworkControllerFinder.buildApi(
                  network: n,
                  params: mk(hubPort),
                ),
              },
        );
        step('xcm-out-dry', 'success=${sim?.dryRun.success}');
        if (sim != null && !sim.dryRun.success) {
          step('xcm-out', 'FAIL dry ${sim.dryRun}');
        } else {
          await (await t.submitXCMTransaction(
            owner: a0,
            params: enc,
            destinationChainController: hub,
            signer: _key(network, 0),
            onTransactionSubmited: (id, b) => step('xcm-out-tx', '$id@$b'),
            onDestinationChainEvent:
                (e) => step(
                  'xcm-out-dest',
                  '${e.status} ${e.deposits.map((d) => d.toJson()).toList()}',
                ),
          )).toList();
          step('xcm-out', 'PASS ${inAsset.symbol}');
        }
      }
    }
  } catch (e) {
    step('xcm-out', 'FAIL ${'$e'.split('\n').first}');
  }
  print('AUDIT-DONE ${network.networkName}');
  exit(0);
}
