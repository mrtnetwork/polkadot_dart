import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

class _XCMV4Constants {
  static const int maxPalletInfo = 64;
}

abstract class XCMInstructionV4 extends SubstrateVariantSerialization
    with XCMInstruction, Equality {
  const XCMInstructionV4();
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMV4WithdrawAsset.layout_(property: property),
        property: XCMInstructionType.withdrawAsset.name,
        index: XCMInstructionType.withdrawAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ReserveAssetDeposited.layout_(property: property),
        property: XCMInstructionType.reserveAssetDeposited.name,
        index: XCMInstructionType.reserveAssetDeposited.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ReceiveTeleportedAsset.layout_(property: property),
        property: XCMInstructionType.receiveTeleportedAsset.name,
        index: XCMInstructionType.receiveTeleportedAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4QueryResponse.layout_(property: property),
        property: XCMInstructionType.queryResponse.name,
        index: XCMInstructionType.queryResponse.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4TransferAsset.layout_(property: property),
        property: XCMInstructionType.transferAsset.name,
        index: XCMInstructionType.transferAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4TransferReserveAsset.layout_(property: property),
        property: XCMInstructionType.transferReserveAsset.name,
        index: XCMInstructionType.transferReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4Transact.layout_(property: property),
        property: XCMInstructionType.transact.name,
        index: XCMInstructionType.transact.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4HrmpNewChannelOpenRequest.layout_(property: property),
        property: XCMInstructionType.hrmpNewChannelOpenRequest.name,
        index: XCMInstructionType.hrmpNewChannelOpenRequest.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4HrmpChannelAccepted.layout_(property: property),
        property: XCMInstructionType.hrmpChannelAccepted.name,
        index: XCMInstructionType.hrmpChannelAccepted.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4HrmpChannelClosing.layout_(property: property),
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
        layout: ({property}) => XCMV4DescendOrigin.layout_(property: property),
        property: XCMInstructionType.descendOrigin.name,
        index: XCMInstructionType.descendOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ReportError.layout_(property: property),
        property: XCMInstructionType.reportError.name,
        index: XCMInstructionType.reportError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4DepositAsset.layout_(property: property),
        property: XCMInstructionType.depositAsset.name,
        index: XCMInstructionType.depositAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4DepositReserveAsset.layout_(property: property),
        property: XCMInstructionType.depositReserveAsset.name,
        index: XCMInstructionType.depositReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ExchangeAsset.layout_(property: property),
        property: XCMInstructionType.exchangeAsset.name,
        index: XCMInstructionType.exchangeAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4InitiateReserveWithdraw.layout_(property: property),
        property: XCMInstructionType.initiateReserveWithdraw.name,
        index: XCMInstructionType.initiateReserveWithdraw.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4InitiateTeleport.layout_(property: property),
        property: XCMInstructionType.initiateTeleport.name,
        index: XCMInstructionType.initiateTeleport.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ReportHolding.layout_(property: property),
        property: XCMInstructionType.reportHolding.name,
        index: XCMInstructionType.reportHolding.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4BuyExecution.layout_(property: property),
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
            XCMV4SetErrorHandler.layout_(property: property),
        property: XCMInstructionType.setErrorHandler.name,
        index: XCMInstructionType.setErrorHandler.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4SetAppendix.layout_(property: property),
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
        layout: ({property}) => XCMV4ClaimAsset.layout_(property: property),
        property: XCMInstructionType.claimAsset.name,
        index: XCMInstructionType.claimAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4Trap.layout_(property: property),
        property: XCMInstructionType.trap.name,
        index: XCMInstructionType.trap.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4SubscribeVersion.layout_(property: property),
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
        layout: ({property}) => XCMV4BurnAsset.layout_(property: property),
        property: XCMInstructionType.burnAsset.name,
        index: XCMInstructionType.burnAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ExpectAsset.layout_(property: property),
        property: XCMInstructionType.expectAsset.name,
        index: XCMInstructionType.expectAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ExpectOrigin.layout_(property: property),
        property: XCMInstructionType.expectOrigin.name,
        index: XCMInstructionType.expectOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ExpectError.layout_(property: property),
        property: XCMInstructionType.expectError.name,
        index: XCMInstructionType.expectError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ExpectTransactStatus.layout_(property: property),
        property: XCMInstructionType.expectTransactStatus.name,
        index: XCMInstructionType.expectTransactStatus.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4QueryPallet.layout_(property: property),
        property: XCMInstructionType.queryPallet.name,
        index: XCMInstructionType.queryPallet.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ExpectPallet.layout_(property: property),
        property: XCMInstructionType.expectPallet.name,
        index: XCMInstructionType.expectPallet.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ReportTransactStatus.layout_(property: property),
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
            XCMV4UniversalOrigin.layout_(property: property),
        property: XCMInstructionType.universalOrigin.name,
        index: XCMInstructionType.universalOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ExportMessage.layout_(property: property),
        property: XCMInstructionType.exportMessage.name,
        index: XCMInstructionType.exportMessage.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4LockAsset.layout_(property: property),
        property: XCMInstructionType.lockAsset.name,
        index: XCMInstructionType.lockAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4UnlockAsset.layout_(property: property),
        property: XCMInstructionType.unlockAsset.name,
        index: XCMInstructionType.unlockAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4NoteUnlockable.layout_(property: property),
        property: XCMInstructionType.noteUnlockable.name,
        index: XCMInstructionType.noteUnlockable.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4RequestUnlock.layout_(property: property),
        property: XCMInstructionType.requestUnlock.name,
        index: XCMInstructionType.requestUnlock.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4SetFeesMode.layout_(property: property),
        property: XCMInstructionType.setFeesMode.name,
        index: XCMInstructionType.setFeesMode.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4SetTopic.layout_(property: property),
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
        layout: ({property}) => XCMV4AliasOrigin.layout_(property: property),
        property: XCMInstructionType.aliasOrigin.name,
        index: XCMInstructionType.aliasOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4UnpaidExecution.layout_(property: property),
        property: XCMInstructionType.unpaidExecution.name,
        index: XCMInstructionType.unpaidExecution.variantIndex,
      ),
    ]);
  }

  factory XCMInstructionV4.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMInstructionType.fromName(decode.variantName);
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV4WithdrawAsset.deserializeJson(decode.value),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV4ReserveAssetDeposited.deserializeJson(decode.value),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV4ReceiveTeleportedAsset.deserializeJson(decode.value),
      XCMInstructionType.queryResponse =>
        XCMV4QueryResponse.deserializeJson(decode.value),
      XCMInstructionType.transferAsset =>
        XCMV4TransferAsset.deserializeJson(decode.value),
      XCMInstructionType.transferReserveAsset =>
        XCMV4TransferReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.transact =>
        XCMV4Transact.deserializeJson(decode.value),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV4HrmpNewChannelOpenRequest.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV4HrmpChannelAccepted.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV4HrmpChannelClosing.deserializeJson(decode.value),
      XCMInstructionType.clearOrigin => XCMV4ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV4DescendOrigin.deserializeJson(decode.value),
      XCMInstructionType.reportError =>
        XCMV4ReportError.deserializeJson(decode.value),
      XCMInstructionType.depositAsset =>
        XCMV4DepositAsset.deserializeJson(decode.value),
      XCMInstructionType.depositReserveAsset =>
        XCMV4DepositReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.exchangeAsset =>
        XCMV4ExchangeAsset.deserializeJson(decode.value),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV4InitiateReserveWithdraw.deserializeJson(decode.value),
      XCMInstructionType.initiateTeleport =>
        XCMV4InitiateTeleport.deserializeJson(decode.value),
      XCMInstructionType.reportHolding =>
        XCMV4ReportHolding.deserializeJson(decode.value),
      XCMInstructionType.buyExecution =>
        XCMV4BuyExecution.deserializeJson(decode.value),
      XCMInstructionType.refundSurplus => XCMV4RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV4SetErrorHandler.deserializeJson(decode.value),
      XCMInstructionType.setAppendix =>
        XCMV4SetAppendix.deserializeJson(decode.value),
      XCMInstructionType.clearError => XCMV4ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV4ClaimAsset.deserializeJson(decode.value),
      XCMInstructionType.trap => XCMV4Trap.deserializeJson(decode.value),
      XCMInstructionType.subscribeVersion =>
        XCMV4SubscribeVersion.deserializeJson(decode.value),
      XCMInstructionType.unsubscribeVersion => XCMV4UnsubscribeVersion(),
      XCMInstructionType.burnAsset =>
        XCMV4BurnAsset.deserializeJson(decode.value),
      XCMInstructionType.expectAsset =>
        XCMV4ExpectAsset.deserializeJson(decode.value),
      XCMInstructionType.expectOrigin =>
        XCMV4ExpectOrigin.deserializeJson(decode.value),
      XCMInstructionType.expectError =>
        XCMV4ExpectError.deserializeJson(decode.value),
      XCMInstructionType.expectTransactStatus =>
        XCMV4ExpectTransactStatus.deserializeJson(decode.value),
      XCMInstructionType.queryPallet =>
        XCMV4QueryPallet.deserializeJson(decode.value),
      XCMInstructionType.expectPallet =>
        XCMV4ExpectPallet.deserializeJson(decode.value),
      XCMInstructionType.reportTransactStatus =>
        XCMV4ReportTransactStatus.deserializeJson(decode.value),
      XCMInstructionType.clearTransactStatus => XCMV4ClearTransactStatus(),
      XCMInstructionType.universalOrigin =>
        XCMV4UniversalOrigin.deserializeJson(decode.value),
      XCMInstructionType.exportMessage =>
        XCMV4ExportMessage.deserializeJson(decode.value),
      XCMInstructionType.lockAsset =>
        XCMV4LockAsset.deserializeJson(decode.value),
      XCMInstructionType.unlockAsset =>
        XCMV4UnlockAsset.deserializeJson(decode.value),
      XCMInstructionType.noteUnlockable =>
        XCMV4NoteUnlockable.deserializeJson(decode.value),
      XCMInstructionType.requestUnlock =>
        XCMV4RequestUnlock.deserializeJson(decode.value),
      XCMInstructionType.setFeesMode =>
        XCMV4SetFeesMode.deserializeJson(decode.value),
      XCMInstructionType.setTopic =>
        XCMV4SetTopic.deserializeJson(decode.value),
      XCMInstructionType.clearTopic => XCMV4ClearTopic(),
      XCMInstructionType.aliasOrigin =>
        XCMV4AliasOrigin.deserializeJson(decode.value),
      XCMInstructionType.unpaidExecution =>
        XCMV4UnpaidExecution.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 4.",
          details: {"type": type.name})
    };
  }
  factory XCMInstructionV4.fromJson(Map<String, dynamic> json) {
    final type = XCMInstructionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMInstructionType.withdrawAsset => XCMV4WithdrawAsset.fromJson(json),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV4ReserveAssetDeposited.fromJson(json),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV4ReceiveTeleportedAsset.fromJson(json),
      XCMInstructionType.queryResponse => XCMV4QueryResponse.fromJson(json),
      XCMInstructionType.transferAsset => XCMV4TransferAsset.fromJson(json),
      XCMInstructionType.transferReserveAsset =>
        XCMV4TransferReserveAsset.fromJson(json),
      XCMInstructionType.transact => XCMV4Transact.fromJson(json),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV4HrmpNewChannelOpenRequest.fromJson(json),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV4HrmpChannelAccepted.fromJson(json),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV4HrmpChannelClosing.fromJson(json),
      XCMInstructionType.clearOrigin => XCMV4ClearOrigin.fromJson(json),
      XCMInstructionType.descendOrigin => XCMV4DescendOrigin.fromJson(json),
      XCMInstructionType.reportError => XCMV4ReportError.fromJson(json),
      XCMInstructionType.depositAsset => XCMV4DepositAsset.fromJson(json),
      XCMInstructionType.depositReserveAsset =>
        XCMV4DepositReserveAsset.fromJson(json),
      XCMInstructionType.exchangeAsset => XCMV4ExchangeAsset.fromJson(json),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV4InitiateReserveWithdraw.fromJson(json),
      XCMInstructionType.initiateTeleport =>
        XCMV4InitiateTeleport.fromJson(json),
      XCMInstructionType.reportHolding => XCMV4ReportHolding.fromJson(json),
      XCMInstructionType.buyExecution => XCMV4BuyExecution.fromJson(json),
      XCMInstructionType.refundSurplus => XCMV4RefundSurplus.fromJson(json),
      XCMInstructionType.setErrorHandler => XCMV4SetErrorHandler.fromJson(json),
      XCMInstructionType.setAppendix => XCMV4SetAppendix.fromJson(json),
      XCMInstructionType.clearError => XCMV4ClearError.fromJson(json),
      XCMInstructionType.claimAsset => XCMV4ClaimAsset.fromJson(json),
      XCMInstructionType.trap => XCMV4Trap.fromJson(json),
      XCMInstructionType.subscribeVersion =>
        XCMV4SubscribeVersion.fromJson(json),
      XCMInstructionType.unsubscribeVersion =>
        XCMV4UnsubscribeVersion.fromJson(json),
      XCMInstructionType.burnAsset => XCMV4BurnAsset.fromJson(json),
      XCMInstructionType.expectAsset => XCMV4ExpectAsset.fromJson(json),
      XCMInstructionType.expectOrigin => XCMV4ExpectOrigin.fromJson(json),
      XCMInstructionType.expectError => XCMV4ExpectError.fromJson(json),
      XCMInstructionType.expectTransactStatus =>
        XCMV4ExpectTransactStatus.fromJson(json),
      XCMInstructionType.queryPallet => XCMV4QueryPallet.fromJson(json),
      XCMInstructionType.expectPallet => XCMV4ExpectPallet.fromJson(json),
      XCMInstructionType.reportTransactStatus =>
        XCMV4ReportTransactStatus.fromJson(json),
      XCMInstructionType.clearTransactStatus =>
        XCMV4ClearTransactStatus.fromJson(json),
      XCMInstructionType.universalOrigin => XCMV4UniversalOrigin.fromJson(json),
      XCMInstructionType.exportMessage => XCMV4ExportMessage.fromJson(json),
      XCMInstructionType.lockAsset => XCMV4LockAsset.fromJson(json),
      XCMInstructionType.unlockAsset => XCMV4UnlockAsset.fromJson(json),
      XCMInstructionType.noteUnlockable => XCMV4NoteUnlockable.fromJson(json),
      XCMInstructionType.requestUnlock => XCMV4RequestUnlock.fromJson(json),
      XCMInstructionType.setFeesMode => XCMV4SetFeesMode.fromJson(json),
      XCMInstructionType.setTopic => XCMV4SetTopic.fromJson(json),
      XCMInstructionType.clearTopic => XCMV4ClearTopic.fromJson(json),
      XCMInstructionType.aliasOrigin => XCMV4AliasOrigin.fromJson(json),
      XCMInstructionType.unpaidExecution => XCMV4UnpaidExecution.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 4.",
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4WithdrawAsset extends XCMInstructionV4 with XCMWithdrawAsset {
  @override
  final XCMV4Assets assets;
  XCMV4WithdrawAsset({required this.assets});
  factory XCMV4WithdrawAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4WithdrawAsset(
        assets: XCMV4Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV4WithdrawAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.withdrawAsset.type);

    return XCMV4WithdrawAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()));
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

