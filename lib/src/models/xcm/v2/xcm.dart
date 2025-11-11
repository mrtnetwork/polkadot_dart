import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

abstract class XCMV2WeightLimit extends SubstrateVariantSerialization
    with WeightLimit, Equality {
  @override
  XCMWeightLimitType get type;
  const XCMV2WeightLimit();
  factory XCMV2WeightLimit.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWeightLimitType.fromName(decode.variantName);
    return switch (type) {
      XCMWeightLimitType.unlimited => XCMV2WeightLimitUnlimited(),
      XCMWeightLimitType.limited =>
        XCMV2WeightLimitLimited.deserializeJson(decode.value),
    };
  }

  factory XCMV2WeightLimit.fromJson(Map<String, dynamic> json) {
    final type = XCMWeightLimitType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWeightLimitType.unlimited => XCMV2WeightLimitUnlimited.fromJson(json),
      XCMWeightLimitType.limited => XCMV2WeightLimitLimited.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMWeightLimitType.unlimited.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2WeightLimitLimited.layout_(property: property),
        property: XCMWeightLimitType.limited.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2WeightLimitLimited extends XCMV2WeightLimit {
  final BigInt weight;
  XCMV2WeightLimitLimited({required this.weight}) : super();

  factory XCMV2WeightLimitLimited.deserializeJson(Map<String, dynamic> json) {
    return XCMV2WeightLimitLimited(weight: json.valueAs("weight"));
  }
  factory XCMV2WeightLimitLimited.fromJson(Map<String, dynamic> json) {
    return XCMV2WeightLimitLimited(
        weight: json.valueAs(XCMWeightLimitType.limited.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactBigintU64(property: "weight")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"weight": weight};
  }

  @override
  XCMWeightLimitType get type => XCMWeightLimitType.limited;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: weight};
  }

  @override
  List get variabels => [type, weight];
}

class XCMV2WeightLimitUnlimited extends XCMV2WeightLimit
    with SubstrateVariantNoArgs {
  XCMV2WeightLimitUnlimited() : super();
  factory XCMV2WeightLimitUnlimited.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWeightLimitType.unlimited.type);
    return XCMV2WeightLimitUnlimited();
  }

  @override
  XCMWeightLimitType get type => XCMWeightLimitType.unlimited;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract class XCMInstructionV2 extends SubstrateVariantSerialization
    with XCMInstruction, Equality {
  const XCMInstructionV2();
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMV2WithdrawAsset.layout_(property: property),
        property: XCMInstructionType.withdrawAsset.name,
        index: XCMInstructionType.withdrawAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2ReserveAssetDeposited.layout_(property: property),
        property: XCMInstructionType.reserveAssetDeposited.name,
        index: XCMInstructionType.reserveAssetDeposited.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2ReceiveTeleportedAsset.layout_(property: property),
        property: XCMInstructionType.receiveTeleportedAsset.name,
        index: XCMInstructionType.receiveTeleportedAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2QueryResponse.layout_(property: property),
        property: XCMInstructionType.queryResponse.name,
        index: XCMInstructionType.queryResponse.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2TransferAsset.layout_(property: property),
        property: XCMInstructionType.transferAsset.name,
        index: XCMInstructionType.transferAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2TransferReserveAsset.layout_(property: property),
        property: XCMInstructionType.transferReserveAsset.name,
        index: XCMInstructionType.transferReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2Transact.layout_(property: property),
        property: XCMInstructionType.transact.name,
        index: XCMInstructionType.transact.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2HrmpNewChannelOpenRequest.layout_(property: property),
        property: XCMInstructionType.hrmpNewChannelOpenRequest.name,
        index: XCMInstructionType.hrmpNewChannelOpenRequest.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2HrmpChannelAccepted.layout_(property: property),
        property: XCMInstructionType.hrmpChannelAccepted.name,
        index: XCMInstructionType.hrmpChannelAccepted.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2HrmpChannelClosing.layout_(property: property),
        property: XCMInstructionType.hrmpChannelClosing.name,
        index: XCMInstructionType.hrmpChannelClosing.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.clearOrigin.name,
        index: XCMInstructionType.clearOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2DescendOrigin.layout_(property: property),
        property: XCMInstructionType.descendOrigin.name,
        index: XCMInstructionType.descendOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2ReportError.layout_(property: property),
        property: XCMInstructionType.reportError.name,
        index: XCMInstructionType.reportError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2DepositAsset.layout_(property: property),
        property: XCMInstructionType.depositAsset.name,
        index: XCMInstructionType.depositAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2DepositReserveAsset.layout_(property: property),
        property: XCMInstructionType.depositReserveAsset.name,
        index: XCMInstructionType.depositReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2ExchangeAsset.layout_(property: property),
        property: XCMInstructionType.exchangeAsset.name,
        index: XCMInstructionType.exchangeAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2InitiateReserveWithdraw.layout_(property: property),
        property: XCMInstructionType.initiateReserveWithdraw.name,
        index: XCMInstructionType.initiateReserveWithdraw.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2InitiateTeleport.layout_(property: property),
        property: XCMInstructionType.initiateTeleport.name,
        index: XCMInstructionType.initiateTeleport.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2QueryHolding.layout_(property: property),
        property: XCMInstructionType.queryHolding.name,
        index: XCMInstructionType.queryHolding.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2BuyExecution.layout_(property: property),
        property: XCMInstructionType.buyExecution.name,
        index: XCMInstructionType.buyExecution.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.refundSurplus.name,
        index: XCMInstructionType.refundSurplus.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2SetErrorHandler.layout_(property: property),
        property: XCMInstructionType.setErrorHandler.name,
        index: XCMInstructionType.setErrorHandler.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2SetAppendix.layout_(property: property),
        property: XCMInstructionType.setAppendix.name,
        index: XCMInstructionType.setAppendix.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.clearError.name,
        index: XCMInstructionType.clearError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2ClaimAsset.layout_(property: property),
        property: XCMInstructionType.claimAsset.name,
        index: XCMInstructionType.claimAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2Trap.layout_(property: property),
        property: XCMInstructionType.trap.name,
        index: XCMInstructionType.trap.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2SubscribeVersion.layout_(property: property),
        property: XCMInstructionType.subscribeVersion.name,
        index: XCMInstructionType.subscribeVersion.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.unsubscribeVersion.name,
        index: XCMInstructionType.unsubscribeVersion.variantIndex,
      ),
    ]);
  }

  factory XCMInstructionV2.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMInstructionType.fromName(decode.variantName);
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV2WithdrawAsset.deserializeJson(decode.value),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV2ReserveAssetDeposited.deserializeJson(decode.value),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV2ReceiveTeleportedAsset.deserializeJson(decode.value),
      XCMInstructionType.queryResponse =>
        XCMV2QueryResponse.deserializeJson(decode.value),
      XCMInstructionType.transferAsset =>
        XCMV2TransferAsset.deserializeJson(decode.value),
      XCMInstructionType.transferReserveAsset =>
        XCMV2TransferReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.transact =>
        XCMV2Transact.deserializeJson(decode.value),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV2HrmpNewChannelOpenRequest.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV2HrmpChannelAccepted.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV2HrmpChannelClosing.deserializeJson(decode.value),
      XCMInstructionType.clearOrigin => XCMV2ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV2DescendOrigin.deserializeJson(decode.value),
      XCMInstructionType.reportError =>
        XCMV2ReportError.deserializeJson(decode.value),
      XCMInstructionType.depositAsset =>
        XCMV2DepositAsset.deserializeJson(decode.value),
      XCMInstructionType.depositReserveAsset =>
        XCMV2DepositReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.exchangeAsset =>
        XCMV2ExchangeAsset.deserializeJson(decode.value),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV2InitiateReserveWithdraw.deserializeJson(decode.value),
      XCMInstructionType.initiateTeleport =>
        XCMV2InitiateTeleport.deserializeJson(decode.value),
      XCMInstructionType.queryHolding =>
        XCMV2QueryHolding.deserializeJson(decode.value),
      XCMInstructionType.buyExecution =>
        XCMV2BuyExecution.deserializeJson(decode.value),
      XCMInstructionType.refundSurplus => XCMV2RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV2SetErrorHandler.deserializeJson(decode.value),
      XCMInstructionType.setAppendix =>
        XCMV2SetAppendix.deserializeJson(decode.value),
      XCMInstructionType.clearError => XCMV2ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV2ClaimAsset.deserializeJson(decode.value),
      XCMInstructionType.trap => XCMV2Trap.deserializeJson(decode.value),
      XCMInstructionType.subscribeVersion =>
        XCMV2SubscribeVersion.deserializeJson(decode.value),
      XCMInstructionType.unsubscribeVersion => XCMV2UnsubscribeVersion(),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 2.",
          details: {"type": type.type})
    };
  }
  factory XCMInstructionV2.fromJson(Map<String, dynamic> json) {
    final type = XCMInstructionType.fromType(json.keys.first);
    return switch (type) {
      XCMInstructionType.withdrawAsset => XCMV2WithdrawAsset.fromJson(json),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV2ReserveAssetDeposited.fromJson(json),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV2ReceiveTeleportedAsset.fromJson(json),
      XCMInstructionType.queryResponse => XCMV2QueryResponse.fromJson(json),
      XCMInstructionType.transferAsset => XCMV2TransferAsset.fromJson(json),
      XCMInstructionType.transferReserveAsset =>
        XCMV2TransferReserveAsset.fromJson(json),
      XCMInstructionType.transact => XCMV2Transact.fromJson(json),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV2HrmpNewChannelOpenRequest.fromJson(json),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV2HrmpChannelAccepted.fromJson(json),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV2HrmpChannelClosing.fromJson(json),
      XCMInstructionType.clearOrigin => XCMV2ClearOrigin(),
      XCMInstructionType.descendOrigin => XCMV2DescendOrigin.fromJson(json),
      XCMInstructionType.reportError => XCMV2ReportError.fromJson(json),
      XCMInstructionType.depositAsset => XCMV2DepositAsset.fromJson(json),
      XCMInstructionType.depositReserveAsset =>
        XCMV2DepositReserveAsset.fromJson(json),
      XCMInstructionType.exchangeAsset => XCMV2ExchangeAsset.fromJson(json),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV2InitiateReserveWithdraw.fromJson(json),
      XCMInstructionType.initiateTeleport =>
        XCMV2InitiateTeleport.fromJson(json),
      XCMInstructionType.queryHolding => XCMV2QueryHolding.fromJson(json),
      XCMInstructionType.buyExecution => XCMV2BuyExecution.fromJson(json),
      XCMInstructionType.refundSurplus => XCMV2RefundSurplus(),
      XCMInstructionType.setErrorHandler => XCMV2SetErrorHandler.fromJson(json),
      XCMInstructionType.setAppendix => XCMV2SetAppendix.fromJson(json),
      XCMInstructionType.clearError => XCMV2ClearError(),
      XCMInstructionType.claimAsset => XCMV2ClaimAsset.fromJson(json),
      XCMInstructionType.trap => XCMV2Trap.fromJson(json),
      XCMInstructionType.subscribeVersion =>
        XCMV2SubscribeVersion.fromJson(json),
      XCMInstructionType.unsubscribeVersion => XCMV2UnsubscribeVersion(),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 2.",
          details: {"type": type.name})
    };
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;

  @override
  Map<String, dynamic> toJson();
}

