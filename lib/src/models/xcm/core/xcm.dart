import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/core/asset.dart';
import 'package:polkadot_dart/src/models/xcm/core/junction.dart';
import 'package:polkadot_dart/src/models/xcm/core/location.dart';
import 'package:polkadot_dart/src/models/xcm/core/network_id.dart';
import 'package:polkadot_dart/src/models/xcm/core/versioned.dart';
import 'package:polkadot_dart/src/models/xcm/v2/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v3/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v4/xcm.dart';
import 'package:polkadot_dart/src/models/xcm/v5/xcm.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

abstract mixin class XCMComponent implements Equality {
  XCMVersion get version;
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

enum XCMWeightLimitType {
  unlimited("Unlimited"),
  limited("Limited");

  final String type;

  const XCMWeightLimitType(this.type);
  static XCMWeightLimitType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMWeightLimitType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract mixin class WeightLimit
    implements SubstrateVariantSerialization, XCMComponent {
  Map<String, dynamic> toJson();
  XCMWeightLimitType get type;
  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

enum XCMInstructionType {
  withdrawAsset("WithdrawAsset", 0),
  reserveAssetDeposited("ReserveAssetDeposited", 1),
  receiveTeleportedAsset("ReceiveTeleportedAsset", 2),
  queryResponse("QueryResponse", 3),
  transferAsset("TransferAsset", 4),
  transferReserveAsset("TransferReserveAsset", 5),
  transact("Transact", 6),
  hrmpNewChannelOpenRequest("HrmpNewChannelOpenRequest", 7),
  hrmpChannelAccepted("HrmpChannelAccepted", 8),
  hrmpChannelClosing("HrmpChannelClosing", 9),
  clearOrigin("ClearOrigin", 10),
  descendOrigin("DescendOrigin", 11),
  reportError("ReportError", 12),
  depositAsset("DepositAsset", 13),
  depositReserveAsset("DepositReserveAsset", 14),
  exchangeAsset("ExchangeAsset", 15),
  initiateReserveWithdraw("InitiateReserveWithdraw", 16),
  initiateTeleport("InitiateTeleport", 17),
  queryHolding("QueryHolding", 18),
  reportHolding("ReportHolding", 18),
  buyExecution("BuyExecution", 19),
  refundSurplus("RefundSurplus", 20),
  setErrorHandler("SetErrorHandler", 21),
  setAppendix("SetAppendix", 22),
  clearError("ClearError", 23),
  claimAsset("ClaimAsset", 24),
  trap("Trap", 25),
  subscribeVersion("SubscribeVersion", 26),
  unsubscribeVersion("UnsubscribeVersion", 27),
  burnAsset("BurnAsset", 28),
  expectAsset("ExpectAsset", 29),
  expectOrigin("ExpectOrigin", 30),
  expectError("ExpectError", 31),
  expectTransactStatus("ExpectTransactStatus", 32),
  queryPallet("QueryPallet", 33),
  expectPallet("ExpectPallet", 34),
  reportTransactStatus("ReportTransactStatus", 35),
  clearTransactStatus("ClearTransactStatus", 36),
  universalOrigin("UniversalOrigin", 37),
  exportMessage("ExportMessage", 38),
  lockAsset("LockAsset", 39),
  unlockAsset("UnlockAsset", 40),
  noteUnlockable("NoteUnlockable", 41),
  requestUnlock("RequestUnlock", 42),
  setFeesMode("SetFeesMode", 43),
  setTopic("SetTopic", 44),
  clearTopic("ClearTopic", 45),
  aliasOrigin("AliasOrigin", 46),
  unpaidExecution("UnpaidExecution", 47),
  payFees("PayFees", 48),
  initiateTransfer("InitiateTransfer", 49),
  executeWithOrigin("ExecuteWithOrigin", 50),
  setHints("SetHints", 51);

  const XCMInstructionType(this.type, this.variantIndex);
  final String type;
  final int variantIndex;

  static XCMInstructionType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }

  static XCMInstructionType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMInstructionType fromIndex(int index) {
    return values.firstWhere((e) => e.variantIndex == index,
        orElse: () => throw ItemNotFoundException(value: index));
  }
}

abstract mixin class XCMInstruction
    implements SubstrateVariantSerialization, XCMComponent {
  XCMInstructionType get type;
  Map<String, dynamic> toJson();

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

abstract mixin class XCM<CALL extends XCMInstruction>
    implements SubstrateSerialization<Map<String, dynamic>>, XCMComponent {
  List<CALL> get instructions;
  @override
  List get variabels => [version, instructions];

  factory XCM.fromInstructions(
      {required List<XCMInstruction> instructions,
      required XCMVersion version}) {
    return switch (version) {
      XCMVersion.v2 =>
        XCMV2(instructions: instructions.cast<XCMInstructionV2>()),
      XCMVersion.v3 =>
        XCMV3(instructions: instructions.cast<XCMInstructionV3>()),
      XCMVersion.v4 =>
        XCMV4(instructions: instructions.cast<XCMInstructionV4>()),
      XCMVersion.v5 =>
        XCMV5(instructions: instructions.cast<XCMInstructionV5>()),
    }
        .cast();
  }

  @override
  T cast<T extends XCMComponent>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
    }
    return this as T;
  }
}

class XCMPalletInfo extends SubstrateSerialization<Map<String, dynamic>>
    with Equality {
  static const int maxPalletNameLen = 48;
  final int index;
  final List<int> name;
  final List<int> moduleName;
  final int major;
  final int minor;
  final int patch;

  XCMPalletInfo(
      {required int index,
      required List<int> name,
      required List<int> moduleName,
      required int major,
      required int minor,
      required int patch})
      : name = name.max(maxPalletNameLen).asImmutableBytes,
        moduleName = moduleName.max(maxPalletNameLen).asImmutableBytes,
        index = index.asUint32,
        major = major.asUint32,
        minor = minor.asUint32,
        patch = patch.asUint32;
  factory XCMPalletInfo.deserializeJson(Map<String, dynamic> json) {
    return XCMPalletInfo(
        index: IntUtils.parse(json["index"]),
        name: (json["name"] as List).cast(),
        moduleName: (json["module_name"] as List).cast(),
        major: IntUtils.parse(json["major"]),
        minor: IntUtils.parse(json["minor"]),
        patch: IntUtils.parse(json["patch"]));
  }
  factory XCMPalletInfo.fromJson(Map<String, dynamic> json) {
    return XCMPalletInfo(
        index: json.valueAs("index"),
        name: json.valueAsBytes("name"),
        moduleName: json.valueAsBytes("module_name"),
        major: json.valueAs("major"),
        minor: json.valueAs("minor"),
        patch: json.valueAs("patch"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "index"),
      LayoutConst.bytes(property: "name"),
      LayoutConst.bytes(property: "module_name"),
      LayoutConst.compactIntU32(property: "major"),
      LayoutConst.compactIntU32(property: "minor"),
      LayoutConst.compactIntU32(property: "patch"),
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
      "major": major,
      "minor": minor,
      "patch": patch
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "name": name,
      "module_name": moduleName,
      "major": major,
      "minor": minor,
      "patch": patch
    };
  }

  @override
  List get variabels => [index, name, moduleName, major, minor, patch];
}

abstract mixin class XCMWithdrawAsset implements XCMInstruction {
  XCMAssets get assets;

  factory XCMWithdrawAsset.fromAssets(XCMAssets assets) {
    return switch (assets.version) {
      XCMVersion.v2 => XCMV2WithdrawAsset(assets: assets.cast()),
      XCMVersion.v3 => XCMV3WithdrawAsset(assets: assets.cast()),
      XCMVersion.v4 => XCMV4WithdrawAsset(assets: assets.cast()),
      XCMVersion.v5 => XCMV5WithdrawAsset(assets: assets.cast()),
    };
  }
  @override
  XCMInstructionType get type => XCMInstructionType.withdrawAsset;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

abstract mixin class XCMReserveAssetDeposited implements XCMInstruction {
  XCMAssets get assets;
  @override
  XCMInstructionType get type => XCMInstructionType.reserveAssetDeposited;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

abstract mixin class XCMReceiveTeleportedAsset implements XCMInstruction {
  XCMAssets get assets;
  @override
  XCMInstructionType get type => XCMInstructionType.receiveTeleportedAsset;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

abstract mixin class XCMQueryResponse implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.queryResponse;
}

abstract mixin class XCMTransferAsset implements XCMInstruction {
  XCMAssets get assets;
  XCMMultiLocation get beneficiary;

  @override
  XCMInstructionType get type => XCMInstructionType.transferAsset;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.assets.map((e) => e.toJson()).toList(),
        "beneficiary": beneficiary.toJson()
      }
    };
  }

  @override
  List get variabels => [type, assets, beneficiary];
}

