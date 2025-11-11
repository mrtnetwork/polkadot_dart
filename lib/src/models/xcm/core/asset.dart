import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

abstract mixin class XCMAssetId
    implements Comparable<XCMAssetId>, XCMComponent {
  XCMMultiLocation? get location;
  @override
  XCMVersion get version;

  factory XCMAssetId.fromLocation(XCMMultiLocation location) {
    final xcm = switch (location.version) {
      XCMVersion.v2 => XCMV2AssetIdConcrete(location: location.cast()),
      XCMVersion.v3 => XCMV3AssetIdConcrete(location: location.cast()),
      XCMVersion.v4 => XCMV4AssetId(location: location.cast()),
      XCMVersion.v5 => XCMV5AssetId(location: location.cast()),
    };
    return xcm;
  }

  factory XCMAssetId.fromJson(
      {required Map<String, dynamic> json, required XCMVersion version}) {
    final xcm = switch (version) {
      XCMVersion.v2 => XCMV2AssetId.fromJson(json),
      XCMVersion.v3 => XCMV3AssetId.fromJson(json),
      XCMVersion.v4 => XCMV4AssetId.fromJson(json),
      XCMVersion.v5 => XCMV5AssetId.fromJson(json),
    };
    return xcm;
  }

  static Layout<Map<String, dynamic>> layout_(XCMVersion version,
      {String? property}) {
    return switch (version) {
      XCMVersion.v5 => XCMV5AssetId.layout_(property: property),
      XCMVersion.v4 => XCMV4AssetId.layout_(property: property),
      XCMVersion.v3 => XCMV3AssetId.layout_(property: property),
      XCMVersion.v2 => XCMV2AssetId.layout_(property: property),
    };
  }

  @override
  int compareTo(XCMAssetId other) {
    return location.compareNullable(other.location);
  }

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  Map<String, dynamic> serializeJson({String? property});

  XCMVersionedAssetId asVersioned() {
    return XCMVersionedAssetId.fromAssetId(this);
  }

  Map<String, dynamic> toJson();

  XCMMultiLocation getLocation() {
    final location = this.location;
    if (location == null) {
      throw DartSubstratePluginException(
          "Unable to determine XCM location for asset ID (V3 Abstract).");
    }
    return location;
  }

  XCMAssetId asVersion(XCMVersion version) {
    return switch (version) {
      XCMVersion.v2 => XCMV2AssetId.from(this),
      XCMVersion.v3 => XCMV3AssetId.from(this),
      XCMVersion.v4 => XCMV4AssetId.from(this),
      XCMVersion.v5 => XCMV5AssetId.from(this),
    };
  }
}

abstract mixin class XCMAssets<ASSET extends XCMAsset>
    implements SubstrateSerialization<Map<String, dynamic>>, XCMComponent {
  List<ASSET> get assets;
  factory XCMAssets.fromAsset(
      {required List<XCMAsset> assets, required XCMVersion version}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2MultiAssets(assets: assets.cast()),
      XCMVersion.v3 => XCMV3MultiAssets(assets: assets.cast()),
      XCMVersion.v4 => XCMV4Assets(assets: assets.cast()),
      XCMVersion.v5 => XCMV5Assets(assets: assets.cast()),
    }
        .cast<XCMAssets<ASSET>>();
  }

  @override
  List get variabels => [assets];

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