class XCMV2WithdrawAsset extends XCMInstructionV2 with XCMWithdrawAsset {
  @override
  final XCMV2MultiAssets assets;
  XCMV2WithdrawAsset({required this.assets});
  factory XCMV2WithdrawAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2WithdrawAsset(
        assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV2WithdrawAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.withdrawAsset.type);

    return XCMV2WithdrawAsset(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()));
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

class XCMV2ReserveAssetDeposited extends XCMInstructionV2
    with XCMReserveAssetDeposited {
  @override
  final XCMV2MultiAssets assets;
  XCMV2ReserveAssetDeposited({required this.assets});
  factory XCMV2ReserveAssetDeposited.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2ReserveAssetDeposited(
        assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV2ReserveAssetDeposited.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.reserveAssetDeposited.type);
    return XCMV2ReserveAssetDeposited(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()));
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

class XCMV2ReceiveTeleportedAsset extends XCMInstructionV2
    with XCMReceiveTeleportedAsset {
  @override
  final XCMV2MultiAssets assets;
  XCMV2ReceiveTeleportedAsset({required this.assets});
  factory XCMV2ReceiveTeleportedAsset.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2ReceiveTeleportedAsset(
        assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV2ReceiveTeleportedAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.receiveTeleportedAsset.type);
    return XCMV2ReceiveTeleportedAsset(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()));
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

class XCMV2QueryResponse extends XCMInstructionV2 with XCMQueryResponse {
  final BigInt queryId;
  final XCMV2Response response;
  final BigInt maxWeight;

  XCMV2QueryResponse(
      {required this.queryId,
      required this.response,
      required BigInt maxWeight})
      : maxWeight = maxWeight.asUint64;
  factory XCMV2QueryResponse.deserializeJson(Map<String, dynamic> json) {
    return XCMV2QueryResponse(
      queryId: json.valueAs("query_id"),
      response: XCMV2Response.deserializeJson(json.valueAs("response")),
      maxWeight: json.valueAs("max_weight"),
    );
  }

  factory XCMV2QueryResponse.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.queryResponse.type);
    return XCMV2QueryResponse(
        queryId: data.valueAs("query_id"),
        response: XCMV2Response.fromJson(data.valueAs("response")),
        maxWeight: data.valueAs("max_weight"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      XCMV2Response.layout_(property: "response"),
      LayoutConst.compactBigintU64(property: "max_weight"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "query_id": queryId,
      "response": response.serializeJsonVariant(),
      "max_weight": maxWeight,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "query_id": queryId,
        "response": response.toJson(),
        "max_weight": maxWeight
      }
    };
  }

  @override
  List get variabels => [type, queryId, response, maxWeight];
}

class XCMV2TransferAsset extends XCMInstructionV2 with XCMTransferAsset {
  @override
  final XCMV2MultiAssets assets;
  @override
  final XCMV2MultiLocation beneficiary;
  XCMV2TransferAsset({required this.assets, required this.beneficiary});
  factory XCMV2TransferAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2TransferAsset(
      assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")),
      beneficiary:
          XCMV2MultiLocation.deserializeJson(json.valueAs("beneficiary")),
    );
  }

  factory XCMV2TransferAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV2TransferAsset(
      assets: XCMV2MultiAssets(
          assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()),
      beneficiary: XCMV2MultiLocation.fromJson(data.valueAs("beneficiary")),
    );
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssets.layout_(property: "assets"),
      XCMV2MultiLocation.layout_(property: "beneficiary")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJson(),
      "beneficiary": beneficiary.serializeJson(),
    };
  }
}

class XCMV2TransferReserveAsset extends XCMInstructionV2
    with XCMTransferReserveAsset {
  @override
  final XCMV2MultiAssets assets;
  @override
  final XCMV2MultiLocation dest;
  @override
  final XCMV2 xcm;
  XCMV2TransferReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV2TransferReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2TransferReserveAsset(
        assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")),
        dest: XCMV2MultiLocation.deserializeJson(json.valueAs("dest")),
        xcm: XCMV2.deserializeJson(json.valueAs("xcm")));
  }

  factory XCMV2TransferReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferReserveAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV2TransferReserveAsset(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()),
        dest: XCMV2MultiLocation.fromJson(data.valueAs("dest")),
        xcm: XCMV2(
            instructions:
                xcm.map((e) => XCMInstructionV2.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssets.layout_(property: "assets"),
      XCMV2MultiLocation.layout_(property: "dest"),
      XCMV2.layout_(property: "xcm")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJson(),
      "dest": dest.serializeJson(),
      "xcm": xcm.serializeJson()
    };
  }
}

