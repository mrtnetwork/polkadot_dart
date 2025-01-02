// ignore_for_file: unused_local_variable
import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateHttpService with SubstrateServiceProvider {
  SubstrateHttpService(this.url,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  final String url;
  final Client client;
  final Duration defaultTimeOut;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SubstrateRequestDetails params,
      {Duration? timeout}) async {
    final response = await client
        .post(params.toUri(url), headers: params.headers, body: params.body())
        .timeout(timeout ?? defaultTimeOut);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}

void main() async {
  final provider = SubstrateProvider(
      SubstrateHttpService("https://westend-rpc.polkadot.io"));

  final genesisHash = await provider
      .request(const SubstrateRequestChainGetBlockHash(number: 0));
  final blockHash = await provider
      .request(const SubstrateRequestChainChainGetFinalizedHead());
  final blockHeader = await provider
      .request(SubstrateRequestChainChainGetHeader(atBlockHash: blockHash));
}
