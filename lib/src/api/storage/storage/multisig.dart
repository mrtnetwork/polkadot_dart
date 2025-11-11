import 'package:polkadot_dart/src/substrate.dart';

enum SubstrateStorageMultisigMethods {
  multisigs("Multisigs");

  final String method;
  const SubstrateStorageMultisigMethods(this.method);
}

/// safexcmversion
class SubstrateStorageMultisig extends SubstrateStorageApi {
  const SubstrateStorageMultisig();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.multisig;
  Future<SubstrateMultisig?> multisigs(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address,
      required List<int> callHashTx}) async {
    return await api.getStorageRequest(
        request: GetStorageRequest<SubstrateMultisig?, Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageMultisigMethods.multisigs.name,
            inputs: [address.toBytes(), callHashTx],
            onJsonResponse: (response, responseBytes, storageKey) {
              return SubstrateMultisig.fromJson(response);
            }),
        rpc: rpc);
  }

  Future<List<SubstrateMultisigWithCallhash>> multisigsEntires(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address}) async {
    final entires = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<SubstrateMultisigWithCallhash?,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageMultisigMethods.multisigs.name,
            inputs: [address.toBytes()],
            onJsonResponse: (response, responseBytes, storageKey) {
              return SubstrateMultisigWithCallhash(
                  multisig: SubstrateMultisig.fromJson(response),
                  callHash: storageKey.encodedInput(1));
            }),
        rpc: rpc);
    final all = await entires.toList();
    return all
        .expand((e) => e.results)
        .map((e) => e.result)
        .whereType<SubstrateMultisigWithCallhash>()
        .toList();
  }
}