abstract mixin class XCMAsset
    implements
        SubstrateSerialization<Map<String, dynamic>>,
        Comparable<XCMAsset>,
        XCMComponent {
  XCMAssetId get id;
  XCMFungibility get fun;

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  factory XCMAsset.fungible(
      {required BigInt amount, required XCMMultiLocation location}) {
    return switch (location.version) {
      XCMVersion.v2 => XCMV2MultiAsset(
          id: XCMV2AssetIdConcrete(location: location.cast()),
          fun: XCMV2FungibilityFungible(units: amount)),
      XCMVersion.v3 => XCMV3MultiAsset(
          id: XCMV3AssetIdConcrete(location: location.cast()),
          fun: XCMV3FungibilityFungible(units: amount)),
      XCMVersion.v4 => XCMV4Asset(
          id: XCMV4AssetId(location: location.cast()),
          fun: XCMV4FungibilityFungible(units: amount)),
      XCMVersion.v5 => XCMV5Asset(
          id: XCMV5AssetId(location: location.cast()),
          fun: XCMV5FungibilityFungible(units: amount)),
    };
  }

  factory XCMAsset.fungibleAsset(
      {required BigInt amount, required XCMAssetId id}) {
    return switch (id.version) {
      XCMVersion.v2 => XCMV2MultiAsset(
          id: id.cast(), fun: XCMV2FungibilityFungible(units: amount)),
      XCMVersion.v3 => XCMV3MultiAsset(
          id: id.cast(), fun: XCMV3FungibilityFungible(units: amount)),
      XCMVersion.v4 =>
        XCMV4Asset(id: id.cast(), fun: XCMV4FungibilityFungible(units: amount)),
      XCMVersion.v5 =>
        XCMV5Asset(id: id.cast(), fun: XCMV5FungibilityFungible(units: amount)),
    };
  }

  XCMVersionedAsset asVersioned() {
    return XCMVersionedAsset.fromAsset(this);
  }

  // XCMAsset asVersion(XCMVersion version){

  //   return
  // }

  @override
  int compareTo(XCMAsset other) {
    final id = this.id.compareTo(other.id);

    if (id != 0) return id;
    return fun.compareTo(other.fun);
  }

  Map<String, dynamic> toJson();

  @override
  List get variabels => [id, fun, version];
}

enum XCMWildFungibilityType {
  fungible("Fungible"),
  nonFungible("NonFungible");

  final String type;

  const XCMWildFungibilityType(this.type);
  static XCMWildFungibilityType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMWildFungibilityType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }
}

abstract mixin class XCMWildFungibility
    implements SubstrateVariantSerialization, XCMComponent {
  XCMWildFungibilityType get type;
  Map<String, dynamic> toJson();

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

abstract mixin class XCMWildFungibilityFungible implements XCMWildFungibility {
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
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMWildFungibilityType get type => XCMWildFungibilityType.fungible;
  @override
  List get variabels => [type];
}

abstract mixin class XCMWildFungibilityNonFungible
    implements XCMWildFungibility {
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
  XCMWildFungibilityType get type => XCMWildFungibilityType.nonFungible;
  @override
  List get variabels => [type];
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

enum XCMWildAssetType {
  all("All"),
  allOf("AllOf"),
  allCounted("AllCounted"),
  allOfCounted("AllOfCounted");

  const XCMWildAssetType(this.type);
  final String type;
  static XCMWildAssetType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMWildAssetType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract mixin class XCMWildMultiAsset
    implements SubstrateVariantSerialization, XCMComponent {
  XCMWildAssetType get type;
  @override
  String get variantName => type.name;
  Map<String, dynamic> toJson();

  factory XCMWildMultiAsset.all({required XCMVersion version}) {
    return switch (version) {
      XCMVersion.v2 => XCMV2WildMultiAssetAll(),
      XCMVersion.v3 => XCMV3WildMultiAssetAll(),
      XCMVersion.v4 => XCMV4WildAssetAll(),
      XCMVersion.v5 => XCMV5WildAssetAll()
    };
  }
  factory XCMWildMultiAsset.allOf(
      {required XCMAssetId assetId,
      required XCMWildFungibilityType fungibility}) {
    return switch (assetId.version) {
      XCMVersion.v2 => XCMV2WildMultiAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV2WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV2WildFungibilityNonFungible()
          }),
      XCMVersion.v3 => XCMV3WildMultiAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV3WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV3WildFungibilityNonFungible(),
          }),
      XCMVersion.v4 => XCMV4WildAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV4WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV4WildFungibilityNonFungible(),
          }),
      XCMVersion.v5 => XCMV5WildAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV5WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV5WildFungibilityNonFungible(),
          })
    };
  }

  factory XCMWildMultiAsset.allCounted(
      {required int count, required XCMVersion version}) {
    return switch (version) {
      XCMVersion.v2 => throw DartSubstratePluginException(
          "Unsuported all counted wild assets by version 2."),
      XCMVersion.v3 => XCMV3WildMultiAssetAllCounted(count: count),
      XCMVersion.v4 => XCMV4WildAssetAllCounted(count: count),
      XCMVersion.v5 => XCMV5WildAssetAllCounted(count: count)
    };
  }
  factory XCMWildMultiAsset.allOfCounted(
      {required XCMAssetId assetId,
      required int count,
      required XCMWildFungibilityType fungibility}) {
    return switch (assetId.version) {
      XCMVersion.v2 => throw DartSubstratePluginException(
          "Unsuported all of counted wild assets by version 2."),
      XCMVersion.v3 => XCMV3WildMultiAssetAllOfCounted(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV3WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV3WildFungibilityNonFungible()
          },
          count: count),
      XCMVersion.v4 => XCMV4WildAssetAllOfCounted(
          id: assetId.cast(),
          count: count,
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV4WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV4WildFungibilityNonFungible()
          }),
      XCMVersion.v5 => XCMV5WildAssetAllOfCounted(
          id: assetId.cast(),
          count: count,
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV5WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV5WildFungibilityNonFungible()
          })
    };
  }

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