enum XCMV2OriginKindType {
  native("Native", 0),
  sovereignAccount("SovereignAccount", 1),
  superuser("Superuser", 2),
  xcm("Xcm", 3);

  const XCMV2OriginKindType(this.type, this.variantIndex);
  final String type;
  final int variantIndex;

  static XCMV2OriginKindType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV2OriginKindType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV2OriginKind extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV2OriginKindType get type;
  Map<String, dynamic> toJson();
  const XCMV2OriginKind();
  factory XCMV2OriginKind.fromJson(Map<String, dynamic> json) {
    final type = XCMV2OriginKindType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV2OriginKindType.native => XCMV2OriginKindNative.fromJson(json),
      XCMV2OriginKindType.sovereignAccount =>
        XCMV2OriginKindSovereignAccount.fromJson(json),
      XCMV2OriginKindType.superuser => XCMV2OriginKindSuperuser.fromJson(json),
      XCMV2OriginKindType.xcm => XCMV2OriginKindXcm.fromJson(json),
    };
  }

  factory XCMV2OriginKind.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV2OriginKindType.fromName(decode.variantName);
    return switch (type) {
      XCMV2OriginKindType.native => XCMV2OriginKindNative(),
      XCMV2OriginKindType.sovereignAccount => XCMV2OriginKindSovereignAccount(),
      XCMV2OriginKindType.superuser => XCMV2OriginKindSuperuser(),
      XCMV2OriginKindType.xcm => XCMV2OriginKindXcm(),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum(
        XCMV2OriginKindType.values
            .map((e) => LazyVariantModel(
                layout: ({property}) =>
                    SubstrateVariantNoArgs.layout_(property: property),
                property: e.name,
                index: e.variantIndex))
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
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2OriginKindNative extends XCMV2OriginKind
    with SubstrateVariantNoArgs {
  @override
  XCMV2OriginKindType get type => XCMV2OriginKindType.native;
  const XCMV2OriginKindNative();
  factory XCMV2OriginKindNative.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2OriginKindType.native.type);
    return XCMV2OriginKindNative();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

class XCMV2OriginKindSovereignAccount extends XCMV2OriginKind
    with SubstrateVariantNoArgs {
  @override
  XCMV2OriginKindType get type => XCMV2OriginKindType.sovereignAccount;
  const XCMV2OriginKindSovereignAccount();
  factory XCMV2OriginKindSovereignAccount.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2OriginKindType.sovereignAccount.type);
    return XCMV2OriginKindSovereignAccount();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

class XCMV2OriginKindSuperuser extends XCMV2OriginKind
    with SubstrateVariantNoArgs {
  @override
  XCMV2OriginKindType get type => XCMV2OriginKindType.superuser;
  const XCMV2OriginKindSuperuser();
  factory XCMV2OriginKindSuperuser.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2OriginKindType.superuser.type);
    return XCMV2OriginKindSuperuser();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

class XCMV2OriginKindXcm extends XCMV2OriginKind with SubstrateVariantNoArgs {
  @override
  XCMV2OriginKindType get type => XCMV2OriginKindType.xcm;
  const XCMV2OriginKindXcm();
  factory XCMV2OriginKindXcm.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2OriginKindType.xcm.type);
    return XCMV2OriginKindXcm();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

class XCMV2Transact extends XCMInstructionV2 with XCMTransact {
  final XCMV2OriginKind originKind;
  final BigInt requireWeightAtMost;
  @override
  final List<int> call;

  XCMV2Transact(
      {required this.originKind,
      required BigInt requireWeightAtMost,
      required List<int> call})
      : call = call.asImmutableBytes,
        requireWeightAtMost = requireWeightAtMost.asUint64;
  factory XCMV2Transact.deserializeJson(Map<String, dynamic> json) {
    return XCMV2Transact(
        originKind:
            XCMV2OriginKind.deserializeJson(json.valueAs("origin_kind")),
        requireWeightAtMost: json.valueAs("require_weight_at_most"),
        call: json.valueAsBytes("call"));
  }
  factory XCMV2Transact.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.transact.type);
    return XCMV2Transact(
        originKind: XCMV2OriginKind.fromJson(data.valueAs("origin_type")),
        requireWeightAtMost: data.valueAs("require_weight_at_most"),
        call: data
            .valueEnsureAsMap<String, dynamic>("call")
            .valueAsBytes("encoded"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2OriginKind.layout_(property: "origin_kind"),
      LayoutConst.compactBigintU64(property: "require_weight_at_most"),
      LayoutConst.bytes(property: "call")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "origin_kind": originKind.serializeJsonVariant(),
      "require_weight_at_most": requireWeightAtMost,
      "call": call
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "origin_type": originKind.toJson(),
        "require_weight_at_most": requireWeightAtMost,
        "call": {"encoded": call}
      }
    };
  }

  @override
  List get variabels => [type, originKind, requireWeightAtMost, call];
}

class XCMV2HrmpNewChannelOpenRequest extends XCMInstructionV2
    with XCMHrmpNewChannelOpenRequest {
  @override
  final int sender;
  @override
  final int maxMessageSize;
  @override
  final int maxCapacity;
  XCMV2HrmpNewChannelOpenRequest(
      {required int sender,
      required int maxMessageSize,
      required int maxCapacity})
      : sender = sender.asUint32,
        maxMessageSize = maxMessageSize.asUint32,
        maxCapacity = maxCapacity.asUint32;
  factory XCMV2HrmpNewChannelOpenRequest.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2HrmpNewChannelOpenRequest(
        sender: json.valueAs("sender"),
        maxCapacity: json.valueAs("max_capacity"),
        maxMessageSize: json.valueAs("max_message_size"));
  }
  factory XCMV2HrmpNewChannelOpenRequest.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpNewChannelOpenRequest.type);
    return XCMV2HrmpNewChannelOpenRequest(
        maxCapacity: data.valueAs("max_capacity"),
        maxMessageSize: data.valueAs("max_message_size"),
        sender: data.valueAs("sender"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "sender"),
      LayoutConst.compactIntU32(property: "max_message_size"),
      LayoutConst.compactIntU32(property: "max_capacity"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "sender": sender,
      "max_message_size": maxMessageSize,
      "max_capacity": maxCapacity
    };
  }
}

class XCMV2HrmpChannelAccepted extends XCMInstructionV2
    with XCMHrmpChannelAccepted {
  @override
  final int recipient;

  XCMV2HrmpChannelAccepted({required int recipient})
      : recipient = recipient.asUint32;
  factory XCMV2HrmpChannelAccepted.deserializeJson(Map<String, dynamic> json) {
    return XCMV2HrmpChannelAccepted(recipient: json.valueAs("recipient"));
  }
  factory XCMV2HrmpChannelAccepted.fromJson(Map<String, dynamic> json) {
    return XCMV2HrmpChannelAccepted(
        recipient: json.valueAs(XCMInstructionType.hrmpChannelAccepted.type));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactIntU32(property: "recipient")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"recipient": recipient};
  }
}

