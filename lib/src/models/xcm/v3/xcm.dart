import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

class _XCMV3Constants {
  static const int maxPalletInfo = 64;
  static const int maxDispatchErrorLen = 128;
}

abstract class XCMV3WeightLimit extends SubstrateVariantSerialization
    with WeightLimit, Equality {
  const XCMV3WeightLimit();
  factory XCMV3WeightLimit.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWeightLimitType.fromName(decode.variantName);
    return switch (type) {
      XCMWeightLimitType.limited =>
        XCMV3WeightLimitLimited.deserializeJson(decode.value),
      XCMWeightLimitType.unlimited => XCMV3WeightLimitUnlimited()
    };
  }
  factory XCMV3WeightLimit.fromJson(Map<String, dynamic> json) {
    final type = XCMWeightLimitType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWeightLimitType.limited => XCMV3WeightLimitLimited.fromJson(json),
      XCMWeightLimitType.unlimited => XCMV3WeightLimitUnlimited.fromJson(json)
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
            XCMV3WeightLimitLimited.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3WeightLimitLimited extends XCMV3WeightLimit {
  final SubstrateWeightV2 weight;
  XCMV3WeightLimitLimited({required this.weight});

  factory XCMV3WeightLimitLimited.deserializeJson(Map<String, dynamic> json) {
    return XCMV3WeightLimitLimited(
        weight: SubstrateWeightV2.deserializeJson(json.valueAs("weight")));
  }
  factory XCMV3WeightLimitLimited.fromJson(Map<String, dynamic> json) {
    return XCMV3WeightLimitLimited(
        weight: SubstrateWeightV2.fromJson(
            json.valueAs(XCMWeightLimitType.limited.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([SubstrateWeightV2.layout_(property: "weight")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"weight": weight.serializeJson()};
  }

  @override
  XCMWeightLimitType get type => XCMWeightLimitType.limited;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: weight.toJson()};
  }

  @override
  List get variabels => [type, weight];
}

class XCMV3WeightLimitUnlimited extends XCMV3WeightLimit
    with SubstrateVariantNoArgs {
  XCMV3WeightLimitUnlimited();

  factory XCMV3WeightLimitUnlimited.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWeightLimitType.unlimited.type);
    return XCMV3WeightLimitUnlimited();
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

abstract class XCMInstructionV3 extends SubstrateVariantSerialization
    with XCMInstruction, Equality {
  const XCMInstructionV3();
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMV3WithdrawAsset.layout_(property: property),
        property: XCMInstructionType.withdrawAsset.name,
        index: XCMInstructionType.withdrawAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ReserveAssetDeposited.layout_(property: property),
        property: XCMInstructionType.reserveAssetDeposited.name,
        index: XCMInstructionType.reserveAssetDeposited.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ReceiveTeleportedAsset.layout_(property: property),
        property: XCMInstructionType.receiveTeleportedAsset.name,
        index: XCMInstructionType.receiveTeleportedAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3QueryResponse.layout_(property: property),
        property: XCMInstructionType.queryResponse.name,
        index: XCMInstructionType.queryResponse.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3TransferAsset.layout_(property: property),
        property: XCMInstructionType.transferAsset.name,
        index: XCMInstructionType.transferAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3TransferReserveAsset.layout_(property: property),
        property: XCMInstructionType.transferReserveAsset.name,
        index: XCMInstructionType.transferReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3Transact.layout_(property: property),
        property: XCMInstructionType.transact.name,
        index: XCMInstructionType.transact.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3HrmpNewChannelOpenRequest.layout_(property: property),
        property: XCMInstructionType.hrmpNewChannelOpenRequest.name,
        index: XCMInstructionType.hrmpNewChannelOpenRequest.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3HrmpChannelAccepted.layout_(property: property),
        property: XCMInstructionType.hrmpChannelAccepted.name,
        index: XCMInstructionType.hrmpChannelAccepted.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3HrmpChannelClosing.layout_(property: property),
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
        layout: ({property}) => XCMV3DescendOrigin.layout_(property: property),
        property: XCMInstructionType.descendOrigin.name,
        index: XCMInstructionType.descendOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ReportError.layout_(property: property),
        property: XCMInstructionType.reportError.name,
        index: XCMInstructionType.reportError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3DepositAsset.layout_(property: property),
        property: XCMInstructionType.depositAsset.name,
        index: XCMInstructionType.depositAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3DepositReserveAsset.layout_(property: property),
        property: XCMInstructionType.depositReserveAsset.name,
        index: XCMInstructionType.depositReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ExchangeAsset.layout_(property: property),
        property: XCMInstructionType.exchangeAsset.name,
        index: XCMInstructionType.exchangeAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3InitiateReserveWithdraw.layout_(property: property),
        property: XCMInstructionType.initiateReserveWithdraw.name,
        index: XCMInstructionType.initiateReserveWithdraw.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3InitiateTeleport.layout_(property: property),
        property: XCMInstructionType.initiateTeleport.name,
        index: XCMInstructionType.initiateTeleport.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ReportHolding.layout_(property: property),
        property: XCMInstructionType.reportHolding.name,
        index: XCMInstructionType.reportHolding.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3BuyExecution.layout_(property: property),
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
            XCMV3SetErrorHandler.layout_(property: property),
        property: XCMInstructionType.setErrorHandler.name,
        index: XCMInstructionType.setErrorHandler.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3SetAppendix.layout_(property: property),
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
        layout: ({property}) => XCMV3ClaimAsset.layout_(property: property),
        property: XCMInstructionType.claimAsset.name,
        index: XCMInstructionType.claimAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3Trap.layout_(property: property),
        property: XCMInstructionType.trap.name,
        index: XCMInstructionType.trap.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3SubscribeVersion.layout_(property: property),
        property: XCMInstructionType.subscribeVersion.name,
        index: XCMInstructionType.subscribeVersion.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.unsubscribeVersion.name,
        index: XCMInstructionType.unsubscribeVersion.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3BurnAsset.layout_(property: property),
        property: XCMInstructionType.burnAsset.name,
        index: XCMInstructionType.burnAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ExpectAsset.layout_(property: property),
        property: XCMInstructionType.expectAsset.name,
        index: XCMInstructionType.expectAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ExpectOrigin.layout_(property: property),
        property: XCMInstructionType.expectOrigin.name,
        index: XCMInstructionType.expectOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ExpectError.layout_(property: property),
        property: XCMInstructionType.expectError.name,
        index: XCMInstructionType.expectError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ExpectTransactStatus.layout_(property: property),
        property: XCMInstructionType.expectTransactStatus.name,
        index: XCMInstructionType.expectTransactStatus.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3QueryPallet.layout_(property: property),
        property: XCMInstructionType.queryPallet.name,
        index: XCMInstructionType.queryPallet.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ExpectPallet.layout_(property: property),
        property: XCMInstructionType.expectPallet.name,
        index: XCMInstructionType.expectPallet.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ReportTransactStatus.layout_(property: property),
        property: XCMInstructionType.reportTransactStatus.name,
        index: XCMInstructionType.reportTransactStatus.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.clearTransactStatus.name,
        index: XCMInstructionType.clearTransactStatus.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3UniversalOrigin.layout_(property: property),
        property: XCMInstructionType.universalOrigin.name,
        index: XCMInstructionType.universalOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ExportMessage.layout_(property: property),
        property: XCMInstructionType.exportMessage.name,
        index: XCMInstructionType.exportMessage.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3LockAsset.layout_(property: property),
        property: XCMInstructionType.lockAsset.name,
        index: XCMInstructionType.lockAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3UnlockAsset.layout_(property: property),
        property: XCMInstructionType.unlockAsset.name,
        index: XCMInstructionType.unlockAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3NoteUnlockable.layout_(property: property),
        property: XCMInstructionType.noteUnlockable.name,
        index: XCMInstructionType.noteUnlockable.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3RequestUnlock.layout_(property: property),
        property: XCMInstructionType.requestUnlock.name,
        index: XCMInstructionType.requestUnlock.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3SetFeesMode.layout_(property: property),
        property: XCMInstructionType.setFeesMode.name,
        index: XCMInstructionType.setFeesMode.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3SetTopic.layout_(property: property),
        property: XCMInstructionType.setTopic.name,
        index: XCMInstructionType.setTopic.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMInstructionType.clearTopic.name,
        index: XCMInstructionType.clearTopic.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3AliasOrigin.layout_(property: property),
        property: XCMInstructionType.aliasOrigin.name,
        index: XCMInstructionType.aliasOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3UnpaidExecution.layout_(property: property),
        property: XCMInstructionType.unpaidExecution.name,
        index: XCMInstructionType.unpaidExecution.variantIndex,
      ),
    ]);
  }

  factory XCMInstructionV3.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMInstructionType.fromName(decode.variantName);
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV3WithdrawAsset.deserializeJson(decode.value),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV3ReserveAssetDeposited.deserializeJson(decode.value),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV3ReceiveTeleportedAsset.deserializeJson(decode.value),
      XCMInstructionType.queryResponse =>
        XCMV3QueryResponse.deserializeJson(decode.value),
      XCMInstructionType.transferAsset =>
        XCMV3TransferAsset.deserializeJson(decode.value),
      XCMInstructionType.transferReserveAsset =>
        XCMV3TransferReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.transact =>
        XCMV3Transact.deserializeJson(decode.value),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV3HrmpNewChannelOpenRequest.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV3HrmpChannelAccepted.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV3HrmpChannelClosing.deserializeJson(decode.value),
      XCMInstructionType.clearOrigin => XCMV3ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV3DescendOrigin.deserializeJson(decode.value),
      XCMInstructionType.reportError =>
        XCMV3ReportError.deserializeJson(decode.value),
      XCMInstructionType.depositAsset =>
        XCMV3DepositAsset.deserializeJson(decode.value),
      XCMInstructionType.depositReserveAsset =>
        XCMV3DepositReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.exchangeAsset =>
        XCMV3ExchangeAsset.deserializeJson(decode.value),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV3InitiateReserveWithdraw.deserializeJson(decode.value),
      XCMInstructionType.initiateTeleport =>
        XCMV3InitiateTeleport.deserializeJson(decode.value),
      XCMInstructionType.reportHolding =>
        XCMV3ReportHolding.deserializeJson(decode.value),
      XCMInstructionType.buyExecution =>
        XCMV3BuyExecution.deserializeJson(decode.value),
      XCMInstructionType.refundSurplus => XCMV3RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV3SetErrorHandler.deserializeJson(decode.value),
      XCMInstructionType.setAppendix =>
        XCMV3SetAppendix.deserializeJson(decode.value),
      XCMInstructionType.clearError => XCMV3ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV3ClaimAsset.deserializeJson(decode.value),
      XCMInstructionType.trap => XCMV3Trap.deserializeJson(decode.value),
      XCMInstructionType.subscribeVersion =>
        XCMV3SubscribeVersion.deserializeJson(decode.value),
      XCMInstructionType.unsubscribeVersion => XCMV3UnsubscribeVersion(),
      XCMInstructionType.burnAsset =>
        XCMV3BurnAsset.deserializeJson(decode.value),
      XCMInstructionType.expectAsset =>
        XCMV3ExpectAsset.deserializeJson(decode.value),
      XCMInstructionType.expectOrigin =>
        XCMV3ExpectOrigin.deserializeJson(decode.value),
      XCMInstructionType.expectError =>
        XCMV3ExpectError.deserializeJson(decode.value),
      XCMInstructionType.expectTransactStatus =>
        XCMV3ExpectTransactStatus.deserializeJson(decode.value),
      XCMInstructionType.queryPallet =>
        XCMV3QueryPallet.deserializeJson(decode.value),
      XCMInstructionType.expectPallet =>
        XCMV3ExpectPallet.deserializeJson(decode.value),
      XCMInstructionType.reportTransactStatus =>
        XCMV3ReportTransactStatus.deserializeJson(decode.value),
      XCMInstructionType.clearTransactStatus => XCMV3ClearTransactStatus(),
      XCMInstructionType.universalOrigin =>
        XCMV3UniversalOrigin.deserializeJson(decode.value),
      XCMInstructionType.exportMessage =>
        XCMV3ExportMessage.deserializeJson(decode.value),
      XCMInstructionType.lockAsset =>
        XCMV3LockAsset.deserializeJson(decode.value),
      XCMInstructionType.unlockAsset =>
        XCMV3UnlockAsset.deserializeJson(decode.value),
      XCMInstructionType.noteUnlockable =>
        XCMV3NoteUnlockable.deserializeJson(decode.value),
      XCMInstructionType.requestUnlock =>
        XCMV3RequestUnlock.deserializeJson(decode.value),
      XCMInstructionType.setFeesMode =>
        XCMV3SetFeesMode.deserializeJson(decode.value),
      XCMInstructionType.setTopic =>
        XCMV3SetTopic.deserializeJson(decode.value),
      XCMInstructionType.clearTopic => XCMV3ClearTopic(),
      XCMInstructionType.aliasOrigin =>
        XCMV3AliasOrigin.deserializeJson(decode.value),
      XCMInstructionType.unpaidExecution =>
        XCMV3UnpaidExecution.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 3",
          details: {"type": type.name})
    };
  }
  factory XCMInstructionV3.fromJson(Map<String, dynamic> json) {
    final type = XCMInstructionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMInstructionType.withdrawAsset => XCMV3WithdrawAsset.fromJson(json),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV3ReserveAssetDeposited.fromJson(json),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV3ReceiveTeleportedAsset.fromJson(json),
      XCMInstructionType.queryResponse => XCMV3QueryResponse.fromJson(json),
      XCMInstructionType.transferAsset => XCMV3TransferAsset.fromJson(json),
      XCMInstructionType.transferReserveAsset =>
        XCMV3TransferReserveAsset.fromJson(json),
      XCMInstructionType.transact => XCMV3Transact.fromJson(json),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV3HrmpNewChannelOpenRequest.fromJson(json),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV3HrmpChannelAccepted.fromJson(json),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV3HrmpChannelClosing.fromJson(json),
      XCMInstructionType.clearOrigin => XCMV3ClearOrigin.fromJson(json),
      XCMInstructionType.descendOrigin => XCMV3DescendOrigin.fromJson(json),
      XCMInstructionType.reportError => XCMV3ReportError.fromJson(json),
      XCMInstructionType.depositAsset => XCMV3DepositAsset.fromJson(json),
      XCMInstructionType.depositReserveAsset =>
        XCMV3DepositReserveAsset.fromJson(json),
      XCMInstructionType.exchangeAsset => XCMV3ExchangeAsset.fromJson(json),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV3InitiateReserveWithdraw.fromJson(json),
      XCMInstructionType.initiateTeleport =>
        XCMV3InitiateTeleport.fromJson(json),
      XCMInstructionType.reportHolding => XCMV3ReportHolding.fromJson(json),
      XCMInstructionType.buyExecution => XCMV3BuyExecution.fromJson(json),
      XCMInstructionType.refundSurplus => XCMV3RefundSurplus.fromJson(json),
      XCMInstructionType.setErrorHandler => XCMV3SetErrorHandler.fromJson(json),
      XCMInstructionType.setAppendix => XCMV3SetAppendix.fromJson(json),
      XCMInstructionType.clearError => XCMV3ClearError.fromJson(json),
      XCMInstructionType.claimAsset => XCMV3ClaimAsset.fromJson(json),
      XCMInstructionType.trap => XCMV3Trap.fromJson(json),
      XCMInstructionType.subscribeVersion =>
        XCMV3SubscribeVersion.fromJson(json),
      XCMInstructionType.unsubscribeVersion => XCMV3UnsubscribeVersion(),
      XCMInstructionType.burnAsset => XCMV3BurnAsset.fromJson(json),
      XCMInstructionType.expectAsset => XCMV3ExpectAsset.fromJson(json),
      XCMInstructionType.expectOrigin => XCMV3ExpectOrigin.fromJson(json),
      XCMInstructionType.expectError => XCMV3ExpectError.fromJson(json),
      XCMInstructionType.expectTransactStatus =>
        XCMV3ExpectTransactStatus.fromJson(json),
      XCMInstructionType.queryPallet => XCMV3QueryPallet.fromJson(json),
      XCMInstructionType.expectPallet => XCMV3ExpectPallet.fromJson(json),
      XCMInstructionType.reportTransactStatus =>
        XCMV3ReportTransactStatus.fromJson(json),
      XCMInstructionType.clearTransactStatus => XCMV3ClearTransactStatus(),
      XCMInstructionType.universalOrigin => XCMV3UniversalOrigin.fromJson(json),
      XCMInstructionType.exportMessage => XCMV3ExportMessage.fromJson(json),
      XCMInstructionType.lockAsset => XCMV3LockAsset.fromJson(json),
      XCMInstructionType.unlockAsset => XCMV3UnlockAsset.fromJson(json),
      XCMInstructionType.noteUnlockable => XCMV3NoteUnlockable.fromJson(json),
      XCMInstructionType.requestUnlock => XCMV3RequestUnlock.fromJson(json),
      XCMInstructionType.setFeesMode => XCMV3SetFeesMode.fromJson(json),
      XCMInstructionType.setTopic => XCMV3SetTopic.fromJson(json),
      XCMInstructionType.clearTopic => XCMV3ClearTopic.fromJson(json),
      XCMInstructionType.aliasOrigin => XCMV3AliasOrigin.fromJson(json),
      XCMInstructionType.unpaidExecution => XCMV3UnpaidExecution.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 3",
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
  XCMVersion get version => XCMVersion.v3;
  @override
  Map<String, dynamic> toJson();
}

