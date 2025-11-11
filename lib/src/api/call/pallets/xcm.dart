import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/models/modesl.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

enum XCMTransferTypeType implements SubstrateCallPalletXCMTransferMethod {
  teleport("Teleport", 0),
  localReserve("LocalReserve", 1),
  destinationReserve("DestinationReserve", 2),
  remoteReserve("RemoteReserve", 3);

  const XCMTransferTypeType(this.method, this.variantIndex);
  @override
  final String method;
  final int variantIndex;

  static XCMTransferTypeType fromMethod(String? type) {
    return values.firstWhere(
      (e) => e.method == type,
      orElse: () => throw ItemNotFoundException(value: type),
    );
  }

  static XCMTransferTypeType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMTransferType extends SubstrateVariantSerialization
    with Equality {
  XCMTransferTypeType get type;
  const XCMTransferType();
  Map<String, dynamic> toJson();
  factory XCMTransferType.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMTransferTypeType.fromName(decode.variantName);
    return switch (type) {
      XCMTransferTypeType.teleport => XCMTransferTypeTeleport(),
      XCMTransferTypeType.localReserve => XCMTransferTypeLocalReserve(),
      XCMTransferTypeType.destinationReserve =>
        XCMTransferTypeDestinationReserve(),
      XCMTransferTypeType.remoteReserve =>
        XCMTransferTypeRemoteReserve.deserializeJson(decode.value),
    };
  }
  factory XCMTransferType.fromJson(Map<String, dynamic> json) {
    final type = XCMTransferTypeType.fromMethod(json.keys.firstOrNull);
    return switch (type) {
      XCMTransferTypeType.teleport => XCMTransferTypeTeleport.fromJson(json),
      XCMTransferTypeType.localReserve =>
        XCMTransferTypeLocalReserve.fromJson(json),
      XCMTransferTypeType.destinationReserve =>
        XCMTransferTypeDestinationReserve.fromJson(json),
      XCMTransferTypeType.remoteReserve =>
        XCMTransferTypeRemoteReserve.fromJson(json),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMTransferTypeType.teleport.name,
        index: XCMTransferTypeType.teleport.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMTransferTypeType.localReserve.name,
        index: XCMTransferTypeType.localReserve.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMTransferTypeType.destinationReserve.name,
        index: XCMTransferTypeType.destinationReserve.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMTransferTypeRemoteReserve.layout_(property: property),
        property: XCMTransferTypeType.remoteReserve.name,
        index: XCMTransferTypeType.remoteReserve.variantIndex,
      )
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
}

class XCMTransferTypeTeleport extends XCMTransferType
    with SubstrateVariantNoArgs {
  const XCMTransferTypeTeleport();
  factory XCMTransferTypeTeleport.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMTransferTypeType.teleport.method);
    return XCMTransferTypeTeleport();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.method: null};
  }

  @override
  XCMTransferTypeType get type => XCMTransferTypeType.teleport;
  @override
  List get variabels => [type];
}

class XCMTransferTypeLocalReserve extends XCMTransferType
    with SubstrateVariantNoArgs {
  const XCMTransferTypeLocalReserve();
  factory XCMTransferTypeLocalReserve.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMTransferTypeType.localReserve.method);
    return XCMTransferTypeLocalReserve();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.method: null};
  }

  @override
  XCMTransferTypeType get type => XCMTransferTypeType.localReserve;
  @override
  List get variabels => [type];
}

class XCMTransferTypeDestinationReserve extends XCMTransferType
    with SubstrateVariantNoArgs {
  const XCMTransferTypeDestinationReserve();
  factory XCMTransferTypeDestinationReserve.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMTransferTypeType.destinationReserve.method);
    return XCMTransferTypeDestinationReserve();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.method: null};
  }

  @override
  XCMTransferTypeType get type => XCMTransferTypeType.destinationReserve;
  @override
  List get variabels => [type];
}

