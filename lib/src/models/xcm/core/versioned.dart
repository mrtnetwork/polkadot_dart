import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/models/xcm/core/asset.dart';
import 'package:polkadot_dart/src/models/xcm/core/location.dart';
import 'package:polkadot_dart/src/models/xcm/core/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v2/types.dart';
import 'package:polkadot_dart/src/models/xcm/v2/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v3/types.dart';
import 'package:polkadot_dart/src/models/xcm/v3/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v4/types.dart';
import 'package:polkadot_dart/src/models/xcm/v4/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v5/types.dart';
import 'package:polkadot_dart/src/models/xcm/v5/xcm.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

enum XCMVersion {
  v2(1, "V2"),
  v3(3, "V3"),
  v4(4, "V4"),
  v5(5, "V5");

  const XCMVersion(this.version, this.type);
  final int version;
  final String type;
  static XCMVersion fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMVersion fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMVersion fromVersion(int? version) {
    return switch (version) {
      1 || 2 => XCMVersion.v2,
      _ => values.firstWhere((e) => e.version == version,
          orElse: () => throw ItemNotFoundException(value: version))
    };
  }

  // Comparison operators
  bool operator >(XCMVersion other) => version > other.version;
  bool operator <(XCMVersion other) => version < other.version;
  bool operator >=(XCMVersion other) => version >= other.version;
  bool operator <=(XCMVersion other) => version <= other.version;
}

abstract class XCMVersionedXCM extends SubstrateVariantSerialization {
  final XCMVersion version;
  XCM get xcm;
  Map<String, dynamic> toJson();
  const XCMVersionedXCM({required this.version});
  factory XCMVersionedXCM.deserialize(List<int> bytes) {
    final json = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    final asset = XCMVersionedXCM.deserializeJson(json);
    return asset;
  }
  factory XCMVersionedXCM.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMVersion.fromName(decode.variantName);
    return switch (type) {
      XCMVersion.v2 => XCMVersionedXCMV2.deserializeJson(decode.value),
      XCMVersion.v3 => XCMVersionedXCMV3.deserializeJson(decode.value),
      XCMVersion.v4 => XCMVersionedXCMV4.deserializeJson(decode.value),
      XCMVersion.v5 => XCMVersionedXCMV5.deserializeJson(decode.value),
    };
  }
  factory XCMVersionedXCM.fromJson(Map<String, dynamic> json,
      {XCMVersion? version}) {
    final type = XCMVersion.fromType(json.keys.firstOrNull);
    if (version != null && version != type) {
      if (json.containsKey(type.type)) {
        json = {version.type: json[type.type]};
      }
    }
    return switch (type) {
      XCMVersion.v2 => XCMVersionedXCMV2.fromJson(json),
      XCMVersion.v3 => XCMVersionedXCMV3.fromJson(json),
      XCMVersion.v4 => XCMVersionedXCMV4.fromJson(json),
      XCMVersion.v5 => XCMVersionedXCMV5.fromJson(json)
    };
  }
  factory XCMVersionedXCM.fromXCM(XCM xcm) {
    return switch (xcm.version) {
      XCMVersion.v2 => XCMVersionedXCMV2(xcm: xcm.cast()),
      XCMVersion.v3 => XCMVersionedXCMV3(xcm: xcm.cast()),
      XCMVersion.v4 => XCMVersionedXCMV4(xcm: xcm.cast()),
      XCMVersion.v5 => XCMVersionedXCMV5(xcm: xcm.cast()),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) => XCMVersionedXCMV2.layout_(property: property),
          property: XCMVersion.v2.name,
          index: 2),
      LazyVariantModel(
          layout: ({property}) => XCMVersionedXCMV3.layout_(property: property),
          property: XCMVersion.v3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) => XCMVersionedXCMV4.layout_(property: property),
          property: XCMVersion.v4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) => XCMVersionedXCMV5.layout_(property: property),
          property: XCMVersion.v5.name,
          index: 5),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => version.name;
}

class XCMVersionedXCMV2 extends XCMVersionedXCM {
  @override
  final XCMV2 xcm;
  XCMVersionedXCMV2({required this.xcm}) : super(version: XCMVersion.v2);