class XCMV2HrmpChannelClosing extends XCMInstructionV2
    with XCMHrmpChannelClosing {
  @override
  final int initiator;
  @override
  final int sender;
  @override
  final int recipient;
  XCMV2HrmpChannelClosing(
      {required int sender, required int initiator, required int recipient})
      : sender = sender.asUint32,
        initiator = initiator.asUint32,
        recipient = recipient.asUint32;
  factory XCMV2HrmpChannelClosing.deserializeJson(Map<String, dynamic> json) {
    return XCMV2HrmpChannelClosing(
        sender: json.valueAs("sender"),
        recipient: json.valueAs("recipient"),
        initiator: json.valueAs("initiator"));
  }
  factory XCMV2HrmpChannelClosing.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpChannelClosing.type);
    return XCMV2HrmpChannelClosing(
        initiator: data.valueAs("initiator"),
        recipient: data.valueAs("recipient"),
        sender: data.valueAs("sender"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "initiator"),
      LayoutConst.compactIntU32(property: "sender"),
      LayoutConst.compactIntU32(property: "recipient"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"initiator": initiator, "sender": sender, "recipient": recipient};
  }
}

class XCMV2ClearOrigin extends XCMInstructionV2
    with SubstrateVariantNoArgs, XCMClearOrigin {
  const XCMV2ClearOrigin();
  factory XCMV2ClearOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearOrigin.type);
    return XCMV2ClearOrigin();
  }
}

class XCMV2DescendOrigin extends XCMInstructionV2 with XCMDescendOrigin {
  @override
  final XCMV2InteriorMultiLocation interior;

  XCMV2DescendOrigin({required this.interior});
  factory XCMV2DescendOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV2DescendOrigin(
        interior: XCMV2Junctions.deserializeJson(json.valueAs("interior")));
  }
  factory XCMV2DescendOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV2DescendOrigin(
        interior: XCMV2Junctions.fromJson(
            json.valueAs(XCMInstructionType.descendOrigin.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2Junctions.layout_(property: "interior")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"interior": interior.serializeJsonVariant()};
  }
}

class XCMV2ReportError extends XCMInstructionV2 with XCMReportError {
  final BigInt queryId;
  final XCMV2MultiLocation dest;
  final BigInt maxResponseWeight;

  XCMV2ReportError(
      {required BigInt queryId,
      required this.dest,
      required BigInt maxResponseWeight})
      : queryId = queryId.asUint64,
        maxResponseWeight = maxResponseWeight.asUint64;
  factory XCMV2ReportError.deserializeJson(Map<String, dynamic> json) {
    return XCMV2ReportError(
        queryId: json.valueAs("query_id"),
        dest: XCMV2MultiLocation.deserializeJson(json.valueAs("dest")),
        maxResponseWeight: json.valueAs("max_response_weight"));
  }

  factory XCMV2ReportError.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.reportError.type);
    return XCMV2ReportError(
        dest: XCMV2MultiLocation.fromJson(data.valueAs("dest")),
        maxResponseWeight: data.valueAs("max_response_weight"),
        queryId: data.valueAs("query_id"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      XCMV2MultiLocation.layout_(property: "dest"),
      LayoutConst.compactBigintU64(property: "max_response_weight")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "query_id": queryId,
      "dest": dest.serializeJson(),
      "max_response_weight": maxResponseWeight
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "query_id": queryId,
        "dest": dest.toJson(),
        "max_response_weight": maxResponseWeight
      }
    };
  }

  @override
  List get variabels => [type, queryId, dest, maxResponseWeight];
}

class XCMV2DepositAsset extends XCMInstructionV2 with XCMDepositAsset {
  @override
  final XCMV2MultiAssetFilter assets;
  final int maxAssets;
  @override
  final XCMV2MultiLocation beneficiary;
  XCMV2DepositAsset(
      {required this.assets, required int maxAssets, required this.beneficiary})
      : maxAssets = maxAssets.asUint32;
  factory XCMV2DepositAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2DepositAsset(
      assets: XCMV2MultiAssetFilter.deserializeJson(json.valueAs("assets")),
      maxAssets: json.valueAs("max_assets"),
      beneficiary:
          XCMV2MultiLocation.deserializeJson(json.valueAs("beneficiary")),
    );
  }

  factory XCMV2DepositAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositAsset.type);
    return XCMV2DepositAsset(
        assets: XCMV2MultiAssetFilter.fromJson(data.valueAs("assets")),
        beneficiary: XCMV2MultiLocation.fromJson(data.valueAs("beneficiary")),
        maxAssets: data.valueAs("max_assets"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssetFilter.layout_(property: "assets"),
      LayoutConst.compactIntU32(property: "max_assets"),
      XCMV2MultiLocation.layout_(property: "beneficiary")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJsonVariant(),
      "max_assets": maxAssets,
      "beneficiary": beneficiary.serializeJson(),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.toJson(),
        "max_assets": maxAssets,
        "beneficiary": beneficiary.toJson(),
      }
    };
  }

  @override
  List get variabels => [type, assets, maxAssets, beneficiary];
}

class XCMV2DepositReserveAsset extends XCMInstructionV2
    with XCMDepositReserveAsset {
  @override
  final XCMV2MultiAssetFilter assets;
  final int maxAssets;
  @override
  final XCMV2MultiLocation dest;
  @override
  final XCMV2 xcm;
  XCMV2DepositReserveAsset(
      {required this.assets,
      required this.dest,
      required int maxAssets,
      required this.xcm})
      : maxAssets = maxAssets.asUint32;
  factory XCMV2DepositReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2DepositReserveAsset(
        assets: XCMV2MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV2MultiLocation.deserializeJson(json.valueAs("dest")),
        maxAssets: json.valueAs("max_assets"),
        xcm: XCMV2.deserializeJson(json.valueAs("xcm")));
  }

  factory XCMV2DepositReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositReserveAsset.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV2DepositReserveAsset(
        assets: XCMV2MultiAssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV2MultiLocation.fromJson(data.valueAs("dest")),
        maxAssets: data.valueAs("max_assets"),
        xcm: XCMV2(
            instructions:
                xcm.map((e) => XCMInstructionV2.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssetFilter.layout_(property: "assets"),
      LayoutConst.compactIntU32(property: "max_assets"),
      XCMV2MultiLocation.layout_(property: "dest"),
      XCMV2.layout_(property: "xcm")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJsonVariant(),
      "dest": dest.serializeJson(),
      "xcm": xcm.serializeJson(),
      "max_assets": maxAssets
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.toJson(),
        "max_assets": maxAssets,
        "dest": dest.toJson(),
        "xcm": xcm.instructions.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  List get variabels => [type, assets, maxAssets, dest, xcm];
}

class XCMV2ExchangeAsset extends XCMInstructionV2 with XCMExchangeAsset {
  final XCMV2MultiAssetFilter give;
  final XCMV2MultiAssets receive;
  XCMV2ExchangeAsset({required this.give, required this.receive});
  factory XCMV2ExchangeAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2ExchangeAsset(
      give: XCMV2MultiAssetFilter.deserializeJson(json.valueAs("give")),
      receive: XCMV2MultiAssets.deserializeJson(json.valueAs("receive")),
    );
  }
  factory XCMV2ExchangeAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exchangeAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("receive");
    return XCMV2ExchangeAsset(
        receive: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()),
        give: XCMV2MultiAssetFilter.fromJson(data.valueAs("give")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssetFilter.layout_(property: "give"),
      XCMV2MultiAssets.layout_(property: "receive"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "give": give.serializeJsonVariant(),
      "receive": receive.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "give": give.toJson(),
        "receive": receive.assets.map((e) => e.toJson()).toList()
      }
    };
  }

  @override
  List get variabels => [type, give, receive];

  @override
  XCMAssets<XCMAsset> get want => receive;
}

