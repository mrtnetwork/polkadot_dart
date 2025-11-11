// ignore_for_file: unused_local_variable

import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'json_rpc_example.dart';
import 'repository/westend_v15.dart';

void main() async {
  /// Setting up the provider to connect to the Substrate node.
  final provider = SubstrateProvider(
      SubstrateHttpService("https://westend-rpc.polkadot.io"));

  /// Parsing the metadata and initializing the Metadata API.
  final metadata = VersionedMetadata<MetadataV14>.fromBytes(
          BytesUtils.fromHexString(westendV14))
      .metadata;
  final api = MetadataApi(metadata);

  /// Defining Substrate addresses for testing.
  final addr =
      SubstrateAddress("5EepAwmzpwn2PK45i3og3emvXs4NFnqzHu4T2VbUGhvkU4yB");
  final addr2 =
      SubstrateAddress("5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43");

  /// Retrieving input and output templates for cheking.
  final template = api.getStorageInputTemplate("System", "account");
  final output = api.getStorageOutputTemplate("System", "account");

  /// Querying single account information.
  final accountInfoSingleResult = await api.getStorageRequest(
      request: GetStorageRequest<Map<String, dynamic>?, Map<String, dynamic>>(
        palletNameOrIndex: "System",
        methodName: "account",
        inputs: addr.toBytes(),
      ),
      rpc: provider,
      fromTemplate: false);

  /// Constructing storage query requests for multiple accounts.
  final rAccOne = GetStorageRequest<Map<String, dynamic>, Map<String, dynamic>>(
    palletNameOrIndex: "System",
    methodName: "account",
    inputs: addr.toBytes(),
  );
  final rAccTwo = GetStorageRequest<Map<String, dynamic>, Map<String, dynamic>>(
    palletNameOrIndex: "System",
    methodName: "account",
    inputs: addr2.toBytes(),
  );

  /// Querying storage for multiple accounts.
  final accountInfoMultipleResult = await api.queryStorageAtBlock(
      requestes: [rAccOne, rAccTwo], rpc: provider, fromTemplate: false);
  final account1Info = accountInfoMultipleResult.getResultAt(1);

  /// Querying storage in a specific block range.
  final queryRange = await api.queryStorageFromBlock(
      requestes: [rAccOne, rAccTwo],
      rpc: provider,
      fromBlock:
          "0x316ed44e1bb758de18a0307eac10cfaedf9d4eef1f7a383fb7ba1bd9270d3938",
      toBlock:
          "0x9afc2fbf7a31dc2f0adeedad895966c6dd6015e0dc540cf2b93c2e54fbf5afa7",
      fromTemplate: false);

  /// Iterating through query results within the specified block range.
  for (int i = 0; i < queryRange.length; i++) {
    final blockResponse = queryRange[i];
    final results = blockResponse.getResultAt(1);
  }
}