  factory XCMVersionedXCMV2.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedXCMV2(xcm: XCMV2.deserializeJson(json["xcm"]));
  }
  factory XCMVersionedXCMV2.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMVersion.v2.type);

    return XCMVersionedXCMV2(
        xcm: XCMV2(
            instructions:
                data.map((e) => XCMInstructionV2.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2.layout_(property: "xcm")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: xcm.instructions.map((e) => e.toJson()).toList()};
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"xcm": xcm.serializeJson()};
  }
}

class XCMVersionedXCMV3 extends XCMVersionedXCM {
  @override
  final XCMV3 xcm;
  XCMVersionedXCMV3({required this.xcm}) : super(version: XCMVersion.v3);

  factory XCMVersionedXCMV3.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedXCMV3(xcm: XCMV3.deserializeJson(json["xcm"]));
  }
  factory XCMVersionedXCMV3.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMVersion.v3.type);

    return XCMVersionedXCMV3(
        xcm: XCMV3(
            instructions:
                data.map((e) => XCMInstructionV3.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3.layout_(property: "xcm")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"xcm": xcm.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: xcm.instructions.map((e) => e.toJson()).toList()};
  }
}

class XCMVersionedXCMV4 extends XCMVersionedXCM {
  @override
  final XCMV4 xcm;
  XCMVersionedXCMV4({required this.xcm}) : super(version: XCMVersion.v4);

  factory XCMVersionedXCMV4.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedXCMV4(xcm: XCMV4.deserializeJson(json["xcm"]));
  }
  factory XCMVersionedXCMV4.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMVersion.v4.type);

    return XCMVersionedXCMV4(
        xcm: XCMV4(
            instructions:
                data.map((e) => XCMInstructionV4.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4.layout_(property: "xcm")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"xcm": xcm.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: xcm.instructions.map((e) => e.toJson()).toList()};
  }
}

class XCMVersionedXCMV5 extends XCMVersionedXCM {
  @override
  final XCMV5 xcm;
  XCMVersionedXCMV5({required this.xcm}) : super(version: XCMVersion.v5);

  factory XCMVersionedXCMV5.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedXCMV5(xcm: XCMV5.deserializeJson(json["xcm"]));
  }
  factory XCMVersionedXCMV5.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMVersion.v5.type);

    return XCMVersionedXCMV5(
        xcm: XCMV5(
            instructions:
                data.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5.layout_(property: "xcm")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"xcm": xcm.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: xcm.instructions.map((e) => e.toJson()).toList()};
  }
}

abstract class XCMVersionedAssetId extends SubstrateVariantSerialization {
  final XCMVersion type;
  XCMAssetId get asset;
  const XCMVersionedAssetId({required this.type});
  factory XCMVersionedAssetId.deserialize(List<int> bytes) {
    final decode = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    return XCMVersionedAssetId.deserializeJson(decode);
  }
  factory XCMVersionedAssetId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMVersion.fromName(decode.variantName);
    return switch (type) {
      XCMVersion.v2 => XCMVersionedAssetIdV2.deserializeJson(decode.value),
      XCMVersion.v3 => XCMVersionedAssetIdV3.deserializeJson(decode.value),
      XCMVersion.v4 => XCMVersionedAssetIdV4.deserializeJson(decode.value),
      XCMVersion.v5 => XCMVersionedAssetIdV5.deserializeJson(decode.value)
    };
  }
  factory XCMVersionedAssetId.fromJson(Map<String, dynamic> json) {
    final type = XCMVersion.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMVersion.v2 => XCMVersionedAssetIdV2.fromJson(json),
      XCMVersion.v3 => XCMVersionedAssetIdV3.fromJson(json),
      XCMVersion.v4 => XCMVersionedAssetIdV4.fromJson(json),
      XCMVersion.v5 => XCMVersionedAssetIdV5.fromJson(json)
    };
  }
  factory XCMVersionedAssetId.fromAssetId(XCMAssetId aseetId) {
    return switch (aseetId.version) {
      XCMVersion.v2 => XCMVersionedAssetIdV2(asset: aseetId.cast()),
      XCMVersion.v3 => XCMVersionedAssetIdV3(asset: aseetId.cast()),
      XCMVersion.v4 => XCMVersionedAssetIdV4(asset: aseetId.cast()),
      XCMVersion.v5 => XCMVersionedAssetIdV5(asset: aseetId.cast())
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetIdV2.layout_(property: property),
          property: XCMVersion.v2.name,
          index: 2),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetIdV3.layout_(property: property),
          property: XCMVersion.v3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetIdV4.layout_(property: property),
          property: XCMVersion.v4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetIdV5.layout_(property: property),
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

  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }
}

