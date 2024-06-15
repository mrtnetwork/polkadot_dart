import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';

import 'digest.dart';

class SubstrateHeaderResponse {
  final String parentHash;
  final int number;
  final String stateRoot;
  final String extrinsicsRoot;
  final DigestResponse digest;
  const SubstrateHeaderResponse(
      {required this.parentHash,
      required this.number,
      required this.stateRoot,
      required this.extrinsicsRoot,
      required this.digest});
  factory SubstrateHeaderResponse.fromJson(Map<String, dynamic> json) {
    return SubstrateHeaderResponse(
        parentHash: json["parentHash"],
        number: IntUtils.parse(json["number"]),
        stateRoot: json["stateRoot"],
        extrinsicsRoot: json["extrinsicsRoot"],
        digest: DigestResponse.fromJson(json["digest"] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {
      "parentHash": parentHash,
      "number": number,
      "stateRoot": stateRoot,
      "extrinsicsRoot": extrinsicsRoot,
      "digest": digest
    };
  }

  MortalEra toMortalEra({int period = SubstrateConstant.defaultMortalLength}) {
    return MortalEra.fromBlockNumber(blockNumber: number, period: period);
  }
}