class XCMV4ReserveAssetDeposited extends XCMInstructionV4
    with XCMReserveAssetDeposited {
  @override
  final XCMV4Assets assets;
  XCMV4ReserveAssetDeposited({required this.assets});
  factory XCMV4ReserveAssetDeposited.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4ReserveAssetDeposited(
        assets: XCMV4Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV4ReserveAssetDeposited.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.reserveAssetDeposited.type);
    return XCMV4ReserveAssetDeposited(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()));
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

class XCMV4ReceiveTeleportedAsset extends XCMInstructionV4
    with XCMReceiveTeleportedAsset {
  @override
  final XCMV4Assets assets;
  XCMV4ReceiveTeleportedAsset({required this.assets});
  factory XCMV4ReceiveTeleportedAsset.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4ReceiveTeleportedAsset(
        assets: XCMV4Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV4ReceiveTeleportedAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.receiveTeleportedAsset.type);
    return XCMV4ReceiveTeleportedAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()));
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

class XCMV4QueryResponse extends XCMInstructionV4 with XCMQueryResponse {
  final BigInt queryId;
  final XCMV4Response response;
  final SubstrateWeightV2 maxWeight;
  final XCMV4Location? querier;

  XCMV4QueryResponse(
      {required this.queryId,
      required this.response,
      required this.maxWeight,
      required this.querier});
  factory XCMV4QueryResponse.deserializeJson(Map<String, dynamic> json) {
    return XCMV4QueryResponse(
        queryId: json.valueAs("query_id"),
        response: XCMV4Response.deserializeJson(json.valueAs("response")),
        maxWeight:
            SubstrateWeightV2.deserializeJson(json.valueAs("max_weight")),
        querier: json.valueTo<XCMV4Location?, Map<String, dynamic>>(
            key: "querier", parse: (v) => XCMV4Location.deserializeJson(v)));
  }
  factory XCMV4QueryResponse.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.queryResponse.type);
    final Map<String, dynamic>? querier =
        MetadataUtils.parseOptional(data.valueAs("querier"));
    return XCMV4QueryResponse(
        queryId: data.valueAs("query_id"),
        response: XCMV4Response.fromJson(data.valueAs("response")),
        maxWeight: SubstrateWeightV2.fromJson(data.valueAs("max_weight")),
        querier: querier == null ? null : XCMV4Location.fromJson(querier));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      XCMV4Response.layout_(property: "response"),
      SubstrateWeightV2.layout_(property: "max_weight"),
      LayoutConst.optional(XCMV4Location.layout_(), property: "querier")
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

