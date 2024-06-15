import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class SyncStateResponse with JsonSerialization {
  final int startingBlock;
  final int currentBlock;
  final int? highestBlock;
  const SyncStateResponse(
      {required this.startingBlock,
      required this.currentBlock,
      required this.highestBlock});
  factory SyncStateResponse.fromJson(Map<String, dynamic> json) {
    return SyncStateResponse(
      startingBlock: IntUtils.parse(json["startingBlock"]),
      currentBlock: IntUtils.parse(json["currentBlock"]),
      highestBlock: IntUtils.tryParse(json["highestBlock"]),
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      "startingBlock": startingBlock,
      "currentBlock": currentBlock,
      "highestBlock": highestBlock
    };
  }
}
