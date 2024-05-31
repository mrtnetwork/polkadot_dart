import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class SubstrateAccountInfo
    extends SubstrateSerialization<Map<String, dynamic>> {
  final int nonce;
  final int consumers;
  final int providers;
  final int sufficients;
  final SubstrateAccountData data;
  const SubstrateAccountInfo(
      {required this.nonce,
      required this.consumers,
      required this.providers,
      required this.sufficients,
      required this.data});
  SubstrateAccountInfo.deserializeJson(Map<String, dynamic> json)
      : nonce = json["nonce"],
        consumers = json["consumers"],
        providers = json["providers"],
        sufficients = json["sufficients"],
        data = SubstrateAccountData.deserializeJson(json["data"]);

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
      "data": data.scaleJsonSerialize()
    };
  }
}

class SubstrateAccountData
    extends SubstrateSerialization<Map<String, dynamic>> {
  final BigInt free;
  final BigInt reserved;
  final BigInt frozen;
  final BigInt flags;
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