abstract mixin class XCMWildMultiAssetAll implements XCMWildMultiAsset {
  @override
  XCMWildAssetType get type => XCMWildAssetType.all;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMWildMultiAssetAllOf implements XCMWildMultiAsset {
  XCMAssetId get id;
  XCMWildFungibility get fun;

  factory XCMWildMultiAssetAllOf.fromAssetId(
      {required XCMAssetId assetId,
      required XCMWildFungibilityType fungibility}) {
    return switch (assetId.version) {
      XCMVersion.v2 => XCMV2WildMultiAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV2WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV2WildFungibilityNonFungible()
          }),
      XCMVersion.v3 => XCMV3WildMultiAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV3WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV3WildFungibilityNonFungible(),
          }),
      XCMVersion.v4 => XCMV4WildAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV4WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV4WildFungibilityNonFungible(),
          }),
      XCMVersion.v5 => XCMV5WildAssetAllOf(
          id: assetId.cast(),
          fun: switch (fungibility) {
            XCMWildFungibilityType.fungible => XCMV5WildFungibilityFungible(),
            XCMWildFungibilityType.nonFungible =>
              XCMV5WildFungibilityNonFungible(),
          })
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"id": id.toJson(), "fun": fun.toJson()}
    };
  }

  @override
  XCMWildAssetType get type => XCMWildAssetType.allOf;
  @override
  List get variabels => [type, id, fun];
}

abstract mixin class XCMWildMultiAssetAllCounted implements XCMWildMultiAsset {
  int get count;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: count};
  }

  @override
  XCMWildAssetType get type => XCMWildAssetType.allCounted;
  @override
  List get variabels => [type, count];
}

abstract mixin class XCMWildMultiAssetAllOfCounted
    implements XCMWildMultiAsset {
  XCMAssetId get id;
  XCMWildFungibility get fun;
  int get count;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"id": id.toJson(), "fun": fun.toJson(), "count": count}
    };
  }

  @override
  XCMWildAssetType get type => XCMWildAssetType.allOfCounted;
  @override
  List get variabels => [type, id, fun, count];
}

enum XCMMultiAssetFilterType {
  definite("Definite"),
  wild("Wild");

  final String type;
  const XCMMultiAssetFilterType(this.type);
  static XCMMultiAssetFilterType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMMultiAssetFilterType fromType(String? type) {
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }
}

abstract mixin class XCMMultiAssetFilter
    implements SubstrateVariantSerialization, XCMComponent {
  XCMMultiAssetFilterType get type;
  const XCMMultiAssetFilter();
  factory XCMMultiAssetFilter.definite(XCMAssets assets) {
    return switch (assets.version) {
      XCMVersion.v2 => XCMV2MultiAssetFilterDefinite(assets: assets.cast()),
      XCMVersion.v3 => XCMV3MultiAssetFilterDefinite(assets: assets.cast()),
      XCMVersion.v4 => XCMV4AssetFilterDefinite(assets: assets.cast()),
      XCMVersion.v5 => XCMV5AssetFilterDefinite(assets: assets.cast())
    };
  }
  factory XCMMultiAssetFilter.wild(XCMWildMultiAsset asset) {
    return switch (asset.version) {
      XCMVersion.v2 => XCMV2MultiAssetFilterWild(asset: asset.cast()),
      XCMVersion.v3 => XCMV3MultiAssetFilterWild(asset: asset.cast()),
      XCMVersion.v4 => XCMV4AssetFilterWild(asset: asset.cast()),
      XCMVersion.v5 => XCMV5AssetFilterWild(asset: asset.cast())
    };
  }
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

abstract mixin class XCMMultiAssetFilterDefinite
    implements XCMMultiAssetFilter {
  XCMAssets get assets;

  @override
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.definite;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

abstract mixin class XCMMultiAssetFilterWild implements XCMMultiAssetFilter {
  XCMWildMultiAsset get asset;
  @override
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.wild;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }

  @override
  List get variabels => [type, asset];
}
