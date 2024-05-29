import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';

class PrimitiveTypes {
  final String name;
  const PrimitiveTypes._(this.name);
  static const PrimitiveTypes boolType = PrimitiveTypes._("Bool");
  static const PrimitiveTypes charType = PrimitiveTypes._("Char");
  static const PrimitiveTypes strType = PrimitiveTypes._("Str");
  static const PrimitiveTypes u8 = PrimitiveTypes._("U8");
  static const PrimitiveTypes u16 = PrimitiveTypes._("U16");
  static const PrimitiveTypes u32 = PrimitiveTypes._("U32");
  static const PrimitiveTypes u64 = PrimitiveTypes._("U64");
  static const PrimitiveTypes u128 = PrimitiveTypes._("U128");
  static const PrimitiveTypes u256 = PrimitiveTypes._("U256");
  static const PrimitiveTypes i8 = PrimitiveTypes._("I8");
  static const PrimitiveTypes i16 = PrimitiveTypes._("I16");
  static const PrimitiveTypes i32 = PrimitiveTypes._("I32");
  static const PrimitiveTypes i64 = PrimitiveTypes._("I64");
  static const PrimitiveTypes i128 = PrimitiveTypes._("I128");
  static const PrimitiveTypes i256 = PrimitiveTypes._("I256");
  static const List<PrimitiveTypes> values = [
    PrimitiveTypes.boolType,
    PrimitiveTypes.charType,
    PrimitiveTypes.strType,
    PrimitiveTypes.u8,
    PrimitiveTypes.u16,
    PrimitiveTypes.u32,
    PrimitiveTypes.u64,
    PrimitiveTypes.u128,
    PrimitiveTypes.u256,
    PrimitiveTypes.i8,
    PrimitiveTypes.i16,
    PrimitiveTypes.i32,
    PrimitiveTypes.i64,
    PrimitiveTypes.i128,
    PrimitiveTypes.i256,
  ];
  static PrimitiveTypes fromValue(String? value) {
    return values.firstWhere(
      (element) => element.name == value,
      orElse: () => throw MetadataException(
          "No PrimitiveTypes found matching the specified value",
          details: {"value": value}),
    );
  }

  Layout toLayout({String? property}) {
    switch (this) {
      case PrimitiveTypes.boolType:
        return LayoutConst.boolean(property: property);
      case PrimitiveTypes.charType:
        return LayoutConst.u32(property: property);
      case PrimitiveTypes.strType:
        return LayoutConst.compactString(property: property);
      default:
        final bitLength = int.parse(name.substring(1));
        final byteLength = bitLength ~/ 8;
        final sign = name.startsWith("I");
        if (bitLength > 48) {
          return LayoutConst.bigintLayout(byteLength,
              sign: sign, property: property);
        }
        return LayoutConst.intLayout(byteLength,
            sign: sign, property: property);
    }
  }

  @override
  String toString() {
    return name;
  }
}

abstract class PrimitiveType {
  abstract final PrimitiveTypes type;
}