class XCMVersionedAssetIdV3 extends XCMVersionedAssetId {
  @override
  final XCMV3AssetId asset;
  XCMVersionedAssetIdV3({required this.asset}) : super(type: XCMVersion.v3);

  factory XCMVersionedAssetIdV3.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV3(
        asset: XCMV3AssetId.deserializeJson(json["asset"]));
  }
  factory XCMVersionedAssetIdV3.fromJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV3(
        asset: XCMV3AssetId.fromJson(json.valueAs(XCMVersion.v3.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3AssetId.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJsonVariant()};
  }
}

class XCMVersionedAssetIdV2 extends XCMVersionedAssetId {
  @override
  final XCMV2AssetId asset;
  XCMVersionedAssetIdV2({required this.asset}) : super(type: XCMVersion.v2);

  factory XCMVersionedAssetIdV2.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV2(
        asset: XCMV2AssetId.deserializeJson(json["asset"]));
  }

  factory XCMVersionedAssetIdV2.fromJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV2(
        asset: XCMV2AssetId.fromJson(json.valueAs(XCMVersion.v2.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2AssetId.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJsonVariant()};
  }
}

class XCMVersionedAssetIdV4 extends XCMVersionedAssetId {
  @override
  final XCMV4AssetId asset;
  XCMVersionedAssetIdV4({required this.asset}) : super(type: XCMVersion.v4);

  factory XCMVersionedAssetIdV4.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV4(
        asset: XCMV4AssetId.deserializeJson(json["asset"]));
  }
  factory XCMVersionedAssetIdV4.fromJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV4(
        asset: XCMV4AssetId.fromJson(json.valueAs(XCMVersion.v4.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4AssetId.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson()};
  }
}

class XCMVersionedAssetIdV5 extends XCMVersionedAssetId {
  @override
  final XCMV5AssetId asset;
  XCMVersionedAssetIdV5({required this.asset}) : super(type: XCMVersion.v5);

  factory XCMVersionedAssetIdV5.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV5(
        asset: XCMV5AssetId.deserializeJson(json["asset"]));
  }
  factory XCMVersionedAssetIdV5.fromJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIdV5(
        asset: XCMV5AssetId.fromJson(json.valueAs(XCMVersion.v5.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5AssetId.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson()};
  }
}

class XCMVersionedAssetIds
    extends SubstrateSerialization<Map<String, dynamic>> {
  final List<XCMVersionedAssetId> assets;
  XCMVersionedAssetIds({required List<XCMVersionedAssetId> assets})
      : assets = assets.immutable;
  factory XCMVersionedAssetIds.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    final assets = XCMVersionedAssetIds.deserializeJson(decode.value);
    return assets;
  }
  factory XCMVersionedAssetIds.fromJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIds(
        assets: (json["assets"] as List)
            .map((e) => XCMVersionedAssetId.fromJson(e))
            .toList());
  }
  factory XCMVersionedAssetIds.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetIds(
        assets: (json["assets"] as List)
            .map((e) => XCMVersionedAssetId.deserializeJson(e))
            .toList());
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMVersionedAssetId.layout_(),
          property: "assets")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.map((e) => e.serializeJsonVariant()).toList()};
  }
}