class XCMTransferTypeRemoteReserve extends XCMTransferType {
  final XCMVersionedLocation location;
  @override
  XCMTransferTypeType get type => XCMTransferTypeType.remoteReserve;
  const XCMTransferTypeRemoteReserve({required this.location});
  factory XCMTransferTypeRemoteReserve.deserializeJson(
      Map<String, dynamic> json) {
    return XCMTransferTypeRemoteReserve(
        location: XCMVersionedLocation.deserializeJson(json["location"]));
  }
  factory XCMTransferTypeRemoteReserve.fromJson(Map<String, dynamic> json) {
    return XCMTransferTypeRemoteReserve(
        location: XCMVersionedLocation.fromJson(
            json.valueAs(XCMTransferTypeType.remoteReserve.method)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMVersionedLocation.layout_(property: "location")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.method: location.toJson()};
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location.serializeJsonVariant()};
  }

  @override
  List get variabels => [type, location];
}

enum XCMCallPalletMethod implements SubstrateCallPalletXCMTransferMethod {
  send("send", 0),
  teleportAssets("teleport_assets", 1),
  reserveTransferAssets("reserve_transfer_assets", 2),
  limitedReserveTransferAssets("limited_reserve_transfer_assets", 8),
  limitedTeleportAssets("limited_teleport_assets", 9),
  transferAssets("transfer_assets", 11),
  claimAssets("claim_assets", 12),
  transferAssetsUsingTypeAndThen("transfer_assets_using_type_and_then", 13);