class XCMV3WithdrawAsset extends XCMInstructionV3 with XCMWithdrawAsset {
  @override
  final XCMV3MultiAssets assets;
  XCMV3WithdrawAsset({required this.assets});
  factory XCMV3WithdrawAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3WithdrawAsset(
        assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV3WithdrawAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.withdrawAsset.type);

    return XCMV3WithdrawAsset(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()));
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

class XCMV3ReserveAssetDeposited extends XCMInstructionV3
    with XCMReserveAssetDeposited {
  @override
  final XCMV3MultiAssets assets;
  XCMV3ReserveAssetDeposited({required this.assets});
  factory XCMV3ReserveAssetDeposited.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3ReserveAssetDeposited(
        assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV3ReserveAssetDeposited.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.reserveAssetDeposited.type);
    return XCMV3ReserveAssetDeposited(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()));
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

class XCMV3ReceiveTeleportedAsset extends XCMInstructionV3
    with XCMReceiveTeleportedAsset {
  @override
  final XCMV3MultiAssets assets;
  XCMV3ReceiveTeleportedAsset({required this.assets});
  factory XCMV3ReceiveTeleportedAsset.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3ReceiveTeleportedAsset(
        assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV3ReceiveTeleportedAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.receiveTeleportedAsset.type);
    return XCMV3ReceiveTeleportedAsset(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()));
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

class XCMV3QueryResponse extends XCMInstructionV3 with XCMQueryResponse {
  final BigInt queryId;
  final XCMV3Response response;
  final SubstrateWeightV2 maxWeight;
  final XCMV3MultiLocation? querier;

  XCMV3QueryResponse(
      {required this.queryId,
      required this.response,
      required this.maxWeight,
      required this.querier});
  factory XCMV3QueryResponse.deserializeJson(Map<String, dynamic> json) {
    return XCMV3QueryResponse(
        queryId: json.valueAs("query_id"),
        response: XCMV3Response.deserializeJson(json.valueAs("response")),
        maxWeight:
            SubstrateWeightV2.deserializeJson(json.valueAs("max_weight")),
        querier: json.valueTo<XCMV3MultiLocation?, Map<String, dynamic>>(
            key: "querier",
            parse: (v) => XCMV3MultiLocation.deserializeJson(v)));
  }
  factory XCMV3QueryResponse.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.queryResponse.type);
    final Map<String, dynamic>? querier =
        MetadataUtils.parseOptional(data.valueAs("querier"));
    return XCMV3QueryResponse(
        queryId: data.valueAs("query_id"),
        response: XCMV3Response.fromJson(data.valueAs("response")),
        maxWeight: SubstrateWeightV2.fromJson(data.valueAs("max_weight")),
        querier: querier == null ? null : XCMV3MultiLocation.fromJson(querier));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      XCMV3Response.layout_(property: "response"),
      SubstrateWeightV2.layout_(property: "max_weight"),
      LayoutConst.optional(XCMV3MultiLocation.layout_(), property: "querier")
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
      "max_weight": maxWeight.serializeJson(),
      "querier": querier?.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "query_id": queryId,
        "response": response.toJson(),
        "max_weight": maxWeight.toJson(),
        "querier": MetadataUtils.toOptionalJson(querier?.toJson())
      }
    };
  }

  @override
  List get variabels => [type, queryId, response, maxWeight, querier];
}

class XCMV3TransferAsset extends XCMInstructionV3 with XCMTransferAsset {
  @override
  final XCMV3MultiAssets assets;
  @override
  final XCMV3MultiLocation beneficiary;
  XCMV3TransferAsset({required this.assets, required this.beneficiary});
  factory XCMV3TransferAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3TransferAsset(
      assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")),
      beneficiary:
          XCMV3MultiLocation.deserializeJson(json.valueAs("beneficiary")),
    );
  }

  factory XCMV3TransferAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV3TransferAsset(
      assets: XCMV3MultiAssets(
          assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()),
      beneficiary: XCMV3MultiLocation.fromJson(data.valueAs("beneficiary")),
    );
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssets.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "beneficiary")
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

class XCMV3TransferReserveAsset extends XCMInstructionV3
    with XCMTransferReserveAsset {
  @override
  final XCMV3MultiAssets assets;
  @override
  final XCMV3MultiLocation dest;
  @override
  final XCMV3 xcm;
  XCMV3TransferReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV3TransferReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3TransferReserveAsset(
        assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")),
        dest: XCMV3MultiLocation.deserializeJson(json.valueAs("dest")),
        xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV3TransferReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferReserveAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV3TransferReserveAsset(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()),
        dest: XCMV3MultiLocation.fromJson(data.valueAs("dest")),
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssets.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "dest"),
      XCMV3.layout_(property: "xcm")
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

enum XCMV3OriginKindType {
  native("Native", 0),
  sovereignAccount("SovereignAccount", 1),
  superuser("Superuser", 2),
  xcm("Xcm", 3);

  const XCMV3OriginKindType(this.type, this.variantIndex);
  final String type;
  final int variantIndex;

  static XCMV3OriginKindType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV3OriginKindType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV3OriginKind extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV3OriginKindType get type;
  const XCMV3OriginKind();
  Map<String, dynamic> toJson();
  factory XCMV3OriginKind.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV3OriginKindType.fromName(decode.variantName);
    return switch (type) {
      XCMV3OriginKindType.native => XCMV3OriginKindNative(),
      XCMV3OriginKindType.sovereignAccount => XCMV3OriginKindSovereignAccount(),
      XCMV3OriginKindType.superuser => XCMV3OriginKindSuperuser(),
      XCMV3OriginKindType.xcm => XCMV3OriginKindXcm(),
    };
  }
  factory XCMV3OriginKind.fromJson(Map<String, dynamic> json) {
    final type = XCMV3OriginKindType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV3OriginKindType.native => XCMV3OriginKindNative.fromJson(json),
      XCMV3OriginKindType.sovereignAccount =>
        XCMV3OriginKindSovereignAccount.fromJson(json),
      XCMV3OriginKindType.superuser => XCMV3OriginKindSuperuser.fromJson(json),
      XCMV3OriginKindType.xcm => XCMV3OriginKindXcm.fromJson(json),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum(
        XCMV3OriginKindType.values
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
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3OriginKindNative extends XCMV3OriginKind
    with SubstrateVariantNoArgs {
  const XCMV3OriginKindNative();
  factory XCMV3OriginKindNative.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3OriginKindType.native.type);
    return XCMV3OriginKindNative();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV3OriginKindType get type => XCMV3OriginKindType.native;
  @override
  List get variabels => [type];
}

class XCMV3OriginKindSovereignAccount extends XCMV3OriginKind
    with SubstrateVariantNoArgs {
  const XCMV3OriginKindSovereignAccount();
  factory XCMV3OriginKindSovereignAccount.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3OriginKindType.sovereignAccount.type);
    return XCMV3OriginKindSovereignAccount();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV3OriginKindType get type => XCMV3OriginKindType.sovereignAccount;
  @override
  List get variabels => [type];
}

class XCMV3OriginKindSuperuser extends XCMV3OriginKind
    with SubstrateVariantNoArgs {
  const XCMV3OriginKindSuperuser();
  factory XCMV3OriginKindSuperuser.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3OriginKindType.superuser.type);
    return XCMV3OriginKindSuperuser();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV3OriginKindType get type => XCMV3OriginKindType.superuser;
  @override
  List get variabels => [type];
}

