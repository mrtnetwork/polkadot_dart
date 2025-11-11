import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/core/body.dart';
import 'package:polkadot_dart/src/models/xcm/core/network_id.dart';
import 'package:polkadot_dart/src/models/xcm/core/versioned.dart';
import 'package:polkadot_dart/src/models/xcm/core/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v2/types.dart';
import 'package:polkadot_dart/src/models/xcm/v3/types.dart';
import 'package:polkadot_dart/src/models/xcm/v4/types.dart';
import 'package:polkadot_dart/src/models/xcm/v5/types.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

enum XCMJunctionType implements Comparable<XCMJunctionType> {
  parachain("Parachain"),
  accountId32("AccountId32"),
  accountIndex64("AccountIndex64"),
  accountKey20("AccountKey20"),
  palletInstance("PalletInstance"),
  generalIndex("GeneralIndex"),
  generalKey("GeneralKey"),
  onlyChild("OnlyChild"),
  plurality("Plurality"),
  globalConsensus("GlobalConsensus");

  final String type;
  const XCMJunctionType(this.type);
  static XCMJunctionType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  static XCMJunctionType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  @override
  int compareTo(XCMJunctionType other) {
    return index.compareTo(other.index);
  }
}

abstract mixin class XCMJunction
    implements
        SubstrateVariantSerialization,
        Comparable<XCMJunction>,
        XCMComponent {
  XCMJunctionType get type;

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  Map<String, dynamic> toJson();
}

abstract mixin class XCMJunctionAccountId32 implements XCMJunction {
  XCMNetworkId? get network;
  List<int> get id;
  factory XCMJunctionAccountId32.fromVersion(
      {required List<int> keyBytes,
      XCMVersion version = XCMVersion.v4,
      XCMV2NetworkId? v2Network}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2JunctionAccountId32(
          id: keyBytes, network: v2Network ?? XCMV2Any()),
      XCMVersion.v3 => XCMV3JunctionAccountId32(id: keyBytes),
      XCMVersion.v4 => XCMV4JunctionAccountId32(id: keyBytes),
      XCMVersion.v5 => XCMV5JunctionAccountId32(id: keyBytes)
    };
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network?.serializeJsonVariant(), "id": id};
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionAccountId32;
    final nullC = network.compareNullable(current.network);
    if (nullC != 0) return nullC;
    return BytesUtils.compareBytes(id, current.id);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.accountId32;

  @override
  List get variabels => [type, network, id];

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "network": MetadataUtils.toOptionalJson(network?.toJson()),
        "id": id
      }
    };
  }
}

abstract mixin class XCMJunctionAccountKey20 implements XCMJunction {
  XCMNetworkId? get network;
  List<int> get key;

  factory XCMJunctionAccountKey20.fromVersion(
      {required List<int> keyBytes,
      XCMVersion version = XCMVersion.v4,
      XCMV2NetworkId? v2Network}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2JunctionAccountKey20(
          key: keyBytes, network: v2Network ?? XCMV2Any()),
      XCMVersion.v3 => XCMV3JunctionAccountKey20(key: keyBytes),
      XCMVersion.v4 => XCMV4JunctionAccountKey20(key: keyBytes),
      XCMVersion.v5 => XCMV5JunctionAccountKey20(key: keyBytes)
    };
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network?.serializeJsonVariant(), "key": key};
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionAccountKey20;
    final nullC = network.compareNullable(current.network);
    if (nullC != 0) return nullC;
    return BytesUtils.compareBytes(key, current.key);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.accountKey20;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "network": MetadataUtils.toOptionalJson(network?.toJson()),
        "key": key
      }
    };
  }

  @override
  List get variabels => [type, network, key];
}

abstract mixin class XCMJunctionParaChain implements XCMJunction {
  int get id;
  factory XCMJunctionParaChain.fromVersion(
      {required int id, XCMVersion version = XCMVersion.v4}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2JunctionParaChain(id: id),
      XCMVersion.v3 => XCMV3JunctionParaChain(id: id),
      XCMVersion.v4 => XCMV4JunctionParaChain(id: id),
      XCMVersion.v5 => XCMV5JunctionParaChain(id: id)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.compactIntU32(property: "id")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id};
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionParaChain;
    return id.compareTo(current.id);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.parachain;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: id};
  }

  @override
  List get variabels {
    return [type, id];
  }
}

abstract mixin class XCMJunctionPalletInstance implements XCMJunction {
  int get index;
  factory XCMJunctionPalletInstance.fromVersion(
      {required int index, XCMVersion version = XCMVersion.v4}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2JunctionPalletInstance(index: index),
      XCMVersion.v3 => XCMV3JunctionPalletInstance(index: index),
      XCMVersion.v4 => XCMV4JunctionPalletInstance(index: index),
      XCMVersion.v5 => XCMV5JunctionPalletInstance(index: index)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "index"),
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
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionPalletInstance;
    return index.compareTo(current.index);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.palletInstance;
  @override
  List get variabels => [type, index];

  @override
  Map<String, dynamic> toJson() {
    return {type.type: index};
  }
}

abstract mixin class XCMJunctionGeneralIndex implements XCMJunction {
  BigInt get index;
  factory XCMJunctionGeneralIndex.fromVersion(
      {required BigInt index, XCMVersion version = XCMVersion.v4}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2JunctionGeneralIndex(index: index),
      XCMVersion.v3 => XCMV3JunctionGeneralIndex(index: index),
      XCMVersion.v4 => XCMV4JunctionGeneralIndex(index: index),
      XCMVersion.v5 => XCMV5JunctionGeneralIndex(index: index)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU128(property: "index"),
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
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionGeneralIndex;
    return index.compareTo(current.index);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.generalIndex;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: index};
  }

  @override
  List get variabels => [type, index];
}

