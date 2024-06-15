import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/extrinsic/layouts/v4.dart';
import 'package:polkadot_dart/src/models/generic/models/block_hash.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class TransactionPayload extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateBlockHash blockHash;
  final SubstrateBaseEra era;
  final SubstrateBlockHash genesisHash;
  final List<int> method;
  final BigInt? tip;
  final int nonce;
  final int specVersion;
  final int transactionVersion;
  TransactionPayload(
      {required this.blockHash,
      required this.era,
      required this.genesisHash,
      required List<int> method,
      required this.nonce,
      required this.specVersion,
      required this.transactionVersion,
      this.tip})
      : method = BytesUtils.toBytes(method, unmodifiable: true);

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.payloadV4(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "method": method,
      "era": era.scaleJsonSerialize(),
      "nonce": nonce,
      "tip": tip ?? BigInt.zero,
      "specVersion": specVersion,
      "transactionVersion": transactionVersion,
      "genesisHash": genesisHash.scaleJsonSerialize(),
      "blockHash": blockHash.scaleJsonSerialize()
    };
  }
}
