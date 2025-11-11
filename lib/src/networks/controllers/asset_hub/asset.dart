import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types/config.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum PolkadotAssetBalanceStatus {
  liquid('Liquid'),
  frozen('Frozen'),
  blocked('Blocked'),
  unknown("Unknown");

  final String status;

  const PolkadotAssetBalanceStatus(this.status);
  static PolkadotAssetBalanceStatus fromJson(Map<String, dynamic> json) {
    final status =
        values.firstWhereNullable((e) => e.status == json.keys.firstOrNull);
    return status ?? PolkadotAssetBalanceStatus.unknown;
  }

  Map<String, dynamic> toJson() {
    return {status: null};
  }
}

enum PolkadotAssetBalanceReasonType {
  consumer('Consumer'),
  sufficient('Sufficient'),
  depositHeld('DepositHeld'),
  depositRefunded('DepositRefunded'),
  depositFrom('DepositFrom'),
  unknown("Unknown");

  final String type;

  const PolkadotAssetBalanceReasonType(this.type);
  static PolkadotAssetBalanceReasonType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? PolkadotAssetBalanceReasonType.unknown;
  }
}

abstract class BasePolkadotAssetBalanceReason {
  final Map<String, dynamic> identifier;
  final PolkadotAssetBalanceReasonType type;
  const BasePolkadotAssetBalanceReason(
      {required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BasePolkadotAssetBalanceReason.fromJson(Map<String, dynamic> json) {
    final type = PolkadotAssetBalanceReasonType.fromJson(json);
    return switch (type) {
      PolkadotAssetBalanceReasonType.consumer =>
        PolkadotAssetBalanceReasonConsumer.fromJson(json),
      PolkadotAssetBalanceReasonType.sufficient =>
        PolkadotAssetBalanceReasonSufficient.fromJson(json),
      PolkadotAssetBalanceReasonType.depositRefunded =>
        PolkadotAssetBalanceReasonDepositRefunded.fromJson(json),
      PolkadotAssetBalanceReasonType.depositHeld =>
        PolkadotAssetBalanceReasonDepositHeld.fromJson(json),
      PolkadotAssetBalanceReasonType.depositFrom =>
        PolkadotAssetBalanceReasonDepositFrom.fromJson(json),
      PolkadotAssetBalanceReasonType.unknown =>
        PolkadotAssetBalanceReasonUnknown.fromJson(json),
    };
  }
}

class PolkadotAssetBalanceReasonConsumer
    extends BasePolkadotAssetBalanceReason {
  const PolkadotAssetBalanceReasonConsumer({required super.identifier})
      : super(type: PolkadotAssetBalanceReasonType.consumer);
  PolkadotAssetBalanceReasonConsumer.fromJson(Map<String, dynamic> json)
      : super(type: PolkadotAssetBalanceReasonType.consumer, identifier: json);
}

class PolkadotAssetBalanceReasonSufficient
    extends BasePolkadotAssetBalanceReason {
  const PolkadotAssetBalanceReasonSufficient({required super.identifier})
      : super(type: PolkadotAssetBalanceReasonType.sufficient);
  PolkadotAssetBalanceReasonSufficient.fromJson(Map<String, dynamic> json)
      : super(
            type: PolkadotAssetBalanceReasonType.sufficient, identifier: json);
}

class PolkadotAssetBalanceReasonDepositRefunded
    extends BasePolkadotAssetBalanceReason {
  const PolkadotAssetBalanceReasonDepositRefunded({required super.identifier})
      : super(type: PolkadotAssetBalanceReasonType.depositRefunded);
  PolkadotAssetBalanceReasonDepositRefunded.fromJson(Map<String, dynamic> json)
      : super(
            type: PolkadotAssetBalanceReasonType.depositRefunded,
            identifier: json);
}

class PolkadotAssetBalanceReasonDepositHeld
    extends BasePolkadotAssetBalanceReason {
  final BigInt amount;
  const PolkadotAssetBalanceReasonDepositHeld(
      {required this.amount, required super.identifier})
      : super(type: PolkadotAssetBalanceReasonType.depositHeld);
  PolkadotAssetBalanceReasonDepositHeld.fromJson(Map<String, dynamic> json)
      : amount = json.valueAs(PolkadotAssetBalanceReasonType.depositHeld.type),
        super(
            type: PolkadotAssetBalanceReasonType.depositHeld, identifier: json);
}

class PolkadotAssetBalanceReasonDepositFrom
    extends BasePolkadotAssetBalanceReason {
  final BigInt amount;
  final SubstrateAddress from;
  const PolkadotAssetBalanceReasonDepositFrom(
      {required this.from, required this.amount, required super.identifier})
      : super(type: PolkadotAssetBalanceReasonType.depositFrom);
  PolkadotAssetBalanceReasonDepositFrom.fromJson(Map<String, dynamic> json)
      : from = SubstrateAddress.fromBytes(BytesUtils.fromHexString(
            json.valueEnsureAsList(
                PolkadotAssetBalanceReasonType.depositFrom.type)[0])),
        amount = BigintUtils.parse(json.valueEnsureAsList(
            PolkadotAssetBalanceReasonType.depositFrom.type)[1]),
        super(
            type: PolkadotAssetBalanceReasonType.depositFrom, identifier: json);
}

class PolkadotAssetBalanceReasonUnknown extends BasePolkadotAssetBalanceReason {
  const PolkadotAssetBalanceReasonUnknown({required super.identifier})
      : super(type: PolkadotAssetBalanceReasonType.unknown);
  PolkadotAssetBalanceReasonUnknown.fromJson(Map<String, dynamic> json)
      : super(type: PolkadotAssetBalanceReasonType.unknown, identifier: json);
}

class PolkadotAssetBalance {
  final BigInt balance;
  final PolkadotAssetBalanceStatus status;
  final BasePolkadotAssetBalanceReason reason;
  const PolkadotAssetBalance(
      {required this.balance, required this.status, required this.reason});
  PolkadotAssetBalance.fromJson(Map<String, dynamic> json)
      : balance = json.valueAs("balance"),
        status = PolkadotAssetBalanceStatus.fromJson(json.valueAs("status")),
        reason =
            BasePolkadotAssetBalanceReason.fromJson(json.valueAs("reason"));
  Map<String, dynamic> toJson() {
    return {
      "balance": balance.toString(),
      "status": status.toJson(),
      "reason": reason.toJson()
    };
  }
}

enum BasePolkadotNetworkAssetsStatus {
  live('Live'),
  frozen('Frozen'),
  destroying('Destroying');

  final String status;

  const BasePolkadotNetworkAssetsStatus(this.status);
  static BasePolkadotNetworkAssetsStatus fromJson(Map<String, dynamic> json) {
    final status = json.keys.firstOrNull;
    return values.firstWhere((e) => e.status == status,
        orElse: () => throw ItemNotFoundException(value: status));
  }

  Map<String, dynamic> toJson() {
    return {status: null};
  }
}

class PolkadotAssetHubAssetInfo {
  final BaseSubstrateAddress owner;
  final BaseSubstrateAddress issuer;
  final BaseSubstrateAddress admin;
  final BaseSubstrateAddress freezer;
  final BigInt supply;
  final BigInt deposit;
  final bool isSufficient;
  final BigInt minBalance;
  final int accounts;
  final int sufficients;
  final int approvals;
  final BasePolkadotNetworkAssetsStatus status;
  PolkadotAssetHubAssetInfo({
    required this.owner,
    required this.issuer,
    required this.admin,
    required this.freezer,
    required this.supply,
    required this.deposit,
    required this.isSufficient,
    required this.accounts,
    required this.sufficients,
    required this.approvals,
    required this.status,
    required this.minBalance,
  });

  PolkadotAssetHubAssetInfo.fromJson(Map<String, dynamic> json)
      : owner = BaseSubstrateAddress.fromBytes(json.valueAsBytes("owner")),
        issuer = BaseSubstrateAddress.fromBytes(json.valueAsBytes("issuer")),
        admin = BaseSubstrateAddress.fromBytes(json.valueAsBytes("admin")),
        freezer = BaseSubstrateAddress.fromBytes(json.valueAsBytes("freezer")),
        supply = json.valueAsBigInt("supply"),
        deposit = json.valueAs("deposit"),
        // minBalance =,
        isSufficient = json.valueAs("is_sufficient"),
        accounts = json.valueAs("accounts"),
        sufficients = json.valueAs("sufficients"),
        approvals = json.valueAs("approvals"),
        status = BasePolkadotNetworkAssetsStatus.fromJson(
            json.valueEnsureAsMap<String, dynamic>("status")),
        minBalance = json.valueAs("min_balance"),
        super();
  Map<String, dynamic> toJson() {
    return {
      "owner": owner.toHex(),
      "issuer": issuer.toHex(),
      "admin": admin.toHex(),
      "freezer": freezer,
      "supply": supply.toString(),
      "deposit": deposit.toString(),
      "is_sufficient": isSufficient,
      "accounts": accounts,
      "sufficients": sufficients,
      "approvals": approvals,
      "min_balance": minBalance.toString(),
      "status": status.toJson()
    };
  }
}

class PolkadotAssetHubAssetMetadata {
  final BigInt deposit;
  final String name;
  final String symbol;
  final int decimals;
  final bool isFrozen;
  PolkadotAssetHubAssetMetadata.fromJson(Map<String, dynamic> json)
      : deposit = json.valueAs("deposit"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        isFrozen = json.valueAsBool("is_frozen"),
        super();
  const PolkadotAssetHubAssetMetadata(
      {required this.deposit,
      required this.name,
      required this.symbol,
      required this.decimals,
      required this.isFrozen});
  Map<String, dynamic> toJson() {
    return {
      "deposit": deposit,
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
      "is_frozen": isFrozen
    };
  }
}

abstract class BasePolkadotAssetHubAsset<ASSETID extends Object> {
  ASSETID get assetId;
  PolkadotAssetHubAssetInfo get asset;
  Map<String, dynamic> toJson();
  SubtrateMetadataPallet get type;
  bool identifierEqual(Object? identifier);
  const BasePolkadotAssetHubAsset();
  factory BasePolkadotAssetHubAsset.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("location")) {
      return PolkadotAssetHubForeignAsset.fromJson(json)
          as BasePolkadotAssetHubAsset<ASSETID>;
    }
    return PolkadotAssetHubAsset.fromJson(json)
        as BasePolkadotAssetHubAsset<ASSETID>;
  }
}

class PolkadotAssetHubAsset implements BasePolkadotAssetHubAsset<BigInt> {
  @override
  final PolkadotAssetHubAssetInfo asset;
  @override
  final BigInt assetId;

