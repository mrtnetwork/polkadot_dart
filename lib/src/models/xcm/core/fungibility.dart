import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/layout/core/types/lazy_union.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/models/xcm/core/xcm.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum XCMFungibilityType implements Comparable<XCMFungibilityType> {
  fungible("Fungible"),
  nonFungible("NonFungible");

  final String type;

  const XCMFungibilityType(this.type);
  static XCMFungibilityType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMFungibilityType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  @override
  int compareTo(XCMFungibilityType other) {
    return index.compareTo(other.index);
  }
}

enum XCMAssetInstanceType implements Comparable<XCMAssetInstanceType> {
  undefined("Undefined"),
  indexId("Index"),
  array4("Array4"),
  array8("Array8"),
  array16("Array16"),
  array32("Array32");

  final String type;

  const XCMAssetInstanceType(this.type);
  static XCMAssetInstanceType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMAssetInstanceType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  @override
  int compareTo(XCMAssetInstanceType other) {
    return index.compareTo(other.index);
  }
}

abstract mixin class XCMAssetInstance
    implements
        SubstrateVariantSerialization,
        Comparable<XCMAssetInstance>,
        XCMComponent {
  XCMAssetInstanceType get type;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMAssetInstanceUndefined.layout_(property: property),
        property: XCMAssetInstanceType.undefined.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMAssetInstanceIndex.layout_(property: property),
        property: XCMAssetInstanceType.indexId.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMAssetInstanceArray4.layout_(property: property),
        property: XCMAssetInstanceType.array4.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMAssetInstanceArray8.layout_(property: property),
        property: XCMAssetInstanceType.array8.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMAssetInstanceArray16.layout_(property: property),
        property: XCMAssetInstanceType.array16.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMAssetInstanceArray32.layout_(property: property),
        property: XCMAssetInstanceType.array32.name,
        index: 5,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  Map<String, dynamic> toJson();

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  @override
  String get variantName => type.name;
}

abstract mixin class XCMAssetInstanceUndefined implements XCMAssetInstance {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  XCMAssetInstanceType get type => XCMAssetInstanceType.undefined;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMAssetInstance other) {
    return type.compareTo(other.type);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMAssetInstanceIndex implements XCMAssetInstance {
  BigInt get index;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactBigintU128(property: "index")],
        property: property);
  }

  @override
  XCMAssetInstanceType get type => XCMAssetInstanceType.indexId;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"index": index};
  }

  @override
  int compareTo(XCMAssetInstance other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMAssetInstanceIndex;
    return index.compareTo(current.index);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: index};
  }

  @override
  List get variabels => [type, index];
}

abstract mixin class XCMAssetInstanceArray4 implements XCMAssetInstance {
  List<int> get datum;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.fixedBlobN(4, property: "datum")],
        property: property);
  }

  @override
  XCMAssetInstanceType get type => XCMAssetInstanceType.array4;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"datum": datum};
  }

  @override
  int compareTo(XCMAssetInstance other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMAssetInstanceArray4;
    return BytesUtils.compareBytes(datum, current.datum);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: datum};
  }

  @override
  List get variabels => [type, datum];
}

abstract mixin class XCMAssetInstanceArray8 implements XCMAssetInstance {
  List<int> get datum;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.fixedBlobN(8, property: "datum")],
        property: property);
  }

  @override
  XCMAssetInstanceType get type => XCMAssetInstanceType.array8;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"datum": datum};
  }

  @override
  int compareTo(XCMAssetInstance other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMAssetInstanceArray8;
    return BytesUtils.compareBytes(datum, current.datum);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: datum};
  }

  @override
  List get variabels => [type, datum];
}

abstract mixin class XCMAssetInstanceArray16 implements XCMAssetInstance {
  List<int> get datum;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.fixedBlobN(16, property: "datum")],
        property: property);
  }

  @override
  XCMAssetInstanceType get type => XCMAssetInstanceType.array16;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"datum": datum};
  }

  @override
  int compareTo(XCMAssetInstance other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMAssetInstanceArray16;
    return BytesUtils.compareBytes(datum, current.datum);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: datum};
  }

  @override
  List get variabels => [type, datum];
}

abstract mixin class XCMAssetInstanceArray32 implements XCMAssetInstance {
  List<int> get datum;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.fixedBlobN(32, property: "datum")],
        property: property);
  }

  @override
  XCMAssetInstanceType get type => XCMAssetInstanceType.array32;

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"datum": datum};
  }

  @override
  int compareTo(XCMAssetInstance other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMAssetInstanceArray32;
    return BytesUtils.compareBytes(datum, current.datum);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: datum};
  }

  @override
  List get variabels => [type, datum];
}

abstract mixin class XCMFungibility
    implements
        SubstrateVariantSerialization,
        Comparable<XCMFungibility>,
        XCMComponent {
  XCMFungibilityType get type;
  const XCMFungibility();

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  @override
  String get variantName => type.name;
  Map<String, dynamic> toJson();
}

abstract mixin class XCMFungibilityFungible implements XCMFungibility {
  BigInt get units;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactBigintU128(property: "units")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"units": units};
  }

  @override
  XCMFungibilityType get type => XCMFungibilityType.fungible;
  @override
  int compareTo(XCMFungibility other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMFungibilityFungible;
    return units.compareTo(current.units);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: units};
  }

  @override
  List get variabels => [type, units];
}

abstract mixin class XCMFungibilityNonFungible implements XCMFungibility {
  XCMAssetInstance get instance;

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"instance": instance.serializeJsonVariant()};
  }

  @override
  XCMFungibilityType get type => XCMFungibilityType.nonFungible;

  @override
  int compareTo(XCMFungibility other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMFungibilityNonFungible;
    return instance.compareTo(current.instance);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: instance.toJson()};
  }

  @override
  List get variabels => [type, instance];
}
