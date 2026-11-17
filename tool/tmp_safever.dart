// ignore_for_file: avoid_print
// Read SafeXcmVersion on hub + astar forks.
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
      timeout ?? const Duration(seconds: 120),
    );
    final bytes = await resp.fold<List<int>>([], (p, e) => p..addAll(e));
    return params.toResponse(bytes, statusCode: resp.statusCode);
  }
}

Future<void> main() async {
  for (final e in [
    (PolkadotNetwork.polkadotAssetHub, 8021),
    (PolkadotNetwork.astar, 8010),
  ]) {
    final network = e.$1;
    final port = e.$2;
    final params = SubstrateNetworkApiDefaultParams(
      (n) async =>
          SubstrateProvider(HttpSubstrateService('http://localhost:$port')),
    );
    try {
      final p = await params.loadMetadata(network);
      final v = await SubstrateQuickStorageApi.polkadotXCM.safeXCMVersion(
        api: p.metadata.api,
        rpc: p.provider,
      );
      print(
        '${network.networkName}: safeXcmVersion=$v defaultXcm=${network.defaultXcmVersion}',
      );
    } catch (err) {
      print('${network.networkName}: FAIL ${'$err'.split('\n').first}');
    }
  }
  exit(0);
}
