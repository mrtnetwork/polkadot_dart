// ignore_for_file: avoid_print
// Dump recent Astar System.Events filtered to XCM/asset pallets.
import 'dart:async';
import 'dart:convert';
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

Future<dynamic> raw(int port, String method, [Object? p]) async {
  final c = HttpClient();
  final req = await c.postUrl(Uri.parse('http://localhost:$port'));
  req.headers.contentType = ContentType.json;
  req.write(
    jsonEncode({
      'jsonrpc': '2.0',
      'id': 1,
      'method': method,
      if (p != null && !(p is List && p.isEmpty)) 'params': p,
    }),
  );
  final r = await req.close().timeout(const Duration(seconds: 60));
  final b = await r.transform(utf8.decoder).join();
  c.close();
  return (jsonDecode(b) as Map)['result'];
}

Future<void> main() async {
  const network = PolkadotNetwork.astar;
  final params = SubstrateNetworkApiDefaultParams(
    (n) async =>
        SubstrateProvider(HttpSubstrateService('http://localhost:8010')),
  );
  final p = await params.loadMetadata(network);
  final head = await raw(8010, 'chain_getHead');
  print('head=$head');
  final headHdr = await raw(8010, 'chain_getHeader', []) as Map;
  final int headNum = int.parse(headHdr['number'] as String);
  const want = {
    'PolkadotXcm',
    'XcmpQueue',
    'Assets',
    'ForeignAssets',
    'Balances',
    'XcAssetConfig',
    'Ethereum',
  };
  for (int i = 0; i < 12; i++) {
    final hash = await raw(8010, 'chain_getBlockHash', headNum - i);
    try {
      final evs = await p.metadata.api.getSystemEvents(
        p.provider,
        atBlockHash: hash,
      );
      for (final e in evs) {
        if (want.contains(e.pallet)) {
          print(
            'blk~$i ${e.pallet}.${e.method} ${'${e.input}'.substring(0, '${e.input}'.length > 300 ? 300 : '${e.input}'.length)}',
          );
        }
      }
    } catch (err) {
      print('blk~$i err ${'$err'.split('\n').first}');
    }
  }
  print('DONE');
  exit(0);
}
