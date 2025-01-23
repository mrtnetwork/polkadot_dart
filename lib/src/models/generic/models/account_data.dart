import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

abstract class BaseSubstrateAccount<DATA extends Object>
    extends SubstrateSerialization<Map<String, dynamic>> {
  final int nonce;
  final int consumers;
  final int providers;
  final int sufficients;
  abstract final DATA data;
  const BaseSubstrateAccount(
      {required this.nonce,
      required this.consumers,
      required this.providers,
      required this.sufficients});
  BaseSubstrateAccount.deserializeJson(Map<String, dynamic> json)
      : nonce = json["nonce"],
        consumers = json["consumers"],
        providers = json["providers"],
        sufficients = json["sufficients"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.account(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "nonce": nonce,
      "consumers": consumers,
      "providers": providers,
      "sufficients": sufficients,
    };
  }
}

class SubstrateAccount extends BaseSubstrateAccount<Object> {
  @override
  final Object data;
  const SubstrateAccount(
      {required super.nonce,
      required super.consumers,
      required super.providers,
      required super.sufficients,
      required this.data});
  SubstrateAccount.deserializeJson(super.json)
      : data = json["data"],
        super.deserializeJson();

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.account(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {...super.scaleJsonSerialize(), "data": data};
  }
}

class SubstrateDefaultAccount
    extends BaseSubstrateAccount<SubstrateAccountData> {
  @override
  final SubstrateAccountData data;
  const SubstrateDefaultAccount(
      {required super.nonce,
      required super.consumers,
      required super.providers,
      required super.sufficients,
      required this.data});
  SubstrateDefaultAccount.deserializeJson(super.json)
      : data = SubstrateAccountData.deserializeJson(json["data"]),
        super.deserializeJson();

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.account(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {...super.scaleJsonSerialize(), "data": data.scaleJsonSerialize()};
  }
}

/// at most network support this template for account data
class SubstrateAccountData
    extends SubstrateSerialization<Map<String, dynamic>> {
  final BigInt free;
  final BigInt? reserved;
  final BigInt? frozen;
  final BigInt? flags;
  const SubstrateAccountData(
      {required this.flags,
      required this.reserved,
      required this.frozen,
      required this.free});
  SubstrateAccountData.deserializeJson(Map<String, dynamic> json)
      : free = json["free"],
        reserved = json["reserved"],
        flags = json["flags"],
        frozen = json["frozen"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.accountData(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "free": free,
      "reserved": reserved,
      "frozen": frozen,
      "flags": flags
    };
  }
}
