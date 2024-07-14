import 'package:blockchain_utils/layout/layout.dart';

class RPCRuntimeLayouts {
  static StructLayout feeDetails({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u128(property: "baseFee"),
      LayoutConst.u128(property: "lenFee"),
      LayoutConst.u128(property: "adjustedWeightFee"),
    ], property: property);
  }

  static StructLayout queryFeeInfo({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(feeDetails(), property: "inclusionFee"),
    ], property: property);
  }
}