abstract mixin class XCMTransferReserveAsset implements XCMInstruction {
  XCMAssets get assets;
  XCMMultiLocation get dest;
  XCM get xcm;
  @override
  XCMInstructionType get type => XCMInstructionType.transferReserveAsset;
  factory XCMTransferReserveAsset.fromAssets(
      {required XCMAssets assets,
      required XCMMultiLocation dest,
      required XCM xcm}) {
    return switch (assets.version) {
      XCMVersion.v2 => XCMV2TransferReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v3 => XCMV3TransferReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v4 => XCMV4TransferReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v5 => XCMV5TransferReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
    };
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.assets.map((e) => e.toJson()).toList(),
        "dest": dest.toJson(),
        "xcm": xcm.instructions.map((e) => e.toJson()).toList()
      }
    };
  }

  @override
  List get variabels => [type, assets, dest, xcm];
}

abstract mixin class XCMTransact implements XCMInstruction {
  List<int> get call;

  @override
  XCMInstructionType get type => XCMInstructionType.transact;
}

abstract mixin class XCMHrmpNewChannelOpenRequest implements XCMInstruction {
  int get sender;
  int get maxMessageSize;
  int get maxCapacity;

  @override
  XCMInstructionType get type => XCMInstructionType.hrmpNewChannelOpenRequest;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "sender": sender,
        "max_message_size": maxMessageSize,
        "max_capacity": maxCapacity
      }
    };
  }

  @override
  List get variabels => [type, sender, maxMessageSize, maxCapacity];
}