class XCMV3OriginKindXcm extends XCMV3OriginKind with SubstrateVariantNoArgs {
  @override
  XCMV3OriginKindType get type => XCMV3OriginKindType.xcm;
  const XCMV3OriginKindXcm();
  factory XCMV3OriginKindXcm.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3OriginKindType.xcm.type);
    return XCMV3OriginKindXcm();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

class XCMV3Transact extends XCMInstructionV3 with XCMTransact {
  final XCMV3OriginKind originKind;
  final SubstrateWeightV2 requireWeightAtMost;
  @override
  final List<int> call;

  XCMV3Transact(
      {required this.originKind,
      required this.requireWeightAtMost,
      required List<int> call})
      : call = call.asImmutableBytes;
  factory XCMV3Transact.deserializeJson(Map<String, dynamic> json) {
    return XCMV3Transact(
        originKind:
            XCMV3OriginKind.deserializeJson(json.valueAs("origin_kind")),
        requireWeightAtMost: SubstrateWeightV2.deserializeJson(
            json.valueAs("require_weight_at_most")),
        call: json.valueAsBytes("call"));
  }
  factory XCMV3Transact.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.transact.type);
    return XCMV3Transact(
        originKind: XCMV3OriginKind.fromJson(data.valueAs("origin_kind")),
        requireWeightAtMost:
            SubstrateWeightV2.fromJson(data.valueAs("require_weight_at_most")),
        call: data
            .valueEnsureAsMap<String, dynamic>("call")
            .valueAsBytes("encoded"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3OriginKind.layout_(property: "origin_kind"),
      SubstrateWeightV2.layout_(property: "require_weight_at_most"),
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
      "require_weight_at_most": requireWeightAtMost.serializeJson(),
      "call": call
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "origin_kind": originKind.toJson(),
        "require_weight_at_most": requireWeightAtMost.toJson(),
        "call": {"encoded": call}
      }
    };
  }

  @override
  List get variabels => [type, originKind, requireWeightAtMost, call];
}