abstract class XCMVersionedAssets extends SubstrateVariantSerialization {
  final XCMVersion type;
  XCMAssets get assets;
  const XCMVersionedAssets({required this.type});
  factory XCMVersionedAssets.deserialize(List<int> bytes) {
    final json = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    final asset = XCMVersionedAssets.deserializeJson(json);
    return asset;
  }
  factory XCMVersionedAssets.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMVersion.fromName(decode.variantName);
    return switch (type) {
      XCMVersion.v3 => XCMVersionedAssetsV3.deserializeJson(decode.value),
      XCMVersion.v4 => XCMVersionedAssetsV4.deserializeJson(decode.value),
      XCMVersion.v5 => XCMVersionedAssetsV5.deserializeJson(decode.value),
      XCMVersion.v2 => XCMVersionedAssetsV2.deserializeJson(decode.value)
    };
  }
  factory XCMVersionedAssets.fromJson(Map<String, dynamic> json) {
    final type = XCMVersion.fromType(json.keys.firstOrNull);
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(type.type);
    return switch (type) {
      XCMVersion.v3 => XCMVersionedAssetsV3(
          assets: XCMV3MultiAssets(
              assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList())),
      XCMVersion.v4 => XCMVersionedAssetsV4(
          assets: XCMV4Assets(
              assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList())),
      XCMVersion.v5 => XCMVersionedAssetsV5(
          assets: XCMV5Assets(
              assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList())),
      XCMVersion.v2 => XCMVersionedAssetsV2(
          assets: XCMV2MultiAssets(
              assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()))
    };
  }
  factory XCMVersionedAssets.fromVersion(
      {required List<XCMAsset> assets,
      required XCMVersion version,
      bool sort = true}) {
    if (sort) {
      assets = assets.clone()..sort((a, b) => a.compareTo(b));
    }
    return switch (version) {
      XCMVersion.v2 => XCMVersionedAssetsV2(
          assets: XCMV2MultiAssets(assets: assets.cast<XCMV2MultiAsset>())),
      XCMVersion.v3 => XCMVersionedAssetsV3(
          assets: XCMV3MultiAssets(assets: assets.cast<XCMV3MultiAsset>())),
      XCMVersion.v4 => XCMVersionedAssetsV4(
          assets: XCMV4Assets(assets: assets.cast<XCMV4Asset>())),
      XCMVersion.v5 => XCMVersionedAssetsV5(
          assets: XCMV5Assets(assets: assets.cast<XCMV5Asset>())),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetsV2.layout_(property: property),
          property: XCMVersion.v2.name,
          index: 1),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetsV3.layout_(property: property),
          property: XCMVersion.v3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetsV4.layout_(property: property),
          property: XCMVersion.v4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetsV5.layout_(property: property),
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

  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }
}

class XCMVersionedAssetsV2 extends XCMVersionedAssets {
  @override
  final XCMV2MultiAssets assets;
  XCMVersionedAssetsV2({required this.assets}) : super(type: XCMVersion.v2);

  factory XCMVersionedAssetsV2.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetsV2(
        assets: XCMV2MultiAssets.deserializeJson(json["assets"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2MultiAssets.layout_(property: "assets")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.serializeJson()};
  }
}

class XCMVersionedAssetsV3 extends XCMVersionedAssets {
  @override
  final XCMV3MultiAssets assets;
  XCMVersionedAssetsV3({required this.assets}) : super(type: XCMVersion.v3);

  factory XCMVersionedAssetsV3.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetsV3(
        assets: XCMV3MultiAssets.deserializeJson(json["assets"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3MultiAssets.layout_(property: "assets")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.serializeJson()};
  }
}

class XCMVersionedAssetsV4 extends XCMVersionedAssets {
  @override
  final XCMV4Assets assets;
  XCMVersionedAssetsV4({required this.assets}) : super(type: XCMVersion.v4);

  factory XCMVersionedAssetsV4.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetsV4(
        assets: XCMV4Assets.deserializeJson(json["assets"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4Assets.layout_(property: "assets")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.serializeJson()};
  }
}

class XCMVersionedAssetsV5 extends XCMVersionedAssets {
  @override
  final XCMV5Assets assets;
  XCMVersionedAssetsV5({required this.assets}) : super(type: XCMVersion.v5);

  factory XCMVersionedAssetsV5.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetsV5(
        assets: XCMV5Assets.deserializeJson(json["assets"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5Assets.layout_(property: "assets")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.serializeJson()};
  }
}

abstract class XCMVersionedAsset extends SubstrateVariantSerialization {
  final XCMVersion type;
  XCMAsset get asset;
  const XCMVersionedAsset({required this.type});
  factory XCMVersionedAsset.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMVersion.fromName(decode.variantName);
    return switch (type) {
      XCMVersion.v2 => XCMVersionedAssetV2.deserializeJson(decode.value),
      XCMVersion.v3 => XCMVersionedAssetV3.deserializeJson(decode.value),
      XCMVersion.v4 => XCMVersionedAssetV4.deserializeJson(decode.value),
      XCMVersion.v5 => XCMVersionedAssetV5.deserializeJson(decode.value),
    };
  }