abstract mixin class XCMHrmpChannelAccepted implements XCMInstruction {
  int get recipient;
  @override
  XCMInstructionType get type => XCMInstructionType.hrmpChannelAccepted;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: recipient};
  }

  @override
  List get variabels => [type, recipient];
}

abstract mixin class XCMHrmpChannelClosing implements XCMInstruction {
  int get initiator;
  int get sender;
  int get recipient;
  @override
  XCMInstructionType get type => XCMInstructionType.hrmpChannelClosing;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "sender": sender,
        "initiator": initiator,
        "recipient": recipient
      }
    };
  }

  @override
  List get variabels => [type, initiator, sender, recipient];
}

abstract mixin class XCMClearOrigin implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.clearOrigin;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMDescendOrigin implements XCMInstruction {
  XCMJunctions get interior;

  @override
  XCMInstructionType get type => XCMInstructionType.descendOrigin;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: interior.toJson()};
  }

  @override
  List get variabels => [type, interior];
}

abstract mixin class XCMReportError implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.reportError;
}

abstract mixin class XCMDepositAsset implements XCMInstruction {
  XCMMultiAssetFilter get assets;
  XCMMultiLocation get beneficiary;
  @override
  XCMInstructionType get type => XCMInstructionType.depositAsset;

  factory XCMDepositAsset.fromAssets(
      {required XCMMultiAssetFilter assets,
      required XCMMultiLocation beneficiary}) {
    return switch (assets.version) {
      XCMVersion.v2 => XCMV2DepositAsset(
          assets: assets.cast(), beneficiary: beneficiary.cast(), maxAssets: 1),
      XCMVersion.v3 => XCMV3DepositAsset(
          assets: assets.cast(), beneficiary: beneficiary.cast()),
      XCMVersion.v4 => XCMV4DepositAsset(
          assets: assets.cast(), beneficiary: beneficiary.cast()),
      XCMVersion.v5 => XCMV5DepositAsset(
          assets: assets.cast(), beneficiary: beneficiary.cast()),
    };
  }
}