class XCMV4TransferAsset extends XCMInstructionV4 with XCMTransferAsset {
  @override
  final XCMV4Assets assets;
  @override
  final XCMV4Location beneficiary;
  XCMV4TransferAsset({required this.assets, required this.beneficiary});
  factory XCMV4TransferAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4TransferAsset(
      assets: XCMV4Assets.deserializeJson(json.valueAs("assets")),
      beneficiary: XCMV4Location.deserializeJson(json.valueAs("beneficiary")),
    );
  }
  factory XCMV4TransferAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV4TransferAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()),
        beneficiary: XCMV4Location.fromJson(data.valueAs("beneficiary")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Assets.layout_(property: "assets"),
      XCMV4Location.layout_(property: "beneficiary")
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

  @override
  List get variabels => [type, assets, beneficiary];
}

class XCMV4TransferReserveAsset extends XCMInstructionV4
    with XCMTransferReserveAsset {
  @override
  final XCMV4Assets assets;
  @override
  final XCMV4Location dest;
  @override
  final XCMV4 xcm;
  XCMV4TransferReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV4TransferReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4TransferReserveAsset(
        assets: XCMV4Assets.deserializeJson(json.valueAs("assets")),
        dest: XCMV4Location.deserializeJson(json.valueAs("dest")),
        xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }

  factory XCMV4TransferReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferReserveAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV4TransferReserveAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()),
        dest: XCMV4Location.fromJson(data.valueAs("dest")),
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Assets.layout_(property: "assets"),
      XCMV4Location.layout_(property: "dest"),
      XCMV4.layout_(property: "xcm")
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

  @override
  List get variabels => [type, assets, dest, xcm];
}

class XCMV4Transact extends XCMInstructionV4 with XCMTransact {
  final XCMV3OriginKind originKind;
  final SubstrateWeightV2 requireWeightAtMost;
  @override
  final List<int> call;

  XCMV4Transact(
      {required this.originKind,
      required this.requireWeightAtMost,
      required List<int> call})
      : call = call.asImmutableBytes;
  factory XCMV4Transact.deserializeJson(Map<String, dynamic> json) {
    return XCMV4Transact(
        originKind:
            XCMV3OriginKind.deserializeJson(json.valueAs("origin_kind")),
        requireWeightAtMost: SubstrateWeightV2.deserializeJson(
            json.valueAs("require_weight_at_most")),
        call: json.valueAsBytes("call"));
  }

  factory XCMV4Transact.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.transact.type);
    return XCMV4Transact(
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

class XCMV4HrmpNewChannelOpenRequest extends XCMInstructionV4
    with XCMHrmpNewChannelOpenRequest {
  @override
  final int sender;
  @override
  final int maxMessageSize;
  @override
  final int maxCapacity;

  XCMV4HrmpNewChannelOpenRequest(
      {required int sender,
      required int maxMessageSize,
      required int maxCapacity})
      : sender = sender.asUint32,
        maxMessageSize = maxMessageSize.asUint32,
        maxCapacity = maxCapacity.asUint32;
  factory XCMV4HrmpNewChannelOpenRequest.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4HrmpNewChannelOpenRequest(
        sender: json.valueAs("sender"),
        maxCapacity: json.valueAs("max_capacity"),
        maxMessageSize: json.valueAs("max_message_size"));
  }
  factory XCMV4HrmpNewChannelOpenRequest.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpNewChannelOpenRequest.type);
    return XCMV4HrmpNewChannelOpenRequest(
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

  @override
  List get variabels => [type, sender, maxMessageSize, maxCapacity];
}