class XCMV2InitiateReserveWithdraw extends XCMInstructionV2
    with XCMInitiateReserveWithdraw {
  @override
  final XCMV2MultiAssetFilter assets;
  @override
  final XCMV2MultiLocation reserve;
  @override
  final XCMV2 xcm;
  XCMV2InitiateReserveWithdraw(
      {required this.assets, required this.reserve, required this.xcm});
  factory XCMV2InitiateReserveWithdraw.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2InitiateReserveWithdraw(
        assets: XCMV2MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        reserve: XCMV2MultiLocation.deserializeJson(json.valueAs("reserve")),
        xcm: XCMV2.deserializeJson(json.valueAs("xcm")));
  }

  factory XCMV2InitiateReserveWithdraw.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateReserveWithdraw.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV2InitiateReserveWithdraw(
        assets: XCMV2MultiAssetFilter.fromJson(data.valueAs("assets")),
        reserve: XCMV2MultiLocation.fromJson(data.valueAs("reserve")),
        xcm: XCMV2(
            instructions:
                xcm.map((e) => XCMInstructionV2.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssetFilter.layout_(property: "assets"),
      XCMV2MultiLocation.layout_(property: "reserve"),
      XCMV2.layout_(property: "xcm"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJsonVariant(),
      "reserve": reserve.serializeJson(),
      "xcm": xcm.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.toJson(),
        "reserve": reserve.toJson(),
        "xcm": xcm.instructions.map((e) => e.toJson()).toList()
      }
    };
  }

  @override
  List get variabels => [type, assets, reserve, xcm];
}

class XCMV2InitiateTeleport extends XCMInstructionV2 with XCMInitiateTeleport {
  final XCMV2MultiAssetFilter assets;
  @override
  final XCMV2MultiLocation dest;
  @override
  final XCMV2 xcm;
  XCMV2InitiateTeleport(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV2InitiateTeleport.deserializeJson(Map<String, dynamic> json) {
    return XCMV2InitiateTeleport(
        assets: XCMV2MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV2MultiLocation.deserializeJson(json.valueAs("dest")),
        xcm: XCMV2.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV2InitiateTeleport.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateTeleport.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV2InitiateTeleport(
        assets: XCMV2MultiAssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV2MultiLocation.fromJson(data.valueAs("dest")),
        xcm: XCMV2(
            instructions:
                xcm.map((e) => XCMInstructionV2.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssetFilter.layout_(property: "assets"),
      XCMV2MultiLocation.layout_(property: "dest"),
      XCMV2.layout_(property: "xcm")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJsonVariant(),
      "dest": dest.serializeJson(),
      "xcm": xcm.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.toJson(),
        "dest": dest.toJson(),
        "xcm": xcm.instructions.map((e) => e.toJson()).toList()
      }
    };
  }

  @override
  List get variabels => [type, assets, dest, xcm];
}

class XCMV2QueryHolding extends XCMInstructionV2 with XCMQueryHolding {
  final XCMV2MultiAssetFilter assets;
  final BigInt queryId;
  final XCMV2MultiLocation dest;
  final BigInt maxResponseWeight;

  XCMV2QueryHolding(
      {required BigInt queryId,
      required this.dest,
      required this.assets,
      required BigInt maxResponseWeight})
      : queryId = queryId.asUint64,
        maxResponseWeight = maxResponseWeight.asUint64;
  factory XCMV2QueryHolding.deserializeJson(Map<String, dynamic> json) {
    return XCMV2QueryHolding(
        queryId: json.valueAs("query_id"),
        dest: XCMV2MultiLocation.deserializeJson(json.valueAs("dest")),
        assets: XCMV2MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        maxResponseWeight: json.valueAs("max_response_weight"));
  }

  factory XCMV2QueryHolding.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.queryHolding.type);
    return XCMV2QueryHolding(
        maxResponseWeight: data.valueAs("max_response_weight"),
        queryId: data.valueAs("query_id"),
        assets: XCMV2MultiAssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV2MultiLocation.fromJson(data.valueAs("dest")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      XCMV2MultiLocation.layout_(property: "dest"),
      XCMV2MultiAssetFilter.layout_(property: "assets"),
      LayoutConst.compactBigintU64(property: "max_response_weight")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "assets": assets.serializeJsonVariant(),
      "query_id": queryId,
      "dest": dest.serializeJson(),
      "max_response_weight": maxResponseWeight
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.toJson(),
        "query_id": queryId,
        "dest": dest.toJson(),
        "max_response_weight": maxResponseWeight
      }
    };
  }

  @override
  List get variabels => [type, assets, queryId, dest, maxResponseWeight];
}

class XCMV2BuyExecution extends XCMInstructionV2 with XCMBuyExecution {
  @override
  final XCMV2MultiAsset fees;
  @override
  final XCMV2WeightLimit weightLimit;

  XCMV2BuyExecution({required this.fees, required this.weightLimit});
  factory XCMV2BuyExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV2BuyExecution(
        fees: XCMV2MultiAsset.deserializeJson(json.valueAs("fees")),
        weightLimit:
            XCMV2WeightLimit.deserializeJson(json.valueAs("weight_limit")));
  }
  factory XCMV2BuyExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.buyExecution.type);
    return XCMV2BuyExecution(
      fees: XCMV2MultiAsset.fromJson(data.valueAs("fees")),
      weightLimit: XCMV2WeightLimit.fromJson(data.valueAs("weight_limit")),
    );
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAsset.layout_(property: "fees"),
      XCMV2WeightLimit.layout_(property: "weight_limit"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "fees": fees.serializeJson(),
      "weight_limit": weightLimit.serializeJsonVariant()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"fees": fees.toJson(), "weight_limit": weightLimit.toJson()}
    };
  }

  @override
  List get variabels => [type, fees, weightLimit];
}

class XCMV2RefundSurplus extends XCMInstructionV2
    with SubstrateVariantNoArgs, XCMRefundSurplus {
  const XCMV2RefundSurplus();
  factory XCMV2RefundSurplus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.refundSurplus.type);
    return XCMV2RefundSurplus();
  }
}

class XCMV2SetErrorHandler extends XCMInstructionV2 with XCMSetErrorHandler {
  @override
  final XCMV2 xcm;
  XCMV2SetErrorHandler({required this.xcm});
  factory XCMV2SetErrorHandler.deserializeJson(Map<String, dynamic> json) {
    return XCMV2SetErrorHandler(
        xcm: XCMV2.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV2SetErrorHandler.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setErrorHandler.type);
    return XCMV2SetErrorHandler(
        xcm: XCMV2(
            instructions:
                xcm.map((e) => XCMInstructionV2.fromJson(e)).toList()));
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
  Map<String, dynamic> serializeJson({String? property}) {
    return {"xcm": xcm.serializeJson()};
  }
}

class XCMV2SetAppendix extends XCMInstructionV2 with XCMSetAppendix {
  @override
  final XCMV2 xcm;
  XCMV2SetAppendix({required this.xcm});
  factory XCMV2SetAppendix.deserializeJson(Map<String, dynamic> json) {
    return XCMV2SetAppendix(xcm: XCMV2.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV2SetAppendix.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setAppendix.type);
    return XCMV2SetAppendix(
        xcm: XCMV2(
            instructions:
                xcm.map((e) => XCMInstructionV2.fromJson(e)).toList()));
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
  Map<String, dynamic> serializeJson({String? property}) {
    return {"xcm": xcm.serializeJson()};
  }
}

class XCMV2ClearError extends XCMInstructionV2
    with SubstrateVariantNoArgs, XCMClearError {
  const XCMV2ClearError();
  factory XCMV2ClearError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearError.type);
    return XCMV2ClearError();
  }
}

class XCMV2ClaimAsset extends XCMInstructionV2 with XCMClaimAsset {
  @override
  final XCMV2MultiAssets assets;
  @override
  final XCMV2MultiLocation ticket;
  XCMV2ClaimAsset({required this.assets, required this.ticket});
  factory XCMV2ClaimAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.claimAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV2ClaimAsset(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()),
        ticket: XCMV2MultiLocation.fromJson(data.valueAs("ticket")));
  }
  factory XCMV2ClaimAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2ClaimAsset(
      assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")),
      ticket: XCMV2MultiLocation.deserializeJson(json.valueAs("ticket")),
    );
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2MultiAssets.layout_(property: "assets"),
      XCMV2MultiLocation.layout_(property: "ticket"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.serializeJson(), "ticket": ticket.serializeJson()};
  }
}

