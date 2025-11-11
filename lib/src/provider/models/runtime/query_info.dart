import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/models/generic/models/weight.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum QueryFeeInfoClass {
  normal("Normal"),
  operational("Operational"),
  mandatory("Mandatory");

  final String variant;
  const QueryFeeInfoClass(this.variant);

  static QueryFeeInfoClass? fromJson(Map<String, dynamic>? json) {
    return values
        .firstWhereNullable((e) => e.variant == json?.keys.firstOrNull);
  }
}

class QueryFeeInfo extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateWeightV2 weight;
  final QueryFeeInfoClass? className;

  /// maybe not exist in some networks
  final BigInt partialFee;
  const QueryFeeInfo(
      {required this.weight,
      required this.className,
      required this.partialFee});
  factory QueryFeeInfo.deserialize(List<int> bytes) {
    final toJson =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return QueryFeeInfo.deserializeJson(toJson.value);
  }
  factory QueryFeeInfo.deserializeJson(Map<String, dynamic> json) {
    return QueryFeeInfo(
        weight: SubstrateWeightV2.deserializeJson(json["weight"]),
        className: QueryFeeInfoClass.fromJson(json["class"]),
        partialFee: BigintUtils.parse(json["partial_fee"]));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      SubstrateWeightV2.layout_(property: "weight"),
      LayoutConst.rustEnum(
          QueryFeeInfoClass.values
              .map((e) => LayoutConst.none(property: e.name))
              .toList(),
          property: "class"),
      LayoutConst.u128(property: "partial_fee")
    ]);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "weight": weight.serializeJson(),
      "class": {className?.variant: null},
      "partial_fee": partialFee
    };
  }
}
