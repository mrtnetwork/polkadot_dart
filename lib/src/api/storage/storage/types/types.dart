import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

enum SubstrateStorageApis {
  system("System"),
  xcmPallet("XcmPallet"),
  polkadotXcm("PolkadotXcm"),
  assets("Assets"),
  evmForeignAssets("EvmForeignAssets"),
  poolAssets("PoolAssets"),
  xcAssetConfig("XcAssetConfig"),
  foreignAssets("ForeignAssets"),
  fungibles("Fungibles"),
  fungible("Fungible"),
  assetRegistry("AssetRegistry"),
  assetsRegistry("AssetsRegistry"),
  assetManager("AssetManager"),
  ormlTokens("OrmlTokens"),
  ormlAssetRegistry("OrmlAssetRegistry"),
  tokens("Tokens"),
  xcmInfo("XcmInfo"),
  multisig("Multisig"),
  xcmTransactor("XcmTransactor"),
  xcmWeightTrader("XcmWeightTrader"),
  ;

  final String name;
  const SubstrateStorageApis(this.name);
}

abstract class SubstrateStorageApi {
  SubstrateStorageApis get api;
  const SubstrateStorageApi();
  bool isSupported(MetadataApi api, String methodName) {
    return api.metadata.storageMethodExists(this.api.name, methodName);
  }
}

abstract class BaseSubstrateAccount<DATA extends Object> {
  final BigInt nonce;
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
      : nonce = BigintUtils.parse(json["nonce"]),
        consumers = json["consumers"],
        providers = json["providers"],
        sufficients = json["sufficients"];

  Map<String, dynamic> toJson({String? property}) {
    return {
      "nonce": nonce.toString(),
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
  Map<String, dynamic> toJson({String? property}) {
    return {...super.toJson(), "data": data};
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
  Map<String, dynamic> toJson({String? property}) {
    return {...super.toJson(), "data": data.toJson()};
  }
}

/// at most network support this template for account data
class SubstrateAccountData {
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

  Map<String, dynamic> toJson({String? property}) {
    return {
      "free": free,
      "reserved": reserved,
      "frozen": frozen,
      "flags": flags
    };
  }
}

class MultisigExtrinsicInfo {
  final int height;
  final int index;
  MultisigExtrinsicInfo({required int height, required int index})
      : height = height.asUint32,
        index = index.asUint32;
  factory MultisigExtrinsicInfo.fromJson(Map<String, dynamic> json) {
    return MultisigExtrinsicInfo(
        height: json.valueAs("height"), index: json.valueAs("index"));
  }

  Map<String, dynamic> toJson() {
    return {"height": height, "index": index};
  }
}

class SubstrateMultisig {
  final MultisigExtrinsicInfo when;
  final BigInt deposit;
  final BaseSubstrateAddress depositor;
  final List<BaseSubstrateAddress> approvals;
  SubstrateMultisig(
      {required this.when,
      required this.deposit,
      required this.depositor,
      required List<BaseSubstrateAddress> approvals})
      : approvals = approvals.immutable;
  factory SubstrateMultisig.fromJson(Map<String, dynamic> json) {
    return SubstrateMultisig(
        when: MultisigExtrinsicInfo.fromJson(json.valueAs("when")),
        deposit: json.valueAsBigInt("deposit"),
        depositor:
            BaseSubstrateAddress.fromBytes(json.valueAsBytes("depositor")),
        approvals: json
            .valueEnsureAsList<String>("approvals")
            .map((e) =>
                BaseSubstrateAddress.fromBytes(BytesUtils.fromHexString(e)))
            .toList());
  }
}

class SubstrateMultisigWithCallhash {
  final SubstrateMultisig multisig;
  final List<int> callHash;
  final String callHashHex;
  SubstrateMultisigWithCallhash(
      {required this.multisig, required List<int> callHash})
      : callHash =
            callHash.exc(QuickCrypto.blake2b256DigestSize).asImmutableBytes,
        callHashHex = BytesUtils.toHexString(callHash);
}