  PolkadotAssetHubAsset.fromJson(Map<String, dynamic> json)
      : asset = PolkadotAssetHubAssetInfo.fromJson(json.valueAs("asset")),
        assetId = json.valueAs("asset_id");
  PolkadotAssetHubAsset({required this.asset, required this.assetId});

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "asset_id": assetId.toString(),
    };
  }

  @override
  SubtrateMetadataPallet get type => SubtrateMetadataPallet.assets;

  @override
  bool identifierEqual(Object? identifier) {
    return assetId == identifier;
  }
}

class PolkadotAssetHubForeignAsset
    implements BasePolkadotAssetHubAsset<XCMVersionedLocation> {
  @override
  final PolkadotAssetHubAssetInfo asset;
  @override
  SubtrateMetadataPallet get type => SubtrateMetadataPallet.foreignAssets;
  @override
  final XCMVersionedLocation assetId;
  PolkadotAssetHubForeignAsset.fromJson(Map<String, dynamic> json,
      {XCMVersion version = XCMVersion.v4})
      : asset = PolkadotAssetHubAssetInfo.fromJson(json.valueAs("asset")),
        assetId = XCMVersionedLocation.fromJson(json.valueAs("location"));
  PolkadotAssetHubForeignAsset({required this.asset, required this.assetId});

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "location": assetId.toJson(),
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is XCMVersionedLocation) {
      return assetId.location.isEqual(identifier.location);
    }
    return false;
  }
}