class XCMV3HrmpNewChannelOpenRequest extends XCMInstructionV3
    with XCMHrmpNewChannelOpenRequest {
  @override
  final int sender;
  @override
  final int maxMessageSize;
  @override
  final int maxCapacity;
  XCMV3HrmpNewChannelOpenRequest(
      {required int sender,
      required int maxMessageSize,
      required int maxCapacity})
      : sender = sender.asUint32,
        maxMessageSize = maxMessageSize.asUint32,
        maxCapacity = maxCapacity.asUint32;
  factory XCMV3HrmpNewChannelOpenRequest.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3HrmpNewChannelOpenRequest(
        sender: json.valueAs("sender"),
        maxCapacity: json.valueAs("max_capacity"),
        maxMessageSize: json.valueAs("max_message_size"));
  }
  factory XCMV3HrmpNewChannelOpenRequest.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpNewChannelOpenRequest.type);
    return XCMV3HrmpNewChannelOpenRequest(
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

class XCMV3HrmpChannelAccepted extends XCMInstructionV3
    with XCMHrmpChannelAccepted {
  @override
  final int recipient;

  XCMV3HrmpChannelAccepted({required int recipient})
      : recipient = recipient.asUint32;
  factory XCMV3HrmpChannelAccepted.deserializeJson(Map<String, dynamic> json) {
    return XCMV3HrmpChannelAccepted(recipient: json.valueAs("recipient"));
  }
  factory XCMV3HrmpChannelAccepted.fromJson(Map<String, dynamic> json) {
    return XCMV3HrmpChannelAccepted(
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

class XCMV3HrmpChannelClosing extends XCMInstructionV3
    with XCMHrmpChannelClosing {
  @override
  final int initiator;
  @override
  final int sender;
  @override
  final int recipient;
  XCMV3HrmpChannelClosing(
      {required int sender, required int initiator, required int recipient})
      : sender = sender.asUint32,
        initiator = initiator.asUint32,
        recipient = recipient.asUint32;
  factory XCMV3HrmpChannelClosing.deserializeJson(Map<String, dynamic> json) {
    return XCMV3HrmpChannelClosing(
        sender: json.valueAs("sender"),
        recipient: json.valueAs("recipient"),
        initiator: json.valueAs("initiator"));
  }
  factory XCMV3HrmpChannelClosing.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpChannelClosing.type);
    return XCMV3HrmpChannelClosing(
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

class XCMV3ClearOrigin extends XCMInstructionV3
    with SubstrateVariantNoArgs, XCMClearOrigin {
  const XCMV3ClearOrigin();
  factory XCMV3ClearOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearOrigin.type);
    return XCMV3ClearOrigin();
  }
}

class XCMV3DescendOrigin extends XCMInstructionV3 with XCMDescendOrigin {
  @override
  final XCMV3InteriorMultiLocation interior;

  XCMV3DescendOrigin({required this.interior});
  factory XCMV3DescendOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV3DescendOrigin(
        interior: XCMV3Junctions.deserializeJson(json.valueAs("interior")));
  }
  factory XCMV3DescendOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV3DescendOrigin(
        interior: XCMV3Junctions.fromJson(
            json.valueAs(XCMInstructionType.descendOrigin.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3Junctions.layout_(property: "interior")],
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

class XCMV3ReportError extends XCMInstructionV3 with XCMReportError {
  final XCMV3QueryResponseInfo responseInfo;

  XCMV3ReportError({required this.responseInfo});
  factory XCMV3ReportError.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ReportError(
        responseInfo: XCMV3QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV3ReportError.fromJson(Map<String, dynamic> json) {
    return XCMV3ReportError(
        responseInfo: XCMV3QueryResponseInfo.fromJson(
            json.valueAs(XCMInstructionType.reportError.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV3QueryResponseInfo.layout_(property: "response_info")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"response_info": responseInfo.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: responseInfo.toJson()};
  }

  @override
  List get variabels => [type, responseInfo];
}

class XCMV3DepositAsset extends XCMInstructionV3 with XCMDepositAsset {
  @override
  final XCMV3MultiAssetFilter assets;
  @override
  final XCMV3MultiLocation beneficiary;
  XCMV3DepositAsset({required this.assets, required this.beneficiary});
  factory XCMV3DepositAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3DepositAsset(
      assets: XCMV3MultiAssetFilter.deserializeJson(json.valueAs("assets")),
      beneficiary:
          XCMV3MultiLocation.deserializeJson(json.valueAs("beneficiary")),
    );
  }

  factory XCMV3DepositAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositAsset.type);
    return XCMV3DepositAsset(
        assets: XCMV3MultiAssetFilter.fromJson(data.valueAs("assets")),
        beneficiary: XCMV3MultiLocation.fromJson(data.valueAs("beneficiary")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssetFilter.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "beneficiary")
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
      "beneficiary": beneficiary.serializeJson(),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.toJson(),
        "beneficiary": beneficiary.toJson()
      }
    };
  }

  @override
  List get variabels => [type, assets, beneficiary];
}

class XCMV3DepositReserveAsset extends XCMInstructionV3
    with XCMDepositReserveAsset {
  @override
  final XCMV3MultiAssetFilter assets;
  @override
  final XCMV3MultiLocation dest;
  @override
  final XCMV3 xcm;
  XCMV3DepositReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV3DepositReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3DepositReserveAsset(
        assets: XCMV3MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV3MultiLocation.deserializeJson(json.valueAs("dest")),
        xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV3DepositReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositReserveAsset.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV3DepositReserveAsset(
        assets: XCMV3MultiAssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV3MultiLocation.fromJson(data.valueAs("dest")),
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssetFilter.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "dest"),
      XCMV3.layout_(property: "xcm")
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
        "xcm": xcm.instructions.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  List get variabels => [type, assets, xcm];
}

class XCMV3ExchangeAsset extends XCMInstructionV3 with XCMExchangeAsset {
  final XCMV3MultiAssetFilter give;
  @override
  final XCMV3MultiAssets want;
  final bool maximal;
  XCMV3ExchangeAsset(
      {required this.give, required this.want, required this.maximal});
  factory XCMV3ExchangeAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ExchangeAsset(
        give: XCMV3MultiAssetFilter.deserializeJson(json.valueAs("give")),
        want: XCMV3MultiAssets.deserializeJson(json.valueAs("want")),
        maximal: json.valueAs("maximal"));
  }
  factory XCMV3ExchangeAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exchangeAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("want");
    return XCMV3ExchangeAsset(
        want: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()),
        give: XCMV3MultiAssetFilter.fromJson(data.valueAs("give")),
        maximal: data.valueAs("maximal"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssetFilter.layout_(property: "give"),
      XCMV3MultiAssets.layout_(property: "want"),
      LayoutConst.boolean(property: "maximal")
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
      "want": want.serializeJson(),
      "maximal": maximal
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "give": give.toJson(),
        "want": want.assets.map((e) => e.toJson()).toList(),
        "maximal": maximal
      }
    };
  }

  @override
  List get variabels => [type, give, want, maximal];
}

class XCMV3InitiateReserveWithdraw extends XCMInstructionV3
    with XCMInitiateReserveWithdraw {
  @override
  final XCMV3MultiAssetFilter assets;
  @override
  final XCMV3MultiLocation reserve;
  @override
  final XCMV3 xcm;
  XCMV3InitiateReserveWithdraw(
      {required this.assets, required this.reserve, required this.xcm});
  factory XCMV3InitiateReserveWithdraw.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3InitiateReserveWithdraw(
        assets: XCMV3MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        reserve: XCMV3MultiLocation.deserializeJson(json.valueAs("reserve")),
        xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV3InitiateReserveWithdraw.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateReserveWithdraw.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV3InitiateReserveWithdraw(
        assets: XCMV3MultiAssetFilter.fromJson(data.valueAs("assets")),
        reserve: XCMV3MultiLocation.fromJson(data.valueAs("reserve")),
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssetFilter.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "reserve"),
      XCMV3.layout_(property: "xcm"),
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

class XCMV3InitiateTeleport extends XCMInstructionV3 with XCMInitiateTeleport {
  final XCMV3MultiAssetFilter assets;
  @override
  final XCMV3MultiLocation dest;
  @override
  final XCMV3 xcm;
  XCMV3InitiateTeleport(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV3InitiateTeleport.deserializeJson(Map<String, dynamic> json) {
    return XCMV3InitiateTeleport(
        assets: XCMV3MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV3MultiLocation.deserializeJson(json.valueAs("dest")),
        xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }

  factory XCMV3InitiateTeleport.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateTeleport.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV3InitiateTeleport(
        assets: XCMV3MultiAssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV3MultiLocation.fromJson(data.valueAs("dest")),
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssetFilter.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "dest"),
      XCMV3.layout_(property: "xcm")
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

class XCMV3ReportHolding extends XCMInstructionV3 with XCMReportHolding {
  final XCMV3QueryResponseInfo responseInfo;
  final XCMV3MultiAssetFilter assets;

  XCMV3ReportHolding({required this.assets, required this.responseInfo});
  factory XCMV3ReportHolding.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ReportHolding(
        assets: XCMV3MultiAssetFilter.deserializeJson(json.valueAs("assets")),
        responseInfo: XCMV3QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV3ReportHolding.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.reportHolding.type);
    return XCMV3ReportHolding(
        assets: XCMV3MultiAssetFilter.fromJson(data.valueAs("assets")),
        responseInfo:
            XCMV3QueryResponseInfo.fromJson(data.valueAs("response_info")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3QueryResponseInfo.layout_(property: "response_info"),
      XCMV3MultiAssetFilter.layout_(property: "assets"),
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
      "response_info": responseInfo.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson({String? property}) {
    return {
      type.type: {
        "assets": assets.toJson(),
        "response_info": responseInfo.toJson()
      }
    };
  }

  @override
  List get variabels => [type, assets, responseInfo];
}

class XCMV3BuyExecution extends XCMInstructionV3 with XCMBuyExecution {
  @override
  final XCMV3MultiAsset fees;
  @override
  final XCMV3WeightLimit weightLimit;

  XCMV3BuyExecution({required this.fees, required this.weightLimit});
  factory XCMV3BuyExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV3BuyExecution(
        fees: XCMV3MultiAsset.deserializeJson(json.valueAs("fees")),
        weightLimit:
            XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit")));
  }
  factory XCMV3BuyExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.buyExecution.type);
    return XCMV3BuyExecution(
      fees: XCMV3MultiAsset.fromJson(data.valueAs("fees")),
      weightLimit: XCMV3WeightLimit.fromJson(data.valueAs("weight_limit")),
    );
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAsset.layout_(property: "fees"),
      XCMV3WeightLimit.layout_(property: "weight_limit"),
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
  Map<String, dynamic> toJson({String? property}) {
    return {
      type.type: {"fees": fees.toJson(), "weight_limit": weightLimit.toJson()}
    };
  }

  @override
  List get variabels => [type, fees, weightLimit];
}

class XCMV3RefundSurplus extends XCMInstructionV3
    with SubstrateVariantNoArgs, XCMRefundSurplus {
  const XCMV3RefundSurplus();
  factory XCMV3RefundSurplus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.refundSurplus.type);
    return XCMV3RefundSurplus();
  }
  @override
  List get variabels => [type];
}

class XCMV3SetErrorHandler extends XCMInstructionV3 with XCMSetErrorHandler {
  @override
  final XCMV3 xcm;
  XCMV3SetErrorHandler({required this.xcm});
  factory XCMV3SetErrorHandler.deserializeJson(Map<String, dynamic> json) {
    return XCMV3SetErrorHandler(
        xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV3SetErrorHandler.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setErrorHandler.type);
    return XCMV3SetErrorHandler(
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
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
}

class XCMV3SetAppendix extends XCMInstructionV3 with XCMSetAppendix {
  @override
  final XCMV3 xcm;
  XCMV3SetAppendix({required this.xcm});
  factory XCMV3SetAppendix.deserializeJson(Map<String, dynamic> json) {
    return XCMV3SetAppendix(xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV3SetAppendix.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setAppendix.type);
    return XCMV3SetAppendix(
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
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
}

class XCMV3ClearError extends XCMInstructionV3
    with SubstrateVariantNoArgs, XCMClearError {
  const XCMV3ClearError();
  factory XCMV3ClearError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearError.type);
    return XCMV3ClearError();
  }
}

class XCMV3ClaimAsset extends XCMInstructionV3 with XCMClaimAsset {
  @override
  final XCMV3MultiAssets assets;
  @override
  final XCMV3MultiLocation ticket;
  XCMV3ClaimAsset({required this.assets, required this.ticket});
  factory XCMV3ClaimAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ClaimAsset(
      assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")),
      ticket: XCMV3MultiLocation.deserializeJson(json.valueAs("ticket")),
    );
  }
  factory XCMV3ClaimAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.claimAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV3ClaimAsset(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()),
        ticket: XCMV3MultiLocation.fromJson(data.valueAs("ticket")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssets.layout_(property: "assets"),
      XCMV3MultiLocation.layout_(property: "ticket"),
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

class XCMV3Trap extends XCMInstructionV3 with XCMTrap {
  @override
  final BigInt trap;
  XCMV3Trap({required BigInt trap}) : trap = trap.asUint64;
  factory XCMV3Trap.deserializeJson(Map<String, dynamic> json) {
    return XCMV3Trap(trap: json.valueAs("trap"));
  }
  factory XCMV3Trap.fromJson(Map<String, dynamic> json) {
    return XCMV3Trap(trap: json.valueAs(XCMInstructionType.trap.type));
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

class XCMV3SubscribeVersion extends XCMInstructionV3 with XCMSubscribeVersion {
  @override
  final BigInt queryId;
  final SubstrateWeightV2 maxResponseWeight;
  XCMV3SubscribeVersion(
      {required BigInt queryId, required this.maxResponseWeight})
      : queryId = queryId.asUint64;
  factory XCMV3SubscribeVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV3SubscribeVersion(
        queryId: json.valueAs("query_id"),
        maxResponseWeight: SubstrateWeightV2.deserializeJson(
            json.valueAs("max_response_weight")));
  }
  factory XCMV3SubscribeVersion.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.subscribeVersion.type);
    return XCMV3SubscribeVersion(
        maxResponseWeight:
            SubstrateWeightV2.fromJson(data.valueAs("max_response_weight")),
        queryId: data.valueAs("query_id"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      SubstrateWeightV2.layout_(property: "max_response_weight")
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
      "max_response_weight": maxResponseWeight.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson({String? property}) {
    return {
      type.type: {
        "query_id": queryId,
        "max_response_weight": maxResponseWeight.toJson()
      }
    };
  }

  @override
  List get variabels => [type, maxResponseWeight];
}

class XCMV3UnsubscribeVersion extends XCMInstructionV3
    with SubstrateVariantNoArgs, XCMUnsubscribeVersion {
  const XCMV3UnsubscribeVersion();
  factory XCMV3UnsubscribeVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.unsubscribeVersion.type);
    return XCMV3UnsubscribeVersion();
  }
}

class XCMV3BurnAsset extends XCMInstructionV3 with XCMBurnAsset {
  @override
  final XCMV3MultiAssets assets;
  XCMV3BurnAsset({required this.assets});
  factory XCMV3BurnAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3BurnAsset(
      assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMV3BurnAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.burnAsset.type);
    return XCMV3BurnAsset(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssets.layout_(property: "assets"),
    ], property: property);
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

class XCMV3ExpectAsset extends XCMInstructionV3 with XCMExpectAsset {
  @override
  final XCMV3MultiAssets assets;
  XCMV3ExpectAsset({required this.assets});
  factory XCMV3ExpectAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ExpectAsset(
      assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMV3ExpectAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.expectAsset.type);
    return XCMV3ExpectAsset(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAssets.layout_(property: "assets"),
    ], property: property);
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

class XCMV3ExpectOrigin extends XCMInstructionV3 with XCMExpectOrigin {
  @override
  final XCMV3MultiLocation? location;
  XCMV3ExpectOrigin({required this.location});
  factory XCMV3ExpectOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ExpectOrigin(
      location: json.valueTo<XCMV3MultiLocation?, Map<String, dynamic>>(
          key: "location", parse: (v) => XCMV3MultiLocation.deserializeJson(v)),
    );
  }
  factory XCMV3ExpectOrigin.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? location = MetadataUtils.parseOptional(
        json.valueEnsureAsMap<String, dynamic>(
            XCMInstructionType.expectOrigin.type));

    return XCMV3ExpectOrigin(
        location:
            location == null ? null : XCMV3MultiLocation.fromJson(location));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV3MultiLocation.layout_(), property: "location"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location?.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: MetadataUtils.toOptionalJson(location?.toJson())};
  }
}

class XCMV3ExpectError extends XCMInstructionV3 with XCMExpectError {
  final int? index;
  final XCMV3Error? error;

  XCMV3ExpectError({int? index, this.error}) : index = index?.asUint32;

  factory XCMV3ExpectError.deserializeJson(Map<String, dynamic> json) {
    final error = json.valueAs<Map<String, dynamic>?>("error");
    if (error == null) return XCMV3ExpectError();
    return XCMV3ExpectError(
        index: error.valueAs<int>("index"),
        error: XCMV3Error.deserializeJson(error.valueAs("error")));
  }
  factory XCMV3ExpectError.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.expectError.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV3ExpectError();
    return XCMV3ExpectError(
        index: IntUtils.parse(opt[0]), error: XCMV3Error.fromJson(opt[1]));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(
          LayoutConst.struct([
            LayoutConst.u32(property: "index"),
            XCMV3Error.layout_(property: "error")
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
  Map<String, dynamic> toJson() {
    return {
      type.type: MetadataUtils.toOptionalJson(
          (index == null || error == null) ? null : [index, error?.toJson()])
    };
  }

  @override
  List get variabels => [type, index, error];
}

class XCMV3ExpectTransactStatus extends XCMInstructionV3
    with XCMExpectTransactStatus {
  @override
  final XCMV3MaybeErrorCode code;

  XCMV3ExpectTransactStatus({required this.code});

  factory XCMV3ExpectTransactStatus.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ExpectTransactStatus(
        code: XCMV3MaybeErrorCode.deserializeJson(json.valueAs("code")));
  }
  factory XCMV3ExpectTransactStatus.fromJson(Map<String, dynamic> json) {
    return XCMV3ExpectTransactStatus(
        code: XCMV3MaybeErrorCode.fromJson(
            json.valueAs(XCMInstructionType.expectTransactStatus.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3MaybeErrorCode.layout_(property: "code")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"code": code.serializeJsonVariant()};
  }

  @override
  List get variabels => [type, code];
}

class XCMV3QueryPallet extends XCMInstructionV3 with XCMQueryPallet {
  @override
  final List<int> moduleName;
  final XCMV3QueryResponseInfo responseInfo;

  XCMV3QueryPallet({
    required List<int> moduleName,
    required this.responseInfo,
  }) : moduleName = moduleName.asImmutableBytes;

  factory XCMV3QueryPallet.deserializeJson(Map<String, dynamic> json) {
    return XCMV3QueryPallet(
        moduleName: json.valueAsBytes("module_name"),
        responseInfo: XCMV3QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV3QueryPallet.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.queryPallet.type);
    return XCMV3QueryPallet(
        moduleName: data.valueAsBytes("module_name"),
        responseInfo:
            XCMV3QueryResponseInfo.fromJson(data.valueAs("response_info")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.bytes(property: "module_name"),
      XCMV3QueryResponseInfo.layout_(property: "response_info")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "module_name": moduleName,
      "response_info": responseInfo.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson({String? property}) {
    return {
      type.type: {
        "module_name": moduleName,
        "response_info": responseInfo.toJson()
      }
    };
  }

  @override
  List get variabels => [type, moduleName, responseInfo];
}

class XCMV3ExpectPallet extends XCMInstructionV3 with XCMExpectPallet {
  @override
  final int index;
  @override
  final List<int> name;
  @override
  final List<int> moduleName;
  @override
  final int crateMajor;
  @override
  final int minCrateMinor;

  XCMV3ExpectPallet({
    required int index,
    required List<int> name,
    required List<int> moduleName,
    required int crateMajor,
    required int minCrateMinor,
  })  : moduleName = moduleName.asImmutableBytes,
        index = index.asUint32,
        name = name.asImmutableBytes,
        crateMajor = crateMajor.asUint32,
        minCrateMinor = minCrateMinor.asUint32;
  factory XCMV3ExpectPallet.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.expectPallet.type);
    return XCMV3ExpectPallet(
        name: data.valueAsBytes("name"),
        moduleName: data.valueAsBytes("module_name"),
        index: data.valueAs("index"),
        crateMajor: data.valueAs("crate_major"),
        minCrateMinor: data.valueAs("min_crate_minor"));
  }
  factory XCMV3ExpectPallet.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ExpectPallet(
        name: json.valueAsBytes("name"),
        moduleName: json.valueAsBytes("module_name"),
        index: json.valueAs("index"),
        crateMajor: json.valueAs("crate_major"),
        minCrateMinor: json.valueAs("min_crate_minor"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "index"),
      LayoutConst.bytes(property: "name"),
      LayoutConst.bytes(property: "module_name"),
      LayoutConst.compactIntU32(property: "crate_major"),
      LayoutConst.compactIntU32(property: "min_crate_minor"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "index": index,
      "name": name,
      "module_name": moduleName,
      "crate_major": crateMajor,
      "min_crate_minor": minCrateMinor
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "index": index,
        "name": name,
        "module_name": moduleName,
        "crate_major": crateMajor,
        "min_crate_minor": minCrateMinor
      }
    };
  }

  @override
  List get variabels =>
      [type, index, name, moduleName, crateMajor, minCrateMinor];
}

class XCMV3ReportTransactStatus extends XCMInstructionV3
    with XCMReportTransactStatus {
  final XCMV3QueryResponseInfo responseInfo;

  XCMV3ReportTransactStatus({
    required this.responseInfo,
  });

  factory XCMV3ReportTransactStatus.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ReportTransactStatus(
        responseInfo: XCMV3QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV3ReportTransactStatus.fromJson(Map<String, dynamic> json) {
    return XCMV3ReportTransactStatus(
        responseInfo: XCMV3QueryResponseInfo.fromJson(
            json.valueAs(XCMInstructionType.reportTransactStatus.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV3QueryResponseInfo.layout_(property: "response_info")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"response_info": responseInfo.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson({String? property}) {
    return {type.type: responseInfo.toJson()};
  }

  @override
  List get variabels => [type, responseInfo];
}

class XCMV3ClearTransactStatus extends XCMInstructionV3
    with SubstrateVariantNoArgs, XCMClearTransactStatus {
  const XCMV3ClearTransactStatus();
  factory XCMV3ClearTransactStatus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearTransactStatus.type);
    return XCMV3ClearTransactStatus();
  }

  @override
  List get variabels => [type];
}

class XCMV3UniversalOrigin extends XCMInstructionV3 with XCMUniversalOrigin {
  @override
  final XCMV3Junction origin;

  XCMV3UniversalOrigin({required this.origin});

  factory XCMV3UniversalOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV3UniversalOrigin(
        origin: XCMV3Junction.deserializeJson(json.valueAs("origin")));
  }
  factory XCMV3UniversalOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV3UniversalOrigin(
        origin: XCMV3Junction.fromJson(
            json.valueAs(XCMInstructionType.universalOrigin.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3Junction.layout_(property: "origin")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"origin": origin.serializeJsonVariant()};
  }

  @override
  List get variabels => [type, origin];
}

class XCMV3ExportMessage extends XCMInstructionV3 with XCMExportMessage {
  @override
  final XCMV3NetworkId network;
  @override
  final XCMV3InteriorMultiLocation destination;
  @override
  final XCMV3 xcm;
  XCMV3ExportMessage(
      {required this.network, required this.destination, required this.xcm});
  factory XCMV3ExportMessage.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ExportMessage(
        network: XCMV3NetworkId.deserializeJson(json.valueAs("network")),
        destination:
            XCMV3Junctions.deserializeJson(json.valueAs("destination")),
        xcm: XCMV3.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV3ExportMessage.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exportMessage.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV3ExportMessage(
        network: XCMV3NetworkId.fromJson(data.valueAs("network")),
        destination: XCMV3Junctions.fromJson(data.valueAs("destination")),
        xcm: XCMV3(
            instructions:
                xcm.map((e) => XCMInstructionV3.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3NetworkId.layout_(property: "network"),
      XCMV3Junctions.layout_(property: "destination"),
      XCMV3.layout_(property: "xcm")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "network": network.serializeJsonVariant(),
      "destination": destination.serializeJsonVariant(),
      "xcm": xcm.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson({String? property}) {
    return {
      type.type: {
        "network": network.toJson(),
        "destination": destination.toJson(),
        "xcm": xcm.instructions.map((e) => e.toJson()).toList()
      }
    };
  }
}

class XCMV3LockAsset extends XCMInstructionV3 with XCMLockAsset {
  @override
  final XCMV3MultiAsset asset;
  @override
  final XCMV3MultiLocation unlocker;
  XCMV3LockAsset({required this.asset, required this.unlocker});
  factory XCMV3LockAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3LockAsset(
      asset: XCMV3MultiAsset.deserializeJson(json.valueAs("asset")),
      unlocker: XCMV3MultiLocation.deserializeJson(json.valueAs("unlocker")),
    );
  }
  factory XCMV3LockAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.lockAsset.type);
    return XCMV3LockAsset(
        asset: XCMV3MultiAsset.fromJson(data.valueAs("asset")),
        unlocker: XCMV3MultiLocation.fromJson(data.valueAs("unlocker")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAsset.layout_(property: "asset"),
      XCMV3MultiLocation.layout_(property: "unlocker")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "asset": asset.serializeJson(),
      "unlocker": unlocker.serializeJson()
    };
  }
}

class XCMV3UnlockAsset extends XCMInstructionV3 with XCMUnlockAsset {
  @override
  final XCMV3MultiAsset asset;
  @override
  final XCMV3MultiLocation target;
  XCMV3UnlockAsset({required this.asset, required this.target});
  factory XCMV3UnlockAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3UnlockAsset(
      asset: XCMV3MultiAsset.deserializeJson(json.valueAs("asset")),
      target: XCMV3MultiLocation.deserializeJson(json.valueAs("target")),
    );
  }
  factory XCMV3UnlockAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.unlockAsset.type);
    return XCMV3UnlockAsset(
        asset: XCMV3MultiAsset.fromJson(data.valueAs("asset")),
        target: XCMV3MultiLocation.fromJson(data.valueAs("target")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAsset.layout_(property: "asset"),
      XCMV3MultiLocation.layout_(property: "target")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson(), "target": target.serializeJson()};
  }
}

class XCMV3NoteUnlockable extends XCMInstructionV3 with XCMNoteUnlockable {
  @override
  final XCMV3MultiAsset asset;
  @override
  final XCMV3MultiLocation owner;
  XCMV3NoteUnlockable({required this.asset, required this.owner});
  factory XCMV3NoteUnlockable.deserializeJson(Map<String, dynamic> json) {
    return XCMV3NoteUnlockable(
      asset: XCMV3MultiAsset.deserializeJson(json.valueAs("asset")),
      owner: XCMV3MultiLocation.deserializeJson(json.valueAs("owner")),
    );
  }
  factory XCMV3NoteUnlockable.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.noteUnlockable.type);
    return XCMV3NoteUnlockable(
        asset: XCMV3MultiAsset.fromJson(data.valueAs("asset")),
        owner: XCMV3MultiLocation.fromJson(data.valueAs("owner")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAsset.layout_(property: "asset"),
      XCMV3MultiLocation.layout_(property: "owner")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson(), "owner": owner.serializeJson()};
  }
}

class XCMV3RequestUnlock extends XCMInstructionV3 with XCMRequestUnlock {
  @override
  final XCMV3MultiAsset asset;
  @override
  final XCMV3MultiLocation locker;
  XCMV3RequestUnlock({required this.asset, required this.locker});
  factory XCMV3RequestUnlock.deserializeJson(Map<String, dynamic> json) {
    return XCMV3RequestUnlock(
      asset: XCMV3MultiAsset.deserializeJson(json.valueAs("asset")),
      locker: XCMV3MultiLocation.deserializeJson(json.valueAs("locker")),
    );
  }
  factory XCMV3RequestUnlock.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.requestUnlock.type);
    return XCMV3RequestUnlock(
        asset: XCMV3MultiAsset.fromJson(data.valueAs("asset")),
        locker: XCMV3MultiLocation.fromJson(data.valueAs("locker")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiAsset.layout_(property: "asset"),
      XCMV3MultiLocation.layout_(property: "locker")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJson(), "locker": locker.serializeJson()};
  }
}

class XCMV3SetFeesMode extends XCMInstructionV3 with XCMSetFeesMode {
  @override
  final bool jitWithdraw;
  XCMV3SetFeesMode({required this.jitWithdraw});
  factory XCMV3SetFeesMode.deserializeJson(Map<String, dynamic> json) {
    return XCMV3SetFeesMode(jitWithdraw: json.valueAs("jit_withdraw"));
  }
  factory XCMV3SetFeesMode.fromJson(Map<String, dynamic> json) {
    return XCMV3SetFeesMode(
        jitWithdraw: json.valueAs(XCMInstructionType.setFeesMode.type));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.boolean(property: "jit_withdraw")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"jit_withdraw": jitWithdraw};
  }
}

class XCMV3SetTopic extends XCMInstructionV3 with XCMSetTopic {
  @override
  final List<int> topic;
  XCMV3SetTopic({required List<int> topic})
      : topic = topic
            .exc(SubstrateAddressUtils.addressBytesLength)
            .asImmutableBytes;
  factory XCMV3SetTopic.deserializeJson(Map<String, dynamic> json) {
    return XCMV3SetTopic(topic: json.valueAsBytes("topic"));
  }
  factory XCMV3SetTopic.fromJson(Map<String, dynamic> json) {
    return XCMV3SetTopic(
        topic: json.valueAsBytes(XCMInstructionType.setTopic.type));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.fixedBlobN(SubstrateAddressUtils.addressBytesLength,
          property: "topic")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"topic": topic};
  }
}

class XCMV3ClearTopic extends XCMInstructionV3
    with SubstrateVariantNoArgs, XCMClearTopic {
  const XCMV3ClearTopic();
  factory XCMV3ClearTopic.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearTopic.type);
    return XCMV3ClearTopic();
  }
}

class XCMV3AliasOrigin extends XCMInstructionV3 with XCMAliasOrigin {
  @override
  final XCMV3MultiLocation origin;
  XCMV3AliasOrigin({required this.origin});
  factory XCMV3AliasOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AliasOrigin(
        origin: XCMV3MultiLocation.deserializeJson(json.valueAs("origin")));
  }
  factory XCMV3AliasOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV3AliasOrigin(
        origin: XCMV3MultiLocation.fromJson(
            json.valueAs(XCMInstructionType.aliasOrigin.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiLocation.layout_(property: "origin"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"origin": origin.serializeJson()};
  }
}

class XCMV3UnpaidExecution extends XCMInstructionV3 with XCMUnpaidExecution {
  @override
  final XCMV3WeightLimit weightLimit;
  @override
  final XCMV3MultiLocation? checkOrigin;
  XCMV3UnpaidExecution({required this.weightLimit, this.checkOrigin});
  factory XCMV3UnpaidExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV3UnpaidExecution(
        weightLimit:
            XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit")),
        checkOrigin: json.valueTo<XCMV3MultiLocation?, Map<String, dynamic>>(
            key: "check_origin",
            parse: (v) => XCMV3MultiLocation.deserializeJson(v)));
  }
  factory XCMV3UnpaidExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap(XCMInstructionType.unpaidExecution.type);
    final Map<String, dynamic>? checkOrigin =
        MetadataUtils.parseOptional(data.valueAs("check_origin"));
    return XCMV3UnpaidExecution(
        weightLimit: XCMV3WeightLimit.fromJson(data.valueAs("weight_limit")),
        checkOrigin: checkOrigin == null
            ? null
            : XCMV3MultiLocation.fromJson(checkOrigin));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3WeightLimit.layout_(property: "weight_limit"),
      LayoutConst.optional(XCMV3MultiLocation.layout_(),
          property: "check_origin"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "check_origin": checkOrigin?.serializeJson(),
      "weight_limit": weightLimit.serializeJsonVariant()
    };
  }
}

enum XCMV3ErrorType {
  overFlow("Overflow", 0),
  unimplemented("Unimplemented", 1),
  untrustedReserveLocation("UntrustedReserveLocation", 2),
  untrustedTeleportLocation("UntrustedTeleportLocation", 3),
  locationFull("LocationFull", 4),
  locationNotInvertible("LocationNotInvertible", 5),
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
  expectationFale("ExpectationFalse", 22),
  palletNotFound("PalletNotFound", 23),
  nameMismatch("NameMismatch", 24),
  versionIncompatible("VersionIncompatible", 25),
  holdingWouldOverflow("HoldingWouldOverflow", 26),
  exportError("ExportError", 27),
  reanchorFailed("ReanchorFailed", 28),
  noDeal("NoDeal", 29),
  feesNotMet("FeesNotMet", 30),
  lockError("LockError", 31),
  noPermission("NoPermission", 32),
  unanchored("Unanchored", 33),
  notDepositable("NotDepositable", 34),
  unhandledXcmVersion("UnhandledXcmVersion", 35),
  weightLimitReached("WeightLimitReached", 36),
  barrier("Barrier", 37),
  weightNotComputable("WeightNotComputable", 38),
  exceedsStackLimit("ExceedsStackLimit", 39);

  const XCMV3ErrorType(this.type, this.variantIndex);
  final String type;
  final int variantIndex;

  static XCMV3ErrorType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV3ErrorType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV3Error extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV3ErrorType get type;
  const XCMV3Error();
  factory XCMV3Error.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV3ErrorType.fromName(decode.variantName);
    return switch (type) {
      XCMV3ErrorType.overFlow => XCMV3ErrorOverflow(),
      XCMV3ErrorType.unimplemented => XCMV3ErrorUnimplemented(),
      XCMV3ErrorType.untrustedReserveLocation =>
        XCMV3ErrorUntrustedReserveLocation(),
      XCMV3ErrorType.untrustedTeleportLocation =>
        XCMV3ErrorUntrustedTeleportLocation(),
      XCMV3ErrorType.locationFull => XCMV3ErrorLocationFull(),
      XCMV3ErrorType.locationNotInvertible => XCMV3ErrorLocationNotInvertible(),
      XCMV3ErrorType.badOrigin => XCMV3ErrorBadOrigin(),
      XCMV3ErrorType.invalidLocation => XCMV3ErrorInvalidLocation(),
      XCMV3ErrorType.assetNotFound => XCMV3ErrorAssetNotFound(),
      XCMV3ErrorType.failedToTransactAsset => XCMV3ErrorFailedToTransactAsset(),
      XCMV3ErrorType.notWithdrawable => XCMV3ErrorNotWithdrawable(),
      XCMV3ErrorType.locationCannotHold => XCMV3ErrorLocationCannotHold(),
      XCMV3ErrorType.exceedsMaxMessageSize => XCMV3ErrorExceedsMaxMessageSize(),
      XCMV3ErrorType.destinationUnsupported =>
        XCMV3ErrorDestinationUnsupported(),
      XCMV3ErrorType.transport => XCMV3ErrorTransport(),
      XCMV3ErrorType.unroutable => XCMV3ErrorUnroutable(),
      XCMV3ErrorType.unknownClaim => XCMV3ErrorUnknownClaim(),
      XCMV3ErrorType.failedToDecode => XCMV3ErrorFailedToDecode(),
      XCMV3ErrorType.maxWeightInvalid => XCMV3ErrorMaxWeightInvalid(),
      XCMV3ErrorType.notHodingFees => XCMV3ErrorNotHoldingFees(),
      XCMV3ErrorType.tooExpensive => XCMV3ErrorTooExpensive(),
      XCMV3ErrorType.trap => XCMV3ErrorTrap.deserializeJson(decode.value),
      XCMV3ErrorType.expectationFale => XCMV3ErrorExpectationFalse(),
      XCMV3ErrorType.palletNotFound => XCMV3ErrorPalletNotFound(),
      XCMV3ErrorType.nameMismatch => XCMV3ErrorNameMismatch(),
      XCMV3ErrorType.versionIncompatible => XCMV3ErrorVersionIncompatible(),
      XCMV3ErrorType.holdingWouldOverflow => XCMV3ErrorHoldingWouldOverflow(),
      XCMV3ErrorType.exportError => XCMV3ErrorExportError(),
      XCMV3ErrorType.reanchorFailed => XCMV3ErrorReanchorFailed(),
      XCMV3ErrorType.noDeal => XCMV3ErrorNoDeal(),
      XCMV3ErrorType.feesNotMet => XCMV3ErrorFeesNotMet(),
      XCMV3ErrorType.lockError => XCMV3ErrorLockError(),
      XCMV3ErrorType.noPermission => XCMV3ErrorNoPermission(),
      XCMV3ErrorType.unanchored => XCMV3ErrorUnanchored(),
      XCMV3ErrorType.notDepositable => XCMV3ErrorNotDepositable(),
      XCMV3ErrorType.unhandledXcmVersion => XCMV3ErrorUnhandledXcmVersion(),
      XCMV3ErrorType.weightLimitReached =>
        XCMV3ErrorWeightLimitReached.deserializeJson(decode.value),
      XCMV3ErrorType.barrier => XCMV3ErrorBarrier(),
      XCMV3ErrorType.weightNotComputable => XCMV3ErrorWeightNotComputable(),
      XCMV3ErrorType.exceedsStackLimit => XCMV3ErrorExceedsStackLimit(),
    };
  }
  factory XCMV3Error.fromJson(Map<String, dynamic> json) {
    final type = XCMV3ErrorType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV3ErrorType.overFlow => XCMV3ErrorOverflow.fromJson(json),
      XCMV3ErrorType.unimplemented => XCMV3ErrorUnimplemented.fromJson(json),
      XCMV3ErrorType.untrustedReserveLocation =>
        XCMV3ErrorUntrustedReserveLocation.fromJson(json),
      XCMV3ErrorType.untrustedTeleportLocation =>
        XCMV3ErrorUntrustedTeleportLocation.fromJson(json),
      XCMV3ErrorType.locationFull => XCMV3ErrorLocationFull.fromJson(json),
      XCMV3ErrorType.locationNotInvertible =>
        XCMV3ErrorLocationNotInvertible.fromJson(json),
      XCMV3ErrorType.badOrigin => XCMV3ErrorBadOrigin.fromJson(json),
      XCMV3ErrorType.invalidLocation =>
        XCMV3ErrorInvalidLocation.fromJson(json),
      XCMV3ErrorType.assetNotFound => XCMV3ErrorAssetNotFound.fromJson(json),
      XCMV3ErrorType.failedToTransactAsset =>
        XCMV3ErrorFailedToTransactAsset.fromJson(json),
      XCMV3ErrorType.notWithdrawable =>
        XCMV3ErrorNotWithdrawable.fromJson(json),
      XCMV3ErrorType.locationCannotHold =>
        XCMV3ErrorLocationCannotHold.fromJson(json),
      XCMV3ErrorType.exceedsMaxMessageSize =>
        XCMV3ErrorExceedsMaxMessageSize.fromJson(json),
      XCMV3ErrorType.destinationUnsupported =>
        XCMV3ErrorDestinationUnsupported.fromJson(json),
      XCMV3ErrorType.transport => XCMV3ErrorTransport.fromJson(json),
      XCMV3ErrorType.unroutable => XCMV3ErrorUnroutable.fromJson(json),
      XCMV3ErrorType.unknownClaim => XCMV3ErrorUnknownClaim.fromJson(json),
      XCMV3ErrorType.failedToDecode => XCMV3ErrorFailedToDecode.fromJson(json),
      XCMV3ErrorType.maxWeightInvalid =>
        XCMV3ErrorMaxWeightInvalid.fromJson(json),
      XCMV3ErrorType.notHodingFees => XCMV3ErrorNotHoldingFees.fromJson(json),
      XCMV3ErrorType.tooExpensive => XCMV3ErrorTooExpensive.fromJson(json),
      XCMV3ErrorType.trap => XCMV3ErrorTrap.fromJson(json),
      XCMV3ErrorType.expectationFale =>
        XCMV3ErrorExpectationFalse.fromJson(json),
      XCMV3ErrorType.palletNotFound => XCMV3ErrorPalletNotFound.fromJson(json),
      XCMV3ErrorType.nameMismatch => XCMV3ErrorNameMismatch.fromJson(json),
      XCMV3ErrorType.versionIncompatible =>
        XCMV3ErrorVersionIncompatible.fromJson(json),
      XCMV3ErrorType.holdingWouldOverflow =>
        XCMV3ErrorHoldingWouldOverflow.fromJson(json),
      XCMV3ErrorType.exportError => XCMV3ErrorExportError.fromJson(json),
      XCMV3ErrorType.reanchorFailed => XCMV3ErrorReanchorFailed.fromJson(json),
      XCMV3ErrorType.noDeal => XCMV3ErrorNoDeal.fromJson(json),
      XCMV3ErrorType.feesNotMet => XCMV3ErrorFeesNotMet.fromJson(json),
      XCMV3ErrorType.lockError => XCMV3ErrorLockError.fromJson(json),
      XCMV3ErrorType.noPermission => XCMV3ErrorNoPermission.fromJson(json),
      XCMV3ErrorType.unanchored => XCMV3ErrorUnanchored.fromJson(json),
      XCMV3ErrorType.notDepositable => XCMV3ErrorNotDepositable.fromJson(json),
      XCMV3ErrorType.unhandledXcmVersion =>
        XCMV3ErrorUnhandledXcmVersion.fromJson(json),
      XCMV3ErrorType.weightLimitReached =>
        XCMV3ErrorWeightLimitReached.fromJson(json),
      XCMV3ErrorType.barrier => XCMV3ErrorBarrier.fromJson(json),
      XCMV3ErrorType.weightNotComputable =>
        XCMV3ErrorWeightNotComputable.fromJson(json),
      XCMV3ErrorType.exceedsStackLimit =>
        XCMV3ErrorExceedsStackLimit.fromJson(json),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum(
        XCMV3ErrorType.values.map((e) {
          return LazyVariantModel(
              layout: ({property}) {
                switch (e) {
                  case XCMV3ErrorType.trap:
                    return XCMV3ErrorTrap.layout_(property: property);
                  case XCMV3ErrorType.weightLimitReached:
                    return XCMV3ErrorWeightLimitReached.layout_(
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
  Map<String, dynamic> toJson();

  @override
  List get variabels => [type];
  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3ErrorOverflow extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.overFlow;

  const XCMV3ErrorOverflow();
  factory XCMV3ErrorOverflow.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.overFlow.type);
    return XCMV3ErrorOverflow();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUnimplemented extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.unimplemented;
  const XCMV3ErrorUnimplemented();
  factory XCMV3ErrorUnimplemented.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.unimplemented.type);
    return XCMV3ErrorUnimplemented();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUntrustedReserveLocation extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.untrustedReserveLocation;

  const XCMV3ErrorUntrustedReserveLocation();
  factory XCMV3ErrorUntrustedReserveLocation.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.untrustedReserveLocation.type);
    return XCMV3ErrorUntrustedReserveLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUntrustedTeleportLocation extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.untrustedTeleportLocation;

  const XCMV3ErrorUntrustedTeleportLocation();
  factory XCMV3ErrorUntrustedTeleportLocation.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.untrustedTeleportLocation.type);
    return XCMV3ErrorUntrustedTeleportLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorLocationFull extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.locationFull;
  const XCMV3ErrorLocationFull();
  factory XCMV3ErrorLocationFull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.locationFull.type);
    return XCMV3ErrorLocationFull();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorLocationNotInvertible extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.locationNotInvertible;
  const XCMV3ErrorLocationNotInvertible();
  factory XCMV3ErrorLocationNotInvertible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.locationNotInvertible.type);
    return XCMV3ErrorLocationNotInvertible();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorBadOrigin extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.badOrigin;
  const XCMV3ErrorBadOrigin();
  factory XCMV3ErrorBadOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.badOrigin.type);
    return XCMV3ErrorBadOrigin();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorInvalidLocation extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.invalidLocation;
  const XCMV3ErrorInvalidLocation();
  factory XCMV3ErrorInvalidLocation.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.invalidLocation.type);
    return XCMV3ErrorInvalidLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorAssetNotFound extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.assetNotFound;
  const XCMV3ErrorAssetNotFound();
  factory XCMV3ErrorAssetNotFound.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.assetNotFound.type);
    return XCMV3ErrorAssetNotFound();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorFailedToTransactAsset extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.failedToTransactAsset;
  const XCMV3ErrorFailedToTransactAsset();
  factory XCMV3ErrorFailedToTransactAsset.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.failedToTransactAsset.type);
    return XCMV3ErrorFailedToTransactAsset();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorNotWithdrawable extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.notWithdrawable;
  const XCMV3ErrorNotWithdrawable();
  factory XCMV3ErrorNotWithdrawable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.notWithdrawable.type);
    return XCMV3ErrorNotWithdrawable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorLocationCannotHold extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.locationCannotHold;
  const XCMV3ErrorLocationCannotHold();
  factory XCMV3ErrorLocationCannotHold.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.locationCannotHold.type);
    return XCMV3ErrorLocationCannotHold();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorExceedsMaxMessageSize extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.exceedsMaxMessageSize;
  const XCMV3ErrorExceedsMaxMessageSize();
  factory XCMV3ErrorExceedsMaxMessageSize.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.exceedsMaxMessageSize.type);
    return XCMV3ErrorExceedsMaxMessageSize();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorDestinationUnsupported extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.destinationUnsupported;
  const XCMV3ErrorDestinationUnsupported();
  factory XCMV3ErrorDestinationUnsupported.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.destinationUnsupported.type);
    return XCMV3ErrorDestinationUnsupported();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorTransport extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.transport;
  const XCMV3ErrorTransport();
  factory XCMV3ErrorTransport.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.transport.type);
    return XCMV3ErrorTransport();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUnroutable extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.unroutable;
  const XCMV3ErrorUnroutable();
  factory XCMV3ErrorUnroutable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.unroutable.type);
    return XCMV3ErrorUnroutable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUnknownClaim extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.unknownClaim;
  const XCMV3ErrorUnknownClaim();
  factory XCMV3ErrorUnknownClaim.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.unknownClaim.type);
    return XCMV3ErrorUnknownClaim();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorFailedToDecode extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.failedToDecode;
  const XCMV3ErrorFailedToDecode();
  factory XCMV3ErrorFailedToDecode.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.failedToDecode.type);
    return XCMV3ErrorFailedToDecode();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorMaxWeightInvalid extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.maxWeightInvalid;
  const XCMV3ErrorMaxWeightInvalid();
  factory XCMV3ErrorMaxWeightInvalid.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.maxWeightInvalid.type);
    return XCMV3ErrorMaxWeightInvalid();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorNotHoldingFees extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.notHodingFees;

  const XCMV3ErrorNotHoldingFees();
  factory XCMV3ErrorNotHoldingFees.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.notHodingFees.type);
    return XCMV3ErrorNotHoldingFees();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorTooExpensive extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.tooExpensive;

  const XCMV3ErrorTooExpensive();
  factory XCMV3ErrorTooExpensive.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.tooExpensive.type);
    return XCMV3ErrorTooExpensive();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorTrap extends XCMV3Error {
  final BigInt code;
  XCMV3ErrorTrap({required BigInt code}) : code = code.asUint64;
  factory XCMV3ErrorTrap.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ErrorTrap(code: BigintUtils.parse(json["code"]));
  }

  factory XCMV3ErrorTrap.fromJson(Map<String, dynamic> json) {
    return XCMV3ErrorTrap(code: json.valueAs(XCMV3ErrorType.trap.type));
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: code};
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
  XCMV3ErrorType get type => XCMV3ErrorType.trap;
  @override
  List get variabels => [type, code];
}