abstract mixin class XCMDepositReserveAsset implements XCMInstruction {
  XCMMultiAssetFilter get assets;
  XCMMultiLocation get dest;
  XCM get xcm;
  @override
  XCMInstructionType get type => XCMInstructionType.depositReserveAsset;
  factory XCMDepositReserveAsset.fromAssets(
      {required XCMMultiAssetFilter assets,
      required XCMMultiLocation dest,
      required XCM xcm}) {
    return switch (assets.version) {
      XCMVersion.v2 => XCMV2DepositReserveAsset(
          assets: assets.cast(),
          dest: dest.cast(),
          maxAssets: 1,
          xcm: xcm.cast()),
      XCMVersion.v3 => XCMV3DepositReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v4 => XCMV4DepositReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v5 => XCMV5DepositReserveAsset(
          assets: assets.cast(), dest: dest.cast(), xcm: xcm.cast()),
    };
  }
}

abstract mixin class XCMExchangeAsset implements XCMInstruction {
  XCMAssets get want;
  @override
  XCMInstructionType get type => XCMInstructionType.exchangeAsset;
}

abstract mixin class XCMInitiateReserveWithdraw implements XCMInstruction {
  XCMMultiAssetFilter get assets;
  XCMMultiLocation get reserve;
  XCM get xcm;

  factory XCMInitiateReserveWithdraw.build(
      {required XCMMultiAssetFilter assets,
      required XCMMultiLocation reserve,
      required XCM xcm}) {
    return switch (assets.version) {
      XCMVersion.v2 => XCMV2InitiateReserveWithdraw(
          assets: assets.cast(), reserve: reserve.cast(), xcm: xcm.cast()),
      XCMVersion.v3 => XCMV3InitiateReserveWithdraw(
          assets: assets.cast(), reserve: reserve.cast(), xcm: xcm.cast()),
      XCMVersion.v4 => XCMV4InitiateReserveWithdraw(
          assets: assets.cast(), reserve: reserve.cast(), xcm: xcm.cast()),
      XCMVersion.v5 => XCMV5InitiateReserveWithdraw(
          assets: assets.cast(), reserve: reserve.cast(), xcm: xcm.cast()),
    };
  }

  @override
  XCMInstructionType get type => XCMInstructionType.initiateReserveWithdraw;
}

abstract mixin class XCMInitiateTeleport implements XCMInstruction {
  XCMMultiLocation get dest;
  XCM get xcm;
  @override
  XCMInstructionType get type => XCMInstructionType.initiateTeleport;

  factory XCMInitiateTeleport.fromAsset(
      {required XCMMultiLocation dest,
      required XCM xcm,
      required XCMMultiAssetFilter asset}) {
    return switch (dest.version) {
      XCMVersion.v2 => XCMV2InitiateTeleport(
          assets: asset.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v3 => XCMV3InitiateTeleport(
          assets: asset.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v4 => XCMV4InitiateTeleport(
          assets: asset.cast(), dest: dest.cast(), xcm: xcm.cast()),
      XCMVersion.v5 => XCMV5InitiateTeleport(
          assets: asset.cast(), dest: dest.cast(), xcm: xcm.cast()),
    };
  }
}

abstract mixin class XCMReportHolding implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.reportHolding;
}

abstract mixin class XCMQueryHolding implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.queryHolding;
}

abstract mixin class XCMBuyExecution implements XCMInstruction {
  XCMAsset get fees;
  WeightLimit get weightLimit;
  factory XCMBuyExecution.fromFees(
      {required XCMAsset fees, WeightLimit? weightLimit}) {
    return switch (fees.version) {
      XCMVersion.v2 => XCMV2BuyExecution(
          fees: fees.cast(),
          weightLimit: weightLimit?.cast() ?? XCMV2WeightLimitUnlimited()),
      XCMVersion.v3 => XCMV3BuyExecution(
          fees: fees.cast(),
          weightLimit: weightLimit?.cast() ?? XCMV3WeightLimitUnlimited()),
      XCMVersion.v4 => XCMV4BuyExecution(
          fees: fees.cast(),
          weightLimit: weightLimit?.cast() ?? XCMV3WeightLimitUnlimited()),
      XCMVersion.v5 => XCMV5BuyExecution(
          fees: fees.cast(),
          weightLimit: weightLimit?.cast() ?? XCMV3WeightLimitUnlimited()),
    };
  }
  @override
  XCMInstructionType get type => XCMInstructionType.buyExecution;
}

