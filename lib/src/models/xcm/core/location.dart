import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/core/asset.dart';
import 'package:polkadot_dart/src/models/xcm/core/junction.dart';
import 'package:polkadot_dart/src/models/xcm/core/versioned.dart';
import 'package:polkadot_dart/src/models/xcm/v2/types.dart';
import 'package:polkadot_dart/src/models/xcm/v3/types.dart';
import 'package:polkadot_dart/src/models/xcm/v4/types.dart';
import 'package:polkadot_dart/src/models/xcm/v5/types.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

abstract class XCMMultiLocation
    extends SubstrateSerialization<Map<String, dynamic>>
    implements Comparable<XCMMultiLocation>, Equality {
  const XCMMultiLocation();

  T cast<T extends XCMMultiLocation>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  XCMVersion get version;
  XCMJunctions get interior;
  int get parents;
  bool isOneParentsAndHere() {
    return isOneParents() && isHere();
  }

  bool isZeroParentsAndHere() {
    return isZeroParents() && isHere();
  }

  bool isZeroParents() {
    return parents == 0;
  }

  bool isOneParents() {
    return parents == 1;
  }

  bool isExternalLocation() {
    return parents > 1;
  }

  bool isHere() {
    return interior.type == XCMJunctionsType.here;
  }

  bool hasGlobalConsensus() {
    return interior.junctions
        .any((e) => e.type == XCMJunctionType.globalConsensus);
  }

  factory XCMMultiLocation.fromJson(
      {required Map<String, dynamic> json, required XCMVersion version}) {
    final location = switch (version) {
      XCMVersion.v2 => XCMV2MultiLocation.fromJson(json),
      XCMVersion.v3 => XCMV3MultiLocation.fromJson(json),
      XCMVersion.v4 => XCMV4Location.fromJson(json),
      XCMVersion.v5 => XCMV5Location.fromJson(json),
    };
    return location;
  }

  factory XCMMultiLocation.fromVersion(
      {XCMJunctions? interior,
      required int parents,
      XCMVersion version = XCMVersion.v4}) {
    interior ??= XCMJunctions.fromVersion(junctions: [], version: version);
    final xcm = switch (version) {
      XCMVersion.v2 =>
        XCMV2MultiLocation(interior: interior.cast(), parents: parents),
      XCMVersion.v3 =>
        XCMV3MultiLocation(interior: interior.cast(), parents: parents),
      XCMVersion.v4 =>
        XCMV4Location(interior: interior.cast(), parents: parents),
      XCMVersion.v5 =>
        XCMV5Location(interior: interior.cast(), parents: parents)
    };
    return xcm.cast();
  }

  T copyWith<T extends XCMMultiLocation>(
      {XCMJunctions? interior, int? parents}) {
    return XCMMultiLocation.fromVersion(
            parents: parents ?? this.parents,
            interior: interior ?? this.interior,
            version: version)
        .cast<T>();
  }

  T asVersion<T extends XCMMultiLocation>(XCMVersion version) {
    if (version == this.version) return cast<T>();
    final xcm = switch (version) {
      XCMVersion.v2 => XCMV2MultiLocation.from(this),
      XCMVersion.v3 => XCMV3MultiLocation.from(this),
      XCMVersion.v4 => XCMV4Location.from(this),
      XCMVersion.v5 => XCMV5Location.from(this)
    };
    return xcm.cast<T>();
  }

  T? tryAsVersion<T extends XCMMultiLocation>(XCMVersion version) {
    try {
      return asVersion<T>(version);
    } catch (_) {
      return null;
    }
  }

  XCMVersionedLocation asVersioned<T extends XCMVersionedLocation>(
      {XCMVersion? version}) {
    version ??= this.version;
    final location = asVersion(version);
    return XCMVersionedLocation.fromLocation(location);
  }

  XCMMultiLocation withParachain(int paraId) {
    if (parents != 0 ||
        interior.junctions.any((e) => e.type == XCMJunctionType.parachain)) {
      throw DartSubstratePluginException("Failed to convert location.");
    }
    final para = XCMJunctionParaChain.fromVersion(id: paraId, version: version);
    final junctions = XCMJunctions.fromVersion(
        junctions: [para, ...interior.junctions], version: version);
    return XCMMultiLocation.fromVersion(
        parents: 1, interior: junctions, version: version);
  }

  bool hasParachain(int id) {
    return interior.junctions
        .whereType<XCMJunctionParaChain>()
        .any((e) => e.id == id);
  }

  XCMJunctionParaChain? getParachain() {
    return interior.junctions.whereType<XCMJunctionParaChain>().firstOrNull;
  }

  T? firstWhereOrNull<T extends XCMJunction>(
      bool Function(XCMJunction junction) test) {
    for (final i in interior.junctions) {
      final find = test(i);
      if (find) return i.cast<T>();
    }
    return null;
  }

  List<T> where<T extends XCMJunction>(
      bool Function(XCMJunction junction) test) {
    List<T> objects = [];
    for (final i in interior.junctions) {
      final find = test(i);
      if (find) objects.add(i.cast<T>());
    }
    return objects;
  }

  @override
  String toHex(
      {bool versioned = false, String? prefix, bool lowerCase = true}) {
    if (versioned) {
      return BytesUtils.toHexString([version.version, ...serialize()],
          lowerCase: lowerCase, prefix: prefix);
    }
    return super.toHex(prefix: prefix, lowerCase: lowerCase);
  }

  @override
  int compareTo(XCMMultiLocation other) {
    final parents = this.parents.compareTo(other.parents);
    if (parents != 0) return parents;
    return interior.compareTo(other.interior);
  }

  @override
  List get variabels => [version, parents, interior];

  XCMAssetId toAssetId() {
    return XCMAssetId.fromLocation(this);
  }

  Map<String, dynamic> toJson();

  bool isEqual(XCMMultiLocation other) {
    if (version == other.version) return this == other;
    if (version.version > other.version.version) {
      return this == other.asVersion(version);
    }
    return asVersion(other.version) == other;
  }
}

extension XCMMultiLocationComparable on XCMMultiLocation? {
  int compareNullable<T extends Comparable>(XCMMultiLocation? other) {
    if (this == null && other == null) return 0;
    if (this == null) return -1;
    if (other == null) return 1;
    return this!.compareTo(other);
  }
}