class XCMV3ErrorExpectationFalse extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.expectationFale;
  const XCMV3ErrorExpectationFalse();
  factory XCMV3ErrorExpectationFalse.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.expectationFale.type);
    return XCMV3ErrorExpectationFalse();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorPalletNotFound extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.palletNotFound;
  const XCMV3ErrorPalletNotFound();
  factory XCMV3ErrorPalletNotFound.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.palletNotFound.type);
    return XCMV3ErrorPalletNotFound();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorNameMismatch extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.nameMismatch;
  const XCMV3ErrorNameMismatch();
  factory XCMV3ErrorNameMismatch.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.nameMismatch.type);
    return XCMV3ErrorNameMismatch();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorVersionIncompatible extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.versionIncompatible;
  const XCMV3ErrorVersionIncompatible();
  factory XCMV3ErrorVersionIncompatible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.versionIncompatible.type);
    return XCMV3ErrorVersionIncompatible();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorHoldingWouldOverflow extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.holdingWouldOverflow;
  const XCMV3ErrorHoldingWouldOverflow();
  factory XCMV3ErrorHoldingWouldOverflow.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.holdingWouldOverflow.type);
    return XCMV3ErrorHoldingWouldOverflow();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorExportError extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.exportError;
  const XCMV3ErrorExportError();
  factory XCMV3ErrorExportError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.exportError.type);
    return XCMV3ErrorExportError();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorReanchorFailed extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.reanchorFailed;
  const XCMV3ErrorReanchorFailed();
  factory XCMV3ErrorReanchorFailed.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.reanchorFailed.type);
    return XCMV3ErrorReanchorFailed();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorNoDeal extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.noDeal;
  const XCMV3ErrorNoDeal();
  factory XCMV3ErrorNoDeal.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.noDeal.type);
    return XCMV3ErrorNoDeal();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorFeesNotMet extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.feesNotMet;
  const XCMV3ErrorFeesNotMet();
  factory XCMV3ErrorFeesNotMet.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.feesNotMet.type);
    return XCMV3ErrorFeesNotMet();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorLockError extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.lockError;
  const XCMV3ErrorLockError();
  factory XCMV3ErrorLockError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.lockError.type);
    return XCMV3ErrorLockError();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorNoPermission extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.noPermission;
  const XCMV3ErrorNoPermission();
  factory XCMV3ErrorNoPermission.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.noPermission.type);
    return XCMV3ErrorNoPermission();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUnanchored extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.unanchored;
  const XCMV3ErrorUnanchored();
  factory XCMV3ErrorUnanchored.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.unanchored.type);
    return XCMV3ErrorUnanchored();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorNotDepositable extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.notDepositable;
  const XCMV3ErrorNotDepositable();
  factory XCMV3ErrorNotDepositable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.notDepositable.type);
    return XCMV3ErrorNotDepositable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorUnhandledXcmVersion extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.unhandledXcmVersion;
  const XCMV3ErrorUnhandledXcmVersion();
  factory XCMV3ErrorUnhandledXcmVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.unhandledXcmVersion.type);
    return XCMV3ErrorUnhandledXcmVersion();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorWeightLimitReached extends XCMV3Error
    with SubstrateVariantNoArgs {
  final SubstrateWeightV2 weight;
  XCMV3ErrorWeightLimitReached({required this.weight});
  factory XCMV3ErrorWeightLimitReached.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3ErrorWeightLimitReached(
        weight: SubstrateWeightV2.deserializeJson(json["weight"]));
  }
  factory XCMV3ErrorWeightLimitReached.fromJson(Map<String, dynamic> json) {
    return XCMV3ErrorWeightLimitReached(
        weight: SubstrateWeightV2.fromJson(
            json.valueAs(XCMV3ErrorType.weightLimitReached.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([SubstrateWeightV2.layout_(property: "weight")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  XCMV3ErrorType get type => XCMV3ErrorType.weightLimitReached;
  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"weight": weight.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: weight.toJson()};
  }

  @override
  List get variabels => [type, weight];
}

class XCMV3ErrorBarrier extends XCMV3Error with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.barrier;
  const XCMV3ErrorBarrier();
  factory XCMV3ErrorBarrier.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.barrier.type);
    return XCMV3ErrorBarrier();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorWeightNotComputable extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.weightNotComputable;
  const XCMV3ErrorWeightNotComputable();
  factory XCMV3ErrorWeightNotComputable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.weightNotComputable.type);
    return XCMV3ErrorWeightNotComputable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3ErrorExceedsStackLimit extends XCMV3Error
    with SubstrateVariantNoArgs {
  @override
  XCMV3ErrorType get type => XCMV3ErrorType.exceedsStackLimit;
  const XCMV3ErrorExceedsStackLimit();
  factory XCMV3ErrorExceedsStackLimit.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ErrorType.exceedsStackLimit.type);
    return XCMV3ErrorExceedsStackLimit();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

enum XCMV3ResponseType {
  nullResponse("Null"),
  assets("Assets"),
  executionResult("ExecutionResult"),
  version("Version"),
  palletsInfo("PalletsInfo"),
  dispatchResult("DispatchResult");

  const XCMV3ResponseType(this.type);
  final String type;

  static XCMV3ResponseType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV3ResponseType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV3Response extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV3ResponseType get type;
  const XCMV3Response();
  Map<String, dynamic> toJson();
  factory XCMV3Response.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV3ResponseType.fromName(decode.variantName);
    return switch (type) {
      XCMV3ResponseType.nullResponse => XCMV3ResponseNull(),
      XCMV3ResponseType.assets =>
        XCMV3ResponseAssets.deserializeJson(decode.value),
      XCMV3ResponseType.executionResult =>
        XCMV3ResponseExecutionResult.deserializeJson(decode.value),
      XCMV3ResponseType.version =>
        XCMV3ResponseVersion.deserializeJson(decode.value),
      XCMV3ResponseType.palletsInfo =>
        XCMV3ResponsePalletsInfo.deserializeJson(decode.value),
      XCMV3ResponseType.dispatchResult =>
        XCMV3ResponseDispatchResult.deserializeJson(decode.value),
    };
  }
  factory XCMV3Response.fromJson(Map<String, dynamic> json) {
    final type = XCMV3ResponseType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV3ResponseType.nullResponse => XCMV3ResponseNull.fromJson(json),
      XCMV3ResponseType.assets => XCMV3ResponseAssets.fromJson(json),
      XCMV3ResponseType.executionResult =>
        XCMV3ResponseExecutionResult.fromJson(json),
      XCMV3ResponseType.version => XCMV3ResponseVersion.fromJson(json),
      XCMV3ResponseType.palletsInfo => XCMV3ResponsePalletsInfo.fromJson(json),
      XCMV3ResponseType.dispatchResult =>
        XCMV3ResponseDispatchResult.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMV3ResponseType.nullResponse.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV3ResponseAssets.layout_(property: property),
        property: XCMV3ResponseType.assets.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ResponseExecutionResult.layout_(property: property),
        property: XCMV3ResponseType.executionResult.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ResponseVersion.layout_(property: property),
        property: XCMV3ResponseType.version.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ResponsePalletsInfo.layout_(property: property),
        property: XCMV3ResponseType.palletsInfo.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3ResponseDispatchResult.layout_(property: property),
        property: XCMV3ResponseType.dispatchResult.name,
        index: 5,
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
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3ResponseNull extends XCMV3Response with SubstrateVariantNoArgs {
  XCMV3ResponseNull();
  factory XCMV3ResponseNull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ResponseType.nullResponse.type);
    return XCMV3ResponseNull();
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV3ResponseType get type => XCMV3ResponseType.nullResponse;
  @override
  List get variabels => [type];
}

class XCMV3ResponseAssets extends XCMV3Response {
  final XCMV3MultiAssets assets;
  XCMV3ResponseAssets({required this.assets});

  factory XCMV3ResponseAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ResponseAssets(
        assets: XCMV3MultiAssets.deserializeJson(json["assets"]));
  }

  factory XCMV3ResponseAssets.fromJson(Map<String, dynamic> json) {
    final assets = json
        .valueEnsureAsList<Map<String, dynamic>>(XCMV3ResponseType.assets.type);
    return XCMV3ResponseAssets(
        assets: XCMV3MultiAssets(
            assets: assets.map((e) => XCMV3MultiAsset.fromJson(e)).toList()));
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

  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  XCMV3ResponseType get type => XCMV3ResponseType.assets;
  @override
  List get variabels => [type, assets];
}

class XCMV3ResponseExecutionResult extends XCMV3Response {
  final int? index;
  final XCMV3Error? error;
  XCMV3ResponseExecutionResult({int? index, this.error})
      : index = index?.asUint32,
        assert((index == null && error == null) ||
            (index != null && error != null));

  factory XCMV3ResponseExecutionResult.deserializeJson(
      Map<String, dynamic> json) {
    final error = json["error"];
    if (error == null) return XCMV3ResponseExecutionResult();

    return XCMV3ResponseExecutionResult(
        index: IntUtils.parse(error["index"]),
        error: XCMV3Error.deserializeJson(error["error"]));
  }

  factory XCMV3ResponseExecutionResult.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMV3ResponseType.executionResult.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV3ResponseExecutionResult();
    return XCMV3ResponseExecutionResult(
        index: IntUtils.parse(opt[0]), error: XCMV3Error.fromJson(opt[1]));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(
          LayoutConst.struct([
            LayoutConst.u32(property: "index"),
            XCMV3Error.layout_(property: "error")
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
  XCMV3ResponseType get type => XCMV3ResponseType.executionResult;
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

class XCMV3ResponseVersion extends XCMV3Response {
  final int versionNumber;
  XCMV3ResponseVersion({required int version})
      : versionNumber = version.asUint32;

  factory XCMV3ResponseVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ResponseVersion(version: IntUtils.parse(json["version"]));
  }
  factory XCMV3ResponseVersion.fromJson(Map<String, dynamic> json) {
    return XCMV3ResponseVersion(
        version: json.valueAs(XCMV3ResponseType.version.type));
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
  XCMV3ResponseType get type => XCMV3ResponseType.version;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: versionNumber};
  }

  @override
  List get variabels => [type, versionNumber];
}

class XCMV3ResponsePalletsInfo extends XCMV3Response {
  final List<XCMPalletInfo> pallets;
  XCMV3ResponsePalletsInfo({required List<XCMPalletInfo> pallets})
      : pallets = pallets.max(_XCMV3Constants.maxPalletInfo).immutable;

  factory XCMV3ResponsePalletsInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ResponsePalletsInfo(
        pallets: (json.valueEnsureAsList<Map<String, dynamic>>("pallets"))
            .map((e) => XCMPalletInfo.deserializeJson(e))
            .toList());
  }
  factory XCMV3ResponsePalletsInfo.fromJson(Map<String, dynamic> json) {
    final pallets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMV3ResponseType.palletsInfo.type);
    return XCMV3ResponsePalletsInfo(
        pallets: pallets.map((e) => XCMPalletInfo.fromJson(e)).toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMPalletInfo.layout_(), property: "pallets")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"pallets": pallets.map((e) => e.serializeJson()).toList()};
  }

  @override
  XCMV3ResponseType get type => XCMV3ResponseType.palletsInfo;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: pallets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, pallets];
}