class XCMV4HrmpChannelAccepted extends XCMInstructionV4
    with XCMHrmpChannelAccepted {
  @override
  final int recipient;

  XCMV4HrmpChannelAccepted({required int recipient})
      : recipient = recipient.asUint32;
  factory XCMV4HrmpChannelAccepted.deserializeJson(Map<String, dynamic> json) {
    return XCMV4HrmpChannelAccepted(recipient: json.valueAs("recipient"));
  }
  factory XCMV4HrmpChannelAccepted.fromJson(Map<String, dynamic> json) {
    return XCMV4HrmpChannelAccepted(
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

  @override
  List get variabels => [type, recipient];
}

class XCMV4HrmpChannelClosing extends XCMInstructionV4
    with XCMHrmpChannelClosing {
  @override
  final int initiator;
  @override
  final int sender;
  @override
  final int recipient;

  XCMV4HrmpChannelClosing(
      {required int sender, required int initiator, required int recipient})
      : sender = sender.asUint32,
        initiator = initiator.asUint32,
        recipient = recipient.asUint32;
  factory XCMV4HrmpChannelClosing.deserializeJson(Map<String, dynamic> json) {
    return XCMV4HrmpChannelClosing(
        sender: json.valueAs("sender"),
        recipient: json.valueAs("recipient"),
        initiator: json.valueAs("initiator"));
  }
  factory XCMV4HrmpChannelClosing.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpChannelClosing.type);
    return XCMV4HrmpChannelClosing(
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

  @override
  List get variabels => [type, initiator, sender, recipient];
}

class XCMV4ClearOrigin extends XCMInstructionV4
    with SubstrateVariantNoArgs, XCMClearOrigin {
  const XCMV4ClearOrigin();
  factory XCMV4ClearOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearOrigin.type);
    return XCMV4ClearOrigin();
  }
  @override
  List get variabels => [type];
}

class XCMV4DescendOrigin extends XCMInstructionV4 with XCMDescendOrigin {
  @override
  final XCMV4InteriorMultiLocation interior;

