// ignore_for_file: unused_local_variable

import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'json_rpc_example.dart';
import 'repository/westend_v14.dart';

void main() async {
  /// Setting up the provider to connect to the Westend Substrate node.
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));

  /// Parsing the metadata and initializing the Metadata API.
  final metadata = VersionedMetadata<MetadataV15>.fromBytes(
      BytesUtils.fromHexString(westendV15));
  final api = MetadataApi(metadata.metadata);

  /// Retrieving runtime metadata at version 15.
  final version = await api.runtimeCall(
      apiName: "Metadata",
      methodName: "metadata_at_version",
      params: [15],
      rpc: provider,
      fromTemplate: false);

  /// Defining a Substrate address for account operations.
  final addr =
      SubstrateAddress("5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43");

  /// Retrieving the account nonce for the specified address.
  final accountNonce = await api.runtimeCall(
      apiName: "AccountNonceApi",
      methodName: "account_nonce",
      params: [
        {"type": "[U8;32]", "value": addr.toBytes()}
      ],
      rpc: provider,
      fromTemplate: true);
}