  @override
  final String method;
  final int variantIndex;
  const XCMCallPalletMethod(this.method, this.variantIndex);
  static XCMCallPalletMethod fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMCallPalletMethod fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class XCMCallPallet extends SubstrateVariantSerialization
    with SubstrateCallPallet
    implements SubstrateXCMCallPallet {
  @override
  final XCMCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
  const XCMCallPallet({required this.type, required this.pallet});
  factory XCMCallPallet.deserialize(List<int> bytes) {
    final decode = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    return XCMCallPallet.deserializeJson(decode);
  }
  factory XCMCallPallet.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMCallPalletMethod.fromName(decode.variantName);
    return switch (type) {
      XCMCallPalletMethod.send =>
        XCMCallPalletSend.deserializeJson(decode.value),
      XCMCallPalletMethod.teleportAssets =>
        XCMCallPalletTeleportAssets.deserializeJson(decode.value),
      XCMCallPalletMethod.reserveTransferAssets =>
        XCMCallPalletReserveTransferAssets.deserializeJson(decode.value),
      XCMCallPalletMethod.limitedReserveTransferAssets =>
        XCMCallPalletLimitedReserveTransferAssets.deserializeJson(decode.value),
      XCMCallPalletMethod.limitedTeleportAssets =>
        XCMCallPalletLimitedTeleportAssets.deserializeJson(decode.value),
      XCMCallPalletMethod.transferAssets =>
        XCMCallPalletTransferAssets.deserializeJson(decode.value),
      XCMCallPalletMethod.claimAssets =>
        XCMCallPalletClaimAssets.deserializeJson(decode.value),
      XCMCallPalletMethod.transferAssetsUsingTypeAndThen =>
        XCMCallPalletTransferAssetsUsingTypeAndThen.deserializeJson(
            decode.value),
    };
  }
  factory XCMCallPallet.fromJson(Map<String, dynamic> json) {
    final type = XCMCallPalletMethod.fromMethod(json.keys.firstOrNull);
    return switch (type) {
      XCMCallPalletMethod.send => XCMCallPalletSend.fromJson(json),
      XCMCallPalletMethod.teleportAssets =>
        XCMCallPalletTeleportAssets.fromJson(json),
      XCMCallPalletMethod.reserveTransferAssets =>
        XCMCallPalletReserveTransferAssets.fromJson(json),
      XCMCallPalletMethod.limitedReserveTransferAssets =>
        XCMCallPalletLimitedReserveTransferAssets.fromJson(json),
      XCMCallPalletMethod.limitedTeleportAssets =>
        XCMCallPalletLimitedTeleportAssets.fromJson(json),
      XCMCallPalletMethod.transferAssets =>
        XCMCallPalletTransferAssets.fromJson(json),
      XCMCallPalletMethod.claimAssets =>
        XCMCallPalletClaimAssets.fromJson(json),
      XCMCallPalletMethod.transferAssetsUsingTypeAndThen =>
        XCMCallPalletTransferAssetsUsingTypeAndThen.fromJson(json),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum(
        XCMCallPalletMethod.values
            .map((e) => LazyVariantModel(
                index: e.variantIndex,
                property: e.name,
                layout: ({property}) => switch (e) {
                      XCMCallPalletMethod.send =>
                        XCMCallPalletSend.layout_(property: property),
                      XCMCallPalletMethod.teleportAssets =>
                        XCMCallPalletTeleportAssets.layout_(property: property),
                      XCMCallPalletMethod.reserveTransferAssets =>
                        XCMCallPalletReserveTransferAssets.layout_(
                            property: property),
                      XCMCallPalletMethod.limitedReserveTransferAssets =>
                        XCMCallPalletLimitedReserveTransferAssets.layout_(
                            property: property),
                      XCMCallPalletMethod.limitedTeleportAssets =>
                        XCMCallPalletLimitedTeleportAssets.layout_(
                            property: property),
                      XCMCallPalletMethod.transferAssets =>
                        XCMCallPalletTransferAssets.layout_(property: property),
                      XCMCallPalletMethod.claimAssets =>
                        XCMCallPalletClaimAssets.layout_(property: property),
                      XCMCallPalletMethod.transferAssetsUsingTypeAndThen =>
                        XCMCallPalletTransferAssetsUsingTypeAndThen.layout_(
                            property: property),
                    }))
            .toList(),
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api.encodeCall(
        palletNameOrIndex: pallet ?? this.pallet.name,
        value: toJson(method: method));
  }
}

class XCMCallPalletSend extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedXCM message;
  const XCMCallPalletSend(
      {required this.dest,
      required this.message,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.send);
  factory XCMCallPalletSend.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletSend.deserializeJson(decode.value);
  }
  factory XCMCallPalletSend.deserializeJson(Map<String, dynamic> json) {
    return XCMCallPalletSend(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        message: XCMVersionedXCM.deserializeJson(json.valueAs("message")));
  }
  factory XCMCallPalletSend.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap(XCMCallPalletMethod.send.method);
    return XCMCallPalletSend(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        message: XCMVersionedXCM.fromJson(data.valueAs("message")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedXCM.layout_(property: "message")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "message": message.serializeJsonVariant()
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "message": message.toJson()
      }
    };
  }

  @override
  XCMMultiLocation get destination => dest.location;
}

class XCMCallPalletTeleportAssets extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedLocation beneficiary;
  final XCMVersionedAssets assets;
  final int feeAssetItem;
  @override
  XCMMultiLocation get destination => dest.location;
  const XCMCallPalletTeleportAssets(
      {required this.dest,
      required this.beneficiary,
      required this.assets,
      required this.feeAssetItem,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.teleportAssets);
  factory XCMCallPalletTeleportAssets.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletTeleportAssets.deserializeJson(decode.value);
  }
  factory XCMCallPalletTeleportAssets.deserializeJson(
      Map<String, dynamic> json) {
    return XCMCallPalletTeleportAssets(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        beneficiary:
            XCMVersionedLocation.deserializeJson(json.valueAs("beneficiary")),
        assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
        feeAssetItem: json.valueAs("fee_asset_item"));
  }
  factory XCMCallPalletTeleportAssets.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsMap(XCMCallPalletMethod.teleportAssets.method);
    return XCMCallPalletTeleportAssets(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        beneficiary: XCMVersionedLocation.fromJson(data.valueAs("beneficiary")),
        assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
        feeAssetItem: data.valueAs("fee_asset_item"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedLocation.layout_(property: "beneficiary"),
      XCMVersionedAssets.layout_(property: "assets"),
      LayoutConst.u32(property: "fee_asset_item"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "beneficiary": beneficiary.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
      "fee_asset_item": feeAssetItem
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "beneficiary": beneficiary.toJson(),
        "assets": assets.toJson(),
        "fee_asset_item": feeAssetItem
      }
    };
  }
}

