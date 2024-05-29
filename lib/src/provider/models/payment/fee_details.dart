import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'includs_fee.dart';

class FeeDetails with JsonSerialization {
  final InclusionFee? inclusionFee;
  const FeeDetails({this.inclusionFee});
  factory FeeDetails.fromJson(Map<String, dynamic> json) {
    return FeeDetails(
        inclusionFee: json["inclusionFee"] == null
            ? null
            : InclusionFee.fromJson(json["inclusionFee"]));
  }

  @override
  Map<String, dynamic> toJson() {
    return {"inclusionFee": inclusionFee?.toJson()};
  }
}