abstract mixin class XCMRefundSurplus implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.refundSurplus;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMSetErrorHandler implements XCMInstruction {
  XCM get xcm;
  @override
  XCMInstructionType get type => XCMInstructionType.setErrorHandler;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: xcm.instructions.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, xcm];
}

abstract mixin class XCMSetAppendix implements XCMInstruction {
  XCM get xcm;

  factory XCMSetAppendix.fromXCM(XCM xcm) {
    return switch (xcm.version) {
      XCMVersion.v2 => XCMV2SetAppendix(xcm: xcm.cast()),
      XCMVersion.v3 => XCMV3SetAppendix(xcm: xcm.cast()),
      XCMVersion.v4 => XCMV4SetAppendix(xcm: xcm.cast()),
      XCMVersion.v5 => XCMV5SetAppendix(xcm: xcm.cast()),
    };
  }

  @override
  XCMInstructionType get type => XCMInstructionType.setAppendix;

  @override
  Map<String, dynamic> toJson() {
    return {type.type: xcm.instructions.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, xcm];
}

abstract mixin class XCMClearError implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.clearError;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMClaimAsset implements XCMInstruction {
  XCMAssets get assets;
  XCMMultiLocation get ticket;
  @override
  XCMInstructionType get type => XCMInstructionType.claimAsset;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "assets": assets.assets.map((e) => e.toJson()).toList(),
        "ticket": ticket.toJson()
      }
    };
  }

  @override
  List get variabels => [type, assets, ticket];
}

abstract mixin class XCMTrap implements XCMInstruction {
  BigInt get trap;
  @override
  XCMInstructionType get type => XCMInstructionType.trap;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: trap};
  }

  @override
  List get variabels => [type, trap];
}

abstract mixin class XCMSubscribeVersion implements XCMInstruction {
  BigInt get queryId;
  @override
  XCMInstructionType get type => XCMInstructionType.subscribeVersion;
}

abstract mixin class XCMUnsubscribeVersion implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.unsubscribeVersion;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMBurnAsset implements XCMInstruction {
  XCMAssets get assets;
  @override
  XCMInstructionType get type => XCMInstructionType.burnAsset;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

abstract mixin class XCMExpectAsset implements XCMInstruction {
  XCMAssets get assets;
  @override
  XCMInstructionType get type => XCMInstructionType.expectAsset;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: assets.assets.map((e) => e.toJson()).toList()};
  }

  @override
  List get variabels => [type, assets];
}

abstract mixin class XCMExpectOrigin implements XCMInstruction {
  XCMMultiLocation? get location;
  @override
  XCMInstructionType get type => XCMInstructionType.expectOrigin;
  @override
  List get variabels => [type, location];
}

abstract mixin class XCMExpectError implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.expectError;
}

abstract mixin class XCMExpectTransactStatus implements XCMInstruction {
  XCMV3MaybeErrorCode get code;

  @override
  XCMInstructionType get type => XCMInstructionType.expectTransactStatus;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: code.toJson()};
  }

  @override
  List get variabels => [type, code];
}

abstract mixin class XCMQueryPallet implements XCMInstruction {
  List<int> get moduleName;
  @override
  XCMInstructionType get type => XCMInstructionType.queryPallet;
}

abstract mixin class XCMReportTransactStatus implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.reportTransactStatus;
}

abstract mixin class XCMClearTransactStatus implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.clearTransactStatus;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMUniversalOrigin implements XCMInstruction {
  XCMJunction get origin;
  @override
  XCMInstructionType get type => XCMInstructionType.universalOrigin;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: origin.toJson()};
  }

  @override
  List get variabels => [type, origin];
}

abstract mixin class XCMExportMessage implements XCMInstruction {
  XCMNetworkId get network;
  XCMJunctions get destination;
  XCM get xcm;
  @override
  XCMInstructionType get type => XCMInstructionType.exportMessage;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "network": network.toJson(),
        "destination": destination.toJson(),
        "xcm": xcm.instructions.map((e) => e.toJson()).toList()
      }
    };
  }

  @override
  List get variabels => [type, network, destination, xcm];
}

abstract mixin class XCMLockAsset implements XCMInstruction {
  XCMAsset get asset;
  XCMMultiLocation get unlocker;
  @override
  XCMInstructionType get type => XCMInstructionType.lockAsset;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"asset": asset.toJson(), "unlocker": unlocker.toJson()}
    };
  }

  @override
  List get variabels => [type, asset, unlocker];
}

