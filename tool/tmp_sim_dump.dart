// ignore_for_file: avoid_print
// Full dry-run simulation dump: USDT hub -> Astar.
import 'dart:async';
import 'dart:io';
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

Future<void> main() async {
  SubstrateNetworkControllerParams mk(int p) =>
      SubstrateNetworkApiDefaultParams(
        (n) async =>
            SubstrateProvider(HttpSubstrateService('http://localhost:$p')),
      );
  const origin = PolkadotNetwork.polkadotAssetHub;
  const destNet = PolkadotNetwork.astar;
  final hub = SubstrateNetworkControllerFinder.buildApi(
    network: origin,
    params: mk(8021),
  );
  final astar = SubstrateNetworkControllerFinder.buildApi(
    network: destNet,
    params: mk(8010),
  );
  final relay = SubstrateNetworkControllerFinder.buildApi(
    network: PolkadotNetwork.polkadot,
    params: mk(8023),
  );
  final owner = SubstrateAddress(
    '13qNZSBNnmcwELq1JsYq5QjUpMukJHVgiZJi56eZHKTLEUuG',
  );
  final destAddr = owner.toSS58(destNet.ss58);
  final hubAccts = await hub
      .getAccountAssets(address: owner)
      .timeout(const Duration(seconds: 420));
  final usdt = hubAccts.balances.firstWhere(
    (b) => '${b.asset.identifier}' == '1984',
  );
  final p = SubstrateXCMTransferParams(
    assets: [
      SubstrateXCMTransferAsset(
        amount: BigInt.from(1000000),
        asset: usdt.asset,
      ),
    ],
    destinationNetwork: destNet,
    destinationAddress: destAddr,
    feeIndex: 0,
    origin: origin,
  );
  final enc = await hub.xcmTransfer(params: p);
  try {
    final sim = await hub.dryRunXcmTransfer(
      owner: owner,
      encodedParams: enc,
      creationParams: p,
      onRequestController:
          (n) async => switch (n) {
            PolkadotNetwork.polkadotAssetHub => hub,
            PolkadotNetwork.astar => astar,
            PolkadotNetwork.polkadot => relay,
            _ => SubstrateNetworkControllerFinder.buildApi(
              network: n,
              params: mk(8021),
            ),
          },
    );
    print('local dry success=${sim?.dryRun.success} err=${sim?.dryRun}');
    for (final l in sim?.localDeliveryFees ?? []) {
      print(
        'localFee result=${l.result} amounts=${l.amounts.map((a) => '${a.asset?.symbol}:${a.amount}').toList()}',
      );
    }
    for (final x in sim?.externalXcm ?? []) {
      print(
        'ext net=${x.network?.networkName} xcmDry=${x.xcmDryRun} weightToFee=${x.weightToFee}',
      );
      for (final d in x.deliveriesFee) {
        print(
          '  deliv amounts=${d.amounts.map((a) => '${a.asset?.symbol}:${a.amount}').toList()} result=${d.result}',
        );
      }
    }
  } catch (e) {
    print('SIM THREW: ${'$e'.split('\n').take(5).join(' | ')}');
  }
  print('DONE');
  exit(0);
}