  factory XCMVersionedAsset.fromAsset(XCMAsset asset) {
    return switch (asset.version) {
      XCMVersion.v2 => XCMVersionedAssetV2(asset: asset.cast()),
      XCMVersion.v3 => XCMVersionedAssetV3(asset: asset.cast()),
      XCMVersion.v4 => XCMVersionedAssetV4(asset: asset.cast()),
      XCMVersion.v5 => XCMVersionedAssetV5(asset: asset.cast()),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetV2.layout_(property: property),
          property: XCMVersion.v2.name,
          index: XCMVersion.v2.version),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetV3.layout_(property: property),
          property: XCMVersion.v3.name,
          index: XCMVersion.v3.version),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetV4.layout_(property: property),
          property: XCMVersion.v4.name,
          index: XCMVersion.v4.version),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedAssetV5.layout_(property: property),
          property: XCMVersion.v5.name,
          index: XCMVersion.v5.version),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;

  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }
}

class XCMVersionedAssetV2 extends XCMVersionedAsset {
  @override
  final XCMV2MultiAsset asset;
  XCMVersionedAssetV2({required this.asset}) : super(type: XCMVersion.v2);

  factory XCMVersionedAssetV2.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetV2(
        asset: XCMV2MultiAsset.deserializeJson(json["asset"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2MultiAsset.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson()};
  }
}

class XCMVersionedAssetV3 extends XCMVersionedAsset {
  @override
  final XCMV3MultiAsset asset;
  XCMVersionedAssetV3({required this.asset}) : super(type: XCMVersion.v3);

  factory XCMVersionedAssetV3.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetV3(
        asset: XCMV3MultiAsset.deserializeJson(json["asset"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3MultiAsset.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson()};
  }
}

class XCMVersionedAssetV4 extends XCMVersionedAsset {
  @override
  final XCMV4Asset asset;
  XCMVersionedAssetV4({required this.asset}) : super(type: XCMVersion.v4);

  factory XCMVersionedAssetV4.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetV4(
        asset: XCMV4Asset.deserializeJson(json["asset"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4Asset.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson()};
  }
}

class XCMVersionedAssetV5 extends XCMVersionedAsset {
  @override
  final XCMV5Asset asset;
  XCMVersionedAssetV5({required this.asset}) : super(type: XCMVersion.v5);

  factory XCMVersionedAssetV5.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedAssetV5(
        asset: XCMV5Asset.deserializeJson(json["asset"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5Asset.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson()};
  }
}

abstract class XCMVersionedLocation extends SubstrateVariantSerialization
    with Equality {
  final XCMVersion version;
  XCMMultiLocation get location;

  const XCMVersionedLocation({required this.version});
  factory XCMVersionedLocation.deserialize(List<int> bytes) {
    final decode = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    final location = XCMVersionedLocation.deserializeJson(decode);
    return location;
  }

  factory XCMVersionedLocation.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMVersion.fromName(decode.variantName);
    return switch (type) {
      XCMVersion.v2 => XCMVersionedLocationV2.deserializeJson(decode.value),
      XCMVersion.v3 => XCMVersionedLocationV3.deserializeJson(decode.value),
      XCMVersion.v4 => XCMVersionedLocationV4.deserializeJson(decode.value),
      XCMVersion.v5 => XCMVersionedLocationV5.deserializeJson(decode.value),
    };
  }
  factory XCMVersionedLocation.fromJson(Map<String, dynamic> json) {
    final type = XCMVersion.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMVersion.v2 => XCMVersionedLocationV2.fromJson(json),
      XCMVersion.v3 => XCMVersionedLocationV3.fromJson(json),
      XCMVersion.v4 => XCMVersionedLocationV4.fromJson(json),
      XCMVersion.v5 => XCMVersionedLocationV5.fromJson(json),
    };
  }