  XCMV4DescendOrigin({required this.interior});
  factory XCMV4DescendOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV4DescendOrigin(
        interior: XCMV4Junctions.deserializeJson(json.valueAs("interior")));
  }

  factory XCMV4DescendOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV4DescendOrigin(
        interior: XCMV4Junctions.fromJson(
            json.valueAs(XCMInstructionType.descendOrigin.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4Junctions.layout_(property: "interior")],
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

  @override
  List get variabels => [type, interior];
}

class XCMV4ReportError extends XCMInstructionV4 with XCMReportError {
  final XCMV4QueryResponseInfo responseInfo;

  XCMV4ReportError({required this.responseInfo});
  factory XCMV4ReportError.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ReportError(
        responseInfo: XCMV4QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV4ReportError.fromJson(Map<String, dynamic> json) {
    return XCMV4ReportError(
        responseInfo: XCMV4QueryResponseInfo.fromJson(
            json.valueAs(XCMInstructionType.reportError.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV4QueryResponseInfo.layout_(property: "response_info")],
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

class XCMV4DepositAsset extends XCMInstructionV4 with XCMDepositAsset {
  @override
  final XCMV4AssetFilter assets;
  @override
  final XCMV4Location beneficiary;

  XCMV4DepositAsset({required this.assets, required this.beneficiary});
  factory XCMV4DepositAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4DepositAsset(
      assets: XCMV4AssetFilter.deserializeJson(json.valueAs("assets")),
      beneficiary: XCMV4Location.deserializeJson(json.valueAs("beneficiary")),
    );
  }

  factory XCMV4DepositAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositAsset.type);
    return XCMV4DepositAsset(
        assets: XCMV4AssetFilter.fromJson(data.valueAs("assets")),
        beneficiary: XCMV4Location.fromJson(data.valueAs("beneficiary")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetFilter.layout_(property: "assets"),
      XCMV4Location.layout_(property: "beneficiary")
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

class XCMV4DepositReserveAsset extends XCMInstructionV4
    with XCMDepositReserveAsset {
  @override
  final XCMV4AssetFilter assets;
  @override
  final XCMV4Location dest;
  @override
  final XCMV4 xcm;

  XCMV4DepositReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV4DepositReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4DepositReserveAsset(
        assets: XCMV4AssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV4Location.deserializeJson(json.valueAs("dest")),
        xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV4DepositReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositReserveAsset.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV4DepositReserveAsset(
        assets: XCMV4AssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV4Location.fromJson(data.valueAs("dest")),
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetFilter.layout_(property: "assets"),
      XCMV4Location.layout_(property: "dest"),
      XCMV4.layout_(property: "xcm")
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
  List get variabels => [type, assets, dest, xcm];
}

class XCMV4ExchangeAsset extends XCMInstructionV4 with XCMExchangeAsset {
  final XCMV4AssetFilter give;
  @override
  final XCMV4Assets want;
  final bool maximal;

  XCMV4ExchangeAsset(
      {required this.give, required this.want, required this.maximal});
  factory XCMV4ExchangeAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ExchangeAsset(
        give: XCMV4AssetFilter.deserializeJson(json.valueAs("give")),
        want: XCMV4Assets.deserializeJson(json.valueAs("want")),
        maximal: json.valueAs("maximal"));
  }
  factory XCMV4ExchangeAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exchangeAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("want");
    return XCMV4ExchangeAsset(
        want: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()),
        give: XCMV4AssetFilter.fromJson(data.valueAs("give")),
        maximal: data.valueAs("maximal"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetFilter.layout_(property: "give"),
      XCMV4Assets.layout_(property: "want"),
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

class XCMV4InitiateReserveWithdraw extends XCMInstructionV4
    with XCMInitiateReserveWithdraw {
  @override
  final XCMV4AssetFilter assets;
  @override
  final XCMV4Location reserve;
  @override
  final XCMV4 xcm;

  XCMV4InitiateReserveWithdraw(
      {required this.assets, required this.reserve, required this.xcm});
  factory XCMV4InitiateReserveWithdraw.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4InitiateReserveWithdraw(
        assets: XCMV4AssetFilter.deserializeJson(json.valueAs("assets")),
        reserve: XCMV4Location.deserializeJson(json.valueAs("reserve")),
        xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV4InitiateReserveWithdraw.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateReserveWithdraw.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV4InitiateReserveWithdraw(
        assets: XCMV4AssetFilter.fromJson(data.valueAs("assets")),
        reserve: XCMV4Location.fromJson(data.valueAs("reserve")),
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetFilter.layout_(property: "assets"),
      XCMV4Location.layout_(property: "reserve"),
      XCMV4.layout_(property: "xcm"),
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

class XCMV4InitiateTeleport extends XCMInstructionV4 with XCMInitiateTeleport {
  final XCMV4AssetFilter assets;
  @override
  final XCMV4Location dest;
  @override
  final XCMV4 xcm;
  XCMV4InitiateTeleport(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV4InitiateTeleport.deserializeJson(Map<String, dynamic> json) {
    return XCMV4InitiateTeleport(
        assets: XCMV4AssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV4Location.deserializeJson(json.valueAs("dest")),
        xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV4InitiateTeleport.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateTeleport.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV4InitiateTeleport(
        assets: XCMV4AssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV4Location.fromJson(data.valueAs("dest")),
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetFilter.layout_(property: "assets"),
      XCMV4Location.layout_(property: "dest"),
      XCMV4.layout_(property: "xcm")
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

class XCMV4ReportHolding extends XCMInstructionV4 with XCMReportHolding {
  final XCMV4QueryResponseInfo responseInfo;
  final XCMV4AssetFilter assets;

  XCMV4ReportHolding({required this.assets, required this.responseInfo});
  factory XCMV4ReportHolding.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ReportHolding(
        assets: XCMV4AssetFilter.deserializeJson(json.valueAs("assets")),
        responseInfo: XCMV4QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV4ReportHolding.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.reportHolding.type);
    return XCMV4ReportHolding(
        assets: XCMV4AssetFilter.fromJson(data.valueAs("assets")),
        responseInfo:
            XCMV4QueryResponseInfo.fromJson(data.valueAs("response_info")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4QueryResponseInfo.layout_(property: "response_info"),
      XCMV4AssetFilter.layout_(property: "assets"),
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

class XCMV4BuyExecution extends XCMInstructionV4 with XCMBuyExecution {
  @override
  final XCMV4Asset fees;
  @override
  final XCMV3WeightLimit weightLimit;

  XCMV4BuyExecution({required this.fees, required this.weightLimit});
  factory XCMV4BuyExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV4BuyExecution(
        fees: XCMV4Asset.deserializeJson(json.valueAs("fees")),
        weightLimit:
            XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit")));
  }
  factory XCMV4BuyExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.buyExecution.type);
    return XCMV4BuyExecution(
        fees: XCMV4Asset.fromJson(data.valueAs("fees")),
        weightLimit: XCMV3WeightLimit.fromJson(data.valueAs("weight_limit")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Asset.layout_(property: "fees"),
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

class XCMV4RefundSurplus extends XCMInstructionV4
    with SubstrateVariantNoArgs, XCMRefundSurplus {
  const XCMV4RefundSurplus();
  factory XCMV4RefundSurplus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.refundSurplus.type);
    return XCMV4RefundSurplus();
  }
}

class XCMV4SetErrorHandler extends XCMInstructionV4 with XCMSetErrorHandler {
  @override
  final XCMV4 xcm;
  XCMV4SetErrorHandler({required this.xcm});
  factory XCMV4SetErrorHandler.deserializeJson(Map<String, dynamic> json) {
    return XCMV4SetErrorHandler(
        xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV4SetErrorHandler.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setErrorHandler.type);
    return XCMV4SetErrorHandler(
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
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
}

class XCMV4SetAppendix extends XCMInstructionV4 with XCMSetAppendix {
  @override
  final XCMV4 xcm;
  XCMV4SetAppendix({required this.xcm});
  factory XCMV4SetAppendix.deserializeJson(Map<String, dynamic> json) {
    return XCMV4SetAppendix(xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV4SetAppendix.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setAppendix.type);
    return XCMV4SetAppendix(
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
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
}

class XCMV4ClearError extends XCMInstructionV4
    with SubstrateVariantNoArgs, XCMClearError {
  const XCMV4ClearError();
  factory XCMV4ClearError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearError.type);
    return XCMV4ClearError();
  }
}

class XCMV4ClaimAsset extends XCMInstructionV4 with XCMClaimAsset {
  @override
  final XCMV4Assets assets;
  @override
  final XCMV4Location ticket;
  XCMV4ClaimAsset({required this.assets, required this.ticket});
  factory XCMV4ClaimAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ClaimAsset(
      assets: XCMV4Assets.deserializeJson(json.valueAs("assets")),
      ticket: XCMV4Location.deserializeJson(json.valueAs("ticket")),
    );
  }
  factory XCMV4ClaimAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.claimAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV4ClaimAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()),
        ticket: XCMV4Location.fromJson(data.valueAs("ticket")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Assets.layout_(property: "assets"),
      XCMV4Location.layout_(property: "ticket"),
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

class XCMV4Trap extends XCMInstructionV4 with XCMTrap {
  @override
  final BigInt trap;
  XCMV4Trap({required BigInt trap}) : trap = trap.asUint64;
  factory XCMV4Trap.deserializeJson(Map<String, dynamic> json) {
    return XCMV4Trap(trap: json.valueAs("trap"));
  }
  factory XCMV4Trap.fromJson(Map<String, dynamic> json) {
    return XCMV4Trap(trap: json.valueAs(XCMInstructionType.trap.type));
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

class XCMV4SubscribeVersion extends XCMInstructionV4 with XCMSubscribeVersion {
  @override
  final BigInt queryId;
  final SubstrateWeightV2 maxResponseWeight;
  XCMV4SubscribeVersion(
      {required BigInt queryId, required this.maxResponseWeight})
      : queryId = queryId.asUint64;
  factory XCMV4SubscribeVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV4SubscribeVersion(
        queryId: json.valueAs("query_id"),
        maxResponseWeight: SubstrateWeightV2.deserializeJson(
            json.valueAs("max_response_weight")));
  }
  factory XCMV4SubscribeVersion.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.subscribeVersion.type);
    return XCMV4SubscribeVersion(
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
  List get variabels => [type, queryId, maxResponseWeight];
}

class XCMV4UnsubscribeVersion extends XCMInstructionV4
    with SubstrateVariantNoArgs, XCMUnsubscribeVersion {
  const XCMV4UnsubscribeVersion();
  factory XCMV4UnsubscribeVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.unsubscribeVersion.type);
    return XCMV4UnsubscribeVersion();
  }
}

class XCMV4BurnAsset extends XCMInstructionV4 with XCMBurnAsset {
  @override
  final XCMV4Assets assets;
  XCMV4BurnAsset({required this.assets});
  factory XCMV4BurnAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4BurnAsset(
      assets: XCMV4Assets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMV4BurnAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.burnAsset.type);
    return XCMV4BurnAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Assets.layout_(property: "assets"),
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

class XCMV4ExpectAsset extends XCMInstructionV4 with XCMExpectAsset {
  @override
  final XCMV4Assets assets;
  XCMV4ExpectAsset({required this.assets});
  factory XCMV4ExpectAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ExpectAsset(
      assets: XCMV4Assets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMV4ExpectAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.expectAsset.type);
    return XCMV4ExpectAsset(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Assets.layout_(property: "assets"),
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

class XCMV4ExpectOrigin extends XCMInstructionV4 with XCMExpectOrigin {
  @override
  final XCMV4Location? location;
  XCMV4ExpectOrigin({required this.location});
  factory XCMV4ExpectOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ExpectOrigin(
      location: json.valueTo<XCMV4Location?, Map<String, dynamic>>(
          key: "location", parse: (v) => XCMV4Location.deserializeJson(v)),
    );
  }
  factory XCMV4ExpectOrigin.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? location = MetadataUtils.parseOptional(
        json.valueEnsureAsMap<String, dynamic>(
            XCMInstructionType.expectOrigin.type));

    return XCMV4ExpectOrigin(
        location: location == null ? null : XCMV4Location.fromJson(location));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV4Location.layout_(), property: "location"),
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

class XCMV4ExpectError extends XCMInstructionV4 with XCMExpectError {
  final int? index;
  final XCMV3Error? error;

  XCMV4ExpectError({int? index, this.error}) : index = index?.asUint32;

  factory XCMV4ExpectError.deserializeJson(Map<String, dynamic> json) {
    final error = json.valueAs<Map<String, dynamic>?>("error");
    if (error == null) return XCMV4ExpectError();
    return XCMV4ExpectError(
        index: error.valueAs<int>("index"),
        error: XCMV3Error.deserializeJson(error.valueAs("error")));
  }
  factory XCMV4ExpectError.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.expectError.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV4ExpectError();
    return XCMV4ExpectError(
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

class XCMV4ExpectTransactStatus extends XCMInstructionV4
    with XCMExpectTransactStatus {
  @override
  final XCMV3MaybeErrorCode code;

  XCMV4ExpectTransactStatus({required this.code});

  factory XCMV4ExpectTransactStatus.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ExpectTransactStatus(
        code: XCMV3MaybeErrorCode.deserializeJson(json.valueAs("code")));
  }
  factory XCMV4ExpectTransactStatus.fromJson(Map<String, dynamic> json) {
    return XCMV4ExpectTransactStatus(
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

class XCMV4QueryPallet extends XCMInstructionV4 with XCMQueryPallet {
  @override
  final List<int> moduleName;
  final XCMV4QueryResponseInfo responseInfo;

  XCMV4QueryPallet({
    required List<int> moduleName,
    required this.responseInfo,
  }) : moduleName = moduleName.asImmutableBytes;

  factory XCMV4QueryPallet.deserializeJson(Map<String, dynamic> json) {
    return XCMV4QueryPallet(
        moduleName: json.valueAsBytes("module_name"),
        responseInfo: XCMV4QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV4QueryPallet.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.queryPallet.type);
    return XCMV4QueryPallet(
        moduleName: data.valueAsBytes("module_name"),
        responseInfo:
            XCMV4QueryResponseInfo.fromJson(data.valueAs("response_info")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.bytes(property: "module_name"),
      XCMV4QueryResponseInfo.layout_(property: "response_info")
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

class XCMV4ExpectPallet extends XCMInstructionV4 with XCMExpectPallet {
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

  XCMV4ExpectPallet({
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

  factory XCMV4ExpectPallet.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ExpectPallet(
        name: json.valueAsBytes("name"),
        moduleName: json.valueAsBytes("module_name"),
        index: json.valueAs("index"),
        crateMajor: json.valueAs("crate_major"),
        minCrateMinor: json.valueAs("min_crate_minor"));
  }
  factory XCMV4ExpectPallet.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.expectPallet.type);
    return XCMV4ExpectPallet(
        name: data.valueAsBytes("name"),
        moduleName: data.valueAsBytes("module_name"),
        index: data.valueAs("index"),
        crateMajor: data.valueAs("crate_major"),
        minCrateMinor: data.valueAs("min_crate_minor"));
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

class XCMV4ReportTransactStatus extends XCMInstructionV4
    with XCMReportTransactStatus {
  final XCMV4QueryResponseInfo responseInfo;

  XCMV4ReportTransactStatus({required this.responseInfo});

  factory XCMV4ReportTransactStatus.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ReportTransactStatus(
        responseInfo: XCMV4QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV4ReportTransactStatus.fromJson(Map<String, dynamic> json) {
    return XCMV4ReportTransactStatus(
        responseInfo: XCMV4QueryResponseInfo.fromJson(
            json.valueAs(XCMInstructionType.reportTransactStatus.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV4QueryResponseInfo.layout_(property: "response_info")],
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

class XCMV4ClearTransactStatus extends XCMInstructionV4
    with SubstrateVariantNoArgs, XCMClearTransactStatus {
  const XCMV4ClearTransactStatus();
  factory XCMV4ClearTransactStatus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearTransactStatus.type);
    return XCMV4ClearTransactStatus();
  }
}

class XCMV4UniversalOrigin extends XCMInstructionV4 with XCMUniversalOrigin {
  @override
  final XCMV4Junction origin;

  XCMV4UniversalOrigin({required this.origin});

  factory XCMV4UniversalOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV4UniversalOrigin(
        origin: XCMV4Junction.deserializeJson(json.valueAs("origin")));
  }
  factory XCMV4UniversalOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV4UniversalOrigin(
        origin: XCMV4Junction.fromJson(
            json.valueAs(XCMInstructionType.universalOrigin.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4Junction.layout_(property: "origin")],
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
}

class XCMV4ExportMessage extends XCMInstructionV4 with XCMExportMessage {
  @override
  final XCMV4NetworkId network;
  @override
  final XCMV4InteriorMultiLocation destination;
  @override
  final XCMV4 xcm;
  XCMV4ExportMessage(
      {required this.network, required this.destination, required this.xcm});
  factory XCMV4ExportMessage.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ExportMessage(
        network: XCMV4NetworkId.deserializeJson(json.valueAs("network")),
        destination:
            XCMV4Junctions.deserializeJson(json.valueAs("destination")),
        xcm: XCMV4.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV4ExportMessage.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exportMessage.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV4ExportMessage(
        network: XCMV4NetworkId.fromJson(data.valueAs("network")),
        destination: XCMV4Junctions.fromJson(data.valueAs("destination")),
        xcm: XCMV4(
            instructions:
                xcm.map((e) => XCMInstructionV4.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4NetworkId.layout_(property: "network"),
      XCMV4Junctions.layout_(property: "destination"),
      XCMV4.layout_(property: "xcm"),
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

class XCMV4LockAsset extends XCMInstructionV4 with XCMLockAsset {
  @override
  final XCMV4Asset asset;
  @override
  final XCMV4Location unlocker;
  XCMV4LockAsset({required this.asset, required this.unlocker});
  factory XCMV4LockAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4LockAsset(
      asset: XCMV4Asset.deserializeJson(json.valueAs("asset")),
      unlocker: XCMV4Location.deserializeJson(json.valueAs("unlocker")),
    );
  }
  factory XCMV4LockAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.lockAsset.type);
    return XCMV4LockAsset(
        asset: XCMV4Asset.fromJson(data.valueAs("asset")),
        unlocker: XCMV4Location.fromJson(data.valueAs("unlocker")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Asset.layout_(property: "asset"),
      XCMV4Location.layout_(property: "unlocker")
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

class XCMV4UnlockAsset extends XCMInstructionV4 with XCMUnlockAsset {
  @override
  final XCMV4Asset asset;
  @override
  final XCMV4Location target;
  XCMV4UnlockAsset({required this.asset, required this.target});
  factory XCMV4UnlockAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4UnlockAsset(
      asset: XCMV4Asset.deserializeJson(json.valueAs("asset")),
      target: XCMV4Location.deserializeJson(json.valueAs("target")),
    );
  }
  factory XCMV4UnlockAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.unlockAsset.type);
    return XCMV4UnlockAsset(
        asset: XCMV4Asset.fromJson(data.valueAs("asset")),
        target: XCMV4Location.fromJson(data.valueAs("target")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Asset.layout_(property: "asset"),
      XCMV4Location.layout_(property: "target")
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

class XCMV4NoteUnlockable extends XCMInstructionV4 with XCMNoteUnlockable {
  @override
  final XCMV4Asset asset;
  @override
  final XCMV4Location owner;
  XCMV4NoteUnlockable({required this.asset, required this.owner});
  factory XCMV4NoteUnlockable.deserializeJson(Map<String, dynamic> json) {
    return XCMV4NoteUnlockable(
      asset: XCMV4Asset.deserializeJson(json.valueAs("asset")),
      owner: XCMV4Location.deserializeJson(json.valueAs("owner")),
    );
  }
  factory XCMV4NoteUnlockable.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.noteUnlockable.type);
    return XCMV4NoteUnlockable(
        asset: XCMV4Asset.fromJson(data.valueAs("asset")),
        owner: XCMV4Location.fromJson(data.valueAs("owner")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Asset.layout_(property: "asset"),
      XCMV4Location.layout_(property: "owner")
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

class XCMV4RequestUnlock extends XCMInstructionV4 with XCMRequestUnlock {
  @override
  final XCMV4Asset asset;
  @override
  final XCMV4Location locker;
  XCMV4RequestUnlock({required this.asset, required this.locker});
  factory XCMV4RequestUnlock.deserializeJson(Map<String, dynamic> json) {
    return XCMV4RequestUnlock(
      asset: XCMV4Asset.deserializeJson(json.valueAs("asset")),
      locker: XCMV4Location.deserializeJson(json.valueAs("locker")),
    );
  }
  factory XCMV4RequestUnlock.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.requestUnlock.type);
    return XCMV4RequestUnlock(
        asset: XCMV4Asset.fromJson(data.valueAs("asset")),
        locker: XCMV4Location.fromJson(data.valueAs("locker")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Asset.layout_(property: "asset"),
      XCMV4Location.layout_(property: "locker")
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

class XCMV4SetFeesMode extends XCMInstructionV4 with XCMSetFeesMode {
  @override
  final bool jitWithdraw;
  XCMV4SetFeesMode({required this.jitWithdraw});
  factory XCMV4SetFeesMode.deserializeJson(Map<String, dynamic> json) {
    return XCMV4SetFeesMode(jitWithdraw: json.valueAs("jit_withdraw"));
  }
  factory XCMV4SetFeesMode.fromJson(Map<String, dynamic> json) {
    return XCMV4SetFeesMode(
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

class XCMV4SetTopic extends XCMInstructionV4 with XCMSetTopic {
  @override
  final List<int> topic;
  XCMV4SetTopic({required List<int> topic})
      : topic = topic
            .exc(SubstrateAddressUtils.addressBytesLength)
            .asImmutableBytes;
  factory XCMV4SetTopic.deserializeJson(Map<String, dynamic> json) {
    return XCMV4SetTopic(topic: json.valueAsBytes("topic"));
  }
  factory XCMV4SetTopic.fromJson(Map<String, dynamic> json) {
    return XCMV4SetTopic(
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

class XCMV4ClearTopic extends XCMInstructionV4
    with SubstrateVariantNoArgs, XCMClearTopic {
  const XCMV4ClearTopic();
  factory XCMV4ClearTopic.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearTopic.type);
    return XCMV4ClearTopic();
  }
}

class XCMV4AliasOrigin extends XCMInstructionV4 with XCMAliasOrigin {
  @override
  final XCMV4Location origin;
  XCMV4AliasOrigin({required this.origin});
  factory XCMV4AliasOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AliasOrigin(
        origin: XCMV4Location.deserializeJson(json.valueAs("origin")));
  }
  factory XCMV4AliasOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV4AliasOrigin(
        origin: XCMV4Location.fromJson(
            json.valueAs(XCMInstructionType.aliasOrigin.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Location.layout_(property: "origin"),
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

class XCMV4UnpaidExecution extends XCMInstructionV4 with XCMUnpaidExecution {
  @override
  final XCMV3WeightLimit weightLimit;
  @override
  final XCMV4Location? checkOrigin;
  XCMV4UnpaidExecution({required this.weightLimit, this.checkOrigin});
  factory XCMV4UnpaidExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV4UnpaidExecution(
        weightLimit:
            XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit")),
        checkOrigin: json.valueTo<XCMV4Location?, Map<String, dynamic>>(
            key: "check_origin",
            parse: (v) => XCMV4Location.deserializeJson(v)));
  }
  factory XCMV4UnpaidExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap(XCMInstructionType.unpaidExecution.type);
    final Map<String, dynamic>? checkOrigin =
        MetadataUtils.parseOptional(json.valueAs("check_origin"));
    return XCMV4UnpaidExecution(
        weightLimit: XCMV3WeightLimit.fromJson(data.valueAs("weight_limit")),
        checkOrigin:
            checkOrigin == null ? null : XCMV4Location.fromJson(checkOrigin));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3WeightLimit.layout_(property: "weight_limit"),
      LayoutConst.optional(XCMV4Location.layout_(property: "check_origin")),
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

enum XCMV4ResponseType {
  nullResponse("Null"),
  assets("Assets"),
  executionResult("ExecutionResult"),
  version("Version"),
  palletsInfo("PalletsInfo"),
  dispatchResult("DispatchResult");

  const XCMV4ResponseType(this.type);
  final String type;

  static XCMV4ResponseType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV4ResponseType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV4Response extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV4ResponseType get type;
  const XCMV4Response();
  factory XCMV4Response.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV4ResponseType.fromName(decode.variantName);
    return switch (type) {
      XCMV4ResponseType.nullResponse => XCMV4ResponseNull(),
      XCMV4ResponseType.assets =>
        XCMV4ResponseAssets.deserializeJson(decode.value),
      XCMV4ResponseType.executionResult =>
        XCMV4ResponseExecutionResult.deserializeJson(decode.value),
      XCMV4ResponseType.version =>
        XCMV4ResponseVersion.deserializeJson(decode.value),
      XCMV4ResponseType.palletsInfo =>
        XCMV4ResponsePalletsInfo.deserializeJson(decode.value),
      XCMV4ResponseType.dispatchResult =>
        XCMV4ResponseDispatchResult.deserializeJson(decode.value),
    };
  }
  factory XCMV4Response.fromJson(Map<String, dynamic> json) {
    final type = XCMV4ResponseType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV4ResponseType.nullResponse => XCMV4ResponseNull(),
      XCMV4ResponseType.assets => XCMV4ResponseAssets.fromJson(json),
      XCMV4ResponseType.executionResult =>
        XCMV4ResponseExecutionResult.fromJson(json),
      XCMV4ResponseType.version => XCMV4ResponseVersion.fromJson(json),
      XCMV4ResponseType.palletsInfo => XCMV4ResponsePalletsInfo.fromJson(json),
      XCMV4ResponseType.dispatchResult =>
        XCMV4ResponseDispatchResult.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMV4ResponseType.nullResponse.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4ResponseAssets.layout_(property: property),
        property: XCMV4ResponseType.assets.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ResponseExecutionResult.layout_(property: property),
        property: XCMV4ResponseType.executionResult.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ResponseVersion.layout_(property: property),
        property: XCMV4ResponseType.version.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ResponsePalletsInfo.layout_(property: property),
        property: XCMV4ResponseType.palletsInfo.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4ResponseDispatchResult.layout_(property: property),
        property: XCMV4ResponseType.dispatchResult.name,
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
  Map<String, dynamic> toJson();
  @override
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4ResponseNull extends XCMV4Response with SubstrateVariantNoArgs {
  XCMV4ResponseNull();
  factory XCMV4ResponseNull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV3ResponseType.nullResponse.type);
    return XCMV4ResponseNull();
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV4ResponseType get type => XCMV4ResponseType.nullResponse;

  @override
  List get variabels => [type];
}

class XCMV4ResponseAssets extends XCMV4Response {
  final XCMV4Assets assets;
  XCMV4ResponseAssets({required this.assets});

  factory XCMV4ResponseAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ResponseAssets(
        assets: XCMV4Assets.deserializeJson(json["assets"]));
  }
  factory XCMV4ResponseAssets.fromJson(Map<String, dynamic> json) {
    final assets = json
        .valueEnsureAsList<Map<String, dynamic>>(XCMV3ResponseType.assets.type);
    return XCMV4ResponseAssets(
        assets: XCMV4Assets(
            assets: assets.map((e) => XCMV4Asset.fromJson(e)).toList()));
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

  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  XCMV4ResponseType get type => XCMV4ResponseType.assets;

  @override
  List get variabels => [type, assets];
}

class XCMV4ResponseExecutionResult extends XCMV4Response {
  final int? index;
  final XCMV3Error? error;
  XCMV4ResponseExecutionResult({int? index, this.error})
      : index = index?.asUint32;

  factory XCMV4ResponseExecutionResult.deserializeJson(
      Map<String, dynamic> json) {
    final error = json["error"];
    if (error == null) return XCMV4ResponseExecutionResult();
    return XCMV4ResponseExecutionResult(
        index: IntUtils.parse(error["index"]),
        error: XCMV3Error.deserializeJson(error["error"]));
  }
  factory XCMV4ResponseExecutionResult.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMV3ResponseType.executionResult.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV4ResponseExecutionResult();
    return XCMV4ResponseExecutionResult(
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
  XCMV4ResponseType get type => XCMV4ResponseType.executionResult;
  @override
  List get variabels => [type, error, index];
}

class XCMV4ResponseVersion extends XCMV4Response {
  final int versionNumber;
  XCMV4ResponseVersion({required int version})
      : versionNumber = version.asUint32;
  factory XCMV4ResponseVersion.fromJson(Map<String, dynamic> json) {
    return XCMV4ResponseVersion(
        version: json.valueAs(XCMV3ResponseType.version.type));
  }

  factory XCMV4ResponseVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ResponseVersion(version: IntUtils.parse(json["version"]));
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
  Map<String, dynamic> toJson() {
    return {type.type: versionNumber};
  }

  @override
  XCMV4ResponseType get type => XCMV4ResponseType.version;
  @override
  List get variabels => [type, versionNumber];
}

class XCMV4ResponsePalletsInfo extends XCMV4Response {
  final List<XCMPalletInfo> pallets;
  XCMV4ResponsePalletsInfo({required List<XCMPalletInfo> pallets})
      : pallets = pallets.max(_XCMV4Constants.maxPalletInfo).immutable;

  factory XCMV4ResponsePalletsInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ResponsePalletsInfo(
        pallets: (json.valueEnsureAsList<Map<String, dynamic>>("pallets"))
            .map((e) => XCMPalletInfo.deserializeJson(e))
            .toList());
  }
  factory XCMV4ResponsePalletsInfo.fromJson(Map<String, dynamic> json) {
    final pallets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMV3ResponseType.palletsInfo.type);
    return XCMV4ResponsePalletsInfo(
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
  XCMV4ResponseType get type => XCMV4ResponseType.palletsInfo;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: pallets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, pallets];
}

class XCMV4ResponseDispatchResult extends XCMV4Response {
  final XCMV3MaybeErrorCode error;
  XCMV4ResponseDispatchResult({required this.error});

  factory XCMV4ResponseDispatchResult.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4ResponseDispatchResult(
        error: XCMV3MaybeErrorCode.deserializeJson(
            json.valueEnsureAsMap("error")));
  }
  factory XCMV4ResponseDispatchResult.fromJson(Map<String, dynamic> json) {
    return XCMV4ResponseDispatchResult(
        error: XCMV3MaybeErrorCode.fromJson(
            json.valueAs(XCMV3ResponseType.dispatchResult.type)));
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
  XCMV4ResponseType get type => XCMV4ResponseType.dispatchResult;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: error.toJson()};
  }

  @override
  List get variabels => [type, error];
}

class XCMV4QueryResponseInfo
    extends SubstrateSerialization<Map<String, dynamic>> with Equality {
  final XCMV4Location destination;
  final BigInt queryId;
  final SubstrateWeightV2 maxWeight;

  XCMV4QueryResponseInfo(
      {required this.destination,
      required BigInt queryId,
      required this.maxWeight})
      : queryId = queryId.asUint64;
  factory XCMV4QueryResponseInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMV4QueryResponseInfo(
        destination: XCMV4Location.deserializeJson(json.valueAs("destination")),
        queryId: json.valueAs("query_id"),
        maxWeight:
            SubstrateWeightV2.deserializeJson(json.valueAs("max_weight")));
  }

  factory XCMV4QueryResponseInfo.fromJson(Map<String, dynamic> json) {
    return XCMV4QueryResponseInfo(
        destination: XCMV4Location.fromJson(json.valueAs("destination")),
        queryId: json.valueAs("query_id"),
        maxWeight: SubstrateWeightV2.fromJson(json.valueAs("max_weight")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4Location.layout_(property: "destination"),
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
}

class XCMV4 extends SubstrateSerialization<Map<String, dynamic>>
    with XCM<XCMInstructionV4>, Equality {
  @override
  final List<XCMInstructionV4> instructions;

  XCMV4({required List<XCMInstructionV4> instructions})
      : instructions = instructions.immutable;
  factory XCMV4.deserializeJson(Map<String, dynamic> json) {
    return XCMV4(
        instructions: json
            .valueEnsureAsList<Map<String, dynamic>>("instructions")
            .map((e) => XCMInstructionV4.deserializeJson(e))
            .toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMInstructionV4.layout_(),
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
  XCMVersion get version => XCMVersion.v4;
  @override
  List get variabels => [version, instructions];
}
