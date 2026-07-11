import 'package:blockchain_utils/networks/types/network.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:test/test.dart';

void main() {
  test('encodable provider params', () {
    final param = SubstrateRequestGrandpaProveFinality(2);
    final request = param.buildRequest(0);
    final deserialize = SubstrateRequestDetails.deserialize(
      bytes: request.toCbor().encode(),
    );
    expect(deserialize.encodeBody(), request.encodeBody());
    expect(deserialize.successStatusCodes, request.successStatusCodes);
    expect(deserialize.errorStatusCodes, request.errorStatusCodes);
    expect(deserialize.network, BlockchainNetwork.substrateAndRelated);
    expect(deserialize.responseEncoding, request.responseEncoding);
    expect(deserialize.requestMethod, request.requestMethod);
  });
}
