import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

class _XCMV5Constants {
  static const int maxPalletInfo = 64;
  static const int maxAssetTransferFilters = 6;
}

abstract class XCMInstructionV5 extends SubstrateVariantSerialization
    with XCMInstruction, Equality {
  const XCMInstructionV5();

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMV5WithdrawAsset.layout_(property: property),
        property: XCMInstructionType.withdrawAsset.name,
        index: XCMInstructionType.withdrawAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ReserveAssetDeposited.layout_(property: property),
        property: XCMInstructionType.reserveAssetDeposited.name,
        index: XCMInstructionType.reserveAssetDeposited.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ReceiveTeleportedAsset.layout_(property: property),
        property: XCMInstructionType.receiveTeleportedAsset.name,
        index: XCMInstructionType.receiveTeleportedAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5QueryResponse.layout_(property: property),
        property: XCMInstructionType.queryResponse.name,
        index: XCMInstructionType.queryResponse.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5TransferAsset.layout_(property: property),
        property: XCMInstructionType.transferAsset.name,
        index: XCMInstructionType.transferAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5TransferReserveAsset.layout_(property: property),
        property: XCMInstructionType.transferReserveAsset.name,
        index: XCMInstructionType.transferReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5Transact.layout_(property: property),
        property: XCMInstructionType.transact.name,
        index: XCMInstructionType.transact.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5HrmpNewChannelOpenRequest.layout_(property: property),
        property: XCMInstructionType.hrmpNewChannelOpenRequest.name,
        index: XCMInstructionType.hrmpNewChannelOpenRequest.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5HrmpChannelAccepted.layout_(property: property),
        property: XCMInstructionType.hrmpChannelAccepted.name,
        index: XCMInstructionType.hrmpChannelAccepted.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5HrmpChannelClosing.layout_(property: property),
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
        layout: ({property}) => XCMV5DescendOrigin.layout_(property: property),
        property: XCMInstructionType.descendOrigin.name,
        index: XCMInstructionType.descendOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ReportError.layout_(property: property),
        property: XCMInstructionType.reportError.name,
        index: XCMInstructionType.reportError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5DepositAsset.layout_(property: property),
        property: XCMInstructionType.depositAsset.name,
        index: XCMInstructionType.depositAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5DepositReserveAsset.layout_(property: property),
        property: XCMInstructionType.depositReserveAsset.name,
        index: XCMInstructionType.depositReserveAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ExchangeAsset.layout_(property: property),
        property: XCMInstructionType.exchangeAsset.name,
        index: XCMInstructionType.exchangeAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5InitiateReserveWithdraw.layout_(property: property),
        property: XCMInstructionType.initiateReserveWithdraw.name,
        index: XCMInstructionType.initiateReserveWithdraw.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5InitiateTeleport.layout_(property: property),
        property: XCMInstructionType.initiateTeleport.name,
        index: XCMInstructionType.initiateTeleport.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ReportHolding.layout_(property: property),
        property: XCMInstructionType.reportHolding.name,
        index: XCMInstructionType.reportHolding.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5BuyExecution.layout_(property: property),
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
            XCMV5SetErrorHandler.layout_(property: property),
        property: XCMInstructionType.setErrorHandler.name,
        index: XCMInstructionType.setErrorHandler.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5SetAppendix.layout_(property: property),
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
        layout: ({property}) => XCMV5ClaimAsset.layout_(property: property),
        property: XCMInstructionType.claimAsset.name,
        index: XCMInstructionType.claimAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5Trap.layout_(property: property),
        property: XCMInstructionType.trap.name,
        index: XCMInstructionType.trap.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5SubscribeVersion.layout_(property: property),
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
        layout: ({property}) => XCMV5BurnAsset.layout_(property: property),
        property: XCMInstructionType.burnAsset.name,
        index: XCMInstructionType.burnAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ExpectAsset.layout_(property: property),
        property: XCMInstructionType.expectAsset.name,
        index: XCMInstructionType.expectAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ExpectOrigin.layout_(property: property),
        property: XCMInstructionType.expectOrigin.name,
        index: XCMInstructionType.expectOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ExpectError.layout_(property: property),
        property: XCMInstructionType.expectError.name,
        index: XCMInstructionType.expectError.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ExpectTransactStatus.layout_(property: property),
        property: XCMInstructionType.expectTransactStatus.name,
        index: XCMInstructionType.expectTransactStatus.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5QueryPallet.layout_(property: property),
        property: XCMInstructionType.queryPallet.name,
        index: XCMInstructionType.queryPallet.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ExpectPallet.layout_(property: property),
        property: XCMInstructionType.expectPallet.name,
        index: XCMInstructionType.expectPallet.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ReportTransactStatus.layout_(property: property),
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
            XCMV5UniversalOrigin.layout_(property: property),
        property: XCMInstructionType.universalOrigin.name,
        index: XCMInstructionType.universalOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ExportMessage.layout_(property: property),
        property: XCMInstructionType.exportMessage.name,
        index: XCMInstructionType.exportMessage.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5LockAsset.layout_(property: property),
        property: XCMInstructionType.lockAsset.name,
        index: XCMInstructionType.lockAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5UnlockAsset.layout_(property: property),
        property: XCMInstructionType.unlockAsset.name,
        index: XCMInstructionType.unlockAsset.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5NoteUnlockable.layout_(property: property),
        property: XCMInstructionType.noteUnlockable.name,
        index: XCMInstructionType.noteUnlockable.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5RequestUnlock.layout_(property: property),
        property: XCMInstructionType.requestUnlock.name,
        index: XCMInstructionType.requestUnlock.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5SetFeesMode.layout_(property: property),
        property: XCMInstructionType.setFeesMode.name,
        index: XCMInstructionType.setFeesMode.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5SetTopic.layout_(property: property),
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
        layout: ({property}) => XCMV5AliasOrigin.layout_(property: property),
        property: XCMInstructionType.aliasOrigin.name,
        index: XCMInstructionType.aliasOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5UnpaidExecution.layout_(property: property),
        property: XCMInstructionType.unpaidExecution.name,
        index: XCMInstructionType.unpaidExecution.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5PayFees.layout_(property: property),
        property: XCMInstructionType.payFees.name,
        index: XCMInstructionType.payFees.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5InitiateTransfer.layout_(property: property),
        property: XCMInstructionType.initiateTransfer.name,
        index: XCMInstructionType.initiateTransfer.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ExecuteWithOrigin.layout_(property: property),
        property: XCMInstructionType.executeWithOrigin.name,
        index: XCMInstructionType.executeWithOrigin.variantIndex,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5SetHints.layout_(property: property),
        property: XCMInstructionType.setHints.name,
        index: XCMInstructionType.setHints.variantIndex,
      ),
    ]);
  }

  factory XCMInstructionV5.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMInstructionType.fromName(decode.variantName);
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV5WithdrawAsset.deserializeJson(decode.value),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV5ReserveAssetDeposited.deserializeJson(decode.value),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV5ReceiveTeleportedAsset.deserializeJson(decode.value),
      XCMInstructionType.queryResponse =>
        XCMV5QueryResponse.deserializeJson(decode.value),
      XCMInstructionType.transferAsset =>
        XCMV5TransferAsset.deserializeJson(decode.value),
      XCMInstructionType.transferReserveAsset =>
        XCMV5TransferReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.transact =>
        XCMV5Transact.deserializeJson(decode.value),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV5HrmpNewChannelOpenRequest.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV5HrmpChannelAccepted.deserializeJson(decode.value),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV5HrmpChannelClosing.deserializeJson(decode.value),
      XCMInstructionType.clearOrigin => XCMV5ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV5DescendOrigin.deserializeJson(decode.value),
      XCMInstructionType.reportError =>
        XCMV5ReportError.deserializeJson(decode.value),
      XCMInstructionType.depositAsset =>
        XCMV5DepositAsset.deserializeJson(decode.value),
      XCMInstructionType.depositReserveAsset =>
        XCMV5DepositReserveAsset.deserializeJson(decode.value),
      XCMInstructionType.exchangeAsset =>
        XCMV5ExchangeAsset.deserializeJson(decode.value),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV5InitiateReserveWithdraw.deserializeJson(decode.value),
      XCMInstructionType.initiateTeleport =>
        XCMV5InitiateTeleport.deserializeJson(decode.value),
      XCMInstructionType.reportHolding =>
        XCMV5ReportHolding.deserializeJson(decode.value),
      XCMInstructionType.buyExecution =>
        XCMV5BuyExecution.deserializeJson(decode.value),
      XCMInstructionType.refundSurplus => XCMV5RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV5SetErrorHandler.deserializeJson(decode.value),
      XCMInstructionType.setAppendix =>
        XCMV5SetAppendix.deserializeJson(decode.value),
      XCMInstructionType.clearError => XCMV5ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV5ClaimAsset.deserializeJson(decode.value),
      XCMInstructionType.trap => XCMV5Trap.deserializeJson(decode.value),
      XCMInstructionType.subscribeVersion =>
        XCMV5SubscribeVersion.deserializeJson(decode.value),
      XCMInstructionType.unsubscribeVersion => XCMV5UnsubscribeVersion(),
      XCMInstructionType.burnAsset =>
        XCMV5BurnAsset.deserializeJson(decode.value),
      XCMInstructionType.expectAsset =>
        XCMV5ExpectAsset.deserializeJson(decode.value),
      XCMInstructionType.expectOrigin =>
        XCMV5ExpectOrigin.deserializeJson(decode.value),
      XCMInstructionType.expectError =>
        XCMV5ExpectError.deserializeJson(decode.value),
      XCMInstructionType.expectTransactStatus =>
        XCMV5ExpectTransactStatus.deserializeJson(decode.value),
      XCMInstructionType.queryPallet =>
        XCMV5QueryPallet.deserializeJson(decode.value),
      XCMInstructionType.expectPallet =>
        XCMV5ExpectPallet.deserializeJson(decode.value),
      XCMInstructionType.reportTransactStatus =>
        XCMV5ReportTransactStatus.deserializeJson(decode.value),
      XCMInstructionType.clearTransactStatus => XCMV5ClearTransactStatus(),
      XCMInstructionType.universalOrigin =>
        XCMV5UniversalOrigin.deserializeJson(decode.value),
      XCMInstructionType.exportMessage =>
        XCMV5ExportMessage.deserializeJson(decode.value),
      XCMInstructionType.lockAsset =>
        XCMV5LockAsset.deserializeJson(decode.value),
      XCMInstructionType.unlockAsset =>
        XCMV5UnlockAsset.deserializeJson(decode.value),
      XCMInstructionType.noteUnlockable =>
        XCMV5NoteUnlockable.deserializeJson(decode.value),
      XCMInstructionType.requestUnlock =>
        XCMV5RequestUnlock.deserializeJson(decode.value),
      XCMInstructionType.setFeesMode =>
        XCMV5SetFeesMode.deserializeJson(decode.value),
      XCMInstructionType.setTopic =>
        XCMV5SetTopic.deserializeJson(decode.value),
      XCMInstructionType.clearTopic => XCMV5ClearTopic(),
      XCMInstructionType.aliasOrigin =>
        XCMV5AliasOrigin.deserializeJson(decode.value),
      XCMInstructionType.unpaidExecution =>
        XCMV5UnpaidExecution.deserializeJson(decode.value),
      XCMInstructionType.payFees => XCMV5PayFees.deserializeJson(decode.value),
      XCMInstructionType.initiateTransfer =>
        XCMV5InitiateTransfer.deserializeJson(decode.value),
      XCMInstructionType.executeWithOrigin =>
        XCMV5ExecuteWithOrigin.deserializeJson(decode.value),
      XCMInstructionType.setHints =>
        XCMV5SetHints.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsupported xcm instruction by version 5.",
          details: {"type": type.type})
    };
  }
  factory XCMInstructionV5.fromJson(Map<String, dynamic> json) {
    final type = XCMInstructionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMInstructionType.withdrawAsset => XCMV5WithdrawAsset.fromJson(json),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV5ReserveAssetDeposited.fromJson(json),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV5ReceiveTeleportedAsset.fromJson(json),
      XCMInstructionType.queryResponse => XCMV5QueryResponse.fromJson(json),
      XCMInstructionType.transferAsset => XCMV5TransferAsset.fromJson(json),
      XCMInstructionType.transferReserveAsset =>
        XCMV5TransferReserveAsset.fromJson(json),
      XCMInstructionType.transact => XCMV5Transact.fromJson(json),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV5HrmpNewChannelOpenRequest.fromJson(json),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV5HrmpChannelAccepted.fromJson(json),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV5HrmpChannelClosing.fromJson(json),
      XCMInstructionType.clearOrigin => XCMV5ClearOrigin.fromJson(json),
      XCMInstructionType.descendOrigin => XCMV5DescendOrigin.fromJson(json),
      XCMInstructionType.reportError => XCMV5ReportError.fromJson(json),
      XCMInstructionType.depositAsset => XCMV5DepositAsset.fromJson(json),
      XCMInstructionType.depositReserveAsset =>
        XCMV5DepositReserveAsset.fromJson(json),
      XCMInstructionType.exchangeAsset => XCMV5ExchangeAsset.fromJson(json),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV5InitiateReserveWithdraw.fromJson(json),
      XCMInstructionType.initiateTeleport =>
        XCMV5InitiateTeleport.fromJson(json),
      XCMInstructionType.reportHolding => XCMV5ReportHolding.fromJson(json),
      XCMInstructionType.buyExecution => XCMV5BuyExecution.fromJson(json),
      XCMInstructionType.refundSurplus => XCMV5RefundSurplus.fromJson(json),
      XCMInstructionType.setErrorHandler => XCMV5SetErrorHandler.fromJson(json),
      XCMInstructionType.setAppendix => XCMV5SetAppendix.fromJson(json),
      XCMInstructionType.clearError => XCMV5ClearError.fromJson(json),
      XCMInstructionType.claimAsset => XCMV5ClaimAsset.fromJson(json),
      XCMInstructionType.trap => XCMV5Trap.fromJson(json),
      XCMInstructionType.subscribeVersion =>
        XCMV5SubscribeVersion.fromJson(json),
      XCMInstructionType.unsubscribeVersion =>
        XCMV5UnsubscribeVersion.fromJson(json),
      XCMInstructionType.burnAsset => XCMV5BurnAsset.fromJson(json),
      XCMInstructionType.expectAsset => XCMV5ExpectAsset.fromJson(json),
      XCMInstructionType.expectOrigin => XCMV5ExpectOrigin.fromJson(json),
      XCMInstructionType.expectError => XCMV5ExpectError.fromJson(json),
      XCMInstructionType.expectTransactStatus =>
        XCMV5ExpectTransactStatus.fromJson(json),
      XCMInstructionType.queryPallet => XCMV5QueryPallet.fromJson(json),
      XCMInstructionType.expectPallet => XCMV5ExpectPallet.fromJson(json),
      XCMInstructionType.reportTransactStatus =>
        XCMV5ReportTransactStatus.fromJson(json),
      XCMInstructionType.clearTransactStatus =>
        XCMV5ClearTransactStatus.fromJson(json),
      XCMInstructionType.universalOrigin => XCMV5UniversalOrigin.fromJson(json),
      XCMInstructionType.exportMessage => XCMV5ExportMessage.fromJson(json),
      XCMInstructionType.lockAsset => XCMV5LockAsset.fromJson(json),
      XCMInstructionType.unlockAsset => XCMV5UnlockAsset.fromJson(json),
      XCMInstructionType.noteUnlockable => XCMV5NoteUnlockable.fromJson(json),
      XCMInstructionType.requestUnlock => XCMV5RequestUnlock.fromJson(json),
      XCMInstructionType.setFeesMode => XCMV5SetFeesMode.fromJson(json),
      XCMInstructionType.setTopic => XCMV5SetTopic.fromJson(json),
      XCMInstructionType.clearTopic => XCMV5ClearTopic.fromJson(json),
      XCMInstructionType.aliasOrigin => XCMV5AliasOrigin.fromJson(json),
      XCMInstructionType.unpaidExecution => XCMV5UnpaidExecution.fromJson(json),
      XCMInstructionType.payFees => XCMV5PayFees.fromJson(json),
      XCMInstructionType.initiateTransfer =>
        XCMV5InitiateTransfer.fromJson(json),
      XCMInstructionType.executeWithOrigin =>
        XCMV5ExecuteWithOrigin.fromJson(json),
      XCMInstructionType.setHints => XCMV5SetHints.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsupported xcm instruction by version 5.",
          details: {"type": type.type})
    };
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5WithdrawAsset extends XCMInstructionV5 with XCMWithdrawAsset {
  @override
  final XCMV5Assets assets;
  XCMV5WithdrawAsset({required this.assets});
  factory XCMV5WithdrawAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5WithdrawAsset(
        assets: XCMV5Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV5WithdrawAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.withdrawAsset.type);

    return XCMV5WithdrawAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
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

class XCMV5ReserveAssetDeposited extends XCMInstructionV5
    with XCMReserveAssetDeposited {
  @override
  final XCMV5Assets assets;
  XCMV5ReserveAssetDeposited({required this.assets});
  factory XCMV5ReserveAssetDeposited.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5ReserveAssetDeposited(
        assets: XCMV5Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV5ReserveAssetDeposited.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.reserveAssetDeposited.type);
    return XCMV5ReserveAssetDeposited(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
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

class XCMV5ReceiveTeleportedAsset extends XCMInstructionV5
    with XCMReceiveTeleportedAsset {
  @override
  final XCMV5Assets assets;
  XCMV5ReceiveTeleportedAsset({required this.assets});
  factory XCMV5ReceiveTeleportedAsset.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5ReceiveTeleportedAsset(
        assets: XCMV5Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV5ReceiveTeleportedAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.receiveTeleportedAsset.type);
    return XCMV5ReceiveTeleportedAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
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

class XCMV5QueryResponse extends XCMInstructionV5 with XCMQueryResponse {
  final BigInt queryId;
  final XCMV5Response response;
  final SubstrateWeightV2 maxWeight;
  final XCMV5Location? querier;

  XCMV5QueryResponse(
      {required this.queryId,
      required this.response,
      required this.maxWeight,
      required this.querier});
  factory XCMV5QueryResponse.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.queryResponse.type);
    final Map<String, dynamic>? querier =
        MetadataUtils.parseOptional(data.valueAs("querier"));
    return XCMV5QueryResponse(
        queryId: data.valueAs("query_id"),
        response: XCMV5Response.fromJson(data.valueAs("response")),
        maxWeight: SubstrateWeightV2.fromJson(data.valueAs("max_weight")),
        querier: querier == null ? null : XCMV5Location.fromJson(querier));
  }

  factory XCMV5QueryResponse.deserializeJson(Map<String, dynamic> json) {
    return XCMV5QueryResponse(
        queryId: json.valueAs("query_id"),
        response: XCMV5Response.deserializeJson(json.valueAs("response")),
        maxWeight:
            SubstrateWeightV2.deserializeJson(json.valueAs("max_weight")),
        querier: json.valueTo<XCMV5Location?, Map<String, dynamic>>(
            key: "querier", parse: (v) => XCMV5Location.deserializeJson(v)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "query_id"),
      XCMV5Response.layout_(property: "response"),
      SubstrateWeightV2.layout_(property: "max_weight"),
      LayoutConst.optional(XCMV5Location.layout_(), property: "querier")
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

class XCMV5TransferAsset extends XCMInstructionV5 with XCMTransferAsset {
  @override
  final XCMV5Assets assets;
  @override
  final XCMV5Location beneficiary;
  XCMV5TransferAsset({required this.assets, required this.beneficiary});
  factory XCMV5TransferAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5TransferAsset(
      assets: XCMV5Assets.deserializeJson(json.valueAs("assets")),
      beneficiary: XCMV5Location.deserializeJson(json.valueAs("beneficiary")),
    );
  }
  factory XCMV5TransferAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV5TransferAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()),
        beneficiary: XCMV5Location.fromJson(data.valueAs("beneficiary")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Assets.layout_(property: "assets"),
      XCMV5Location.layout_(property: "beneficiary")
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

class XCMV5TransferReserveAsset extends XCMInstructionV5
    with XCMTransferReserveAsset {
  @override
  final XCMV5Assets assets;
  @override
  final XCMV5Location dest;
  @override
  final XCMV5 xcm;
  XCMV5TransferReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV5TransferReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5TransferReserveAsset(
        assets: XCMV5Assets.deserializeJson(json.valueAs("assets")),
        dest: XCMV5Location.deserializeJson(json.valueAs("dest")),
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }

  factory XCMV5TransferReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.transferReserveAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV5TransferReserveAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()),
        dest: XCMV5Location.fromJson(data.valueAs("dest")),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Assets.layout_(property: "assets"),
      XCMV5Location.layout_(property: "dest"),
      XCMV5.layout_(property: "xcm")
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

class XCMV5Transact extends XCMInstructionV5 with XCMTransact {
  final XCMV3OriginKind originKind;
  final SubstrateWeightV2? fallBackMaxWeight;
  @override
  final List<int> call;
  XCMV5Transact(
      {required this.originKind,
      required this.fallBackMaxWeight,
      required List<int> call})
      : call = call.asImmutableBytes;
  factory XCMV5Transact.deserializeJson(Map<String, dynamic> json) {
    return XCMV5Transact(
        originKind:
            XCMV3OriginKind.deserializeJson(json.valueAs("origin_kind")),
        fallBackMaxWeight:
            json.valueTo<SubstrateWeightV2?, Map<String, dynamic>>(
          key: "fallback_max_weight",
          parse: (v) => SubstrateWeightV2.deserializeJson(v),
        ),
        call: json.valueAsBytes("call"));
  }
  factory XCMV5Transact.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.transact.type);
    final optWeight =
        data.valueEnsureAsMap<String, dynamic>("fallback_max_weight");
    final Map<String, dynamic>? weight = MetadataUtils.parseOptional(optWeight);
    return XCMV5Transact(
        originKind: XCMV3OriginKind.fromJson(data.valueAs("origin_kind")),
        fallBackMaxWeight:
            weight == null ? null : SubstrateWeightV2.fromJson(weight),
        call: data
            .valueEnsureAsMap<String, dynamic>("call")
            .valueAsBytes("encoded"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3OriginKind.layout_(property: "origin_kind"),
      LayoutConst.optional(SubstrateWeightV2.layout_(),
          property: "fallback_max_weight"),
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
      "fallback_max_weight": fallBackMaxWeight?.serializeJson(),
      "call": call
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "origin_kind": originKind.toJson(),
        "fallback_max_weight":
            MetadataUtils.toOptionalJson(fallBackMaxWeight?.toJson()),
        "call": {"encoded": call}
      }
    };
  }

  @override
  List get variabels => [type, originKind, fallBackMaxWeight, call];
}

class XCMV5HrmpNewChannelOpenRequest extends XCMInstructionV5
    with XCMHrmpNewChannelOpenRequest {
  @override
  final int sender;
  @override
  final int maxMessageSize;
  @override
  final int maxCapacity;
  XCMV5HrmpNewChannelOpenRequest(
      {required int sender,
      required int maxMessageSize,
      required int maxCapacity})
      : sender = sender.asUint32,
        maxMessageSize = maxMessageSize.asUint32,
        maxCapacity = maxCapacity.asUint32;
  factory XCMV5HrmpNewChannelOpenRequest.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5HrmpNewChannelOpenRequest(
        sender: json.valueAs("sender"),
        maxCapacity: json.valueAs("max_capacity"),
        maxMessageSize: json.valueAs("max_message_size"));
  }
  factory XCMV5HrmpNewChannelOpenRequest.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpNewChannelOpenRequest.type);
    return XCMV5HrmpNewChannelOpenRequest(
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

class XCMV5HrmpChannelAccepted extends XCMInstructionV5
    with XCMHrmpChannelAccepted {
  @override
  final int recipient;

  XCMV5HrmpChannelAccepted({required int recipient})
      : recipient = recipient.asUint32;
  factory XCMV5HrmpChannelAccepted.deserializeJson(Map<String, dynamic> json) {
    return XCMV5HrmpChannelAccepted(recipient: json.valueAs("recipient"));
  }
  factory XCMV5HrmpChannelAccepted.fromJson(Map<String, dynamic> json) {
    return XCMV5HrmpChannelAccepted(
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

class XCMV5HrmpChannelClosing extends XCMInstructionV5
    with XCMHrmpChannelClosing {
  @override
  final int initiator;
  @override
  final int sender;
  @override
  final int recipient;
  XCMV5HrmpChannelClosing(
      {required int sender, required int initiator, required int recipient})
      : sender = sender.asUint32,
        initiator = initiator.asUint32,
        recipient = recipient.asUint32;
  factory XCMV5HrmpChannelClosing.deserializeJson(Map<String, dynamic> json) {
    return XCMV5HrmpChannelClosing(
        sender: json.valueAs("sender"),
        recipient: json.valueAs("recipient"),
        initiator: json.valueAs("initiator"));
  }
  factory XCMV5HrmpChannelClosing.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.hrmpChannelClosing.type);
    return XCMV5HrmpChannelClosing(
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

class XCMV5ClearOrigin extends XCMInstructionV5
    with SubstrateVariantNoArgs, XCMClearOrigin {
  const XCMV5ClearOrigin();
  factory XCMV5ClearOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearOrigin.type);
    return XCMV5ClearOrigin();
  }
}

class XCMV5DescendOrigin extends XCMInstructionV5 with XCMDescendOrigin {
  @override
  final XCMV5InteriorMultiLocation interior;

  XCMV5DescendOrigin({required this.interior});
  factory XCMV5DescendOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV5DescendOrigin(
        interior: XCMV5Junctions.deserializeJson(json.valueAs("interior")));
  }
  factory XCMV5DescendOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV5DescendOrigin(
        interior: XCMV5Junctions.fromJson(
            json.valueAs(XCMInstructionType.descendOrigin.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5Junctions.layout_(property: "interior")],
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

class XCMV5ReportError extends XCMInstructionV5 with XCMReportError {
  final XCMV5QueryResponseInfo responseInfo;

  XCMV5ReportError({required this.responseInfo});
  factory XCMV5ReportError.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ReportError(
        responseInfo: XCMV5QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV5ReportError.fromJson(Map<String, dynamic> json) {
    return XCMV5ReportError(
        responseInfo: XCMV5QueryResponseInfo.fromJson(
            json.valueAs(XCMInstructionType.reportError.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV5QueryResponseInfo.layout_(property: "response_info")],
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

class XCMV5DepositAsset extends XCMInstructionV5 with XCMDepositAsset {
  @override
  final XCMV5AssetFilter assets;
  @override
  final XCMV5Location beneficiary;
  XCMV5DepositAsset({required this.assets, required this.beneficiary});
  factory XCMV5DepositAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5DepositAsset(
      assets: XCMV5AssetFilter.deserializeJson(json.valueAs("assets")),
      beneficiary: XCMV5Location.deserializeJson(json.valueAs("beneficiary")),
    );
  }
  factory XCMV5DepositAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositAsset.type);
    return XCMV5DepositAsset(
        assets: XCMV5AssetFilter.fromJson(data.valueAs("assets")),
        beneficiary: XCMV5Location.fromJson(data.valueAs("beneficiary")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetFilter.layout_(property: "assets"),
      XCMV5Location.layout_(property: "beneficiary")
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

class XCMV5DepositReserveAsset extends XCMInstructionV5
    with XCMDepositReserveAsset {
  @override
  final XCMV5AssetFilter assets;
  @override
  final XCMV5Location dest;
  @override
  final XCMV5 xcm;

  XCMV5DepositReserveAsset(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV5DepositReserveAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5DepositReserveAsset(
        assets: XCMV5AssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV5Location.deserializeJson(json.valueAs("dest")),
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5DepositReserveAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.depositReserveAsset.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV5DepositReserveAsset(
        assets: XCMV5AssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV5Location.fromJson(data.valueAs("dest")),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetFilter.layout_(property: "assets"),
      XCMV5Location.layout_(property: "dest"),
      XCMV5.layout_(property: "xcm")
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

class XCMV5ExchangeAsset extends XCMInstructionV5 with XCMExchangeAsset {
  final XCMV5AssetFilter give;
  @override
  final XCMV5Assets want;
  final bool maximal;

  XCMV5ExchangeAsset(
      {required this.give, required this.want, required this.maximal});
  factory XCMV5ExchangeAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExchangeAsset(
        give: XCMV5AssetFilter.deserializeJson(json.valueAs("give")),
        want: XCMV5Assets.deserializeJson(json.valueAs("want")),
        maximal: json.valueAs("maximal"));
  }
  factory XCMV5ExchangeAsset.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exchangeAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("want");
    return XCMV5ExchangeAsset(
        want: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()),
        give: XCMV5AssetFilter.fromJson(data.valueAs("give")),
        maximal: data.valueAs("maximal"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetFilter.layout_(property: "give"),
      XCMV5Assets.layout_(property: "want"),
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

class XCMV5InitiateReserveWithdraw extends XCMInstructionV5
    with XCMInitiateReserveWithdraw {
  @override
  final XCMV5AssetFilter assets;
  @override
  final XCMV5Location reserve;
  @override
  final XCMV5 xcm;
  XCMV5InitiateReserveWithdraw(
      {required this.assets, required this.reserve, required this.xcm});
  factory XCMV5InitiateReserveWithdraw.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5InitiateReserveWithdraw(
        assets: XCMV5AssetFilter.deserializeJson(json.valueAs("assets")),
        reserve: XCMV5Location.deserializeJson(json.valueAs("reserve")),
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5InitiateReserveWithdraw.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateReserveWithdraw.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV5InitiateReserveWithdraw(
        assets: XCMV5AssetFilter.fromJson(data.valueAs("assets")),
        reserve: XCMV5Location.fromJson(data.valueAs("reserve")),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetFilter.layout_(property: "assets"),
      XCMV5Location.layout_(property: "reserve"),
      XCMV5.layout_(property: "xcm"),
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

class XCMV5InitiateTeleport extends XCMInstructionV5 with XCMInitiateTeleport {
  final XCMV5AssetFilter assets;
  @override
  final XCMV5Location dest;
  @override
  final XCMV5 xcm;
  XCMV5InitiateTeleport(
      {required this.assets, required this.dest, required this.xcm});
  factory XCMV5InitiateTeleport.deserializeJson(Map<String, dynamic> json) {
    return XCMV5InitiateTeleport(
        assets: XCMV5AssetFilter.deserializeJson(json.valueAs("assets")),
        dest: XCMV5Location.deserializeJson(json.valueAs("dest")),
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5InitiateTeleport.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateTeleport.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV5InitiateTeleport(
        assets: XCMV5AssetFilter.fromJson(data.valueAs("assets")),
        dest: XCMV5Location.fromJson(data.valueAs("dest")),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetFilter.layout_(property: "assets"),
      XCMV5Location.layout_(property: "dest"),
      XCMV5.layout_(property: "xcm")
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

class XCMV5ReportHolding extends XCMInstructionV5 with XCMReportHolding {
  final XCMV5QueryResponseInfo responseInfo;
  final XCMV5AssetFilter assets;

  XCMV5ReportHolding({required this.assets, required this.responseInfo});
  factory XCMV5ReportHolding.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ReportHolding(
        assets: XCMV5AssetFilter.deserializeJson(json.valueAs("assets")),
        responseInfo: XCMV5QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV5ReportHolding.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.reportHolding.type);
    return XCMV5ReportHolding(
        assets: XCMV5AssetFilter.fromJson(data.valueAs("assets")),
        responseInfo:
            XCMV5QueryResponseInfo.fromJson(data.valueAs("response_info")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5QueryResponseInfo.layout_(property: "response_info"),
      XCMV5AssetFilter.layout_(property: "assets"),
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

class XCMV5BuyExecution extends XCMInstructionV5 with XCMBuyExecution {
  @override
  final XCMV5Asset fees;
  @override
  final XCMV3WeightLimit weightLimit;

  XCMV5BuyExecution({required this.fees, required this.weightLimit});
  factory XCMV5BuyExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV5BuyExecution(
        fees: XCMV5Asset.deserializeJson(json.valueAs("fees")),
        weightLimit:
            XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit")));
  }
  factory XCMV5BuyExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.buyExecution.type);
    return XCMV5BuyExecution(
        fees: XCMV5Asset.fromJson(data.valueAs("fees")),
        weightLimit: XCMV3WeightLimit.fromJson(data.valueAs("weight_limit")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Asset.layout_(property: "fees"),
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

class XCMV5RefundSurplus extends XCMInstructionV5
    with SubstrateVariantNoArgs, XCMRefundSurplus {
  const XCMV5RefundSurplus();
  factory XCMV5RefundSurplus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.refundSurplus.type);
    return XCMV5RefundSurplus();
  }
  @override
  List get variabels => [type];
}

class XCMV5SetErrorHandler extends XCMInstructionV5 with XCMSetErrorHandler {
  @override
  final XCMV5 xcm;
  XCMV5SetErrorHandler({required this.xcm});
  factory XCMV5SetErrorHandler.deserializeJson(Map<String, dynamic> json) {
    return XCMV5SetErrorHandler(
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5SetErrorHandler.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setErrorHandler.type);
    return XCMV5SetErrorHandler(
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
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
  List get variabels => [type, xcm];
}

class XCMV5SetAppendix extends XCMInstructionV5 with XCMSetAppendix {
  @override
  final XCMV5 xcm;
  XCMV5SetAppendix({required this.xcm});
  factory XCMV5SetAppendix.deserializeJson(Map<String, dynamic> json) {
    return XCMV5SetAppendix(xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5SetAppendix.fromJson(Map<String, dynamic> json) {
    final xcm = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setAppendix.type);
    return XCMV5SetAppendix(
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
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
  List get variabels => [type, xcm];
}

class XCMV5ClearError extends XCMInstructionV5
    with SubstrateVariantNoArgs, XCMClearError {
  const XCMV5ClearError();
  factory XCMV5ClearError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearError.type);
    return XCMV5ClearError();
  }
  @override
  List get variabels => [type];
}

class XCMV5ClaimAsset extends XCMInstructionV5 with XCMClaimAsset {
  @override
  final XCMV5Assets assets;
  @override
  final XCMV5Location ticket;
  XCMV5ClaimAsset({required this.assets, required this.ticket});
  factory XCMV5ClaimAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ClaimAsset(
      assets: XCMV5Assets.deserializeJson(json.valueAs("assets")),
      ticket: XCMV5Location.deserializeJson(json.valueAs("ticket")),
    );
  }
  factory XCMV5ClaimAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.claimAsset.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    return XCMV5ClaimAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()),
        ticket: XCMV5Location.fromJson(data.valueAs("ticket")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Assets.layout_(property: "assets"),
      XCMV5Location.layout_(property: "ticket"),
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

  @override
  List get variabels => [type, assets, ticket];
}

class XCMV5Trap extends XCMInstructionV5 with XCMTrap {
  @override
  final BigInt trap;
  XCMV5Trap({required BigInt trap}) : trap = trap.asUint64;
  factory XCMV5Trap.deserializeJson(Map<String, dynamic> json) {
    return XCMV5Trap(trap: json.valueAs("trap"));
  }
  factory XCMV5Trap.fromJson(Map<String, dynamic> json) {
    return XCMV5Trap(trap: json.valueAs(XCMInstructionType.trap.type));
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

  @override
  List get variabels => [type, trap];
}

class XCMV5SubscribeVersion extends XCMInstructionV5 with XCMSubscribeVersion {
  @override
  final BigInt queryId;
  final SubstrateWeightV2 maxResponseWeight;
  XCMV5SubscribeVersion(
      {required BigInt queryId, required this.maxResponseWeight})
      : queryId = queryId.asUint64;
  factory XCMV5SubscribeVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV5SubscribeVersion(
        queryId: json.valueAs("query_id"),
        maxResponseWeight: SubstrateWeightV2.deserializeJson(
            json.valueAs("max_response_weight")));
  }
  factory XCMV5SubscribeVersion.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.subscribeVersion.type);
    return XCMV5SubscribeVersion(
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

class XCMV5UnsubscribeVersion extends XCMInstructionV5
    with SubstrateVariantNoArgs, XCMUnsubscribeVersion {
  const XCMV5UnsubscribeVersion();
  factory XCMV5UnsubscribeVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.unsubscribeVersion.type);
    return XCMV5UnsubscribeVersion();
  }
  @override
  List get variabels => [type];
}

class XCMV5BurnAsset extends XCMInstructionV5 with XCMBurnAsset {
  @override
  final XCMV5Assets assets;
  XCMV5BurnAsset({required this.assets});
  factory XCMV5BurnAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5BurnAsset(
      assets: XCMV5Assets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMV5BurnAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.burnAsset.type);
    return XCMV5BurnAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Assets.layout_(property: "assets"),
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

  @override
  List get variabels => [type, assets];
}

class XCMV5ExpectAsset extends XCMInstructionV5 with XCMExpectAsset {
  @override
  final XCMV5Assets assets;
  XCMV5ExpectAsset({required this.assets});
  factory XCMV5ExpectAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExpectAsset(
      assets: XCMV5Assets.deserializeJson(json.valueAs("assets")),
    );
  }
  factory XCMV5ExpectAsset.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.expectAsset.type);
    return XCMV5ExpectAsset(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Assets.layout_(property: "assets"),
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

  @override
  List get variabels => [type, assets];
}

class XCMV5ExpectOrigin extends XCMInstructionV5 with XCMExpectOrigin {
  @override
  final XCMV5Location? location;
  XCMV5ExpectOrigin({required this.location});
  factory XCMV5ExpectOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExpectOrigin(
      location: json.valueTo<XCMV5Location?, Map<String, dynamic>>(
          key: "location", parse: (v) => XCMV5Location.deserializeJson(v)),
    );
  }
  factory XCMV5ExpectOrigin.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? location = MetadataUtils.parseOptional(
        json.valueEnsureAsMap<String, dynamic>(
            XCMInstructionType.expectOrigin.type));

    return XCMV5ExpectOrigin(
        location: location == null ? null : XCMV5Location.fromJson(location));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV5Location.layout_(), property: "location"),
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

  @override
  List get variabels => [type, location];
}

class XCMV5ExpectError extends XCMInstructionV5 with XCMExpectError {
  final int? index;
  final XCMV5Error? error;

  XCMV5ExpectError({int? index, this.error}) : index = index?.asUint32;

  factory XCMV5ExpectError.deserializeJson(Map<String, dynamic> json) {
    final error = json.valueAs<Map<String, dynamic>?>("error");
    if (error == null) return XCMV5ExpectError();
    return XCMV5ExpectError(
        index: error.valueAs<int>("index"),
        error: XCMV5Error.deserializeJson(error.valueAs("error")));
  }
  factory XCMV5ExpectError.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.expectError.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV5ExpectError();
    return XCMV5ExpectError(
        index: IntUtils.parse(opt[0]), error: XCMV5Error.fromJson(opt[1]));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(
          LayoutConst.struct([
            LayoutConst.u32(property: "index"),
            XCMV5Error.layout_(property: "error")
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

class XCMV5ExpectTransactStatus extends XCMInstructionV5
    with XCMExpectTransactStatus {
  @override
  final XCMV3MaybeErrorCode code;

  XCMV5ExpectTransactStatus({required this.code});

  factory XCMV5ExpectTransactStatus.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExpectTransactStatus(
        code: XCMV3MaybeErrorCode.deserializeJson(json.valueAs("code")));
  }
  factory XCMV5ExpectTransactStatus.fromJson(Map<String, dynamic> json) {
    return XCMV5ExpectTransactStatus(
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

class XCMV5QueryPallet extends XCMInstructionV5 with XCMQueryPallet {
  @override
  final List<int> moduleName;
  final XCMV5QueryResponseInfo responseInfo;

  XCMV5QueryPallet({
    required List<int> moduleName,
    required this.responseInfo,
  }) : moduleName = moduleName.asImmutableBytes;

  factory XCMV5QueryPallet.deserializeJson(Map<String, dynamic> json) {
    return XCMV5QueryPallet(
        moduleName: json.valueAsBytes("module_name"),
        responseInfo: XCMV5QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV5QueryPallet.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.queryPallet.type);
    return XCMV5QueryPallet(
        moduleName: data.valueAsBytes("module_name"),
        responseInfo:
            XCMV5QueryResponseInfo.fromJson(data.valueAs("response_info")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.bytes(property: "module_name"),
      XCMV5QueryResponseInfo.layout_(property: "response_info")
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

class XCMV5ExpectPallet extends XCMInstructionV5 with XCMExpectPallet {
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

  XCMV5ExpectPallet({
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

  factory XCMV5ExpectPallet.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExpectPallet(
        name: json.valueAsBytes("name"),
        moduleName: json.valueAsBytes("module_name"),
        index: json.valueAs("index"),
        crateMajor: json.valueAs("crate_major"),
        minCrateMinor: json.valueAs("min_crate_minor"));
  }
  factory XCMV5ExpectPallet.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.expectPallet.type);
    return XCMV5ExpectPallet(
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

class XCMV5ReportTransactStatus extends XCMInstructionV5
    with XCMReportTransactStatus {
  final XCMV5QueryResponseInfo responseInfo;

  XCMV5ReportTransactStatus({required this.responseInfo});

  factory XCMV5ReportTransactStatus.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ReportTransactStatus(
        responseInfo: XCMV5QueryResponseInfo.deserializeJson(
            json.valueAs("response_info")));
  }
  factory XCMV5ReportTransactStatus.fromJson(Map<String, dynamic> json) {
    return XCMV5ReportTransactStatus(
        responseInfo: XCMV5QueryResponseInfo.fromJson(
            json.valueAs(XCMInstructionType.reportTransactStatus.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV5QueryResponseInfo.layout_(property: "response_info")],
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

class XCMV5ClearTransactStatus extends XCMInstructionV5
    with SubstrateVariantNoArgs, XCMClearTransactStatus {
  const XCMV5ClearTransactStatus();
  factory XCMV5ClearTransactStatus.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearTransactStatus.type);
    return XCMV5ClearTransactStatus();
  }
}

class XCMV5UniversalOrigin extends XCMInstructionV5 with XCMUniversalOrigin {
  @override
  final XCMV5Junction origin;

  XCMV5UniversalOrigin({required this.origin});

  factory XCMV5UniversalOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV5UniversalOrigin(
        origin: XCMV5Junction.deserializeJson(json.valueAs("origin")));
  }
  factory XCMV5UniversalOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV5UniversalOrigin(
        origin: XCMV5Junction.fromJson(
            json.valueAs(XCMInstructionType.universalOrigin.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5Junction.layout_(property: "origin")],
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

class XCMV5ExportMessage extends XCMInstructionV5 with XCMExportMessage {
  @override
  final XCMV5NetworkId network;
  @override
  final XCMV5InteriorMultiLocation destination;
  @override
  final XCMV5 xcm;
  XCMV5ExportMessage(
      {required this.network, required this.destination, required this.xcm});
  factory XCMV5ExportMessage.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExportMessage(
        network: XCMV5NetworkId.deserializeJson(json.valueAs("network")),
        destination:
            XCMV5Junctions.deserializeJson(json.valueAs("destination")),
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5ExportMessage.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.exportMessage.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    return XCMV5ExportMessage(
        network: XCMV5NetworkId.fromJson(data.valueAs("network")),
        destination: XCMV5Junctions.fromJson(data.valueAs("destination")),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5NetworkId.layout_(property: "network"),
      XCMV5Junctions.layout_(property: "destination"),
      XCMV5.layout_(property: "xcm")
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

class XCMV5LockAsset extends XCMInstructionV5 with XCMLockAsset {
  @override
  final XCMV5Asset asset;
  @override
  final XCMV5Location unlocker;
  XCMV5LockAsset({required this.asset, required this.unlocker});
  factory XCMV5LockAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5LockAsset(
      asset: XCMV5Asset.deserializeJson(json.valueAs("asset")),
      unlocker: XCMV5Location.deserializeJson(json.valueAs("unlocker")),
    );
  }
  factory XCMV5LockAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.lockAsset.type);
    return XCMV5LockAsset(
        asset: XCMV5Asset.fromJson(data.valueAs("asset")),
        unlocker: XCMV5Location.fromJson(data.valueAs("unlocker")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Asset.layout_(property: "asset"),
      XCMV5Location.layout_(property: "unlocker")
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

class XCMV5UnlockAsset extends XCMInstructionV5 with XCMUnlockAsset {
  @override
  final XCMV5Asset asset;
  @override
  final XCMV5Location target;
  XCMV5UnlockAsset({required this.asset, required this.target});
  factory XCMV5UnlockAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5UnlockAsset(
      asset: XCMV5Asset.deserializeJson(json.valueAs("asset")),
      target: XCMV5Location.deserializeJson(json.valueAs("target")),
    );
  }
  factory XCMV5UnlockAsset.fromJson(Map<String, dynamic> json) {
    final data = json
        .valueEnsureAsMap<String, dynamic>(XCMInstructionType.unlockAsset.type);
    return XCMV5UnlockAsset(
        asset: XCMV5Asset.fromJson(data.valueAs("asset")),
        target: XCMV5Location.fromJson(data.valueAs("target")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Asset.layout_(property: "asset"),
      XCMV5Location.layout_(property: "target")
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

class XCMV5NoteUnlockable extends XCMInstructionV5 with XCMNoteUnlockable {
  @override
  final XCMV5Asset asset;
  @override
  final XCMV5Location owner;
  XCMV5NoteUnlockable({required this.asset, required this.owner});
  factory XCMV5NoteUnlockable.deserializeJson(Map<String, dynamic> json) {
    return XCMV5NoteUnlockable(
      asset: XCMV5Asset.deserializeJson(json.valueAs("asset")),
      owner: XCMV5Location.deserializeJson(json.valueAs("owner")),
    );
  }
  factory XCMV5NoteUnlockable.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.noteUnlockable.type);
    return XCMV5NoteUnlockable(
        asset: XCMV5Asset.fromJson(data.valueAs("asset")),
        owner: XCMV5Location.fromJson(data.valueAs("owner")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Asset.layout_(property: "asset"),
      XCMV5Location.layout_(property: "owner")
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

class XCMV5RequestUnlock extends XCMInstructionV5 with XCMRequestUnlock {
  @override
  final XCMV5Asset asset;
  @override
  final XCMV5Location locker;
  XCMV5RequestUnlock({required this.asset, required this.locker});
  factory XCMV5RequestUnlock.deserializeJson(Map<String, dynamic> json) {
    return XCMV5RequestUnlock(
      asset: XCMV5Asset.deserializeJson(json.valueAs("asset")),
      locker: XCMV5Location.deserializeJson(json.valueAs("locker")),
    );
  }
  factory XCMV5RequestUnlock.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.requestUnlock.type);
    return XCMV5RequestUnlock(
        asset: XCMV5Asset.fromJson(data.valueAs("asset")),
        locker: XCMV5Location.fromJson(data.valueAs("locker")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Asset.layout_(property: "asset"),
      XCMV5Location.layout_(property: "locker")
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

class XCMV5SetFeesMode extends XCMInstructionV5 with XCMSetFeesMode {
  @override
  final bool jitWithdraw;
  XCMV5SetFeesMode({required this.jitWithdraw});
  factory XCMV5SetFeesMode.deserializeJson(Map<String, dynamic> json) {
    return XCMV5SetFeesMode(jitWithdraw: json.valueAs("jit_withdraw"));
  }
  factory XCMV5SetFeesMode.fromJson(Map<String, dynamic> json) {
    return XCMV5SetFeesMode(
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

class XCMV5SetTopic extends XCMInstructionV5 with XCMSetTopic {
  @override
  final List<int> topic;
  XCMV5SetTopic({required List<int> topic})
      : topic = topic
            .exc(SubstrateAddressUtils.addressBytesLength)
            .asImmutableBytes;
  factory XCMV5SetTopic.deserializeJson(Map<String, dynamic> json) {
    return XCMV5SetTopic(topic: json.valueAsBytes("topic"));
  }
  factory XCMV5SetTopic.fromJson(Map<String, dynamic> json) {
    return XCMV5SetTopic(
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

class XCMV5ClearTopic extends XCMInstructionV5
    with SubstrateVariantNoArgs, XCMClearTopic {
  const XCMV5ClearTopic();
  factory XCMV5ClearTopic.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMInstructionType.clearTopic.type);
    return XCMV5ClearTopic();
  }
}

class XCMV5AliasOrigin extends XCMInstructionV5 with XCMAliasOrigin {
  @override
  final XCMV5Location origin;
  XCMV5AliasOrigin({required this.origin});
  factory XCMV5AliasOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AliasOrigin(
        origin: XCMV5Location.deserializeJson(json.valueAs("origin")));
  }
  factory XCMV5AliasOrigin.fromJson(Map<String, dynamic> json) {
    return XCMV5AliasOrigin(
        origin: XCMV5Location.fromJson(
            json.valueAs(XCMInstructionType.aliasOrigin.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Location.layout_(property: "origin"),
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

class XCMV5UnpaidExecution extends XCMInstructionV5 with XCMUnpaidExecution {
  @override
  final XCMV3WeightLimit weightLimit;
  @override
  final XCMV5Location? checkOrigin;
  XCMV5UnpaidExecution({required this.weightLimit, this.checkOrigin});
  factory XCMV5UnpaidExecution.deserializeJson(Map<String, dynamic> json) {
    return XCMV5UnpaidExecution(
        weightLimit:
            XCMV3WeightLimit.deserializeJson(json.valueAs("weight_limit")),
        checkOrigin: json.valueTo<XCMV5Location?, Map<String, dynamic>>(
            key: "check_origin",
            parse: (v) => XCMV5Location.deserializeJson(v)));
  }
  factory XCMV5UnpaidExecution.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap(XCMInstructionType.unpaidExecution.type);
    final Map<String, dynamic>? checkOrigin =
        MetadataUtils.parseOptional(data.valueAs("check_origin"));
    return XCMV5UnpaidExecution(
        weightLimit: XCMV3WeightLimit.fromJson(data.valueAs("weight_limit")),
        checkOrigin:
            checkOrigin == null ? null : XCMV5Location.fromJson(checkOrigin));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3WeightLimit.layout_(property: "weight_limit"),
      LayoutConst.optional(XCMV5Location.layout_(), property: "check_origin"),
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

class XCMV5PayFees extends XCMInstructionV5 with XCMPayFees {
  @override
  final XCMV5Asset asset;
  XCMV5PayFees({required this.asset});
  factory XCMV5PayFees.deserializeJson(Map<String, dynamic> json) {
    return XCMV5PayFees(
        asset: XCMV5Asset.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV5PayFees.fromJson(Map<String, dynamic> json) {
    return XCMV5PayFees(
        asset:
            XCMV5Asset.fromJson(json.valueAs(XCMInstructionType.payFees.type)));
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

enum XCMV5AssetTransferFilterType {
  teleport("Teleport"),
  reserveDeposit("ReserveDeposit"),
  reserveWithdraw("ReserveWithdraw");

  const XCMV5AssetTransferFilterType(this.type);
  final String type;
  static XCMV5AssetTransferFilterType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMV5AssetTransferFilterType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract class XCMV5AssetTransfer extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV5AssetTransferFilterType get type;
  const XCMV5AssetTransfer();
  Map<String, dynamic> toJson();
  factory XCMV5AssetTransfer.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV5AssetTransferFilterType.fromName(decode.variantName);
    return switch (type) {
      XCMV5AssetTransferFilterType.teleport =>
        XCMV5AssetTransferTeleport.deserializeJson(decode.value),
      XCMV5AssetTransferFilterType.reserveDeposit =>
        XCMV5AssetTransferReserveDeposit.deserializeJson(decode.value),
      XCMV5AssetTransferFilterType.reserveWithdraw =>
        XCMV5AssetTransferReserveWithdraw.deserializeJson(decode.value)
    };
  }
  factory XCMV5AssetTransfer.fromJson(Map<String, dynamic> json) {
    final type = XCMV5AssetTransferFilterType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV5AssetTransferFilterType.teleport =>
        XCMV5AssetTransferTeleport.fromJson(json),
      XCMV5AssetTransferFilterType.reserveDeposit =>
        XCMV5AssetTransferReserveDeposit.fromJson(json),
      XCMV5AssetTransferFilterType.reserveWithdraw =>
        XCMV5AssetTransferReserveWithdraw.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5AssetTransferTeleport.layout_(property: property),
        property: XCMV5AssetTransferFilterType.teleport.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5AssetTransferReserveDeposit.layout_(property: property),
        property: XCMV5AssetTransferFilterType.reserveDeposit.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5AssetTransferReserveWithdraw.layout_(property: property),
        property: XCMV5AssetTransferFilterType.reserveWithdraw.name,
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5AssetTransferTeleport extends XCMV5AssetTransfer {
  final XCMV5AssetFilter asset;

  XCMV5AssetTransferTeleport({required this.asset});
  factory XCMV5AssetTransferTeleport.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5AssetTransferTeleport(
        asset: XCMV5AssetFilter.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV5AssetTransferTeleport.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetTransferTeleport(
        asset: XCMV5AssetFilter.fromJson(
            json.valueAs(XCMV5AssetTransferFilterType.teleport.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5AssetFilter.layout_(property: "asset")],
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

  @override
  XCMV5AssetTransferFilterType get type =>
      XCMV5AssetTransferFilterType.teleport;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }

  @override
  List get variabels => [type, asset];
}

class XCMV5AssetTransferReserveDeposit extends XCMV5AssetTransfer {
  final XCMV5AssetFilter asset;
  factory XCMV5AssetTransferReserveDeposit.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5AssetTransferReserveDeposit(
        asset: XCMV5AssetFilter.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV5AssetTransferReserveDeposit.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetTransferReserveDeposit(
        asset: XCMV5AssetFilter.fromJson(
            json.valueAs(XCMV5AssetTransferFilterType.reserveDeposit.type)));
  }
  XCMV5AssetTransferReserveDeposit({required this.asset});

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5AssetFilter.layout_(property: "asset")],
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

  @override
  XCMV5AssetTransferFilterType get type =>
      XCMV5AssetTransferFilterType.reserveDeposit;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }

  @override
  List get variabels => [type, asset];
}

class XCMV5AssetTransferReserveWithdraw extends XCMV5AssetTransfer {
  final XCMV5AssetFilter asset;
  factory XCMV5AssetTransferReserveWithdraw.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5AssetTransferReserveWithdraw(
        asset: XCMV5AssetFilter.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV5AssetTransferReserveWithdraw.fromJson(
      Map<String, dynamic> json) {
    return XCMV5AssetTransferReserveWithdraw(
        asset: XCMV5AssetFilter.fromJson(
            json.valueAs(XCMV5AssetTransferFilterType.reserveWithdraw.type)));
  }
  XCMV5AssetTransferReserveWithdraw({required this.asset});

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5AssetFilter.layout_(property: "asset")],
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

  @override
  XCMV5AssetTransferFilterType get type =>
      XCMV5AssetTransferFilterType.reserveWithdraw;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }

  @override
  List get variabels => [type, asset];
}

class XCMV5InitiateTransfer extends XCMInstructionV5 with XCMInitiateTransfer {
  final XCMV5Location destination;
  final XCMV5AssetTransfer? remoteFees;
  final bool preserveOrigin;
  final List<XCMV5AssetTransfer> assets;
  final XCMV5 xcm;

  XCMV5InitiateTransfer(
      {required this.destination,
      required this.remoteFees,
      required this.preserveOrigin,
      required List<XCMV5AssetTransfer> assets,
      required this.xcm})
      : assets =
            assets.max(_XCMV5Constants.maxAssetTransferFilters).toImutableList;
  factory XCMV5InitiateTransfer.deserializeJson(Map<String, dynamic> json) {
    return XCMV5InitiateTransfer(
        destination: XCMV5Location.deserializeJson(json.valueAs("destination")),
        remoteFees: json.valueTo<XCMV5AssetTransfer?, Map<String, dynamic>>(
          key: "remote_fees",
          parse: (v) {
            return XCMV5AssetTransfer.deserializeJson(v);
          },
        ),
        preserveOrigin: json.valueAs("preserve_origin"),
        assets: json
            .valueEnsureAsList<Map<String, dynamic>>("assets")
            .map((e) => XCMV5AssetTransfer.deserializeJson(e))
            .toList(),
        xcm: XCMV5.deserializeJson(json.valueAs("remote_xcm")));
  }
  factory XCMV5InitiateTransfer.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.initiateTransfer.type);
    final assets = data.valueEnsureAsList<Map<String, dynamic>>("assets");
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("remote_xcm");
    final Map<String, dynamic>? optRemoteFees =
        MetadataUtils.parseOptional(data.valueAs("remote_fees"));
    return XCMV5InitiateTransfer(
        destination: XCMV5Location.fromJson(data.valueAs("destination")),
        remoteFees: optRemoteFees == null
            ? null
            : XCMV5AssetTransfer.fromJson(optRemoteFees),
        preserveOrigin: data.valueAs("preserve_origin"),
        assets: assets.map((e) => XCMV5AssetTransfer.fromJson(e)).toList(),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Location.layout_(property: "destination"),
      LayoutConst.optional(XCMV5AssetTransfer.layout_(),
          property: "remote_fees"),
      LayoutConst.boolean(property: "preserve_origin"),
      LayoutConst.compactArray(XCMV5AssetTransfer.layout_(),
          property: "assets"),
      XCMV5.layout_(property: "remote_xcm")
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
      "remote_fees": remoteFees?.serializeJsonVariant(),
      "preserve_origin": preserveOrigin,
      "assets": assets.map((e) => e.serializeJsonVariant()).toList(),
      "remote_xcm": xcm.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "destination": destination.toJson(),
        "preserve_origin": preserveOrigin,
        "remote_xcm": xcm.instructions.map((e) => e.toJson()).toList(),
        "assets": assets.map((e) => e.toJson()).toList(),
        "remote_fees": MetadataUtils.toOptionalJson(remoteFees?.toJson())
      }
    };
  }

  @override
  List get variabels =>
      [type, destination, remoteFees, preserveOrigin, assets, xcm];
}

class XCMV5ExecuteWithOrigin extends XCMInstructionV5
    with XCMExecuteWithOrigin {
  final XCMV5InteriorMultiLocation? descendantOrigin;
  @override
  final XCMV5 xcm;
  XCMV5ExecuteWithOrigin({required this.descendantOrigin, required this.xcm});
  factory XCMV5ExecuteWithOrigin.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ExecuteWithOrigin(
        descendantOrigin: json.valueTo<XCMV5Junctions?, Map<String, dynamic>>(
            key: "descendant_origin",
            parse: (v) => XCMV5Junctions.deserializeJson(v)),
        xcm: XCMV5.deserializeJson(json.valueAs("xcm")));
  }
  factory XCMV5ExecuteWithOrigin.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMInstructionType.executeWithOrigin.type);
    final xcm = data.valueEnsureAsList<Map<String, dynamic>>("xcm");
    final Map<String, dynamic>? optDescendantOrigin =
        MetadataUtils.parseOptional(data.valueAs("descendant_origin"));
    return XCMV5ExecuteWithOrigin(
        descendantOrigin: optDescendantOrigin == null
            ? null
            : XCMV5Junctions.fromJson(optDescendantOrigin),
        xcm: XCMV5(
            instructions:
                xcm.map((e) => XCMInstructionV5.fromJson(e)).toList()));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV5Junctions.layout_(),
          property: "descendant_origin"),
      XCMV5.layout_(property: "xcm")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "descendant_origin": descendantOrigin?.serializeJsonVariant(),
      "xcm": xcm.serializeJson()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "xcm": xcm.instructions.map((e) => e.toJson()).toList(),
        "descendant_origin":
            MetadataUtils.toOptionalJson(descendantOrigin?.toJson())
      }
    };
  }

  @override
  List get variabels => [type, descendantOrigin, xcm];
}

class XCMV5SetHints extends XCMInstructionV5 with XCMSetHints {
  final List<XCMV5Hint> hints;

  XCMV5SetHints({required List<XCMV5Hint> hints}) : hints = hints.immutable;
  factory XCMV5SetHints.deserializeJson(Map<String, dynamic> json) {
    return XCMV5SetHints(
        hints: json
            .valueEnsureAsList<Map<String, dynamic>>("hints")
            .map((e) => XCMV5Hint.deserializeJson(e))
            .toList());
  }
  factory XCMV5SetHints.fromJson(Map<String, dynamic> json) {
    final hints = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMInstructionType.setHints.type);
    return XCMV5SetHints(
        hints: hints.map((e) => XCMV5Hint.fromJson(e)).toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactArray(XCMV5Hint.layout_(), property: "hints")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"hints": hints.map((e) => e.serializeJsonVariant()).toList()};
  }

  @override
  Map<String, dynamic> toJson({String? property}) {
    return {type.type: hints.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, hints];
}

enum XCMV5HintType {
  assetClaimer("AssetClaimer");

  const XCMV5HintType(this.type);
  final String type;

  static XCMV5HintType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV5HintType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV5Hint extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV5HintType get type;
  Map<String, dynamic> toJson();
  const XCMV5Hint();
  factory XCMV5Hint.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV5HintType.fromName(decode.variantName);
    return switch (type) {
      XCMV5HintType.assetClaimer =>
        XCMV5HintAssetClaimer.deserializeJson(decode.value)
    };
  }
  factory XCMV5Hint.fromJson(Map<String, dynamic> json) {
    final type = XCMV5HintType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV5HintType.assetClaimer => XCMV5HintAssetClaimer.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5HintAssetClaimer.layout_(property: property),
        property: XCMV5HintType.assetClaimer.name,
        index: 0,
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5HintAssetClaimer extends XCMV5Hint {
  final XCMV5Location location;
  const XCMV5HintAssetClaimer({required this.location});

  factory XCMV5HintAssetClaimer.deserializeJson(Map<String, dynamic> json) {
    return XCMV5HintAssetClaimer(
        location: XCMV5Location.deserializeJson(json["location"]));
  }

  factory XCMV5HintAssetClaimer.fromJson(Map<String, dynamic> json) {
    return XCMV5HintAssetClaimer(
        location: XCMV5Location.fromJson(
            json.valueAs(XCMV5HintType.assetClaimer.type)));
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
  XCMV5HintType get type => XCMV5HintType.assetClaimer;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: location.toJson()};
  }

  @override
  List get variabels => [type, location];
}

enum XCMV5ResponseType {
  nullResponse("Null"),
  assets("Assets"),
  executionResult("ExecutionResult"),
  version("Version"),
  palletsInfo("PalletsInfo"),
  dispatchResult("DispatchResult");

  const XCMV5ResponseType(this.type);
  final String type;

  static XCMV5ResponseType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV5ResponseType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV5Response extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV5ResponseType get type;
  const XCMV5Response();
  Map<String, dynamic> toJson();
  factory XCMV5Response.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV5ResponseType.fromName(decode.variantName);
    return switch (type) {
      XCMV5ResponseType.nullResponse => XCMV5ResponseNull(),
      XCMV5ResponseType.assets =>
        XCMV5ResponseAssets.deserializeJson(decode.value),
      XCMV5ResponseType.executionResult =>
        XCMV5ResponseExecutionResult.deserializeJson(decode.value),
      XCMV5ResponseType.version =>
        XCMV5ResponseVersion.deserializeJson(decode.value),
      XCMV5ResponseType.palletsInfo =>
        XCMV5ResponsePalletsInfo.deserializeJson(decode.value),
      XCMV5ResponseType.dispatchResult =>
        XCMV5ResponseDispatchResult.deserializeJson(decode.value),
    };
  }
  factory XCMV5Response.fromJson(Map<String, dynamic> json) {
    final type = XCMV5ResponseType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV5ResponseType.nullResponse => XCMV5ResponseNull.fromJson(json),
      XCMV5ResponseType.assets => XCMV5ResponseAssets.fromJson(json),
      XCMV5ResponseType.executionResult =>
        XCMV5ResponseExecutionResult.fromJson(json),
      XCMV5ResponseType.version => XCMV5ResponseVersion.fromJson(json),
      XCMV5ResponseType.palletsInfo => XCMV5ResponsePalletsInfo.fromJson(json),
      XCMV5ResponseType.dispatchResult =>
        XCMV5ResponseDispatchResult.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            SubstrateVariantNoArgs.layout_(property: property),
        property: XCMV5ResponseType.nullResponse.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5ResponseAssets.layout_(property: property),
        property: XCMV5ResponseType.assets.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ResponseExecutionResult.layout_(property: property),
        property: XCMV5ResponseType.executionResult.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ResponseVersion.layout_(property: property),
        property: XCMV5ResponseType.version.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ResponsePalletsInfo.layout_(property: property),
        property: XCMV5ResponseType.palletsInfo.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5ResponseDispatchResult.layout_(property: property),
        property: XCMV5ResponseType.dispatchResult.name,
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5ResponseNull extends XCMV5Response with SubstrateVariantNoArgs {
  XCMV5ResponseNull();
  factory XCMV5ResponseNull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ResponseType.nullResponse.type);
    return XCMV5ResponseNull();
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  XCMV5ResponseType get type => XCMV5ResponseType.nullResponse;

  @override
  List get variabels => [type];
}

class XCMV5ResponseAssets extends XCMV5Response {
  final XCMV5Assets assets;
  XCMV5ResponseAssets({required this.assets});

  factory XCMV5ResponseAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ResponseAssets(
        assets: XCMV5Assets.deserializeJson(json["assets"]));
  }
  factory XCMV5ResponseAssets.fromJson(Map<String, dynamic> json) {
    final assets = json
        .valueEnsureAsList<Map<String, dynamic>>(XCMV5ResponseType.assets.type);
    return XCMV5ResponseAssets(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
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

  @override
  XCMV5ResponseType get type => XCMV5ResponseType.assets;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

class XCMV5ResponseExecutionResult extends XCMV5Response {
  final int? index;
  final XCMV5Error? error;
  XCMV5ResponseExecutionResult({int? index, this.error})
      : index = index?.asUint32;

  factory XCMV5ResponseExecutionResult.deserializeJson(
      Map<String, dynamic> json) {
    final error = json["error"];
    if (error == null) return XCMV5ResponseExecutionResult();
    return XCMV5ResponseExecutionResult(
        index: IntUtils.parse(error["index"]),
        error: XCMV5Error.deserializeJson(error["error"]));
  }
  factory XCMV5ResponseExecutionResult.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        XCMV5ResponseType.executionResult.type);
    final List? opt = MetadataUtils.parseOptional(data);
    if (opt == null) return XCMV5ResponseExecutionResult();
    return XCMV5ResponseExecutionResult(
        index: IntUtils.parse(opt[0]), error: XCMV5Error.fromJson(opt[1]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(
          LayoutConst.struct([
            LayoutConst.u32(property: "index"),
            XCMV5Error.layout_(property: "error")
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
  XCMV5ResponseType get type => XCMV5ResponseType.executionResult;
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

class XCMV5ResponseVersion extends XCMV5Response {
  final int versionNumber;
  XCMV5ResponseVersion({required int version})
      : versionNumber = version.asUint32;

  factory XCMV5ResponseVersion.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ResponseVersion(version: IntUtils.parse(json["version"]));
  }
  factory XCMV5ResponseVersion.fromJson(Map<String, dynamic> json) {
    return XCMV5ResponseVersion(
        version: json.valueAs(XCMV5ResponseType.version.type));
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
  XCMV5ResponseType get type => XCMV5ResponseType.version;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: versionNumber};
  }

  @override
  List get variabels => [type, versionNumber];
}

class XCMV5ResponsePalletsInfo extends XCMV5Response {
  final List<XCMPalletInfo> pallets;
  XCMV5ResponsePalletsInfo({required List<XCMPalletInfo> pallets})
      : pallets = pallets.max(_XCMV5Constants.maxPalletInfo).immutable;

  factory XCMV5ResponsePalletsInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ResponsePalletsInfo(
        pallets: (json.valueEnsureAsList<Map<String, dynamic>>("pallets"))
            .map((e) => XCMPalletInfo.deserializeJson(e))
            .toList());
  }
  factory XCMV5ResponsePalletsInfo.fromJson(Map<String, dynamic> json) {
    final pallets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMV5ResponseType.palletsInfo.type);
    return XCMV5ResponsePalletsInfo(
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
  XCMV5ResponseType get type => XCMV5ResponseType.palletsInfo;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: pallets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, pallets];
}

class XCMV5ResponseDispatchResult extends XCMV5Response {
  final XCMV3MaybeErrorCode error;
  XCMV5ResponseDispatchResult({required this.error});

  factory XCMV5ResponseDispatchResult.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5ResponseDispatchResult(
        error: XCMV3MaybeErrorCode.deserializeJson(
            json.valueEnsureAsMap("error")));
  }
  factory XCMV5ResponseDispatchResult.fromJson(Map<String, dynamic> json) {
    return XCMV5ResponseDispatchResult(
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
  XCMV5ResponseType get type => XCMV5ResponseType.dispatchResult;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: error.toJson()};
  }

  @override
  List get variabels => [type, error];
}

class XCMV5QueryResponseInfo
    extends SubstrateSerialization<Map<String, dynamic>>
    with XCMComponent, Equality {
  final XCMV5Location destination;
  final BigInt queryId;
  final SubstrateWeightV2 maxWeight;

  XCMV5QueryResponseInfo(
      {required this.destination,
      required BigInt queryId,
      required this.maxWeight})
      : queryId = queryId.asUint64;
  factory XCMV5QueryResponseInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMV5QueryResponseInfo(
        destination: XCMV5Location.deserializeJson(json.valueAs("destination")),
        queryId: json.valueAs("query_id"),
        maxWeight:
            SubstrateWeightV2.deserializeJson(json.valueAs("max_weight")));
  }
  factory XCMV5QueryResponseInfo.fromJson(Map<String, dynamic> json) {
    return XCMV5QueryResponseInfo(
        destination: XCMV5Location.fromJson(json.valueAs("destination")),
        queryId: json.valueAs("query_id"),
        maxWeight: SubstrateWeightV2.fromJson(json.valueAs("max_weight")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5Location.layout_(property: "destination"),
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
  XCMVersion get version => XCMVersion.v5;
}

enum XCMV5ErrorType {
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
  tooManyAssets("TooManyAssets", 35),
  unhandledXcmVersion("UnhandledXcmVersion", 36),
  weightLimitReached("WeightLimitReached", 37),
  barrier("Barrier", 38),
  weightNotComputable("WeightNotComputable", 39),
  exceedsStackLimit("ExceedsStackLimit", 40);

  const XCMV5ErrorType(this.type, this.variantIndex);
  final String type;
  final int variantIndex;

  static XCMV5ErrorType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMV5ErrorType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

abstract class XCMV5Error extends SubstrateVariantSerialization
    with XCMComponent, Equality {
  XCMV5ErrorType get type;
  const XCMV5Error();
  Map<String, dynamic> toJson();
  factory XCMV5Error.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV5ErrorType.fromName(decode.variantName);
    return switch (type) {
      XCMV5ErrorType.overFlow => XCMV5ErrorOverflow(),
      XCMV5ErrorType.unimplemented => XCMV5ErrorUnimplemented(),
      XCMV5ErrorType.untrustedReserveLocation =>
        XCMV5ErrorUntrustedReserveLocation(),
      XCMV5ErrorType.untrustedTeleportLocation =>
        XCMV5ErrorUntrustedTeleportLocation(),
      XCMV5ErrorType.locationFull => XCMV5ErrorLocationFull(),
      XCMV5ErrorType.locationNotInvertible => XCMV5ErrorLocationNotInvertible(),
      XCMV5ErrorType.badOrigin => XCMV5ErrorBadOrigin(),
      XCMV5ErrorType.invalidLocation => XCMV5ErrorInvalidLocation(),
      XCMV5ErrorType.assetNotFound => XCMV5ErrorAssetNotFound(),
      XCMV5ErrorType.failedToTransactAsset => XCMV5ErrorFailedToTransactAsset(),
      XCMV5ErrorType.notWithdrawable => XCMV5ErrorNotWithdrawable(),
      XCMV5ErrorType.locationCannotHold => XCMV5ErrorLocationCannotHold(),
      XCMV5ErrorType.exceedsMaxMessageSize => XCMV5ErrorExceedsMaxMessageSize(),
      XCMV5ErrorType.destinationUnsupported =>
        XCMV5ErrorDestinationUnsupported(),
      XCMV5ErrorType.transport => XCMV5ErrorTransport(),
      XCMV5ErrorType.unroutable => XCMV5ErrorUnroutable(),
      XCMV5ErrorType.unknownClaim => XCMV5ErrorUnknownClaim(),
      XCMV5ErrorType.failedToDecode => XCMV5ErrorFailedToDecode(),
      XCMV5ErrorType.maxWeightInvalid => XCMV5ErrorMaxWeightInvalid(),
      XCMV5ErrorType.notHodingFees => XCMV5ErrorNotHoldingFees(),
      XCMV5ErrorType.tooExpensive => XCMV5ErrorTooExpensive(),
      XCMV5ErrorType.trap => XCMV5ErrorTrap.deserializeJson(decode.value),
      XCMV5ErrorType.expectationFale => XCMV5ErrorExpectationFalse(),
      XCMV5ErrorType.palletNotFound => XCMV5ErrorPalletNotFound(),
      XCMV5ErrorType.nameMismatch => XCMV5ErrorNameMismatch(),
      XCMV5ErrorType.versionIncompatible => XCMV5ErrorVersionIncompatible(),
      XCMV5ErrorType.holdingWouldOverflow => XCMV5ErrorHoldingWouldOverflow(),
      XCMV5ErrorType.exportError => XCMV5ErrorExportError(),
      XCMV5ErrorType.reanchorFailed => XCMV5ErrorReanchorFailed(),
      XCMV5ErrorType.noDeal => XCMV5ErrorNoDeal(),
      XCMV5ErrorType.feesNotMet => XCMV5ErrorFeesNotMet(),
      XCMV5ErrorType.lockError => XCMV5ErrorLockError(),
      XCMV5ErrorType.noPermission => XCMV5ErrorNoPermission(),
      XCMV5ErrorType.unanchored => XCMV5ErrorUnanchored(),
      XCMV5ErrorType.notDepositable => XCMV5ErrorNotDepositable(),
      XCMV5ErrorType.tooManyAssets => XCMV5ErrorTooManyAssets(),
      XCMV5ErrorType.unhandledXcmVersion => XCMV5ErrorUnhandledXcmVersion(),
      XCMV5ErrorType.weightLimitReached =>
        XCMV5ErrorWeightLimitReached.deserializeJson(decode.value),
      XCMV5ErrorType.barrier => XCMV5ErrorBarrier(),
      XCMV5ErrorType.weightNotComputable => XCMV5ErrorWeightNotComputable(),
      XCMV5ErrorType.exceedsStackLimit => XCMV5ErrorExceedsStackLimit(),
    };
  }
  factory XCMV5Error.fromJson(Map<String, dynamic> json) {
    final type = XCMV5ErrorType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV5ErrorType.overFlow => XCMV5ErrorOverflow.fromJson(json),
      XCMV5ErrorType.unimplemented => XCMV5ErrorUnimplemented.fromJson(json),
      XCMV5ErrorType.untrustedReserveLocation =>
        XCMV5ErrorUntrustedReserveLocation.fromJson(json),
      XCMV5ErrorType.untrustedTeleportLocation =>
        XCMV5ErrorUntrustedTeleportLocation.fromJson(json),
      XCMV5ErrorType.locationFull => XCMV5ErrorLocationFull.fromJson(json),
      XCMV5ErrorType.locationNotInvertible =>
        XCMV5ErrorLocationNotInvertible.fromJson(json),
      XCMV5ErrorType.badOrigin => XCMV5ErrorBadOrigin.fromJson(json),
      XCMV5ErrorType.invalidLocation =>
        XCMV5ErrorInvalidLocation.fromJson(json),
      XCMV5ErrorType.assetNotFound => XCMV5ErrorAssetNotFound.fromJson(json),
      XCMV5ErrorType.failedToTransactAsset =>
        XCMV5ErrorFailedToTransactAsset.fromJson(json),
      XCMV5ErrorType.notWithdrawable =>
        XCMV5ErrorNotWithdrawable.fromJson(json),
      XCMV5ErrorType.locationCannotHold =>
        XCMV5ErrorLocationCannotHold.fromJson(json),
      XCMV5ErrorType.exceedsMaxMessageSize =>
        XCMV5ErrorExceedsMaxMessageSize.fromJson(json),
      XCMV5ErrorType.destinationUnsupported =>
        XCMV5ErrorDestinationUnsupported.fromJson(json),
      XCMV5ErrorType.transport => XCMV5ErrorTransport.fromJson(json),
      XCMV5ErrorType.unroutable => XCMV5ErrorUnroutable.fromJson(json),
      XCMV5ErrorType.unknownClaim => XCMV5ErrorUnknownClaim.fromJson(json),
      XCMV5ErrorType.failedToDecode => XCMV5ErrorFailedToDecode.fromJson(json),
      XCMV5ErrorType.maxWeightInvalid =>
        XCMV5ErrorMaxWeightInvalid.fromJson(json),
      XCMV5ErrorType.notHodingFees => XCMV5ErrorNotHoldingFees.fromJson(json),
      XCMV5ErrorType.tooExpensive => XCMV5ErrorTooExpensive.fromJson(json),
      XCMV5ErrorType.trap => XCMV5ErrorTrap.fromJson(json),
      XCMV5ErrorType.expectationFale =>
        XCMV5ErrorExpectationFalse.fromJson(json),
      XCMV5ErrorType.palletNotFound => XCMV5ErrorPalletNotFound.fromJson(json),
      XCMV5ErrorType.nameMismatch => XCMV5ErrorNameMismatch.fromJson(json),
      XCMV5ErrorType.versionIncompatible =>
        XCMV5ErrorVersionIncompatible.fromJson(json),
      XCMV5ErrorType.holdingWouldOverflow =>
        XCMV5ErrorHoldingWouldOverflow.fromJson(json),
      XCMV5ErrorType.exportError => XCMV5ErrorExportError.fromJson(json),
      XCMV5ErrorType.reanchorFailed => XCMV5ErrorReanchorFailed.fromJson(json),
      XCMV5ErrorType.noDeal => XCMV5ErrorNoDeal.fromJson(json),
      XCMV5ErrorType.feesNotMet => XCMV5ErrorFeesNotMet.fromJson(json),
      XCMV5ErrorType.lockError => XCMV5ErrorLockError.fromJson(json),
      XCMV5ErrorType.noPermission => XCMV5ErrorNoPermission.fromJson(json),
      XCMV5ErrorType.unanchored => XCMV5ErrorUnanchored.fromJson(json),
      XCMV5ErrorType.notDepositable => XCMV5ErrorNotDepositable.fromJson(json),
      XCMV5ErrorType.tooManyAssets => XCMV5ErrorTooManyAssets.fromJson(json),
      XCMV5ErrorType.unhandledXcmVersion =>
        XCMV5ErrorUnhandledXcmVersion.fromJson(json),
      XCMV5ErrorType.weightLimitReached =>
        XCMV5ErrorWeightLimitReached.fromJson(json),
      XCMV5ErrorType.barrier => XCMV5ErrorBarrier.fromJson(json),
      XCMV5ErrorType.weightNotComputable =>
        XCMV5ErrorWeightNotComputable.fromJson(json),
      XCMV5ErrorType.exceedsStackLimit =>
        XCMV5ErrorExceedsStackLimit.fromJson(json),
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum(
        XCMV5ErrorType.values.map((e) {
          return LazyVariantModel(
              layout: ({property}) {
                switch (e) {
                  case XCMV5ErrorType.trap:
                    return XCMV5ErrorTrap.layout_(property: property);
                  case XCMV5ErrorType.weightLimitReached:
                    return XCMV5ErrorWeightLimitReached.layout_(
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5ErrorOverflow extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.overFlow;
  const XCMV5ErrorOverflow();
  factory XCMV5ErrorOverflow.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.overFlow.type);
    return XCMV5ErrorOverflow();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUnimplemented extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.unimplemented;
  const XCMV5ErrorUnimplemented();
  factory XCMV5ErrorUnimplemented.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.unimplemented.type);
    return XCMV5ErrorUnimplemented();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUntrustedReserveLocation extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.untrustedReserveLocation;
  const XCMV5ErrorUntrustedReserveLocation();
  factory XCMV5ErrorUntrustedReserveLocation.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.untrustedReserveLocation.type);
    return XCMV5ErrorUntrustedReserveLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUntrustedTeleportLocation extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.untrustedTeleportLocation;
  const XCMV5ErrorUntrustedTeleportLocation();
  factory XCMV5ErrorUntrustedTeleportLocation.fromJson(
      Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.untrustedTeleportLocation.type);
    return XCMV5ErrorUntrustedTeleportLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorLocationFull extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.locationFull;
  const XCMV5ErrorLocationFull();
  factory XCMV5ErrorLocationFull.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.locationFull.type);
    return XCMV5ErrorLocationFull();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorLocationNotInvertible extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.locationNotInvertible;
  const XCMV5ErrorLocationNotInvertible();
  factory XCMV5ErrorLocationNotInvertible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.locationNotInvertible.type);
    return XCMV5ErrorLocationNotInvertible();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorBadOrigin extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.badOrigin;
  const XCMV5ErrorBadOrigin();
  factory XCMV5ErrorBadOrigin.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.badOrigin.type);
    return XCMV5ErrorBadOrigin();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorInvalidLocation extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.invalidLocation;
  const XCMV5ErrorInvalidLocation();
  factory XCMV5ErrorInvalidLocation.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.invalidLocation.type);
    return XCMV5ErrorInvalidLocation();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorAssetNotFound extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.assetNotFound;
  const XCMV5ErrorAssetNotFound();
  factory XCMV5ErrorAssetNotFound.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.assetNotFound.type);
    return XCMV5ErrorAssetNotFound();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorFailedToTransactAsset extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.failedToTransactAsset;
  const XCMV5ErrorFailedToTransactAsset();
  factory XCMV5ErrorFailedToTransactAsset.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.failedToTransactAsset.type);
    return XCMV5ErrorFailedToTransactAsset();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorNotWithdrawable extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.notWithdrawable;
  const XCMV5ErrorNotWithdrawable();
  factory XCMV5ErrorNotWithdrawable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.notWithdrawable.type);
    return XCMV5ErrorNotWithdrawable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorLocationCannotHold extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.locationCannotHold;
  const XCMV5ErrorLocationCannotHold();
  factory XCMV5ErrorLocationCannotHold.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.locationCannotHold.type);
    return XCMV5ErrorLocationCannotHold();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorExceedsMaxMessageSize extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.exceedsMaxMessageSize;
  const XCMV5ErrorExceedsMaxMessageSize();
  factory XCMV5ErrorExceedsMaxMessageSize.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.exceedsMaxMessageSize.type);
    return XCMV5ErrorExceedsMaxMessageSize();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorDestinationUnsupported extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.destinationUnsupported;
  const XCMV5ErrorDestinationUnsupported();
  factory XCMV5ErrorDestinationUnsupported.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.destinationUnsupported.type);
    return XCMV5ErrorDestinationUnsupported();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorTransport extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.transport;
  const XCMV5ErrorTransport();
  factory XCMV5ErrorTransport.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.transport.type);
    return XCMV5ErrorTransport();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUnroutable extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.unroutable;
  const XCMV5ErrorUnroutable();
  factory XCMV5ErrorUnroutable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.unroutable.type);
    return XCMV5ErrorUnroutable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUnknownClaim extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.unknownClaim;
  const XCMV5ErrorUnknownClaim();
  factory XCMV5ErrorUnknownClaim.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.unknownClaim.type);
    return XCMV5ErrorUnknownClaim();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorFailedToDecode extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.failedToDecode;
  const XCMV5ErrorFailedToDecode();
  factory XCMV5ErrorFailedToDecode.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.failedToDecode.type);
    return XCMV5ErrorFailedToDecode();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorMaxWeightInvalid extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.maxWeightInvalid;
  const XCMV5ErrorMaxWeightInvalid();
  factory XCMV5ErrorMaxWeightInvalid.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.maxWeightInvalid.type);
    return XCMV5ErrorMaxWeightInvalid();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorNotHoldingFees extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.notHodingFees;
  const XCMV5ErrorNotHoldingFees();
  factory XCMV5ErrorNotHoldingFees.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.notHodingFees.type);
    return XCMV5ErrorNotHoldingFees();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorTooExpensive extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.tooExpensive;
  const XCMV5ErrorTooExpensive();
  factory XCMV5ErrorTooExpensive.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.tooExpensive.type);
    return XCMV5ErrorTooExpensive();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorTrap extends XCMV5Error {
  final BigInt code;
  XCMV5ErrorTrap({required BigInt code}) : code = code.asUint64;
  factory XCMV5ErrorTrap.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ErrorTrap(code: BigintUtils.parse(json["code"]));
  }
  factory XCMV5ErrorTrap.fromJson(Map<String, dynamic> json) {
    return XCMV5ErrorTrap(code: json.valueAs(XCMV5ErrorType.trap.type));
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
  XCMV5ErrorType get type => XCMV5ErrorType.trap;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: code};
  }

  @override
  List get variabels => [type, code];
}

class XCMV5ErrorExpectationFalse extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.expectationFale;
  const XCMV5ErrorExpectationFalse();
  factory XCMV5ErrorExpectationFalse.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.expectationFale.type);
    return XCMV5ErrorExpectationFalse();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorPalletNotFound extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.palletNotFound;
  const XCMV5ErrorPalletNotFound();
  factory XCMV5ErrorPalletNotFound.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.palletNotFound.type);
    return XCMV5ErrorPalletNotFound();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorNameMismatch extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.nameMismatch;
  const XCMV5ErrorNameMismatch();
  factory XCMV5ErrorNameMismatch.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.nameMismatch.type);
    return XCMV5ErrorNameMismatch();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorVersionIncompatible extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.versionIncompatible;
  const XCMV5ErrorVersionIncompatible();
  factory XCMV5ErrorVersionIncompatible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.versionIncompatible.type);
    return XCMV5ErrorVersionIncompatible();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorHoldingWouldOverflow extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.holdingWouldOverflow;
  const XCMV5ErrorHoldingWouldOverflow();
  factory XCMV5ErrorHoldingWouldOverflow.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.holdingWouldOverflow.type);
    return XCMV5ErrorHoldingWouldOverflow();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorExportError extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.exportError;
  const XCMV5ErrorExportError();
  factory XCMV5ErrorExportError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.exportError.type);
    return XCMV5ErrorExportError();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorReanchorFailed extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.reanchorFailed;
  const XCMV5ErrorReanchorFailed();
  factory XCMV5ErrorReanchorFailed.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.reanchorFailed.type);
    return XCMV5ErrorReanchorFailed();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorNoDeal extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.noDeal;
  const XCMV5ErrorNoDeal();
  factory XCMV5ErrorNoDeal.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.noDeal.type);
    return XCMV5ErrorNoDeal();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorFeesNotMet extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.feesNotMet;
  const XCMV5ErrorFeesNotMet();
  factory XCMV5ErrorFeesNotMet.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.feesNotMet.type);
    return XCMV5ErrorFeesNotMet();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorLockError extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.lockError;
  const XCMV5ErrorLockError();
  factory XCMV5ErrorLockError.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.lockError.type);
    return XCMV5ErrorLockError();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorNoPermission extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.noPermission;
  const XCMV5ErrorNoPermission();
  factory XCMV5ErrorNoPermission.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.noPermission.type);
    return XCMV5ErrorNoPermission();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUnanchored extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.unanchored;
  const XCMV5ErrorUnanchored();
  factory XCMV5ErrorUnanchored.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.unanchored.type);
    return XCMV5ErrorUnanchored();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorNotDepositable extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.notDepositable;
  const XCMV5ErrorNotDepositable();
  factory XCMV5ErrorNotDepositable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.notDepositable.type);
    return XCMV5ErrorNotDepositable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorTooManyAssets extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.tooManyAssets;
  const XCMV5ErrorTooManyAssets();
  factory XCMV5ErrorTooManyAssets.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.tooManyAssets.type);
    return XCMV5ErrorTooManyAssets();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorUnhandledXcmVersion extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.unhandledXcmVersion;
  const XCMV5ErrorUnhandledXcmVersion();
  factory XCMV5ErrorUnhandledXcmVersion.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.unhandledXcmVersion.type);
    return XCMV5ErrorUnhandledXcmVersion();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorWeightLimitReached extends XCMV5Error
    with SubstrateVariantNoArgs {
  final SubstrateWeightV2 weight;
  XCMV5ErrorWeightLimitReached({required this.weight});
  factory XCMV5ErrorWeightLimitReached.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5ErrorWeightLimitReached(
        weight: SubstrateWeightV2.deserializeJson(json["weight"]));
  }
  factory XCMV5ErrorWeightLimitReached.fromJson(Map<String, dynamic> json) {
    return XCMV5ErrorWeightLimitReached(
        weight: SubstrateWeightV2.fromJson(
            json.valueAs(XCMV5ErrorType.weightLimitReached.type)));
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
  XCMV5ErrorType get type => XCMV5ErrorType.weightLimitReached;
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

class XCMV5ErrorBarrier extends XCMV5Error with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.barrier;
  const XCMV5ErrorBarrier();
  factory XCMV5ErrorBarrier.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.barrier.type);
    return XCMV5ErrorBarrier();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorWeightNotComputable extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.weightNotComputable;
  const XCMV5ErrorWeightNotComputable();
  factory XCMV5ErrorWeightNotComputable.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.weightNotComputable.type);
    return XCMV5ErrorWeightNotComputable();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5ErrorExceedsStackLimit extends XCMV5Error
    with SubstrateVariantNoArgs {
  @override
  XCMV5ErrorType get type => XCMV5ErrorType.exceedsStackLimit;
  const XCMV5ErrorExceedsStackLimit();
  factory XCMV5ErrorExceedsStackLimit.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMV5ErrorType.exceedsStackLimit.type);
    return XCMV5ErrorExceedsStackLimit();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV5 extends SubstrateSerialization<Map<String, dynamic>>
    with XCM<XCMInstructionV5>, Equality {
  @override
  final List<XCMInstructionV5> instructions;

  XCMV5({required List<XCMInstructionV5> instructions})
      : instructions = instructions.immutable;
  factory XCMV5.deserializeJson(Map<String, dynamic> json) {
    return XCMV5(
        instructions: json
            .valueEnsureAsList<Map<String, dynamic>>("instructions")
            .map((e) => XCMInstructionV5.deserializeJson(e))
            .toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMInstructionV5.layout_(),
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
  XCMVersion get version => XCMVersion.v5;
}