abstract class BasePolkadotAssetHubNetworkAsset
    extends BaseSubstrateNetworkAsset {
  BasePolkadotAssetHubNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet,
      required super.chargeAssetTxPayment});
  BasePolkadotAssetHubNetworkAsset.fromJson(super.json) : super.fromJson();
  @override
  Object? asChargeTxPaymentAssetId(
      {required BaseSubstrateNetwork network, required XCMVersion version}) {
    if (chargeAssetTxPayment) {
      return getAssetId(version: version, reserveNetwork: network).toJson();
    }
    return null;
  }
}

class PolkadotAssetHubNetworkAsset extends BasePolkadotAssetHubNetworkAsset {
  final BasePolkadotAssetHubAsset asset;
  final PolkadotAssetHubAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;

  PolkadotAssetHubNetworkAsset({
    required this.asset,
    required this.metadata,
    required this.location,
    required super.isFeeToken,
    required super.chargeAssetTxPayment,
  }) : super(
            decimals: metadata?.decimals,
            excutionPallet: asset.type,
            minBalance: asset.asset.minBalance,
            name: metadata?.name,
            symbol: metadata?.symbol,
            isSpendable:
                asset.asset.status != BasePolkadotNetworkAssetsStatus.frozen);
  factory PolkadotAssetHubNetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = BasePolkadotAssetHubAsset.fromJson(json.valueAs("asset"));
    final metadata =
        json.valueTo<PolkadotAssetHubAssetMetadata?, Map<String, dynamic>>(
      key: "metadata",
      parse: (v) {
        return PolkadotAssetHubAssetMetadata.fromJson(v);
      },
    );
    final bool isFeeToken = json.valueAs("is_fee_token");
    return PolkadotAssetHubNetworkAsset(
        asset: asset,
        metadata: metadata,
        chargeAssetTxPayment: json.valueAs("charge_asset_tx_payment"),
        location: (asset is PolkadotAssetHubForeignAsset)
            ? asset.assetId
            : json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
                key: "location",
                parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken);
  }

  @override
  Object get identifier => asset.assetId;
  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
      "charge_asset_tx_payment": chargeAssetTxPayment,
      if (asset is! PolkadotAssetHubForeignAsset) "location": location?.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    return asset.identifierEqual(identifier);
  }
}

class PolkadotAssetHubNetworkNativeAsset
    extends BasePolkadotAssetHubNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  Object? get identifier => null;
  PolkadotAssetHubNetworkNativeAsset({
    required this.location,
    super.isFeeToken = true,
    super.isSpendable = true,
    required super.name,
    required super.symbol,
    required super.decimals,
    super.minBalance,
  }) : super(
            excutionPallet: SubtrateMetadataPallet.balances,
            chargeAssetTxPayment: true);
  PolkadotAssetHubNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();
  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "location": location.toJson(),
      "identifier": identifier,
    };
  }
}