enum XCMV3MaybeErrorCodeType {
  success("Success"),
  error("Error"),
  truncatedError("TruncatedError");

  const XCMV3MaybeErrorCodeType(this.type);
  final String type;

  static XCMV3MaybeErrorCodeType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV3MaybeErrorCodeType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV3MaybeErrorCode extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV3MaybeErrorCodeType get type;
  const XCMV3MaybeErrorCode();

  Map<String, dynamic> toJson();

  factory XCMV3MaybeErrorCode.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV3MaybeErrorCodeType.fromName(decode.variantName);
    return switch (type) {
      XCMV3MaybeErrorCodeType.success => XCMV3MaybeErrorCodeSuccess(),
      XCMV3MaybeErrorCodeType.error =>
        XCMV3MaybeErrorCodeError.deserializeJson(decode.value),
      XCMV3MaybeErrorCodeType.truncatedError =>
        XCMV3MaybeErrorCodeTruncatedError.deserializeJson(decode.value),
    };
  }

  factory XCMV3MaybeErrorCode.fromJson(Map<String, dynamic> json) {
    final type = XCMV3MaybeErrorCodeType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV3MaybeErrorCodeType.success =>
        XCMV3MaybeErrorCodeSuccess.fromJson(json),
      XCMV3MaybeErrorCodeType.error => XCMV3MaybeErrorCodeError.fromJson(json),
      XCMV3MaybeErrorCodeType.truncatedError =>
        XCMV3MaybeErrorCodeTruncatedError.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMV3MaybeErrorCodeType.success.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3MaybeErrorCodeError.layout_(property: property),
        property: XCMV3MaybeErrorCodeType.error.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3MaybeErrorCodeTruncatedError.layout_(property: property),
        property: XCMV3MaybeErrorCodeType.truncatedError.name,
        index: 2,
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
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3MaybeErrorCodeSuccess extends XCMV3MaybeErrorCode
    with SubstrateVariantNoArgs {
  const XCMV3MaybeErrorCodeSuccess();
  factory XCMV3MaybeErrorCodeSuccess.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3MaybeErrorCodeType.success.type);
    return XCMV3MaybeErrorCodeSuccess();
  }
  @override
  XCMV3MaybeErrorCodeType get type => XCMV3MaybeErrorCodeType.success;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