  factory XCMVersionedLocation.fromLocation(XCMMultiLocation location) {
    return switch (location.version) {
      XCMVersion.v2 => XCMVersionedLocationV2(location: location.cast()),
      XCMVersion.v3 => XCMVersionedLocationV3(location: location.cast()),
      XCMVersion.v4 => XCMVersionedLocationV4(location: location.cast()),
      XCMVersion.v5 => XCMVersionedLocationV5(location: location.cast()),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) {
            return XCMVersionedLocationV2.layout_(property: property);
          },
          property: XCMVersion.v2.name,
          index: 1),
      LazyVariantModel(
          layout: ({property}) {
            return XCMVersionedLocationV3.layout_(property: property);
          },
          property: XCMVersion.v3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedLocationV4.layout_(property: property),
          property: XCMVersion.v4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMVersionedLocationV5.layout_(property: property),
          property: XCMVersion.v5.name,
          index: 5),
    ], property: property);
  }

  T cast<T extends XCMVersionedLocation>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  XCMVersionedLocation asVersion(XCMVersion version) {
    if (version == this.version) return this;
    return switch (version) {
      XCMVersion.v2 =>
        XCMVersionedLocationV2(location: location.asVersion(version)),
      XCMVersion.v3 =>
        XCMVersionedLocationV3(location: location.asVersion(version)),
      XCMVersion.v4 =>
        XCMVersionedLocationV4(location: location.asVersion(version)),
      XCMVersion.v5 =>
        XCMVersionedLocationV5(location: location.asVersion(version))
    }
        .cast();
  }

  Map<String, dynamic> toJson();

  @override
  String get variantName => version.name;

  @override
  List get variabels => [version, location];
}

class XCMVersionedLocationV2 extends XCMVersionedLocation {
  @override
  final XCMV2MultiLocation location;
  XCMVersionedLocationV2({required this.location})
      : super(version: XCMVersion.v2);

  factory XCMVersionedLocationV2.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV2(
        location: XCMV2MultiLocation.deserializeJson(json["location"]));
  }
  factory XCMVersionedLocationV2.fromJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV2(
        location:
            XCMV2MultiLocation.fromJson(json.valueAs(XCMVersion.v2.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV2MultiLocation.layout_(property: "location")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: location.toJson()};
  }
}

class XCMVersionedLocationV3 extends XCMVersionedLocation {
  @override
  final XCMV3MultiLocation location;
  const XCMVersionedLocationV3({required this.location})
      : super(version: XCMVersion.v3);

  factory XCMVersionedLocationV3.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV3(
        location: XCMV3MultiLocation.deserializeJson(json["location"]));
  }
  factory XCMVersionedLocationV3.fromJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV3(
        location:
            XCMV3MultiLocation.fromJson(json.valueAs(XCMVersion.v3.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV3MultiLocation.layout_(property: "location")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: location.toJson()};
  }
}

class XCMVersionedLocationV4 extends XCMVersionedLocation {
  @override
  final XCMV4Location location;
  XCMVersionedLocationV4({required this.location})
      : super(version: XCMVersion.v4);

  factory XCMVersionedLocationV4.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV4(
        location: XCMV4Location.deserializeJson(json["location"]));
  }
  factory XCMVersionedLocationV4.fromJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV4(
        location: XCMV4Location.fromJson(json.valueAs(XCMVersion.v4.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4Location.layout_(property: "location")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: location.toJson()};
  }
}

class XCMVersionedLocationV5 extends XCMVersionedLocation {
  @override
  final XCMV5Location location;
  XCMVersionedLocationV5({required this.location})
      : super(version: XCMVersion.v5);

  factory XCMVersionedLocationV5.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV5(
        location: XCMV5Location.deserializeJson(json["location"]));
  }
  factory XCMVersionedLocationV5.fromJson(Map<String, dynamic> json) {
    return XCMVersionedLocationV5(
        location: XCMV5Location.fromJson(json.valueAs(XCMVersion.v5.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5Location.layout_(property: "location")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {version.type: location.toJson()};
  }
}

class XCMVersionedLocations
    extends SubstrateSerialization<Map<String, dynamic>> {
  final List<XCMVersionedLocation> locations;
  XCMVersionedLocations({required this.locations});
  factory XCMVersionedLocations.deserialize(List<int> bytes) {
    final json =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    final locations = XCMVersionedLocations.deserializeJson(json.value);
    return locations;
  }
  factory XCMVersionedLocations.deserializeJson(Map<String, dynamic> json) {
    return XCMVersionedLocations(
        locations: (json["locations"] as List)
            .map((e) => XCMVersionedLocation.deserializeJson(e))
            .toList());
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMVersionedLocation.layout_(),
          property: "locations")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "locations": locations.map((e) => e.serializeJsonVariant()).toList()
    };
  }
}