abstract mixin class XCMJunctionAccountIndex64 implements XCMJunction {
  XCMNetworkId? get network;
  BigInt get index;

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network?.serializeJsonVariant(), "index": index};
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionAccountIndex64;
    final nullC = network.compareNullable(current.network);
    if (nullC != 0) return nullC;
    return index.compareTo(other.index);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.accountIndex64;
  @override
  List get variabels => [type, index, network];

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "network": MetadataUtils.toOptionalJson(network?.toJson()),
        "index": index
      }
    };
  }
}

abstract mixin class XCMJunctionGeneralKey implements XCMJunction {
  int get length;
  List<int> get data;
  factory XCMJunctionGeneralKey.fromVersion(
      {required List<int> data,
      required int length,
      XCMVersion version = XCMVersion.v4}) {
    return switch (version) {
      XCMVersion.v2 =>
        XCMV2JunctionGeneralKey(data: data.sublist(0, length), length: length),
      XCMVersion.v3 => XCMV3JunctionGeneralKey(data: data, length: length),
      XCMVersion.v4 => XCMV4JunctionGeneralKey(data: data, length: length),
      XCMVersion.v5 => XCMV5JunctionGeneralKey(data: data, length: length)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "length"),
      LayoutConst.fixedBlob32(property: "data")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"length": length, "data": data};
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionGeneralKey;
    final length = this.length.compareTo(current.length);
    if (length != 0) return length;
    return BytesUtils.compareBytes(data, other.data);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.generalKey;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"length": length, "data": data}
    };
  }

  @override
  List get variabels => [type, length, data];
}

abstract mixin class XCMJunctionOnlyChild implements XCMJunction {
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
  int compareTo(XCMJunction other) {
    return type.compareTo(other.type);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.onlyChild;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMJunctionPlurality implements XCMJunction {
  XCMBodyId get id;
  XCMBodyPart get part;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3BodyId.layout_(property: "id"),
      XCMV3BodyPart.layout_(property: "part")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "id": id.serializeJsonVariant(),
      "part": part.serializeJsonVariant()
    };
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionPlurality;
    final id = this.id.compareTo(current.id);
    if (id != 0) return id;
    return part.compareTo(other.part);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.plurality;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"id": id.toJson(), "part": part.toJson()}
    };
  }

  @override
  List get variabels => [type, id, part];
}

abstract mixin class XCMJunctionGlobalConsensus implements XCMJunction {
  XCMNetworkId get network;

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network.serializeJsonVariant()};
  }

  @override
  int compareTo(XCMJunction other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMJunctionGlobalConsensus;
    return network.compareTo(current.network);
  }

  @override
  XCMJunctionType get type => XCMJunctionType.globalConsensus;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: network.toJson()};
  }

  bool get isKusama => network.type == XCMNetworkIdType.kusama;
  bool get isPolkadot => network.type == XCMNetworkIdType.polkadot;
  bool get isEthereum => network.type == XCMNetworkIdType.ethereum;

  @override
  List get variabels => [type, network];
}

enum XCMJunctionsType implements Comparable<XCMJunctionsType> {
  here("Here", 0),
  x1("X1", 1),
  x2("X2", 2),
  x3("X3", 3),
  x4("X4", 4),
  x5("X5", 5),
  x6("X6", 6),
  x7("X7", 7),
  x8("X8", 8);

  final int junctionsLength;
  const XCMJunctionsType(this.type, this.junctionsLength);
  final String type;
  static XCMJunctionsType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMJunctionsType fromLength(int length) {
    return values.firstWhere((e) => e.junctionsLength == length,
        orElse: () => throw ItemNotFoundException(value: length));
  }

  static XCMJunctionsType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  @override
  int compareTo(XCMJunctionsType other) {
    return junctionsLength.compareTo(other.junctionsLength);
  }
}

abstract class XCMJunctions<JUNCTION extends XCMJunction>
    extends SubstrateVariantSerialization
    with Equality
    implements Comparable<XCMJunctions<JUNCTION>>, XCMComponent {
  final XCMJunctionsType type;
  final List<JUNCTION> junctions;

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  XCMJunctions({required this.type, required List<JUNCTION> junctions})
      : junctions =
            junctions.exc(type.junctionsLength, name: "junctions").immutable;

  factory XCMJunctions.fromVersion(
      {required List<JUNCTION> junctions,
      XCMVersion version = XCMVersion.v4,
      XCMV2NetworkId? v2Network}) {
    return (switch (version) {
      XCMVersion.v2 =>
        XCMV2Junctions.fromJunctions(junctions.cast<XCMV2Junction>()),
      XCMVersion.v3 =>
        XCMV3Junctions.fromJunctions(junctions.cast<XCMV3Junction>()),
      XCMVersion.v4 =>
        XCMV4Junctions.fromJunctions(junctions.cast<XCMV4Junction>()),
      XCMVersion.v5 =>
        XCMV5Junctions.fromJunctions(junctions.cast<XCMV5Junction>())
    } as XCMJunctions)
        .cast<XCMJunctions<JUNCTION>>();
  }

  @override
  int compareTo(XCMJunctions<JUNCTION> other) {
    final len = junctions.length < other.junctions.length
        ? junctions.length
        : other.junctions.length;
    for (int i = 0; i < len; i++) {
      final cmp = junctions[i].compareTo(other.junctions[i]);
      if (cmp != 0) return cmp;
    }
    return junctions.length.compareTo(other.junctions.length);
  }

  Map<String, dynamic> toJson();
  @override
  List get variabels => [type, junctions];
}