class XCMCallPalletReserveTransferAssets extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedLocation beneficiary;
  final XCMVersionedAssets assets;
  final int feeAssetItem;
  @override
  XCMMultiLocation get destination => dest.location;
  const XCMCallPalletReserveTransferAssets(
      {required this.dest,
      required this.beneficiary,
      required this.assets,
      required this.feeAssetItem,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.reserveTransferAssets);
  factory XCMCallPalletReserveTransferAssets.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletReserveTransferAssets.deserializeJson(decode.value);
  }
  factory XCMCallPalletReserveTransferAssets.deserializeJson(
      Map<String, dynamic> json) {
    return XCMCallPalletReserveTransferAssets(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        beneficiary:
            XCMVersionedLocation.deserializeJson(json.valueAs("beneficiary")),
        assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
        feeAssetItem: json.valueAs("fee_asset_item"));
  }
  factory XCMCallPalletReserveTransferAssets.fromJson(
      Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsMap(XCMCallPalletMethod.reserveTransferAssets.method);
    return XCMCallPalletReserveTransferAssets(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        beneficiary: XCMVersionedLocation.fromJson(data.valueAs("beneficiary")),
        assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
        feeAssetItem: data.valueAs("fee_asset_item"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedLocation.layout_(property: "beneficiary"),
      XCMVersionedAssets.layout_(property: "assets"),
      LayoutConst.u32(property: "fee_asset_item"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "beneficiary": beneficiary.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
      "fee_asset_item": feeAssetItem
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "beneficiary": beneficiary.toJson(),
        "assets": assets.toJson(),
        "fee_asset_item": feeAssetItem
      }
    };
  }
}

class XCMCallPalletLimitedReserveTransferAssets extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedLocation beneficiary;
  final XCMVersionedAssets assets;
  final int feeAssetItem;
  final WeightLimit weightLimit;
  final XCMVersion version;
  @override
  XCMMultiLocation get destination => dest.location;
  const XCMCallPalletLimitedReserveTransferAssets(
      {required this.dest,
      required this.beneficiary,
      required this.assets,
      required this.feeAssetItem,
      required this.version,
      required this.weightLimit,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.limitedReserveTransferAssets);
  factory XCMCallPalletLimitedReserveTransferAssets.deserialize(
      List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletLimitedReserveTransferAssets.deserializeJson(
        decode.value);
  }
  factory XCMCallPalletLimitedReserveTransferAssets.deserializeJson(
      Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    return XCMCallPalletLimitedReserveTransferAssets(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        beneficiary:
            XCMVersionedLocation.deserializeJson(json.valueAs("beneficiary")),
        assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
        feeAssetItem: json.valueAs("fee_asset_item"),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.deserializeJson(json.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit"))
        });
  }
  factory XCMCallPalletLimitedReserveTransferAssets.fromJson(
      Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    final data = json.valueEnsureAsMap(
        XCMCallPalletMethod.limitedReserveTransferAssets.method);
    return XCMCallPalletLimitedReserveTransferAssets(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        beneficiary: XCMVersionedLocation.fromJson(data.valueAs("beneficiary")),
        assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
        feeAssetItem: data.valueAs("fee_asset_item"),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.fromJson(data.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.fromJson(data.valueAs("weight_limit"))
        });
  }

  static Layout<Map<String, dynamic>> layout_(
      {String? property, XCMVersion version = XCMVersion.v3}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedLocation.layout_(property: "beneficiary"),
      XCMVersionedAssets.layout_(property: "assets"),
      LayoutConst.u32(property: "fee_asset_item"),
      switch (version) {
        XCMVersion.v2 => XCMV2WeightLimit.layout_(property: "weight_limit"),
        _ => XCMV3WeightLimit.layout_(property: "weight_limit")
      }
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "beneficiary": beneficiary.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
      "fee_asset_item": feeAssetItem,
      "weight_limit": weightLimit.serializeJsonVariant()
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "beneficiary": beneficiary.toJson(),
        "assets": assets.toJson(),
        "fee_asset_item": feeAssetItem,
        "weight_limit": weightLimit.toJson()
      }
    };
  }
}