class XCMV2Trap extends XCMInstructionV2 with XCMTrap {
  @override
  final BigInt trap;
  XCMV2Trap({required BigInt trap}) : trap = trap.asUint64;
  factory XCMV2Trap.deserializeJson(Map<String, dynamic> json) {
    return XCMV2Trap(trap: json.valueAs("trap"));
  }
  factory XCMV2Trap.fromJson(Map<String, dynamic> json) {
    return XCMV2Trap(trap: json.valueAs(XCMInstructionType.trap.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.compactBigintU64(property: "trap")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"trap": trap};
  }
}

class XCMV2SubscribeVersion extends XCMInstructionV2 with XCMSubscribeVersion {
  @override
  final BigInt queryId;
  final BigInt maxResponseWeight;
  XCMV2SubscribeVersion(
      {required BigInt queryId, required this.maxResponseWeight})
      : queryId = queryId.asUint64;
  factory XCMV2SubscribeVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV2SubscribeVersion(
        queryId: json.valueAs("query_id"),
        maxResponseWeight: json.valueAs("max_response_weight"));
  }
  factory XCMV2SubscribeVersion.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.subscribeVersion.type);
    return XCMV2SubscribeVersion(
      maxResponseWeight: data.valueAs("max_response_weight"),
      queryId: data.valueAs("query_id"),
    );
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      LayoutConst.compactBigintU64(property: "max_response_weight")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"query_id": queryId, "max_response_weight": maxResponseWeight};
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"query_id": queryId, "max_response_weight": maxResponseWeight}
    };
  }

  @override
  List get variabels => [type, queryId, maxResponseWeight];
}

class XCMV2UnsubscribeVersion extends XCMInstructionV2
    with SubstrateVariantNoArgs, XCMUnsubscribeVersion {
  const XCMV2UnsubscribeVersion();
  factory XCMV2UnsubscribeVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.unsubscribeVersion.type);
    return XCMV2UnsubscribeVersion();
  }
}

enum XCMV2ResponseType {
  nullResponse("Null"),
  assets("Assets"),
  executionResult("ExecutionResult"),
  version("Version");

  const XCMV2ResponseType(this.type);
  final String type;

  static XCMV2ResponseType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV2ResponseType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

enum XCMV2ErrorType {
  overFlow("Overflow", 0),
  unimplemented("Unimplemented", 1),
  untrustedReserveLocation("UntrustedReserveLocation", 2),
  untrustedTeleportLocation("UntrustedTeleportLocation", 3),
  locationFull("MultiLocationFull", 4),
  locationNotInvertible("MultiLocationNotInvertible", 5),
  badOrigin("BadOrigin", 6),
  invalidLocation("InvalidLocation", 7),
  assetNotFound("AssetNotFound", 8),
  failedToTransactAsset("FailedToTransactAsset", 9),
  notWithdrawable("NotWithdrawable", 10),
  locationCannotHold("LocationCannotHold", 11),
  exceedsMaxMessageSize("ExceedsMaxMessageSize", 12),
  destinationUnsupported("DestinationUnsupported", 13),
  transport("Transport", 14),
  unroutable("Unroutable", 15),
  unknownClaim("UnknownClaim", 16),
  failedToDecode("FailedToDecode", 17),
  maxWeightInvalid("MaxWeightInvalid", 18),
  notHodingFees("NotHoldingFees", 19),
  tooExpensive("TooExpensive", 20),
  trap("Trap", 21),
  unhandledXcmVersion("UnhandledXcmVersion", 22),
  weightLimitReached("WeightLimitReached", 23),
  barrier("Barrier", 24),
  weightNotComputable("WeightNotComputable", 25);

  const XCMV2ErrorType(this.type, this.variantIndex);
  final String type;
  final int variantIndex;

