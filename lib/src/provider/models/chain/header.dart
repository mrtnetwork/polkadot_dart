import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';

import 'digest.dart';

class SubstrateHeaderResponse {
  final String parentHash;
  final int number;
  final String stateRoot;
  final String extrinsicsRoot;
  final DigestResponse? digest;
  const SubstrateHeaderResponse(
      {required this.parentHash,
      required this.number,
      required this.stateRoot,
      required this.extrinsicsRoot,
      required this.digest});
  factory SubstrateHeaderResponse.fromJson(Map<String, dynamic> json) {
    return SubstrateHeaderResponse(
        parentHash: json.valueAs("parentHash"),
        number: json.valueAsInt("number"),
        stateRoot: json.valueAs("stateRoot"),
        extrinsicsRoot: json.valueAs("extrinsicsRoot"),
        digest: json.valueTo<DigestResponse?, Map<String, dynamic>>(
            key: "digest", parse: (e) => DigestResponse.fromJson(e)));
  }

  Map<String, dynamic> toJson() {
    return {
      "parentHash": parentHash,
      "number": number,
      "stateRoot": stateRoot,
      "extrinsicsRoot": extrinsicsRoot,
      "digest": digest?.toJson()
    };
  }

  MortalEra toMortalEra({int period = SubstrateConstant.defaultMortalLength}) {
    return MortalEra.fromBlockNumber(blockNumber: number, period: period);
  }
}