abstract mixin class XCMUnlockAsset implements XCMInstruction {
  XCMAsset get asset;
  XCMMultiLocation get target;
  @override
  XCMInstructionType get type => XCMInstructionType.unlockAsset;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"asset": asset.toJson(), "target": target.toJson()}
    };
  }

  @override
  List get variabels => [type, asset, target];
}

abstract mixin class XCMNoteUnlockable implements XCMInstruction {
  XCMAsset get asset;
  XCMMultiLocation get owner;

  @override
  XCMInstructionType get type => XCMInstructionType.noteUnlockable;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"asset": asset.toJson(), "owner": owner.toJson()}
    };
  }

  @override
  List get variabels => [type, asset, owner];
}

abstract mixin class XCMRequestUnlock implements XCMInstruction {
  XCMAsset get asset;
  XCMMultiLocation get locker;

  @override
  XCMInstructionType get type => XCMInstructionType.requestUnlock;

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"asset": asset.toJson(), "locker": locker.toJson()}
    };
  }

  @override
  List get variabels => [type, asset, locker];
}

abstract mixin class XCMSetFeesMode implements XCMInstruction {
  bool get jitWithdraw;
  factory XCMSetFeesMode.fromVersion(
      {required XCMVersion version, bool jitWithdraw = true}) {
    return switch (version) {
      XCMVersion.v2 => throw DartSubstratePluginException(
          "Unsupported xcm instraction by version 2.",
          details: {"type": XCMInstructionType.setFeesMode.type}),
      XCMVersion.v3 => XCMV3SetFeesMode(jitWithdraw: jitWithdraw),
      XCMVersion.v4 => XCMV4SetFeesMode(jitWithdraw: jitWithdraw),
      XCMVersion.v5 => XCMV5SetFeesMode(jitWithdraw: jitWithdraw),
    };
  }
  @override
  XCMInstructionType get type => XCMInstructionType.setFeesMode;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: jitWithdraw};
  }

  @override
  List get variabels => [type, jitWithdraw];
}

abstract mixin class XCMSetTopic implements XCMInstruction {
  List<int> get topic;

  @override
  XCMInstructionType get type => XCMInstructionType.setTopic;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: topic};
  }

  @override
  List get variabels => [type, topic];
}

abstract mixin class XCMClearTopic implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.clearTopic;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  List get variabels => [type];
}

abstract mixin class XCMAliasOrigin implements XCMInstruction {
  XCMMultiLocation get origin;

  @override
  XCMInstructionType get type => XCMInstructionType.aliasOrigin;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: origin.toJson()};
  }

  @override
  List get variabels => [type, origin];
}

abstract mixin class XCMUnpaidExecution implements XCMInstruction {
  XCMV3WeightLimit get weightLimit;
  XCMMultiLocation? get checkOrigin;
  @override
  XCMInstructionType get type => XCMInstructionType.unpaidExecution;
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {
        "weight_limit": weightLimit.toJson(),
        "check_origin": MetadataUtils.toOptionalJson(checkOrigin?.toJson())
      }
    };
  }

  @override
  List get variabels => [type, weightLimit, checkOrigin];
}

abstract mixin class XCMPayFees implements XCMInstruction {
  XCMAsset get asset;
  @override
  XCMInstructionType get type => XCMInstructionType.payFees;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: asset.toJson()};
  }

  @override
  List get variabels => [type, asset];
}

abstract mixin class XCMInitiateTransfer implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.initiateTransfer;
}

abstract mixin class XCMExecuteWithOrigin implements XCMInstruction {
  XCM get xcm;
  @override
  XCMInstructionType get type => XCMInstructionType.executeWithOrigin;
}

abstract mixin class XCMSetHints implements XCMInstruction {
  @override
  XCMInstructionType get type => XCMInstructionType.setHints;
}

abstract mixin class XCMExpectPallet implements XCMInstruction {
  int get index;
  List<int> get name;
  List<int> get moduleName;
  int get crateMajor;
  int get minCrateMinor;

  @override
  XCMInstructionType get type => XCMInstructionType.expectPallet;
}