  static XCMV2ErrorType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV2ErrorType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV2Error extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV2ErrorType get type;
  const XCMV2Error();
  Map<String, dynamic> toJson();
  factory XCMV2Error.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV2ErrorType.fromName(decode.variantName);
    return switch (type) {
      XCMV2ErrorType.overFlow => XCMV2ErrorOverflow(),
      XCMV2ErrorType.unimplemented => XCMV2ErrorUnimplemented(),
      XCMV2ErrorType.untrustedReserveLocation =>
        XCMV2ErrorUntrustedReserveLocation(),
      XCMV2ErrorType.untrustedTeleportLocation =>
        XCMV2ErrorUntrustedTeleportLocation(),
      XCMV2ErrorType.locationFull => XCMV2ErrorLocationFull(),
      XCMV2ErrorType.locationNotInvertible => XCMV2ErrorLocationNotInvertible(),
      XCMV2ErrorType.badOrigin => XCMV2ErrorBadOrigin(),
      XCMV2ErrorType.invalidLocation => XCMV2ErrorInvalidLocation(),
      XCMV2ErrorType.assetNotFound => XCMV2ErrorAssetNotFound(),
      XCMV2ErrorType.failedToTransactAsset => XCMV2ErrorFailedToTransactAsset(),
      XCMV2ErrorType.notWithdrawable => XCMV2ErrorNotWithdrawable(),
      XCMV2ErrorType.locationCannotHold => XCMV2ErrorLocationCannotHold(),
      XCMV2ErrorType.exceedsMaxMessageSize => XCMV2ErrorExceedsMaxMessageSize(),
      XCMV2ErrorType.destinationUnsupported =>
        XCMV2ErrorDestinationUnsupported(),
      XCMV2ErrorType.transport => XCMV2ErrorTransport(),
      XCMV2ErrorType.unroutable => XCMV2ErrorUnroutable(),
      XCMV2ErrorType.unknownClaim => XCMV2ErrorUnknownClaim(),
      XCMV2ErrorType.failedToDecode => XCMV2ErrorFailedToDecode(),
      XCMV2ErrorType.maxWeightInvalid => XCMV2ErrorMaxWeightInvalid(),
      XCMV2ErrorType.notHodingFees => XCMV2ErrorNotHoldingFees(),
      XCMV2ErrorType.tooExpensive => XCMV2ErrorTooExpensive(),
      XCMV2ErrorType.trap => XCMV2ErrorTrap.deserializeJson(decode.value),
      XCMV2ErrorType.unhandledXcmVersion => XCMV2ErrorUnhandledXcmVersion(),
      XCMV2ErrorType.weightLimitReached =>
        XCMV2ErrorWeightLimitReached.deserializeJson(decode.value),
      XCMV2ErrorType.barrier => XCMV2ErrorBarrier(),
      XCMV2ErrorType.weightNotComputable => XCMV2ErrorWeightNotComputable(),
    };
  }
  factory XCMV2Error.fromJson(Map<String, dynamic> json) {
    final type = XCMV2ErrorType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV2ErrorType.overFlow => XCMV2ErrorOverflow.fromJson(json),
      XCMV2ErrorType.unimplemented => XCMV2ErrorUnimplemented.fromJson(json),
      XCMV2ErrorType.untrustedReserveLocation =>
        XCMV2ErrorUntrustedReserveLocation.fromJson(json),
      XCMV2ErrorType.untrustedTeleportLocation =>
        XCMV2ErrorUntrustedTeleportLocation.fromJson(json),
      XCMV2ErrorType.locationFull => XCMV2ErrorLocationFull.fromJson(json),
      XCMV2ErrorType.locationNotInvertible =>
        XCMV2ErrorLocationNotInvertible.fromJson(json),
      XCMV2ErrorType.badOrigin => XCMV2ErrorBadOrigin.fromJson(json),
      XCMV2ErrorType.invalidLocation =>
        XCMV2ErrorInvalidLocation.fromJson(json),
      XCMV2ErrorType.assetNotFound => XCMV2ErrorAssetNotFound.fromJson(json),
      XCMV2ErrorType.failedToTransactAsset =>
        XCMV2ErrorFailedToTransactAsset.fromJson(json),
      XCMV2ErrorType.notWithdrawable =>
        XCMV2ErrorNotWithdrawable.fromJson(json),
      XCMV2ErrorType.locationCannotHold =>
        XCMV2ErrorLocationCannotHold.fromJson(json),
      XCMV2ErrorType.exceedsMaxMessageSize =>
        XCMV2ErrorExceedsMaxMessageSize.fromJson(json),
      XCMV2ErrorType.destinationUnsupported =>
        XCMV2ErrorDestinationUnsupported.fromJson(json),
      XCMV2ErrorType.transport => XCMV2ErrorTransport.fromJson(json),
      XCMV2ErrorType.unroutable => XCMV2ErrorUnroutable.fromJson(json),
      XCMV2ErrorType.unknownClaim => XCMV2ErrorUnknownClaim.fromJson(json),
      XCMV2ErrorType.failedToDecode => XCMV2ErrorFailedToDecode.fromJson(json),
      XCMV2ErrorType.maxWeightInvalid =>
        XCMV2ErrorMaxWeightInvalid.fromJson(json),
      XCMV2ErrorType.notHodingFees => XCMV2ErrorNotHoldingFees.fromJson(json),
      XCMV2ErrorType.tooExpensive => XCMV2ErrorTooExpensive.fromJson(json),
      XCMV2ErrorType.trap => XCMV2ErrorTrap.fromJson(json),
      XCMV2ErrorType.unhandledXcmVersion =>
        XCMV2ErrorUnhandledXcmVersion.fromJson(json),
      XCMV2ErrorType.weightLimitReached =>
        XCMV2ErrorWeightLimitReached.fromJson(json),
      XCMV2ErrorType.barrier => XCMV2ErrorBarrier.fromJson(json),
      XCMV2ErrorType.weightNotComputable =>
        XCMV2ErrorWeightNotComputable.fromJson(json),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum(
        XCMV2ErrorType.values.map((e) {
          return LazyVariantModel(
              layout: ({property}) {
                switch (e) {
                  case XCMV2ErrorType.trap:
                    return XCMV2ErrorTrap.layout_(property: property);
                  case XCMV2ErrorType.weightLimitReached:
                    return XCMV2ErrorWeightLimitReached.layout_(
                        property: property);
                  default:
                    return SubstrateVariantNoArgs.layout_(property: property);
                }
              },
              property: e.name,
              index: e.variantIndex);
        }).toList(),
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;

  @override
  List get variabels => [type];

  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2ErrorOverflow extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.overFlow;
  const XCMV2ErrorOverflow();
  factory XCMV2ErrorOverflow.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.overFlow.type);
    return XCMV2ErrorOverflow();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorUnimplemented extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.unimplemented;
  const XCMV2ErrorUnimplemented();
  factory XCMV2ErrorUnimplemented.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.unimplemented.type);
    return XCMV2ErrorUnimplemented();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorUntrustedReserveLocation extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.untrustedReserveLocation;
  const XCMV2ErrorUntrustedReserveLocation();
  factory XCMV2ErrorUntrustedReserveLocation.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.untrustedReserveLocation.type);
    return XCMV2ErrorUntrustedReserveLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorUntrustedTeleportLocation extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.untrustedTeleportLocation;
  const XCMV2ErrorUntrustedTeleportLocation();
  factory XCMV2ErrorUntrustedTeleportLocation.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.untrustedTeleportLocation.type);
    return XCMV2ErrorUntrustedTeleportLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorLocationFull extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.locationFull;
  const XCMV2ErrorLocationFull();
  factory XCMV2ErrorLocationFull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.locationFull.type);
    return XCMV2ErrorLocationFull();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorLocationNotInvertible extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.locationNotInvertible;
  const XCMV2ErrorLocationNotInvertible();
  factory XCMV2ErrorLocationNotInvertible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.locationNotInvertible.type);
    return XCMV2ErrorLocationNotInvertible();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorBadOrigin extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.badOrigin;
  const XCMV2ErrorBadOrigin();
  factory XCMV2ErrorBadOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.badOrigin.type);
    return XCMV2ErrorBadOrigin();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorInvalidLocation extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.invalidLocation;
  const XCMV2ErrorInvalidLocation();
  factory XCMV2ErrorInvalidLocation.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.invalidLocation.type);
    return XCMV2ErrorInvalidLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorAssetNotFound extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.assetNotFound;
  const XCMV2ErrorAssetNotFound();
  factory XCMV2ErrorAssetNotFound.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.assetNotFound.type);
    return XCMV2ErrorAssetNotFound();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorFailedToTransactAsset extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.failedToTransactAsset;
  const XCMV2ErrorFailedToTransactAsset();
  factory XCMV2ErrorFailedToTransactAsset.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.failedToTransactAsset.type);
    return XCMV2ErrorFailedToTransactAsset();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorNotWithdrawable extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.notWithdrawable;
  const XCMV2ErrorNotWithdrawable();
  factory XCMV2ErrorNotWithdrawable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.notWithdrawable.type);
    return XCMV2ErrorNotWithdrawable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorLocationCannotHold extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.locationCannotHold;
  const XCMV2ErrorLocationCannotHold();
  factory XCMV2ErrorLocationCannotHold.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.locationCannotHold.type);
    return XCMV2ErrorLocationCannotHold();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorExceedsMaxMessageSize extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.exceedsMaxMessageSize;
  const XCMV2ErrorExceedsMaxMessageSize();
  factory XCMV2ErrorExceedsMaxMessageSize.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.exceedsMaxMessageSize.type);
    return XCMV2ErrorExceedsMaxMessageSize();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorDestinationUnsupported extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.destinationUnsupported;
  const XCMV2ErrorDestinationUnsupported();
  factory XCMV2ErrorDestinationUnsupported.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.destinationUnsupported.type);
    return XCMV2ErrorDestinationUnsupported();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorTransport extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.transport;
  const XCMV2ErrorTransport();
  factory XCMV2ErrorTransport.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.transport.type);
    return XCMV2ErrorTransport();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorUnroutable extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.unroutable;
  const XCMV2ErrorUnroutable();
  factory XCMV2ErrorUnroutable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.unroutable.type);
    return XCMV2ErrorUnroutable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorUnknownClaim extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.unknownClaim;
  const XCMV2ErrorUnknownClaim();
  factory XCMV2ErrorUnknownClaim.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.unknownClaim.type);
    return XCMV2ErrorUnknownClaim();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorFailedToDecode extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.failedToDecode;
  const XCMV2ErrorFailedToDecode();
  factory XCMV2ErrorFailedToDecode.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.failedToDecode.type);
    return XCMV2ErrorFailedToDecode();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorMaxWeightInvalid extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.maxWeightInvalid;
  const XCMV2ErrorMaxWeightInvalid();
  factory XCMV2ErrorMaxWeightInvalid.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.maxWeightInvalid.type);
    return XCMV2ErrorMaxWeightInvalid();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorNotHoldingFees extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.notHodingFees;
  const XCMV2ErrorNotHoldingFees();
  factory XCMV2ErrorNotHoldingFees.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.notHodingFees.type);
    return XCMV2ErrorNotHoldingFees();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorTooExpensive extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.tooExpensive;
  const XCMV2ErrorTooExpensive();
  factory XCMV2ErrorTooExpensive.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.tooExpensive.type);
    return XCMV2ErrorTooExpensive();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorTrap extends XCMV2Error {
  final BigInt code;
  XCMV2ErrorTrap({required BigInt code}) : code = code.asUint64;
  factory XCMV2ErrorTrap.deserializeJson(Map<String, dynamic> json) {
    return XCMV2ErrorTrap(code: BigintUtils.parse(json["code"]));
  }
  factory XCMV2ErrorTrap.fromJson(Map<String, dynamic> json) {
    return XCMV2ErrorTrap(code: json.valueAs(XCMV2ErrorType.trap.type));
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.u64(property: "code")],
        property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"code": code};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: code};
  }

  @override
  XCMV2ErrorType get type => XCMV2ErrorType.trap;

  @override
  List get variabels => [type, code];
}