class XCMV3MaybeErrorCodeError extends XCMV3MaybeErrorCode {
  final List<int> error;
  XCMV3MaybeErrorCodeError({required List<int> error})
      : error = error.max(_XCMV3Constants.maxDispatchErrorLen).asImmutableBytes;
  factory XCMV3MaybeErrorCodeError.deserializeJson(Map<String, dynamic> json) {
    return XCMV3MaybeErrorCodeError(error: json.valueAsBytes("error"));
  }
  factory XCMV3MaybeErrorCodeError.fromJson(Map<String, dynamic> json) {
    return XCMV3MaybeErrorCodeError(
        error: json.valueAsBytes(XCMV3MaybeErrorCodeType.error.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.bytes(property: "error"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"error": error};
  }

  @override
  XCMV3MaybeErrorCodeType get type => XCMV3MaybeErrorCodeType.error;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: error};
  }

  @override
  List get variabels => [type, error];
}

class XCMV3MaybeErrorCodeTruncatedError extends XCMV3MaybeErrorCode {
  final List<int> error;
  XCMV3MaybeErrorCodeTruncatedError({required List<int> error})
      : error = error.max(_XCMV3Constants.maxDispatchErrorLen).asImmutableBytes;
  factory XCMV3MaybeErrorCodeTruncatedError.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3MaybeErrorCodeTruncatedError(error: json.valueAsBytes("error"));
  }
  factory XCMV3MaybeErrorCodeTruncatedError.fromJson(
      Map<String, dynamic> json) {
    return XCMV3MaybeErrorCodeTruncatedError(
        error: json.valueAsBytes(XCMV3MaybeErrorCodeType.truncatedError.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.bytes(property: "error"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"error": error};
  }

  @override
  XCMV3MaybeErrorCodeType get type => XCMV3MaybeErrorCodeType.truncatedError;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: error};
  }

  @override
  List get variabels => [type, error];
}