class XCMCallPalletLimitedTeleportAssets extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedLocation beneficiary;
  final XCMVersionedAssets assets;
  final int feeAssetItem;
  final WeightLimit weightLimit;
  final XCMVersion version;
  @override
  XCMMultiLocation get destination => dest.location;
  const XCMCallPalletLimitedTeleportAssets(
      {required this.dest,
      required this.beneficiary,
      required this.assets,
      required this.feeAssetItem,
      required this.version,
      required this.weightLimit,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.limitedTeleportAssets);
  factory XCMCallPalletLimitedTeleportAssets.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletLimitedTeleportAssets.deserializeJson(decode.value);
  }
  factory XCMCallPalletLimitedTeleportAssets.deserializeJson(
      Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    return XCMCallPalletLimitedTeleportAssets(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        beneficiary:
            XCMVersionedLocation.deserializeJson(json.valueAs("beneficiary")),
        assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
        feeAssetItem: json.valueAs("fee_asset_item"),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.deserializeJson(json.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit"))
        });
  }
  factory XCMCallPalletLimitedTeleportAssets.fromJson(Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    final data =
        json.valueEnsureAsMap(XCMCallPalletMethod.limitedTeleportAssets.method);
    return XCMCallPalletLimitedTeleportAssets(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        beneficiary: XCMVersionedLocation.fromJson(data.valueAs("beneficiary")),
        assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
        feeAssetItem: data.valueAs("fee_asset_item"),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.fromJson(data.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.fromJson(data.valueAs("weight_limit"))
        });
  }

  static Layout<Map<String, dynamic>> layout_(
      {String? property, XCMVersion version = XCMVersion.v3}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedLocation.layout_(property: "beneficiary"),
      XCMVersionedAssets.layout_(property: "assets"),
      LayoutConst.u32(property: "fee_asset_item"),
      switch (version) {
        XCMVersion.v2 => XCMV2WeightLimit.layout_(property: "weight_limit"),
        _ => XCMV3WeightLimit.layout_(property: "weight_limit")
      }
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "beneficiary": beneficiary.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
      "fee_asset_item": feeAssetItem,
      "weight_limit": weightLimit.serializeJsonVariant()
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "beneficiary": beneficiary.toJson(),
        "assets": assets.toJson(),
        "fee_asset_item": feeAssetItem,
        "weight_limit": weightLimit.toJson()
      }
    };
  }
}