class XCMV2ErrorUnhandledXcmVersion extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.unhandledXcmVersion;
  const XCMV2ErrorUnhandledXcmVersion();
  factory XCMV2ErrorUnhandledXcmVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.unhandledXcmVersion.type);
    return XCMV2ErrorUnhandledXcmVersion();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorWeightLimitReached extends XCMV2Error
    with SubstrateVariantNoArgs {
  final BigInt weight;
  XCMV2ErrorWeightLimitReached({required this.weight});
  factory XCMV2ErrorWeightLimitReached.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2ErrorWeightLimitReached(weight: json.valueAs("weight"));
  }

  factory XCMV2ErrorWeightLimitReached.fromJson(Map<String, dynamic> json) {
    return XCMV2ErrorWeightLimitReached(
        weight: json.valueAs(XCMV2ErrorType.weightLimitReached.type));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.u64(property: "weight")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  XCMV2ErrorType get type => XCMV2ErrorType.weightLimitReached;
  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"weight": weight};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: weight};
  }

  @override
  List get variabels => [type, weight];
}

class XCMV2ErrorBarrier extends XCMV2Error with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.barrier;
  const XCMV2ErrorBarrier();
  factory XCMV2ErrorBarrier.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.barrier.type);
    return XCMV2ErrorBarrier();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2ErrorWeightNotComputable extends XCMV2Error
    with SubstrateVariantNoArgs {
  @override
  XCMV2ErrorType get type => XCMV2ErrorType.weightNotComputable;
  const XCMV2ErrorWeightNotComputable();
  factory XCMV2ErrorWeightNotComputable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ErrorType.weightNotComputable.type);
    return XCMV2ErrorWeightNotComputable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

abstract class XCMV2Response extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV2ResponseType get type;

  const XCMV2Response();
  factory XCMV2Response.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV2ResponseType.fromName(decode.variantName);
    return switch (type) {
      XCMV2ResponseType.nullResponse => XCMV2ResponseNull(),
      XCMV2ResponseType.assets =>
        XCMV2ResponseAssets.deserializeJson(decode.value),
      XCMV2ResponseType.executionResult =>
        XCMV2ResponseExecutionResult.deserializeJson(decode.value),
      XCMV2ResponseType.version =>
        XCMV2ResponseVersion.deserializeJson(decode.value),
    };
  }
  factory XCMV2Response.fromJson(Map<String, dynamic> json) {
    final type = XCMV2ResponseType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV2ResponseType.nullResponse => XCMV2ResponseNull.fromJson(json),
      XCMV2ResponseType.assets => XCMV2ResponseAssets.fromJson(json),
      XCMV2ResponseType.executionResult =>
        XCMV2ResponseExecutionResult.fromJson(json),
      XCMV2ResponseType.version => XCMV2ResponseVersion.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMV2ResponseType.nullResponse.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV2ResponseAssets.layout_(property: property),
        property: XCMV2ResponseType.assets.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2ResponseExecutionResult.layout_(property: property),
        property: XCMV2ResponseType.executionResult.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2ResponseVersion.layout_(property: property),
        property: XCMV2ResponseType.version.name,
        index: 3,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  Map<String, dynamic> toJson();
  @override
  String get variantName => type.name;

  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2ResponseNull extends XCMV2Response with SubstrateVariantNoArgs {
  XCMV2ResponseNull();
  factory XCMV2ResponseNull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV2ResponseType.nullResponse.type);
    return XCMV2ResponseNull();
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV2ResponseType get type => XCMV2ResponseType.nullResponse;

  @override
  List get variabels => [type];
}

class XCMV2ResponseAssets extends XCMV2Response {
  final XCMV2MultiAssets assets;
  XCMV2ResponseAssets({required this.assets});

  factory XCMV2ResponseAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMV2ResponseAssets(
        assets: XCMV2MultiAssets.deserializeJson(json["assets"]));
  }
  factory XCMV2ResponseAssets.fromJson(Map<String, dynamic> json) {
    final assets = json
        .valueEnsureAsList<Map<String, dynamic>>(XCMV2ResponseType.assets.type);
    return XCMV2ResponseAssets(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()));
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

  @override
  XCMV2ResponseType get type => XCMV2ResponseType.assets;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

class XCMV2ResponseExecutionResult extends XCMV2Response {
  final int? index;
  final XCMV2Error? error;
  XCMV2ResponseExecutionResult({int? index, this.error})
      : index = index?.asUint32;

  factory XCMV2ResponseExecutionResult.deserializeJson(
      Map<String, dynamic> json) {
    final error = json["error"];
    if (error == null) return XCMV2ResponseExecutionResult();
    return XCMV2ResponseExecutionResult(
        index: IntUtils.parse(error["index"]),
        error: XCMV2Error.deserializeJson(error["error"]));
  }

  factory XCMV2ResponseExecutionResult.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMV2ResponseType.executionResult.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV2ResponseExecutionResult();
    return XCMV2ResponseExecutionResult(
        index: IntUtils.parse(opt[0]), error: XCMV2Error.fromJson(opt[1]));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(
          LayoutConst.struct([
            LayoutConst.u32(property: "index"),
            XCMV2Error.layout_(property: "error")
          ]),
          property: "error")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "error": (index == null || error == null)
          ? null
          : {"index": index, "error": error?.serializeJsonVariant()}
    };
  }

  @override
  XCMV2ResponseType get type => XCMV2ResponseType.executionResult;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: MetadataUtils.toOptionalJson(
          (index == null || error == null) ? null : [index, error?.toJson()])
    };
  }

  @override
  List get variabels => [type, index, error];
}

class XCMV2ResponseVersion extends XCMV2Response {
  final int versionNumber;
  XCMV2ResponseVersion({required int version})
      : versionNumber = version.asUint32;

  factory XCMV2ResponseVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV2ResponseVersion(version: IntUtils.parse(json["version"]));
  }
  factory XCMV2ResponseVersion.fromJson(Map<String, dynamic> json) {
    return XCMV2ResponseVersion(
        version: json.valueAs(XCMV2ResponseType.version.type));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.u32(property: "version")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"version": versionNumber};
  }

  @override
  XCMV2ResponseType get type => XCMV2ResponseType.version;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: versionNumber};
  }

  @override
  List get variabels => [type, versionNumber];
}

class XCMV2 extends SubstrateSerialization<Map<String, dynamic>>
    with XCM<XCMInstructionV2>, Equality {
  @override
  final List<XCMInstructionV2> instructions;

  XCMV2({required List<XCMInstructionV2> instructions})
      : instructions = instructions.immutable;
  factory XCMV2.deserializeJson(Map<String, dynamic> json) {
    return XCMV2(
        instructions: json
            .valueEnsureAsList<Map<String, dynamic>>("instructions")
            .map((e) => XCMInstructionV2.deserializeJson(e))
            .toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMInstructionV2.layout_(),
          property: "instructions")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "instructions": instructions.map((e) => e.serializeJsonVariant()).toList()
    };
  }

  @override
  XCMVersion get version => XCMVersion.v2;
}
