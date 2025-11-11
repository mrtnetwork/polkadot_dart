import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:polkadot_dart/src/models/xcm/core/xcm.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum XCMBodyIdType implements Comparable<XCMBodyIdType> {
  unit("Unit"),
  named("Named"),
  moniker("Moniker"),
  indexId("Index"),
  executive("Executive"),
  technical("Technical"),
  legislative("Legislative"),
  judical("Judicial"),
  defense("Defense"),
  administration("Administration"),
  treasury("Treasury");

  final String type;
  const XCMBodyIdType(this.type);

  static XCMBodyIdType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMBodyIdType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  @override
  int compareTo(XCMBodyIdType other) {
    return index.compareTo(other.index);
  }
}

abstract mixin class XCMBodyId
    implements
        SubstrateVariantSerialization,
        Comparable<XCMBodyId>,
        XCMComponent {
  XCMBodyIdType get type;

  @override
  String get variantName => type.name;

  Map<String, dynamic> toJson();

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

abstract mixin class XCMBodyIdMoniker implements XCMBodyId {
  List<int> get moniker;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.fixedBlobN(4, property: "moniker"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"moniker": moniker};
  }

  @override
  int compareTo(XCMBodyId other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMBodyIdMoniker;
    return BytesUtils.compareBytes(moniker, current.moniker);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.moniker;
  @override
  List get variabels => [type, moniker];
}

abstract mixin class XCMBodyIdNamed implements XCMBodyId {
  List<int> get name;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.bytes(property: "name"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"name": name};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.named;
  @override
  List get variabels => [type, name];
}

abstract mixin class XCMBodyIdUnit implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.unit;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdIndex implements XCMBodyId {
  int get index;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "index"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"index": index};
  }

  @override
  int compareTo(XCMBodyId other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMBodyIdIndex;
    return index.compareTo(current.index);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.indexId;
  @override
  List get variabels => [type, index];
}

abstract mixin class XCMBodyIdExecutive implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.executive;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdTechnical implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.technical;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdLegislative implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.legislative;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdJudical implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.judical;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdDefense implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.defense;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdAdministration implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.administration;
  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyIdTreasury implements XCMBodyId {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyIdType get type => XCMBodyIdType.treasury;
  @override
  List get variabels => [type];
}

enum XCMBodyPartType implements Comparable<XCMBodyPartType> {
  voice("Voice"),
  members("Members"),
  fraction("Fraction"),
  atLeastProportion("AtLeastProportion"),
  moreThanProportion("MoreThanProportion");

  final String type;
  const XCMBodyPartType(this.type);

  static XCMBodyPartType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMBodyPartType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  @override
  int compareTo(XCMBodyPartType other) {
    return index.compareTo(other.index);
  }
}

abstract mixin class XCMBodyPart
    implements
        SubstrateVariantSerialization,
        Comparable<XCMBodyPart>,
        XCMComponent {
  XCMBodyPartType get type;
  const XCMBodyPart();

  Map<String, dynamic> toJson();
  @override
  String get variantName => type.name;

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

abstract mixin class XCMBodyPartMembers implements XCMBodyPart {
  int get count;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.compactIntU32(property: "count")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"count": count};
  }

  @override
  int compareTo(XCMBodyPart other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMBodyPartMembers;
    return count.compareTo(current.count);
  }

  @override
  XCMBodyPartType get type => XCMBodyPartType.members;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: count};
  }

  @override
  List get variabels => [type, count];
}

abstract mixin class XCMBodyPartVoice implements XCMBodyPart {
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  int compareTo(XCMBodyPart other) {
    return type.compareTo(other.type);
  }

  @override
  XCMBodyPartType get type => XCMBodyPartType.voice;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMBodyPartFraction implements XCMBodyPart {
  int get nom;
  int get denom;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "nom"),
      LayoutConst.compactIntU32(property: "denom"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"nom": nom, "denom": denom};
  }

  @override
  int compareTo(XCMBodyPart other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMBodyPartFraction;
    final nom = this.nom.compareTo(current.nom);
    if (nom != 0) return nom;
    return denom.compareTo(current.denom);
  }

  @override
  XCMBodyPartType get type => XCMBodyPartType.fraction;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"denom": denom, "nom": nom}
    };
  }

  @override
  List get variabels => [type, nom, denom];
}

abstract mixin class XCMBodyPartAtLeastProportion implements XCMBodyPart {
  int get nom;
  int get denom;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "nom"),
      LayoutConst.compactIntU32(property: "denom"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"nom": nom, "denom": denom};
  }

  @override
  int compareTo(XCMBodyPart other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMBodyPartAtLeastProportion;
    final nom = this.nom.compareTo(current.nom);
    if (nom != 0) return nom;
    return denom.compareTo(current.denom);
  }

  @override
  XCMBodyPartType get type => XCMBodyPartType.atLeastProportion;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"denom": denom, "nom": nom}
    };
  }

  @override
  List get variabels => [type, nom, denom];
}

abstract mixin class XCMBodyPartMoreThanProportion implements XCMBodyPart {
  int get nom;
  int get denom;
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "nom"),
      LayoutConst.compactIntU32(property: "denom"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"nom": nom, "denom": denom};
  }

  @override
  int compareTo(XCMBodyPart other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMBodyPartMoreThanProportion;
    final nom = this.nom.compareTo(current.nom);
    if (nom != 0) return nom;
    return denom.compareTo(current.denom);
  }

  @override
  XCMBodyPartType get type => XCMBodyPartType.moreThanProportion;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"denom": denom, "nom": nom}
    };
  }

  @override
  List get variabels => [type, nom, denom];
}