class XCMCallPalletTransferAssets extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedLocation beneficiary;
  final XCMVersionedAssets assets;
  final int feeAssetItem;
  final WeightLimit weightLimit;
  final XCMVersion version;
  @override
  XCMMultiLocation get destination => dest.location;
  const XCMCallPalletTransferAssets(
      {required this.dest,
      required this.beneficiary,
      required this.assets,
      required this.feeAssetItem,
      required this.version,
      required this.weightLimit,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.transferAssets);
  factory XCMCallPalletTransferAssets.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletTransferAssets.deserializeJson(decode.value);
  }
  factory XCMCallPalletTransferAssets.deserializeJson(Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    return XCMCallPalletTransferAssets(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        beneficiary:
            XCMVersionedLocation.deserializeJson(json.valueAs("beneficiary")),
        assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
        feeAssetItem: json.valueAs("fee_asset_item"),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.fromJson(json.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.fromJson(json.valueAs("weight_limit"))
        });
  }
  factory XCMCallPalletTransferAssets.fromJson(Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    final data =
        json.valueEnsureAsMap(XCMCallPalletMethod.transferAssets.method);
    return XCMCallPalletTransferAssets(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        beneficiary: XCMVersionedLocation.fromJson(data.valueAs("beneficiary")),
        assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
        feeAssetItem: data.valueAs("fee_asset_item"),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.fromJson(json.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.fromJson(json.valueAs("weight_limit"))
        });
  }

  static Layout<Map<String, dynamic>> layout_(
      {String? property, XCMVersion version = XCMVersion.v3}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedLocation.layout_(property: "beneficiary"),
      XCMVersionedAssets.layout_(property: "assets"),
      LayoutConst.u32(property: "fee_asset_item"),
      switch (version) {
        XCMVersion.v2 => XCMV2WeightLimit.layout_(property: "weight_limit"),
        _ => XCMV3WeightLimit.layout_(property: "weight_limit")
      }
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "beneficiary": beneficiary.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
      "fee_asset_item": feeAssetItem,
      "weight_limit": weightLimit.serializeJsonVariant()
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "beneficiary": beneficiary.toJson(),
        "assets": assets.toJson(),
        "fee_asset_item": feeAssetItem,
        "weight_limit": weightLimit.toJson()
      }
    };
  }
}

class XCMCallPalletClaimAssets extends XCMCallPallet {
  final XCMVersionedAssets assets;
  final XCMVersionedLocation beneficiary;
  @override
  XCMMultiLocation get destination => throw UnimplementedError();
  const XCMCallPalletClaimAssets(
      {required this.beneficiary,
      required this.assets,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.claimAssets);
  factory XCMCallPalletClaimAssets.deserialize(List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletClaimAssets.deserializeJson(decode.value);
  }
  factory XCMCallPalletClaimAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMCallPalletClaimAssets(
      beneficiary:
          XCMVersionedLocation.deserializeJson(json.valueAs("beneficiary")),
      assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMCallPalletClaimAssets.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap(XCMCallPalletMethod.claimAssets.method);
    return XCMCallPalletClaimAssets(
      beneficiary: XCMVersionedLocation.fromJson(data.valueAs("beneficiary")),
      assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
    );
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMVersionedAssets.layout_(property: "assets"),
      XCMVersionedLocation.layout_(property: "beneficiary"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "beneficiary": beneficiary.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "beneficiary": beneficiary.toJson(),
        "assets": assets.toJson(),
      }
    };
  }
}

class XCMCallPalletTransferAssetsUsingTypeAndThen extends XCMCallPallet {
  final XCMVersionedLocation dest;
  final XCMVersionedAssets assets;
  final XCMTransferType assetsTransferType;
  final XCMVersionedAssetId remoteFeesId;
  final XCMTransferType feesTransferType;
  final XCMVersionedXCM customXcmOnDest;

