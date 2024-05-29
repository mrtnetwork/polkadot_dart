// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:http/http.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateHttpService with SubstrateRPCService {
  SubstrateHttpService(this.url,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  @override
  final String url;
  final Client client;
  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(SubstrateRequestDetails params,
      [Duration? timeout]) async {
    final response = await client
        .post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: params.toRequestBody())
        .timeout(timeout ?? defaultTimeOut);
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data;
  }
}

void main() async {
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  final genesisHash =
      await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));
  final blockHash =
      await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));
}
