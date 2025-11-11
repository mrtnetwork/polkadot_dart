import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/equatable/equatable.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/core/versioned.dart';
import 'package:polkadot_dart/src/models/xcm/core/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v3/types.dart';
import 'package:polkadot_dart/src/models/xcm/v4/types.dart';
import 'package:polkadot_dart/src/models/xcm/v5/types.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum XCMNetworkIdType implements Comparable<XCMNetworkIdType> {
  any("Any"),
  named("Named"),
  byGenesis("ByGenesis"),
  byFork("ByFork"),
  polkadot("Polkadot"),
  kusama("Kusama"),
  westend("Westend"),
  rococo("Rococo"),
  wococo("Wococo"),
  ethereum("Ethereum"),
  bitcoinCore("BitcoinCore"),
  bitcoinCash("BitcoinCash"),
  polkadotBulletIn("PolkadotBulletin");

  final String type;
  const XCMNetworkIdType(this.type);

  static XCMNetworkIdType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMNetworkIdType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  @override
  int compareTo(XCMNetworkIdType other) {
    return index.compareTo(other.index);
  }
}

abstract mixin class XCMNetworkId
    implements
        SubstrateVariantSerialization,
        Comparable<XCMNetworkId>,
        XCMComponent {
  XCMNetworkIdType get type;

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

abstract mixin class XCMNetworkIdByGenesis implements XCMNetworkId {
  List<int> get genesis;
  @override
  int compareTo(XCMNetworkId other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMNetworkIdByGenesis;
    return BytesUtils.compareBytes(genesis, current.genesis);
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.fixedBlob32(property: "genesis"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"genesis": genesis};
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.byGenesis;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: genesis};
  }

  @override
  List get variabels => [type, genesis];
}

abstract mixin class XCMNetworkIdByFork implements XCMNetworkId {
  List<int> get blockHash;
  BigInt get blockNumber;

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u64(property: "block_number"),
      LayoutConst.fixedBlob32(property: "block_hash"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"block_hash": blockHash, "block_number": blockNumber};
  }

  @override
  int compareTo(XCMNetworkId other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMNetworkIdByFork;
    final blockHash =
        BytesUtils.compareBytes(this.blockHash, current.blockHash);
    if (blockHash != 0) return blockHash;
    return blockNumber.compareTo(other.blockNumber);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.byFork;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"block_hash": blockHash, "block_number": blockNumber}
    };
  }

  @override
  List get variabels => [type, blockHash, blockNumber];
}

abstract mixin class XCMNetworkIdPolkadot implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.polkadot;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdKusama implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.kusama;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdWestend implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.westend;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdRococo implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.rococo;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdWococo implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.wococo;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdEthereum implements XCMNetworkId {
  BigInt get chainId;
  @override
  int compareTo(XCMNetworkId other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMNetworkIdEthereum;
    return chainId.compareTo(current.chainId);
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "chain_id"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"chain_id": chainId};
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.ethereum;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: chainId};
  }

  @override
  List get variabels => [type, chainId];
}

abstract mixin class XCMNetworkIdBitcoinCore implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.bitcoinCore;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdBitcoinCash implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.bitcoinCash;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdPolkadotBulletIn implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.polkadotBulletIn;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdAny implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    return type.compareTo(other.type);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.any;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMNetworkIdNamed implements XCMNetworkId {
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
  int compareTo(XCMNetworkId other) {
    final type = this.type.compareTo(other.type);
    if (type != 0) return type;
    final current = other as XCMNetworkIdNamed;
    return BytesUtils.compareBytes(name, current.name);
  }

  @override
  XCMNetworkIdType get type => XCMNetworkIdType.named;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: name};
  }

  @override
  List get variabels => [type];
}

extension NetworkComparable on XCMNetworkId? {
  int compareNullable<T extends Comparable>(XCMNetworkId? other) {
    if (this == null && other == null) return 0;
    if (this == null) return -1;
    if (other == null) return 1;
    return this!.compareTo(other);
  }
}

abstract class XCMVersionedNetworkId extends SubstrateVariantSerialization
    with Equality {
  final XCMVersion type;
  XCMNetworkId get network;
  const XCMVersionedNetworkId({required this.type});
  factory XCMVersionedNetworkId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMVersion.fromName(decode.variantName);
    return switch (type) {
      XCMVersion.v3 => XCMVersionedNetworkIdV3.deserializeJson(decode.value),
      XCMVersion.v4 => XCMVersionedNetworkIdV4.deserializeJson(decode.value),
      XCMVersion.v5 => XCMVersionedNetworkIdV5.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException("Unsuported xcm version.")
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedNetworkIdV3.layout_(property: property),
          property: XCMVersion.v3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedNetworkIdV4.layout_(property: property),
          property: XCMVersion.v4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedNetworkIdV5.layout_(property: property),
          property: XCMVersion.v5.name,
          index: 5),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  List get variabels => [type, network];
}

class XCMVersionedNetworkIdV3 extends XCMVersionedNetworkId {
  @override
  final XCMV3NetworkId network;
  XCMVersionedNetworkIdV3({required this.network}) : super(type: XCMVersion.v3);

  factory XCMVersionedNetworkIdV3.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedNetworkIdV3(
        network: XCMV3NetworkId.deserializeJson(json["network"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3NetworkId.layout_(property: "network")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network.serializeJsonVariant()};
  }
}

class XCMVersionedNetworkIdV4 extends XCMVersionedNetworkId {
  @override
  final XCMV4NetworkId network;
  XCMVersionedNetworkIdV4({required this.network}) : super(type: XCMVersion.v4);

  factory XCMVersionedNetworkIdV4.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedNetworkIdV4(
        network: XCMV4NetworkId.deserializeJson(json["network"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4NetworkId.layout_(property: "network")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network.serializeJsonVariant()};
  }
}

class XCMVersionedNetworkIdV5 extends XCMVersionedNetworkId {
  @override
  final XCMV5NetworkId network;
  XCMVersionedNetworkIdV5({required this.network}) : super(type: XCMVersion.v4);

  factory XCMVersionedNetworkIdV5.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedNetworkIdV5(
        network: XCMV5NetworkId.deserializeJson(json["network"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5NetworkId.layout_(property: "network")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"network": network.serializeJsonVariant()};
  }
}