  final WeightLimit weightLimit;
  final XCMVersion version;
  @override
  XCMMultiLocation get destination => dest.location;
  const XCMCallPalletTransferAssetsUsingTypeAndThen(
      {required this.dest,
      required this.assets,
      required this.assetsTransferType,
      required this.remoteFeesId,
      required this.feesTransferType,
      required this.customXcmOnDest,
      required this.version,
      required this.weightLimit,
      super.pallet = SubtrateMetadataPallet.polkadotXcm})
      : super(type: XCMCallPalletMethod.transferAssetsUsingTypeAndThen);
  factory XCMCallPalletTransferAssetsUsingTypeAndThen.deserialize(
      List<int> bytes) {
    final decode =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMCallPalletTransferAssetsUsingTypeAndThen.deserializeJson(
        decode.value);
  }
  factory XCMCallPalletTransferAssetsUsingTypeAndThen.deserializeJson(
      Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    return XCMCallPalletTransferAssetsUsingTypeAndThen(
        dest: XCMVersionedLocation.deserializeJson(json.valueAs("dest")),
        assets: XCMVersionedAssets.deserializeJson(json.valueAs("assets")),
        assetsTransferType: XCMTransferType.deserializeJson(
            json.valueAs("assets_transfer_type")),
        remoteFeesId:
            XCMVersionedAssetId.deserializeJson(json.valueAs("remote_fees_id")),
        feesTransferType:
            XCMTransferType.deserializeJson(json.valueAs("fees_transfer_type")),
        customXcmOnDest:
            XCMVersionedXCM.deserializeJson(json.valueAs("custom_xcm_on_dest")),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.deserializeJson(json.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit"))
        });
  }
  factory XCMCallPalletTransferAssetsUsingTypeAndThen.fromJson(
      Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v3}) {
    final data = json.valueEnsureAsMap(
        XCMCallPalletMethod.transferAssetsUsingTypeAndThen.method);
    return XCMCallPalletTransferAssetsUsingTypeAndThen(
        dest: XCMVersionedLocation.fromJson(data.valueAs("dest")),
        assets: XCMVersionedAssets.fromJson(data.valueAs("assets")),
        assetsTransferType:
            XCMTransferType.fromJson(data.valueAs("assets_transfer_type")),
        remoteFeesId:
            XCMVersionedAssetId.fromJson(data.valueAs("remote_fees_id")),
        feesTransferType:
            XCMTransferType.fromJson(data.valueAs("fees_transfer_type")),
        customXcmOnDest:
            XCMVersionedXCM.fromJson(data.valueAs("custom_xcm_on_dest")),
        version: version,
        weightLimit: switch (version) {
          XCMVersion.v2 =>
            XCMV2WeightLimit.fromJson(data.valueAs("weight_limit")),
          _ => XCMV3WeightLimit.fromJson(data.valueAs("weight_limit"))
        });
  }

  static Layout<Map<String, dynamic>> layout_(
      {String? property, XCMVersion version = XCMVersion.v3}) {
    return LayoutConst.struct([
      XCMVersionedLocation.layout_(property: "dest"),
      XCMVersionedAssets.layout_(property: "assets"),
      XCMTransferType.layout_(property: "assets_transfer_type"),
      XCMVersionedAssetId.layout_(property: "remote_fees_id"),
      XCMTransferType.layout_(property: "fees_transfer_type"),
      XCMVersionedXCM.layout_(property: "custom_xcm_on_dest"),
      switch (version) {
        XCMVersion.v2 => XCMV2WeightLimit.layout_(property: "weight_limit"),
        _ => XCMV3WeightLimit.layout_(property: "weight_limit")
      }
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "dest": dest.serializeJsonVariant(),
      "assets": assets.serializeJsonVariant(),
      "assets_transfer_type": assetsTransferType.serializeJsonVariant(),
      "remote_fees_id": remoteFeesId.serializeJsonVariant(),
      "fees_transfer_type": feesTransferType.serializeJsonVariant(),
      "custom_xcm_on_dest": customXcmOnDest.serializeJsonVariant(),
      "weight_limit": weightLimit.serializeJsonVariant()
    };
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.toJson(),
        "assets": assets.toJson(),
        "assets_transfer_type": assetsTransferType.toJson(),
        "remote_fees_id": remoteFeesId.toJson(),
        "fees_transfer_type": feesTransferType.toJson(),
        "custom_xcm_on_dest": customXcmOnDest.toJson(),
        "weight_limit": weightLimit.toJson(),
      }
    };
  }
}