class XCMV3ResponseDispatchResult extends XCMV3Response {
  final XCMV3MaybeErrorCode error;
  XCMV3ResponseDispatchResult({required this.error});
  factory XCMV3ResponseDispatchResult.fromJson(Map<String, dynamic> json) {
    return XCMV3ResponseDispatchResult(
        error: XCMV3MaybeErrorCode.fromJson(
            json.valueAs(XCMV3ResponseType.dispatchResult.type)));
  }
  factory XCMV3ResponseDispatchResult.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3ResponseDispatchResult(
        error: XCMV3MaybeErrorCode.deserializeJson(
            json.valueEnsureAsMap("error")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3MaybeErrorCode.layout_(property: "error")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"error": error.serializeJsonVariant()};
  }

  @override
  XCMV3ResponseType get type => XCMV3ResponseType.dispatchResult;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: error.toJson()};
  }

  @override
  List get variabels => [type, error];
}

class XCMV3QueryResponseInfo
    extends SubstrateSerialization<Map<String, dynamic>>
    with XCMComponent, Equality {
  final XCMV3MultiLocation destination;
  final BigInt queryId;
  final SubstrateWeightV2 maxWeight;
  XCMV3QueryResponseInfo(
      {required this.destination,
      required BigInt queryId,
      required this.maxWeight})
      : queryId = queryId.asUint64;
  factory XCMV3QueryResponseInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMV3QueryResponseInfo(
        destination:
            XCMV3MultiLocation.deserializeJson(json.valueAs("destination")),
        queryId: json.valueAs("query_id"),
        maxWeight:
            SubstrateWeightV2.deserializeJson(json.valueAs("max_weight")));
  }
  factory XCMV3QueryResponseInfo.fromJson(Map<String, dynamic> json) {
    return XCMV3QueryResponseInfo(
        destination: XCMV3MultiLocation.fromJson(json.valueAs("destination")),
        queryId: json.valueAs("query_id"),
        maxWeight: SubstrateWeightV2.fromJson(json.valueAs("max_weight")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3MultiLocation.layout_(property: "destination"),
      LayoutConst.compactBigintU64(property: "query_id"),
      SubstrateWeightV2.layout_(property: "max_weight")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "destination": destination.serializeJson(),
      "query_id": queryId,
      "max_weight": maxWeight.serializeJson()
    };
  }

  Map<String, dynamic> toJson({String? property}) {
    return {
      "destination": destination.toJson(),
      "query_id": queryId,
      "max_weight": maxWeight.toJson()
    };
  }

  @override
  List get variabels => [destination, queryId, maxWeight];

  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3 extends SubstrateSerialization<Map<String, dynamic>>
    with XCM<XCMInstructionV3>, Equality {
  @override
  final List<XCMInstructionV3> instructions;

  XCMV3({required List<XCMInstructionV3> instructions})
      : instructions = instructions.immutable;
  factory XCMV3.deserializeJson(Map<String, dynamic> json) {
    return XCMV3(
        instructions: json
            .valueEnsureAsList<Map<String, dynamic>>("instructions")
            .map((e) => XCMInstructionV3.deserializeJson(e))
            .toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMInstructionV3.layout_(),
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
  XCMVersion get version => XCMVersion.v3;
}
