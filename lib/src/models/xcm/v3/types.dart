import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

abstract class XCMV3NetworkId extends SubstrateVariantSerialization
    with XCMNetworkId, Equality {
  const XCMV3NetworkId();
  factory XCMV3NetworkId.fromJson(Map<String, dynamic> json) {
    final type = XCMNetworkIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMNetworkIdType.byGenesis => XCMV3ByGenesis.fromJson(json),
      XCMNetworkIdType.byFork => XCMV3ByFork.fromJson(json),
      XCMNetworkIdType.polkadot => XCMV3Polkadot.fromJson(json),
      XCMNetworkIdType.kusama => XCMV3Kusama.fromJson(json),
      XCMNetworkIdType.ethereum => XCMV3Ethereum.fromJson(json),
      XCMNetworkIdType.rococo => XCMV3Rococo.fromJson(json),
      XCMNetworkIdType.wococo => XCMV3Wococo.fromJson(json),
      XCMNetworkIdType.bitcoinCash => XCMV3BitcoinCash.fromJson(json),
      XCMNetworkIdType.bitcoinCore => XCMV3BitcoinCore.fromJson(json),
      XCMNetworkIdType.polkadotBulletIn => XCMV3PolkadotBulletIn.fromJson(json),
      XCMNetworkIdType.westend => XCMV3Westend.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 3.",
          details: {"type": type.name})
    };
  }

  factory XCMV3NetworkId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMNetworkIdType.fromName(decode.variantName);
    return switch (type) {
      XCMNetworkIdType.byGenesis =>
        XCMV3ByGenesis.deserializeJson(decode.value),
      XCMNetworkIdType.byFork => XCMV3ByFork.deserializeJson(decode.value),
      XCMNetworkIdType.polkadot => XCMV3Polkadot.deserializeJson(decode.value),
      XCMNetworkIdType.kusama => XCMV3Kusama.deserializeJson(decode.value),
      XCMNetworkIdType.ethereum => XCMV3Ethereum.deserializeJson(decode.value),
      XCMNetworkIdType.rococo => XCMV3Rococo.deserializeJson(decode.value),
      XCMNetworkIdType.wococo => XCMV3Wococo.deserializeJson(decode.value),
      XCMNetworkIdType.bitcoinCash =>
        XCMV3BitcoinCash.deserializeJson(decode.value),
      XCMNetworkIdType.bitcoinCore =>
        XCMV3BitcoinCore.deserializeJson(decode.value),
      XCMNetworkIdType.polkadotBulletIn =>
        XCMV3PolkadotBulletIn.deserializeJson(decode.value),
      XCMNetworkIdType.westend => XCMV3Westend.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 3.",
          details: {"type": type.name})
    };
  }

  factory XCMV3NetworkId.from(XCMNetworkId network) {
    if (network is XCMV3NetworkId) return network;
    final type = network.type;
    return switch (type) {
      XCMNetworkIdType.byGenesis =>
        XCMV3ByGenesis(genesis: (network as XCMNetworkIdByGenesis).genesis),
      XCMNetworkIdType.byFork => () {
          final fork = network as XCMNetworkIdByFork;
          return XCMV3ByFork(
              blockHash: fork.blockHash, blockNumber: fork.blockNumber);
        }(),
      XCMNetworkIdType.polkadot => XCMV3Polkadot(),
      XCMNetworkIdType.kusama => XCMV3Kusama(),
      XCMNetworkIdType.wococo => XCMV3Wococo(),
      XCMNetworkIdType.rococo => XCMV3Rococo(),
      XCMNetworkIdType.westend => XCMV3Westend(),
      XCMNetworkIdType.ethereum =>
        XCMV3Ethereum(chainId: (network as XCMNetworkIdEthereum).chainId),
      XCMNetworkIdType.bitcoinCash => XCMV3BitcoinCash(),
      XCMNetworkIdType.bitcoinCore => XCMV3BitcoinCore(),
      XCMNetworkIdType.polkadotBulletIn => XCMV3PolkadotBulletIn(),
      _ => throw DartSubstratePluginException(
          "Unsuported network type by version 3.",
          details: {"type": type.name})
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMNetworkIdByGenesis.layout_(property: property),
          property: XCMNetworkIdType.byGenesis.name,
          index: 0),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdByFork.layout_(property: property),
        property: XCMNetworkIdType.byFork.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdPolkadot.layout_(property: property),
        property: XCMNetworkIdType.polkadot.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdKusama.layout_(property: property),
        property: XCMNetworkIdType.kusama.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdWestend.layout_(property: property),
        property: XCMNetworkIdType.westend.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdRococo.layout_(property: property),
        property: XCMNetworkIdType.rococo.name,
        index: 5,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdWococo.layout_(property: property),
        property: XCMNetworkIdType.wococo.name,
        index: 6,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdEthereum.layout_(property: property),
        property: XCMNetworkIdType.ethereum.name,
        index: 7,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdBitcoinCore.layout_(property: property),
        property: XCMNetworkIdType.bitcoinCore.name,
        index: 8,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdBitcoinCash.layout_(property: property),
        property: XCMNetworkIdType.bitcoinCash.name,
        index: 9,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdPolkadotBulletIn.layout_(property: property),
        property: XCMNetworkIdType.polkadotBulletIn.name,
        index: 10,
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
  Map<String, dynamic> toJson();
  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3ByGenesis extends XCMV3NetworkId with XCMNetworkIdByGenesis {
  @override
  final List<int> genesis;
  XCMV3ByGenesis({required List<int> genesis})
      : genesis = genesis
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes;

  factory XCMV3ByGenesis.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ByGenesis(genesis: (json["genesis"] as List).cast());
  }

  factory XCMV3ByGenesis.fromJson(Map<String, dynamic> json) {
    return XCMV3ByGenesis(
        genesis: json.valueAsBytes(XCMNetworkIdType.byGenesis.type));
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: genesis};
  }
}

class XCMV3ByFork extends XCMV3NetworkId with XCMNetworkIdByFork {
  @override
  final List<int> blockHash;
  @override
  final BigInt blockNumber;

  factory XCMV3ByFork.fromJson(Map<String, dynamic> json) {
    final byFork =
        json.valueEnsureAsMap<String, dynamic>(XCMNetworkIdType.byFork.type);
    return XCMV3ByFork(
        blockHash: byFork.valueAsBytes("block_hash"),
        blockNumber: byFork.valueAs("block_number"));
  }

  XCMV3ByFork({required List<int> blockHash, required BigInt blockNumber})
      : blockHash = blockHash
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes,
        blockNumber = blockNumber.asUint64;

  factory XCMV3ByFork.deserializeJson(Map<String, dynamic> json) {
    return XCMV3ByFork(
      blockNumber: BigintUtils.parse(json["block_number"]),
      blockHash: (json["block_hash"] as List).cast(),
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"block_hash": blockHash, "block_number": blockNumber}
    };
  }
}

class XCMV3Polkadot extends XCMV3NetworkId with XCMNetworkIdPolkadot {
  XCMV3Polkadot();
  XCMV3Polkadot.deserializeJson(Map<String, dynamic> json);
  factory XCMV3Polkadot.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadot.type);
    return XCMV3Polkadot();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3Kusama extends XCMV3NetworkId with XCMNetworkIdKusama {
  XCMV3Kusama();
  XCMV3Kusama.deserializeJson(Map<String, dynamic> json);
  factory XCMV3Kusama.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.kusama.type);
    return XCMV3Kusama();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3Westend extends XCMV3NetworkId with XCMNetworkIdWestend {
  XCMV3Westend();
  XCMV3Westend.deserializeJson(Map<String, dynamic> json);
  factory XCMV3Westend.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.westend.type);
    return XCMV3Westend();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3Rococo extends XCMV3NetworkId with XCMNetworkIdRococo {
  XCMV3Rococo();
  XCMV3Rococo.deserializeJson(Map<String, dynamic> json);
  factory XCMV3Rococo.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.rococo.type);
    return XCMV3Rococo();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3Wococo extends XCMV3NetworkId with XCMNetworkIdWococo {
  XCMV3Wococo();
  XCMV3Wococo.deserializeJson(Map<String, dynamic> json);
  factory XCMV3Wococo.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.wococo.type);
    return XCMV3Wococo();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3Ethereum extends XCMV3NetworkId with XCMNetworkIdEthereum {
  @override
  final BigInt chainId;
  const XCMV3Ethereum({required this.chainId});
  factory XCMV3Ethereum.fromJson(Map<String, dynamic> json) {
    final BigInt chainId = json.valueAs(XCMNetworkIdType.ethereum.type);
    return XCMV3Ethereum(chainId: chainId);
  }

  factory XCMV3Ethereum.deserializeJson(Map<String, dynamic> json) {
    return XCMV3Ethereum(chainId: BigintUtils.parse(json["chain_id"]));
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: chainId};
  }
}

class XCMV3BitcoinCore extends XCMV3NetworkId with XCMNetworkIdBitcoinCore {
  XCMV3BitcoinCore();
  XCMV3BitcoinCore.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BitcoinCore.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.bitcoinCore.type);
    return XCMV3BitcoinCore();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BitcoinCash extends XCMV3NetworkId with XCMNetworkIdBitcoinCash {
  XCMV3BitcoinCash();
  XCMV3BitcoinCash.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BitcoinCash.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.bitcoinCash.type);
    return XCMV3BitcoinCash();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3PolkadotBulletIn extends XCMV3NetworkId
    with XCMNetworkIdPolkadotBulletIn {
  XCMV3PolkadotBulletIn();
  XCMV3PolkadotBulletIn.deserializeJson(Map<String, dynamic> json);
  factory XCMV3PolkadotBulletIn.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadotBulletIn.type);
    return XCMV3PolkadotBulletIn();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

abstract class XCMV3BodyId extends SubstrateVariantSerialization
    with XCMBodyId, Equality {
  const XCMV3BodyId();
  factory XCMV3BodyId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMBodyIdType.fromName(decode.variantName);
    return switch (type) {
      XCMBodyIdType.unit => XCMV3BodyIdUnit.deserializeJson(decode.value),
      XCMBodyIdType.moniker => XCMV3BodyIdMoniker.deserializeJson(decode.value),
      XCMBodyIdType.indexId => XCMV3BodyIdIndex.deserializeJson(decode.value),
      XCMBodyIdType.executive =>
        XCMV3BodyIdExecutive.deserializeJson(decode.value),
      XCMBodyIdType.technical =>
        XCMV3BodyIdTechnical.deserializeJson(decode.value),
      XCMBodyIdType.legislative =>
        XCMV3BodyIdLegislative.deserializeJson(decode.value),
      XCMBodyIdType.judical => XCMV3BodyIdJudical.deserializeJson(decode.value),
      XCMBodyIdType.defense => XCMV3BodyIdDefense.deserializeJson(decode.value),
      XCMBodyIdType.administration =>
        XCMV3BodyIdAdministration.deserializeJson(decode.value),
      XCMBodyIdType.treasury =>
        XCMV3BodyIdTreasury.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported body id by version 3.",
          details: {"type": type.name})
    };
  }

  factory XCMV3BodyId.fromJson(Map<String, dynamic> json) {
    final type = XCMBodyIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMBodyIdType.unit => XCMV3BodyIdUnit.fromJson(json),
      XCMBodyIdType.moniker => XCMV3BodyIdMoniker.fromJson(json),
      XCMBodyIdType.indexId => XCMV3BodyIdIndex.fromJson(json),
      XCMBodyIdType.executive => XCMV3BodyIdExecutive.fromJson(json),
      XCMBodyIdType.technical => XCMV3BodyIdTechnical.fromJson(json),
      XCMBodyIdType.legislative => XCMV3BodyIdLegislative.fromJson(json),
      XCMBodyIdType.judical => XCMV3BodyIdJudical.fromJson(json),
      XCMBodyIdType.defense => XCMV3BodyIdDefense.fromJson(json),
      XCMBodyIdType.administration => XCMV3BodyIdAdministration.fromJson(json),
      XCMBodyIdType.treasury => XCMV3BodyIdTreasury.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported body id by version 3.",
          details: {"type": type.name})
    };
  }
  factory XCMV3BodyId.from(XCMBodyId body) {
    if (body is XCMV3BodyId) return body;
    final type = body.type;
    return switch (type) {
      XCMBodyIdType.unit => XCMV3BodyIdUnit(),
      XCMBodyIdType.moniker =>
        XCMV3BodyIdMoniker(moniker: (body as XCMBodyIdMoniker).moniker),
      XCMBodyIdType.indexId =>
        XCMV3BodyIdIndex(index: (body as XCMBodyIdIndex).index),
      XCMBodyIdType.executive => XCMV3BodyIdExecutive(),
      XCMBodyIdType.technical => XCMV3BodyIdTechnical(),
      XCMBodyIdType.legislative => XCMV3BodyIdLegislative(),
      XCMBodyIdType.judical => XCMV3BodyIdJudical(),
      XCMBodyIdType.defense => XCMV3BodyIdDefense(),
      XCMBodyIdType.administration => XCMV3BodyIdAdministration(),
      XCMBodyIdType.treasury => XCMV3BodyIdTreasury(),
      _ => throw DartSubstratePluginException(
          "Unsuported body id by version 3.",
          details: {"type": type.name})
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdUnit.layout_(property: property),
        property: XCMBodyIdType.unit.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdMoniker.layout_(property: property),
        property: XCMBodyIdType.moniker.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdIndex.layout_(property: property),
        property: XCMBodyIdType.indexId.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdExecutive.layout_(property: property),
        property: XCMBodyIdType.executive.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdTechnical.layout_(property: property),
        property: XCMBodyIdType.technical.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyIdLegislative.layout_(property: property),
        property: XCMBodyIdType.legislative.name,
        index: 5,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdJudical.layout_(property: property),
        property: XCMBodyIdType.judical.name,
        index: 6,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdDefense.layout_(property: property),
        property: XCMBodyIdType.defense.name,
        index: 7,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyIdAdministration.layout_(property: property),
        property: XCMBodyIdType.administration.name,
        index: 8,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdTreasury.layout_(property: property),
        property: XCMBodyIdType.treasury.name,
        index: 9,
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
  Map<String, dynamic> toJson();

  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3BodyIdMoniker extends XCMV3BodyId with XCMBodyIdMoniker {
  @override
  final List<int> moniker;
  XCMV3BodyIdMoniker({required List<int> moniker})
      : moniker = moniker.exc(4).asImmutableBytes;

  factory XCMV3BodyIdMoniker.deserializeJson(Map<String, dynamic> json) {
    return XCMV3BodyIdMoniker(
      moniker: (json["moniker"] as List).cast(),
    );
  }
  factory XCMV3BodyIdMoniker.fromJson(Map<String, dynamic> json) {
    final List<int> moniker = json.valueAsBytes(XCMBodyIdType.moniker.type);
    return XCMV3BodyIdMoniker(moniker: moniker);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: moniker};
  }
}

class XCMV3BodyIdUnit extends XCMV3BodyId with XCMBodyIdUnit {
  XCMV3BodyIdUnit();

  XCMV3BodyIdUnit.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdUnit.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.unit.type);
    return XCMV3BodyIdUnit();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdIndex extends XCMV3BodyId with XCMBodyIdIndex {
  @override
  final int index;
  XCMV3BodyIdIndex({required int index}) : index = index.asUint32;

  factory XCMV3BodyIdIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV3BodyIdIndex(index: IntUtils.parse(json["index"]));
  }
  factory XCMV3BodyIdIndex.fromJson(Map<String, dynamic> json) {
    final int index = json.valueAs(XCMBodyIdType.indexId.type);
    return XCMV3BodyIdIndex(index: index);
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: index};
  }
}

class XCMV3BodyIdExecutive extends XCMV3BodyId with XCMBodyIdExecutive {
  XCMV3BodyIdExecutive();
  XCMV3BodyIdExecutive.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdExecutive.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.executive.type);
    return XCMV3BodyIdExecutive();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdTechnical extends XCMV3BodyId with XCMBodyIdTechnical {
  XCMV3BodyIdTechnical();
  XCMV3BodyIdTechnical.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdTechnical.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.technical.type);
    return XCMV3BodyIdTechnical();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdLegislative extends XCMV3BodyId with XCMBodyIdLegislative {
  XCMV3BodyIdLegislative();
  XCMV3BodyIdLegislative.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdLegislative.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.legislative.type);
    return XCMV3BodyIdLegislative();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdJudical extends XCMV3BodyId with XCMBodyIdJudical {
  XCMV3BodyIdJudical();
  XCMV3BodyIdJudical.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdJudical.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.judical.type);
    return XCMV3BodyIdJudical();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdDefense extends XCMV3BodyId with XCMBodyIdDefense {
  XCMV3BodyIdDefense();
  XCMV3BodyIdDefense.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdDefense.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.defense.type);
    return XCMV3BodyIdDefense();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdAdministration extends XCMV3BodyId
    with XCMBodyIdAdministration {
  XCMV3BodyIdAdministration();
  XCMV3BodyIdAdministration.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdAdministration.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.administration.type);
    return XCMV3BodyIdAdministration();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3BodyIdTreasury extends XCMV3BodyId with XCMBodyIdTreasury {
  XCMV3BodyIdTreasury();
  XCMV3BodyIdTreasury.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyIdTreasury.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.treasury.type);
    return XCMV3BodyIdTreasury();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

abstract class XCMV3BodyPart extends SubstrateVariantSerialization
    with XCMBodyPart, Equality {
  bool get isMajority => false;
  const XCMV3BodyPart();
  factory XCMV3BodyPart.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMBodyPartType.fromName(decode.variantName);
    return switch (type) {
      XCMBodyPartType.voice => XCMV3BodyPartVoice.deserializeJson(decode.value),
      XCMBodyPartType.members =>
        XCMV3BodyPartMembers.deserializeJson(decode.value),
      XCMBodyPartType.fraction =>
        XCMV3BodyPartFraction.deserializeJson(decode.value),
      XCMBodyPartType.atLeastProportion =>
        XCMV3BodyPartAtLeastProportion.deserializeJson(decode.value),
      XCMBodyPartType.moreThanProportion =>
        XCMV3BodyPartMoreThanProportion.deserializeJson(decode.value)
    };
  }
  factory XCMV3BodyPart.fromJson(Map<String, dynamic> json) {
    final type = XCMBodyPartType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMBodyPartType.voice => XCMV3BodyPartVoice.fromJson(json),
      XCMBodyPartType.members => XCMV3BodyPartMembers.fromJson(json),
      XCMBodyPartType.fraction => XCMV3BodyPartFraction.fromJson(json),
      XCMBodyPartType.atLeastProportion =>
        XCMV3BodyPartAtLeastProportion.fromJson(json),
      XCMBodyPartType.moreThanProportion =>
        XCMV3BodyPartMoreThanProportion.fromJson(json)
    };
  }
  factory XCMV3BodyPart.from(XCMBodyPart body) {
    if (body is XCMV3BodyPart) return body;
    final type = body.type;
    return switch (type) {
      XCMBodyPartType.voice => XCMV3BodyPartVoice(),
      XCMBodyPartType.members =>
        XCMV3BodyPartMembers(count: (body as XCMBodyPartMembers).count),
      XCMBodyPartType.fraction => () {
          final fraction = body as XCMBodyPartFraction;
          return XCMV3BodyPartFraction(
              denom: fraction.denom, nom: fraction.nom);
        }(),
      XCMBodyPartType.atLeastProportion => () {
          final fraction = body as XCMBodyPartAtLeastProportion;
          return XCMV3BodyPartAtLeastProportion(
              denom: fraction.denom, nom: fraction.nom);
        }(),
      XCMBodyPartType.moreThanProportion => () {
          final fraction = body as XCMBodyPartMoreThanProportion;
          return XCMV3BodyPartMoreThanProportion(
              denom: fraction.denom, nom: fraction.nom);
        }(),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMBodyPartVoice.layout_(property: property),
        property: XCMBodyPartType.voice.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyPartMembers.layout_(property: property),
        property: XCMBodyPartType.members.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyPartFraction.layout_(property: property),
        property: XCMBodyPartType.fraction.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyPartAtLeastProportion.layout_(property: property),
        property: XCMBodyPartType.atLeastProportion.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyPartMoreThanProportion.layout_(property: property),
        property: XCMBodyPartType.moreThanProportion.name,
        index: 4,
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
  Map<String, dynamic> toJson();
  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3BodyPartMembers extends XCMV3BodyPart with XCMBodyPartMembers {
  @override
  final int count;
  XCMV3BodyPartMembers({required int count}) : count = count.asUint32;

  factory XCMV3BodyPartMembers.deserializeJson(Map<String, dynamic> json) {
    return XCMV3BodyPartMembers(count: IntUtils.parse(json["count"]));
  }
  factory XCMV3BodyPartMembers.fromJson(Map<String, dynamic> json) {
    final int count = json.valueAs(XCMBodyPartType.members.type);
    return XCMV3BodyPartMembers(count: count);
  }
}

class XCMV3BodyPartVoice extends XCMV3BodyPart with XCMBodyPartVoice {
  XCMV3BodyPartVoice();
  XCMV3BodyPartVoice.deserializeJson(Map<String, dynamic> json);
  factory XCMV3BodyPartVoice.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyPartType.voice.type);
    return XCMV3BodyPartVoice();
  }
}

class XCMV3BodyPartFraction extends XCMV3BodyPart with XCMBodyPartFraction {
  @override
  final int nom;
  @override
  final int denom;
  @override
  bool get isMajority => nom * 2 > denom;
  XCMV3BodyPartFraction({required int nom, required int denom})
      : nom = nom.asUint32,
        denom = denom.asUint32;

  XCMV3BodyPartFraction.deserializeJson(Map<String, dynamic> json)
      : nom = IntUtils.parse(json["nom"]),
        denom = IntUtils.parse(json["denom"]);
  factory XCMV3BodyPartFraction.fromJson(Map<String, dynamic> json) {
    final fraction =
        json.valueEnsureAsMap<String, dynamic>(XCMBodyPartType.fraction.type);
    return XCMV3BodyPartFraction(
        denom: fraction.valueAs("denom"), nom: fraction.valueAs("nom"));
  }
}

class XCMV3BodyPartAtLeastProportion extends XCMV3BodyPart
    with XCMBodyPartAtLeastProportion {
  @override
  final int nom;
  @override
  final int denom;
  XCMV3BodyPartAtLeastProportion({required int nom, required int denom})
      : nom = nom.asUint32,
        denom = denom.asUint32;

  XCMV3BodyPartAtLeastProportion.deserializeJson(Map<String, dynamic> json)
      : nom = IntUtils.parse(json["nom"]),
        denom = IntUtils.parse(json["denom"]);

  factory XCMV3BodyPartAtLeastProportion.fromJson(Map<String, dynamic> json) {
    final atLeastProportion = json.valueEnsureAsMap<String, dynamic>(
        XCMBodyPartType.atLeastProportion.type);
    return XCMV3BodyPartAtLeastProportion(
        denom: atLeastProportion.valueAs("denom"),
        nom: atLeastProportion.valueAs("nom"));
  }
}

class XCMV3BodyPartMoreThanProportion extends XCMV3BodyPart
    with XCMBodyPartMoreThanProportion {
  @override
  bool get isMajority => nom * 2 >= denom;
  @override
  final int nom;
  @override
  final int denom;
  XCMV3BodyPartMoreThanProportion({required int nom, required int denom})
      : nom = nom.asUint32,
        denom = denom.asUint32;

  XCMV3BodyPartMoreThanProportion.deserializeJson(Map<String, dynamic> json)
      : nom = IntUtils.parse(json["nom"]),
        denom = IntUtils.parse(json["denom"]);

  factory XCMV3BodyPartMoreThanProportion.fromJson(Map<String, dynamic> json) {
    final moreThanProportion = json.valueEnsureAsMap<String, dynamic>(
        XCMBodyPartType.moreThanProportion.type);
    return XCMV3BodyPartMoreThanProportion(
        denom: moreThanProportion.valueAs("denom"),
        nom: moreThanProportion.valueAs("nom"));
  }
}

typedef XCMV3InteriorMultiLocation = XCMV3Junctions;

abstract class XCMV3Junction extends SubstrateVariantSerialization
    with XCMJunction, Equality {
  const XCMV3Junction();
  factory XCMV3Junction.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV3JunctionParaChain.deserializeJson(decode.value),
      XCMJunctionType.accountId32 =>
        XCMV3JunctionAccountId32.deserializeJson(decode.value),
      XCMJunctionType.accountIndex64 =>
        XCMV3JunctionAccountIndex64.deserializeJson(decode.value),
      XCMJunctionType.accountKey20 =>
        XCMV3JunctionAccountKey20.deserializeJson(decode.value),
      XCMJunctionType.palletInstance =>
        XCMV3JunctionPalletInstance.deserializeJson(decode.value),
      XCMJunctionType.generalIndex =>
        XCMV3JunctionGeneralIndex.deserializeJson(decode.value),
      XCMJunctionType.generalKey =>
        XCMV3JunctionGeneralKey.deserializeJson(decode.value),
      XCMJunctionType.onlyChild =>
        XCMV3JunctionOnlyChild.deserializeJson(decode.value),
      XCMJunctionType.plurality =>
        XCMV3JunctionPlurality.deserializeJson(decode.value),
      XCMJunctionType.globalConsensus =>
        XCMV3JunctionGlobalConsensus.deserializeJson(decode.value),
    };
  }

  factory XCMV3Junction.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionType.parachain => XCMV3JunctionParaChain.fromJson(json),
      XCMJunctionType.accountId32 => XCMV3JunctionAccountId32.fromJson(json),
      XCMJunctionType.accountIndex64 =>
        XCMV3JunctionAccountIndex64.fromJson(json),
      XCMJunctionType.accountKey20 => XCMV3JunctionAccountKey20.fromJson(json),
      XCMJunctionType.palletInstance =>
        XCMV3JunctionPalletInstance.fromJson(json),
      XCMJunctionType.generalIndex => XCMV3JunctionGeneralIndex.fromJson(json),
      XCMJunctionType.generalKey => XCMV3JunctionGeneralKey.fromJson(json),
      XCMJunctionType.onlyChild => XCMV3JunctionOnlyChild.fromJson(json),
      XCMJunctionType.plurality => XCMV3JunctionPlurality.fromJson(json),
      XCMJunctionType.globalConsensus =>
        XCMV3JunctionGlobalConsensus.fromJson(json),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionParaChain.layout_(property: property),
        property: XCMJunctionType.parachain.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3JunctionAccountId32.layout_(property: property),
        property: XCMJunctionType.accountId32.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3JunctionAccountIndex64.layout_(property: property),
        property: XCMJunctionType.accountIndex64.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3JunctionAccountKey20.layout_(property: property),
        property: XCMJunctionType.accountKey20.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionPalletInstance.layout_(property: property),
        property: XCMJunctionType.palletInstance.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionGeneralIndex.layout_(property: property),
        property: XCMJunctionType.generalIndex.name,
        index: 5,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionGeneralKey.layout_(property: property),
        property: XCMJunctionType.generalKey.name,
        index: 6,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionOnlyChild.layout_(property: property),
        property: XCMJunctionType.onlyChild.name,
        index: 7,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionPlurality.layout_(property: property),
        property: XCMJunctionType.plurality.name,
        index: 8,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3JunctionGlobalConsensus.layout_(property: property),
        property: XCMJunctionType.globalConsensus.name,
        index: 9,
      ),
    ], property: property);
  }

  factory XCMV3Junction.from(XCMJunction junction) {
    if (junction is XCMV3Junction) return junction;
    final type = junction.type;
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV3JunctionParaChain(id: (junction as XCMJunctionParaChain).id),
      XCMJunctionType.accountId32 => () {
          final account32 = junction as XCMJunctionAccountId32;
          return XCMV3JunctionAccountId32(
              id: account32.id,
              network: account32.network == null
                  ? null
                  : XCMV3NetworkId.from(account32.network!));
        }(),
      XCMJunctionType.accountIndex64 => () {
          final account = junction as XCMJunctionAccountIndex64;
          return XCMV3JunctionAccountIndex64(
              index: account.index,
              network: account.network == null
                  ? null
                  : XCMV3NetworkId.from(account.network!));
        }(),
      XCMJunctionType.accountKey20 => () {
          final account = junction as XCMJunctionAccountKey20;
          return XCMV3JunctionAccountKey20(
              key: account.key,
              network: account.network == null
                  ? null
                  : XCMV3NetworkId.from(account.network!));
        }(),
      XCMJunctionType.palletInstance => XCMV3JunctionPalletInstance(
          index: (junction as XCMJunctionPalletInstance).index),
      XCMJunctionType.generalIndex => XCMV3JunctionGeneralIndex(
          index: (junction as XCMJunctionGeneralIndex).index),
      XCMJunctionType.generalKey => () {
          final account = junction as XCMJunctionGeneralKey;
          return XCMV3JunctionGeneralKey(
              data: account.data, length: account.length);
        }(),
      XCMJunctionType.onlyChild => XCMV3JunctionOnlyChild(),
      XCMJunctionType.plurality => () {
          final plurality = junction as XCMJunctionPlurality;
          return XCMV3JunctionPlurality(
              id: XCMV3BodyId.from(plurality.id),
              part: XCMV3BodyPart.from(plurality.part));
        }(),
      XCMJunctionType.globalConsensus => XCMV3JunctionGlobalConsensus(
          network: XCMV3NetworkId.from(
              (junction as XCMJunctionGlobalConsensus).network)),
    };
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  Map<String, dynamic> toJson();
  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3JunctionParaChain extends XCMV3Junction with XCMJunctionParaChain {
  @override
  final int id;
  XCMV3JunctionParaChain({required int id}) : id = id.asUint32;

  factory XCMV3JunctionParaChain.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionParaChain(id: IntUtils.parse(json["id"]));
  }
  factory XCMV3JunctionParaChain.fromJson(Map<String, dynamic> json) {
    return XCMV3JunctionParaChain(
        id: json.valueAs(XCMJunctionType.parachain.type));
  }
}

class XCMV3JunctionAccountId32 extends XCMV3Junction
    with XCMJunctionAccountId32 {
  @override
  final XCMV3NetworkId? network;
  @override
  final List<int> id;
  XCMV3JunctionAccountId32({this.network, required List<int> id})
      : id = id.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;

  factory XCMV3JunctionAccountId32.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionAccountId32(
        network: json["network"] == null
            ? null
            : XCMV3NetworkId.deserializeJson(json["network"]),
        id: (json["id"] as List).cast());
  }
  factory XCMV3JunctionAccountId32.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountId32.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV3JunctionAccountId32(
        network: network == null ? null : XCMV3NetworkId.fromJson(network),
        id: accountId.valueAsBytes("id"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV3NetworkId.layout_(), property: "network"),
      LayoutConst.fixedBlob32(property: "id")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV3JunctionAccountIndex64 extends XCMV3Junction
    with XCMJunctionAccountIndex64 {
  @override
  final XCMV3NetworkId? network;
  @override
  final BigInt index;
  XCMV3JunctionAccountIndex64({this.network, required BigInt index})
      : index = index.asUint64;

  factory XCMV3JunctionAccountIndex64.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3JunctionAccountIndex64(
        network: json["network"] == null
            ? null
            : XCMV3NetworkId.deserializeJson(json["network"]),
        index: BigintUtils.parse(json["index"]));
  }
  factory XCMV3JunctionAccountIndex64.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountIndex64.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV3JunctionAccountIndex64(
        network: network == null ? null : XCMV3NetworkId.fromJson(network),
        index: accountId.valueAs("index"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV3NetworkId.layout_(), property: "network"),
      LayoutConst.compactBigintU64(property: "index")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV3JunctionAccountKey20 extends XCMV3Junction
    with XCMJunctionAccountKey20 {
  @override
  final XCMV3NetworkId? network;
  @override
  final List<int> key;
  XCMV3JunctionAccountKey20({this.network, required List<int> key})
      : key = key
            .exc(SubstrateConstant.accountId20LengthInBytes)
            .asImmutableBytes;

  factory XCMV3JunctionAccountKey20.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionAccountKey20(
        network: json["network"] == null
            ? null
            : XCMV3NetworkId.deserializeJson(json["network"]),
        key: (json["key"] as List).cast());
  }

  factory XCMV3JunctionAccountKey20.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountKey20.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV3JunctionAccountKey20(
        network: network == null ? null : XCMV3NetworkId.fromJson(network),
        key: accountId.valueAsBytes("key"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV3NetworkId.layout_(), property: "network"),
      LayoutConst.fixedBlobN(SubstrateConstant.accountId20LengthInBytes,
          property: "key")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV3JunctionPalletInstance extends XCMV3Junction
    with XCMJunctionPalletInstance {
  @override
  final int index;
  XCMV3JunctionPalletInstance({required int index}) : index = index.asUint8;

  factory XCMV3JunctionPalletInstance.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3JunctionPalletInstance(index: IntUtils.parse(json["index"]));
  }

  factory XCMV3JunctionPalletInstance.fromJson(Map<String, dynamic> json) {
    return XCMV3JunctionPalletInstance(
        index: json.valueAs(XCMJunctionType.palletInstance.type));
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: index};
  }
}

class XCMV3JunctionGeneralIndex extends XCMV3Junction
    with XCMJunctionGeneralIndex {
  @override
  final BigInt index;
  XCMV3JunctionGeneralIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV3JunctionGeneralIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionGeneralIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV3JunctionGeneralIndex.fromJson(Map<String, dynamic> json) {
    return XCMV3JunctionGeneralIndex(
        index: json.valueAs(XCMJunctionType.generalIndex.type));
  }
}

class XCMV3JunctionGeneralKey extends XCMV3Junction with XCMJunctionGeneralKey {
  @override
  final int length;
  @override
  final List<int> data;
  factory XCMV3JunctionGeneralKey(
      {required int length, required List<int> data}) {
    if (data.length < length ||
        length > SubstrateConstant.accountIdLengthInBytes ||
        data.length > SubstrateConstant.accountIdLengthInBytes) {
      throw DartSubstratePluginException(
          "Invalid V3 Junction GeneralKey bytes.");
    }
    if (data.length != SubstrateConstant.accountIdLengthInBytes) {
      final dataBytes =
          List<int>.filled(SubstrateConstant.accountIdLengthInBytes, 0);
      dataBytes.setAll(0, data);
      data = dataBytes;
    }

    return XCMV3JunctionGeneralKey._(length: length, data: data);
  }
  XCMV3JunctionGeneralKey._({required int length, required List<int> data})
      : length = length.asUint8,
        data =
            data.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;

  factory XCMV3JunctionGeneralKey.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionGeneralKey(
        length: IntUtils.parse(json["length"]),
        data: (json["data"] as List).cast());
  }
  factory XCMV3JunctionGeneralKey.fromJson(Map<String, dynamic> json) {
    final key = json.valueEnsureAsMap(XCMJunctionType.generalKey.type);
    return XCMV3JunctionGeneralKey(
        length: key.valueAs("length"), data: key.valueAsBytes("data"));
  }
}

class XCMV3JunctionOnlyChild extends XCMV3Junction with XCMJunctionOnlyChild {
  XCMV3JunctionOnlyChild();

  factory XCMV3JunctionOnlyChild.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionOnlyChild();
  }
  factory XCMV3JunctionOnlyChild.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionType.onlyChild.type);
    return XCMV3JunctionOnlyChild();
  }
}

class XCMV3JunctionPlurality extends XCMV3Junction with XCMJunctionPlurality {
  @override
  final XCMV3BodyId id;
  @override
  final XCMV3BodyPart part;
  XCMV3JunctionPlurality({required this.id, required this.part});

  factory XCMV3JunctionPlurality.fromJson(Map<String, dynamic> json) {
    final plurality =
        json.valueEnsureAsMap<String, dynamic>(XCMJunctionType.plurality.type);
    return XCMV3JunctionPlurality(
        id: XCMV3BodyId.fromJson(plurality.valueAs("id")),
        part: XCMV3BodyPart.fromJson(plurality.valueAs("part")));
  }

  factory XCMV3JunctionPlurality.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionPlurality(
        id: XCMV3BodyId.deserializeJson(json["id"]),
        part: XCMV3BodyPart.deserializeJson(json["part"]));
  }
}

class XCMV3JunctionGlobalConsensus extends XCMV3Junction
    with XCMJunctionGlobalConsensus {
  @override
  final XCMV3NetworkId network;
  XCMV3JunctionGlobalConsensus({required this.network});

  factory XCMV3JunctionGlobalConsensus.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3JunctionGlobalConsensus(
        network: XCMV3NetworkId.deserializeJson(json["network"]));
  }
  factory XCMV3JunctionGlobalConsensus.fromJson(Map<String, dynamic> json) {
    final network = json.valueEnsureAsMap<String, dynamic>(
        XCMJunctionType.globalConsensus.type);
    return XCMV3JunctionGlobalConsensus(
        network: XCMV3NetworkId.fromJson(network));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3NetworkId.layout_(property: "network"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

abstract class XCMV3Junctions extends XCMJunctions<XCMV3Junction> {
  XCMV3Junctions({required super.type, required super.junctions});
  factory XCMV3Junctions.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionsType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionsType.here => XCMV3JunctionsHere.deserializeJson(decode.value),
      XCMJunctionsType.x1 => XCMV3JunctionsX1.deserializeJson(decode.value),
      XCMJunctionsType.x2 => XCMV3JunctionsX2.deserializeJson(decode.value),
      XCMJunctionsType.x3 => XCMV3JunctionsX3.deserializeJson(decode.value),
      XCMJunctionsType.x4 => XCMV3JunctionsX4.deserializeJson(decode.value),
      XCMJunctionsType.x5 => XCMV3JunctionsX5.deserializeJson(decode.value),
      XCMJunctionsType.x6 => XCMV3JunctionsX6.deserializeJson(decode.value),
      XCMJunctionsType.x7 => XCMV3JunctionsX7.deserializeJson(decode.value),
      XCMJunctionsType.x8 => XCMV3JunctionsX8.deserializeJson(decode.value),
    };
  }
  factory XCMV3Junctions.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionsType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionsType.here => XCMV3JunctionsHere.fromJson(json),
      XCMJunctionsType.x1 => XCMV3JunctionsX1.fromJson(json),
      XCMJunctionsType.x2 => XCMV3JunctionsX2.fromJson(json),
      XCMJunctionsType.x3 => XCMV3JunctionsX3.fromJson(json),
      XCMJunctionsType.x4 => XCMV3JunctionsX4.fromJson(json),
      XCMJunctionsType.x5 => XCMV3JunctionsX5.fromJson(json),
      XCMJunctionsType.x6 => XCMV3JunctionsX6.fromJson(json),
      XCMJunctionsType.x7 => XCMV3JunctionsX7.fromJson(json),
      XCMJunctionsType.x8 => XCMV3JunctionsX8.fromJson(json),
    };
  }

  factory XCMV3Junctions.fromJunctions(List<XCMV3Junction> junctions) {
    final type = XCMJunctionsType.fromLength(junctions.length);
    return switch (type) {
      XCMJunctionsType.here => XCMV3JunctionsHere(),
      XCMJunctionsType.x1 => XCMV3JunctionsX1(junctions: junctions),
      XCMJunctionsType.x2 => XCMV3JunctionsX2(junctions: junctions),
      XCMJunctionsType.x3 => XCMV3JunctionsX3(junctions: junctions),
      XCMJunctionsType.x4 => XCMV3JunctionsX4(junctions: junctions),
      XCMJunctionsType.x5 => XCMV3JunctionsX5(junctions: junctions),
      XCMJunctionsType.x6 => XCMV3JunctionsX6(junctions: junctions),
      XCMJunctionsType.x7 => XCMV3JunctionsX7(junctions: junctions),
      XCMJunctionsType.x8 => XCMV3JunctionsX8(junctions: junctions),
    };
  }
  factory XCMV3Junctions.from(XCMJunctions junctions) {
    if (junctions is XCMV3Junctions) return junctions;
    final type = junctions.type;
    final vJunctions =
        junctions.junctions.map((e) => XCMV3Junction.from(e)).toList();
    return switch (type) {
      XCMJunctionsType.here => XCMV3JunctionsHere(),
      XCMJunctionsType.x1 => XCMV3JunctionsX1(junctions: vJunctions),
      XCMJunctionsType.x2 => XCMV3JunctionsX2(junctions: vJunctions),
      XCMJunctionsType.x3 => XCMV3JunctionsX3(junctions: vJunctions),
      XCMJunctionsType.x4 => XCMV3JunctionsX4(junctions: vJunctions),
      XCMJunctionsType.x5 => XCMV3JunctionsX5(junctions: vJunctions),
      XCMJunctionsType.x6 => XCMV3JunctionsX6(junctions: vJunctions),
      XCMJunctionsType.x7 => XCMV3JunctionsX7(junctions: vJunctions),
      XCMJunctionsType.x8 => XCMV3JunctionsX8(junctions: vJunctions),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsHere.layout_(property: property),
          property: XCMJunctionsType.here.name,
          index: 0),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x1, property: property),
          property: XCMJunctionsType.x1.name,
          index: 1),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x2, property: property),
          property: XCMJunctionsType.x2.name,
          index: 2),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x3, property: property),
          property: XCMJunctionsType.x3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x4, property: property),
          property: XCMJunctionsType.x4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x5, property: property),
          property: XCMJunctionsType.x5.name,
          index: 5),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x6, property: property),
          property: XCMJunctionsType.x6.name,
          index: 6),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x7, property: property),
          property: XCMJunctionsType.x7.name,
          index: 7),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV3JunctionsX1.layout_(XCMJunctionsType.x8, property: property),
          property: XCMJunctionsType.x8.name,
          index: 8)
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  Map<String, dynamic> toJson();

  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3JunctionsHere extends XCMV3Junctions {
  XCMV3JunctionsHere() : super(type: XCMJunctionsType.here, junctions: []);

  factory XCMV3JunctionsHere.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionsHere();
  }
  factory XCMV3JunctionsHere.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionsType.here.type);
    return XCMV3JunctionsHere();
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV3JunctionsX1 extends XCMV3Junctions {
  XCMV3JunctionsX1._({required super.junctions, required super.type});
  XCMV3JunctionsX1({required super.junctions})
      : super(type: XCMJunctionsType.x1);

  XCMV3JunctionsX1._deserialize(Map<String, dynamic> json,
      {required super.type})
      : super(
            junctions: (json["junctions"] as List)
                .map((e) => XCMV3Junction.deserializeJson(e))
                .toList());
  factory XCMV3JunctionsX1.deserializeJson(Map<String, dynamic> json) {
    return XCMV3JunctionsX1(
        junctions: (json["junctions"] as List)
            .map((e) => XCMV3Junction.deserializeJson(e))
            .toList());
  }
  factory XCMV3JunctionsX1.fromJson(Map<String, dynamic> json) {
    return XCMV3JunctionsX1(junctions: [
      XCMV3Junction.fromJson(json.valueAs(XCMJunctionsType.x1.type))
    ]);
  }

  static Layout<Map<String, dynamic>> layout_(XCMJunctionsType type,
      {String? property}) {
    return LayoutConst.struct([
      LayoutConst.tuple(
          List.filled(type.junctionsLength, XCMV3Junction.layout_()),
          property: "junctions"),
    ], property: property ?? type.name);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(type, property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "junctions": junctions.map((e) => e.serializeJsonVariant()).toList()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.first.toJson()};
  }
}

class XCMV3JunctionsX2 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX2.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x2);
  XCMV3JunctionsX2({required super.junctions})
      : super._(type: XCMJunctionsType.x2);
  factory XCMV3JunctionsX2.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x2.type);
    return XCMV3JunctionsX2(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV3JunctionsX3 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX3.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x3);
  XCMV3JunctionsX3({required super.junctions})
      : super._(type: XCMJunctionsType.x3);
  factory XCMV3JunctionsX3.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x3.type);
    return XCMV3JunctionsX3(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV3JunctionsX4 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX4.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x4);
  XCMV3JunctionsX4({required super.junctions})
      : super._(type: XCMJunctionsType.x4);
  factory XCMV3JunctionsX4.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x4.type);
    return XCMV3JunctionsX4(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV3JunctionsX5 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX5.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x5);
  XCMV3JunctionsX5({required super.junctions})
      : super._(type: XCMJunctionsType.x5);
  factory XCMV3JunctionsX5.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x5.type);
    return XCMV3JunctionsX5(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV3JunctionsX6 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX6.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x6);
  XCMV3JunctionsX6({required super.junctions})
      : super._(type: XCMJunctionsType.x6);
  factory XCMV3JunctionsX6.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x6.type);
    return XCMV3JunctionsX6(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV3JunctionsX7 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX7.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x7);
  XCMV3JunctionsX7({required super.junctions})
      : super._(type: XCMJunctionsType.x7);
  factory XCMV3JunctionsX7.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x7.type);
    return XCMV3JunctionsX7(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV3JunctionsX8 extends XCMV3JunctionsX1 {
  XCMV3JunctionsX8.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x8);
  XCMV3JunctionsX8({required super.junctions})
      : super._(type: XCMJunctionsType.x8);
  factory XCMV3JunctionsX8.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x7.type);
    return XCMV3JunctionsX8(
        junctions: junctions.map((e) => XCMV3Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

abstract class XCMV3AssetInstance extends SubstrateVariantSerialization
    with XCMAssetInstance, Equality {
  const XCMV3AssetInstance();
  factory XCMV3AssetInstance.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMAssetInstanceType.fromName(decode.variantName);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV3AssetInstanceUndefined.deserializeJson(decode.value),
      XCMAssetInstanceType.indexId =>
        XCMV3AssetInstanceIndex.deserializeJson(decode.value),
      XCMAssetInstanceType.array4 =>
        XCMV3AssetInstanceArray4.deserializeJson(decode.value),
      XCMAssetInstanceType.array8 =>
        XCMV3AssetInstanceArray8.deserializeJson(decode.value),
      XCMAssetInstanceType.array16 =>
        XCMV3AssetInstanceArray16.deserializeJson(decode.value),
      XCMAssetInstanceType.array32 =>
        XCMV3AssetInstanceArray32.deserializeJson(decode.value)
    };
  }

  factory XCMV3AssetInstance.fromJson(Map<String, dynamic> json) {
    final type = XCMAssetInstanceType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV3AssetInstanceUndefined.fromJson(json),
      XCMAssetInstanceType.indexId => XCMV3AssetInstanceIndex.fromJson(json),
      XCMAssetInstanceType.array4 => XCMV3AssetInstanceArray4.fromJson(json),
      XCMAssetInstanceType.array8 => XCMV3AssetInstanceArray8.fromJson(json),
      XCMAssetInstanceType.array16 => XCMV3AssetInstanceArray16.fromJson(json),
      XCMAssetInstanceType.array32 => XCMV3AssetInstanceArray32.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return XCMAssetInstance.layout_(property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  Map<String, dynamic> toJson();
  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3AssetInstanceUndefined extends XCMV3AssetInstance
    with XCMAssetInstanceUndefined {
  XCMV3AssetInstanceUndefined();

  factory XCMV3AssetInstanceUndefined.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3AssetInstanceUndefined();
  }
  factory XCMV3AssetInstanceUndefined.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMAssetInstanceType.undefined.type);
    return XCMV3AssetInstanceUndefined();
  }
}

class XCMV3AssetInstanceIndex extends XCMV3AssetInstance
    with XCMAssetInstanceIndex {
  @override
  final BigInt index;
  XCMV3AssetInstanceIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV3AssetInstanceIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV3AssetInstanceIndex.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceIndex(
        index: json.valueAs(XCMAssetInstanceType.indexId.type));
  }
}

class XCMV3AssetInstanceArray4 extends XCMV3AssetInstance
    with XCMAssetInstanceArray4 {
  @override
  final List<int> datum;
  XCMV3AssetInstanceArray4({required List<int> datum})
      : datum = datum.exc(4).asImmutableBytes;

  factory XCMV3AssetInstanceArray4.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray4(datum: (json["datum"] as List).cast());
  }
  factory XCMV3AssetInstanceArray4.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray4(
        datum: json.valueAsBytes(XCMAssetInstanceType.array4.type));
  }
}

class XCMV3AssetInstanceArray8 extends XCMV3AssetInstance
    with XCMAssetInstanceArray8 {
  @override
  final List<int> datum;
  XCMV3AssetInstanceArray8({required List<int> datum})
      : datum = datum.exc(8).asImmutableBytes;

  factory XCMV3AssetInstanceArray8.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray8(datum: (json["datum"] as List).cast());
  }
  factory XCMV3AssetInstanceArray8.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray8(
        datum: json.valueAsBytes(XCMAssetInstanceType.array8.type));
  }
}

class XCMV3AssetInstanceArray16 extends XCMV3AssetInstance
    with XCMAssetInstanceArray16 {
  @override
  final List<int> datum;
  XCMV3AssetInstanceArray16({required List<int> datum})
      : datum = datum.exc(16).asImmutableBytes;

  factory XCMV3AssetInstanceArray16.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray16(datum: (json["datum"] as List).cast());
  }
  factory XCMV3AssetInstanceArray16.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray16(
        datum: json.valueAsBytes(XCMAssetInstanceType.array16.type));
  }
}

class XCMV3AssetInstanceArray32 extends XCMV3AssetInstance
    with XCMAssetInstanceArray32 {
  @override
  final List<int> datum;
  XCMV3AssetInstanceArray32({required List<int> datum})
      : datum = datum.exc(32).asImmutableBytes;

  factory XCMV3AssetInstanceArray32.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray32(datum: (json["datum"] as List).cast());
  }
  factory XCMV3AssetInstanceArray32.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetInstanceArray32(
        datum: json.valueAsBytes(XCMAssetInstanceType.array32.type));
  }
}

abstract class XCMV3Fungibility extends SubstrateVariantSerialization
    with XCMFungibility, Equality {
  const XCMV3Fungibility();
  factory XCMV3Fungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMFungibilityType.fungible =>
        XCMV3FungibilityFungible.deserializeJson(decode.value),
      XCMFungibilityType.nonFungible =>
        XCMV3FungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV3Fungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMFungibilityType.fungible => XCMV3FungibilityFungible.fromJson(json),
      XCMFungibilityType.nonFungible =>
        XCMV3FungibilityNonFungible.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMFungibilityFungible.layout_(property: property),
        property: XCMFungibilityType.fungible.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3FungibilityNonFungible.layout_(property: property),
        property: XCMFungibilityType.nonFungible.name,
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
  Map<String, dynamic> toJson();

  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3FungibilityFungible extends XCMV3Fungibility
    with XCMFungibilityFungible {
  @override
  final BigInt units;

  XCMV3FungibilityFungible({required BigInt units}) : units = units.asUint128;

  factory XCMV3FungibilityFungible.deserializeJson(Map<String, dynamic> json) {
    return XCMV3FungibilityFungible(units: BigintUtils.parse(json["units"]));
  }
  factory XCMV3FungibilityFungible.fromJson(Map<String, dynamic> json) {
    return XCMV3FungibilityFungible(
        units: json.valueAs(XCMFungibilityType.fungible.type));
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: units};
  }
}

class XCMV3FungibilityNonFungible extends XCMV3Fungibility
    with XCMFungibilityNonFungible {
  @override
  final XCMV3AssetInstance instance;

  XCMV3FungibilityNonFungible({required this.instance});

  factory XCMV3FungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3FungibilityNonFungible(
        instance: XCMV3AssetInstance.deserializeJson(json["instance"]));
  }
  factory XCMV3FungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    return XCMV3FungibilityNonFungible(
        instance: XCMV3AssetInstance.fromJson(
            json.valueAs(XCMFungibilityType.nonFungible.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV3AssetInstance.layout_(property: "instance")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: instance.toJson()};
  }
}

abstract class XCMV3WildFungibility extends SubstrateVariantSerialization
    with XCMWildFungibility, Equality {
  const XCMV3WildFungibility();
  factory XCMV3WildFungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV3WildFungibilityFungible.deserializeJson(decode.value),
      XCMWildFungibilityType.nonFungible =>
        XCMV3WildFungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV3WildFungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMWildFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV3WildFungibilityFungible.fromJson(json),
      XCMWildFungibilityType.nonFungible =>
        XCMV3WildFungibilityNonFungible.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMWildFungibilityFungible.layout_(property: property),
        property: XCMWildFungibilityType.fungible.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMWildFungibilityNonFungible.layout_(property: property),
        property: XCMWildFungibilityType.nonFungible.name,
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

class XCMV3WildFungibilityFungible extends XCMV3WildFungibility
    with XCMWildFungibilityFungible {
  XCMV3WildFungibilityFungible();
  factory XCMV3WildFungibilityFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3WildFungibilityFungible();
  }
  factory XCMV3WildFungibilityFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.fungible.type);
    return XCMV3WildFungibilityFungible();
  }
}

class XCMV3WildFungibilityNonFungible extends XCMV3WildFungibility
    with XCMWildFungibilityNonFungible {
  XCMV3WildFungibilityNonFungible();
  factory XCMV3WildFungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3WildFungibilityNonFungible();
  }
  factory XCMV3WildFungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.nonFungible.type);
    return XCMV3WildFungibilityNonFungible();
  }
}

class XCMV3MultiLocation extends XCMMultiLocation with Equality {
  @override
  final int parents;
  @override
  final XCMV3Junctions interior;

  @override
  XCMVersion get version => XCMVersion.v3;

  XCMV3MultiLocation({required int parents, required this.interior})
      : parents = parents.asUint8;
  factory XCMV3MultiLocation.deserialize(List<int> bytes) {
    final json =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMV3MultiLocation.deserializeJson(json.value);
  }
  factory XCMV3MultiLocation.fromJson(Map<String, dynamic> json) {
    return XCMV3MultiLocation(
        parents: json.valueAs("parents"),
        interior: XCMV3Junctions.fromJson(json.valueAs("interior")));
  }

  factory XCMV3MultiLocation.deserializeJson(Map<String, dynamic> json) {
    return XCMV3MultiLocation(
        parents: IntUtils.parse(json["parents"]),
        interior: XCMV3Junctions.deserializeJson(json["interior"]));
  }
  factory XCMV3MultiLocation.from(XCMMultiLocation location) {
    if (location is XCMV3MultiLocation) return location;
    return XCMV3MultiLocation(
        parents: location.parents,
        interior: XCMV3Junctions.from(location.interior));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "parents"),
      XCMV3Junctions.layout_(property: "interior")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"parents": parents, "interior": interior.serializeJsonVariant()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {"parents": parents, "interior": interior.toJson()};
  }
}

enum XCMV3AssetIdType {
  concrete("Concrete"),
  abtract("Abtract");

  final String type;
  const XCMV3AssetIdType(this.type);
  static XCMV3AssetIdType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMV3AssetIdType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract class XCMV3AssetId extends SubstrateVariantSerialization
    with XCMAssetId, Equality {
  final XCMV3AssetIdType type;
  const XCMV3AssetId({required this.type});
  factory XCMV3AssetId.deserialize(List<int> bytes) {
    final decode = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    final assetId = XCMV3AssetId.deserializeJson(decode);
    return assetId;
  }
  factory XCMV3AssetId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV3AssetIdType.fromName(decode.variantName);
    return switch (type) {
      XCMV3AssetIdType.concrete =>
        XCMV3AssetIdConcrete.deserializeJson(decode.value),
      XCMV3AssetIdType.abtract =>
        XCMV3AssetIdAbstract.deserializeJson(decode.value)
    };
  }
  factory XCMV3AssetId.from(XCMAssetId id) {
    return switch (id) {
      final XCMV3AssetId assetId => assetId,
      final XCMV2AssetId assetId => switch (assetId.type) {
          XCMV2AssetIdType.abtract =>
            XCMV3AssetIdAbstract(id: assetId.cast<XCMV2AssetIdAbstract>().id),
          XCMV2AssetIdType.concrete => XCMV3AssetIdConcrete(
              location: assetId
                  .cast<XCMV2AssetIdConcrete>()
                  .location
                  .asVersion(XCMVersion.v3)),
        },
      final XCMV4AssetId assetId => XCMV3AssetIdConcrete(
          location: assetId.location.asVersion(XCMVersion.v3)),
      final XCMV5AssetId assetId => XCMV3AssetIdConcrete(
          location: assetId.location.asVersion(XCMVersion.v3)),
      _ => throw DartSubstratePluginException("Unknow asset id.")
    };
  }

  factory XCMV3AssetId.fromJson(Map<String, dynamic> json) {
    final type = XCMV3AssetIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV3AssetIdType.concrete => XCMV3AssetIdConcrete.fromJson(json),
      XCMV3AssetIdType.abtract => XCMV3AssetIdAbstract.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3AssetIdConcrete.layout_(property: property),
        property: XCMV3AssetIdType.concrete.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3AssetIdAbstract.layout_(property: property),
        property: XCMV3AssetIdType.abtract.name,
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
  @override
  Map<String, dynamic> toJson();
}

class XCMV3AssetIdConcrete extends XCMV3AssetId {
  @override
  final XCMV3MultiLocation location;
  XCMV3AssetIdConcrete({required this.location})
      : super(type: XCMV3AssetIdType.concrete);

  factory XCMV3AssetIdConcrete.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetIdConcrete(
        location: XCMV3MultiLocation.deserializeJson(json["location"]));
  }
  factory XCMV3AssetIdConcrete.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetIdConcrete(
        location: XCMV3MultiLocation.fromJson(
            json.valueAs(XCMV3AssetIdType.concrete.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV3MultiLocation.layout_(property: "location")],
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
  List get variabels => [type, location];

  @override
  Map<String, dynamic> toJson() {
    return {type.type: location.toJson()};
  }
}

class XCMV3AssetIdAbstract extends XCMV3AssetId {
  final List<int> id;
  XCMV3AssetIdAbstract({required List<int> id})
      : id = id.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes,
        super(type: XCMV3AssetIdType.abtract);
  factory XCMV3AssetIdAbstract.fromJson(Map<String, dynamic> json) {
    return XCMV3AssetIdAbstract(
        id: json.valueAsBytes(XCMV3AssetIdType.abtract.type));
  }
  factory XCMV3AssetIdAbstract.deserializeJson(Map<String, dynamic> json) {
    return XCMV3AssetIdAbstract(id: (json["id"] as List).cast());
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.fixedBlob32(property: "id")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": location};
  }

  @override
  XCMMultiLocation? get location => null;
  @override
  List get variabels => [type, id];

  @override
  Map<String, dynamic> toJson() {
    return {type.type: id};
  }
}

class XCMV3MultiAsset extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAsset, Equality {
  @override
  final XCMV3AssetId id;
  @override
  final XCMV3Fungibility fun;

  XCMV3MultiAsset({required this.id, required this.fun});

  factory XCMV3MultiAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV3MultiAsset(
        id: XCMV3AssetId.deserializeJson(json["id"]),
        fun: XCMV3Fungibility.deserializeJson(json["fun"]));
  }
  factory XCMV3MultiAsset.fromJson(Map<String, dynamic> json) {
    return XCMV3MultiAsset(
        id: XCMV3AssetId.fromJson(json.valueAs("id")),
        fun: XCMV3Fungibility.fromJson(json["fun"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3AssetId.layout_(property: "id"),
      XCMV3Fungibility.layout_(property: "fun")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id.serializeJsonVariant(), "fun": fun.serializeJsonVariant()};
  }

  @override
  XCMVersion get version => XCMVersion.v3;

  @override
  Map<String, dynamic> toJson() {
    return {"id": id.toJson(), "fun": fun.toJson()};
  }
}

class XCMV3MultiAssets extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAssets<XCMV3MultiAsset>, Equality {
  @override
  final List<XCMV3MultiAsset> assets;

  XCMV3MultiAssets({required List<XCMV3MultiAsset> assets})
      : assets = assets.immutable;

  factory XCMV3MultiAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMV3MultiAssets(
        assets: (json["assets"] as List)
            .map((e) => XCMV3MultiAsset.deserializeJson(e))
            .toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMV3MultiAsset.layout_(), property: "assets")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.map((e) => e.serializeJson()).toList()};
  }

  @override
  XCMVersion get version => XCMVersion.v3;
}

abstract class XCMV3WildMultiAsset extends SubstrateVariantSerialization
    with XCMWildMultiAsset, Equality {
  const XCMV3WildMultiAsset();
  factory XCMV3WildMultiAsset.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildAssetType.fromName(decode.variantName);
    return switch (type) {
      XCMWildAssetType.all =>
        XCMV3WildMultiAssetAll.deserializeJson(decode.value),
      XCMWildAssetType.allOf =>
        XCMV3WildMultiAssetAllOf.deserializeJson(decode.value),
      XCMWildAssetType.allCounted =>
        XCMV3WildMultiAssetAllCounted.deserializeJson(decode.value),
      XCMWildAssetType.allOfCounted =>
        XCMV3WildMultiAssetAllOfCounted.deserializeJson(decode.value)
    };
  }
  factory XCMV3WildMultiAsset.fromJson(Map<String, dynamic> json) {
    final type = XCMWildAssetType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildAssetType.all => XCMV3WildMultiAssetAll.fromJson(json),
      XCMWildAssetType.allOf => XCMV3WildMultiAssetAllOf.fromJson(json),
      XCMWildAssetType.allCounted =>
        XCMV3WildMultiAssetAllCounted.fromJson(json),
      XCMWildAssetType.allOfCounted =>
        XCMV3WildMultiAssetAllOfCounted.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3WildMultiAssetAll.layout_(property: property),
        property: XCMWildAssetType.all.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3WildMultiAssetAllOf.layout_(property: property),
        property: XCMWildAssetType.allOf.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3WildMultiAssetAllCounted.layout_(property: property),
        property: XCMWildAssetType.allCounted.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3WildMultiAssetAllOfCounted.layout_(property: property),
        property: XCMWildAssetType.allOfCounted.name,
        index: 3,
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
  Map<String, dynamic> toJson();

  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3WildMultiAssetAll extends XCMV3WildMultiAsset
    with XCMWildMultiAssetAll {
  XCMV3WildMultiAssetAll();

  factory XCMV3WildMultiAssetAll.deserializeJson(Map<String, dynamic> json) {
    return XCMV3WildMultiAssetAll();
  }
  factory XCMV3WildMultiAssetAll.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildAssetType.all.type);
    return XCMV3WildMultiAssetAll();
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}

class XCMV3WildMultiAssetAllOf extends XCMV3WildMultiAsset
    with XCMWildMultiAssetAllOf {
  @override
  final XCMV3AssetId id;
  @override
  final XCMV3WildFungibility fun;
  XCMV3WildMultiAssetAllOf({required this.id, required this.fun});

  factory XCMV3WildMultiAssetAllOf.deserializeJson(Map<String, dynamic> json) {
    return XCMV3WildMultiAssetAllOf(
        id: XCMV3AssetId.deserializeJson(json["id"]),
        fun: XCMV3WildFungibility.deserializeJson(json["fun"]));
  }
  factory XCMV3WildMultiAssetAllOf.fromJson(Map<String, dynamic> json) {
    final allOf =
        json.valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOf.type);
    return XCMV3WildMultiAssetAllOf(
        id: XCMV3AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV3WildFungibility.fromJson(allOf.valueAs("fun")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3AssetId.layout_(property: "id"),
      XCMV3WildFungibility.layout_(property: "fun"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id.serializeJsonVariant(), "fun": fun.serializeJsonVariant()};
  }
}

class XCMV3WildMultiAssetAllCounted extends XCMV3WildMultiAsset
    with XCMWildMultiAssetAllCounted {
  @override
  final int count;
  XCMV3WildMultiAssetAllCounted({required int count}) : count = count.asUint32;

  factory XCMV3WildMultiAssetAllCounted.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3WildMultiAssetAllCounted(count: IntUtils.parse(json["count"]));
  }
  factory XCMV3WildMultiAssetAllCounted.fromJson(Map<String, dynamic> json) {
    return XCMV3WildMultiAssetAllCounted(
        count: json.valueAs(XCMWildAssetType.allCounted.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactIntU32(property: "count"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"count": count};
  }
}

class XCMV3WildMultiAssetAllOfCounted extends XCMV3WildMultiAsset
    with XCMWildMultiAssetAllOfCounted {
  @override
  final XCMV3AssetId id;
  @override
  final XCMV3WildFungibility fun;
  @override
  final int count;
  XCMV3WildMultiAssetAllOfCounted(
      {required this.id, required this.fun, required int count})
      : count = count.asUint32;

  factory XCMV3WildMultiAssetAllOfCounted.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3WildMultiAssetAllOfCounted(
        id: XCMV3AssetId.deserializeJson(json["id"]),
        fun: XCMV3WildFungibility.deserializeJson(json["fun"]),
        count: IntUtils.parse(json["count"]));
  }
  factory XCMV3WildMultiAssetAllOfCounted.fromJson(Map<String, dynamic> json) {
    final allOf = json
        .valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOfCounted.type);
    return XCMV3WildMultiAssetAllOfCounted(
        id: XCMV3AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV3WildFungibility.fromJson(allOf.valueAs("fun")),
        count: allOf.valueAs("count"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV3AssetId.layout_(property: "id"),
      XCMV3WildFungibility.layout_(property: "fun"),
      LayoutConst.compactIntU32(property: "count")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "id": id.serializeJsonVariant(),
      "fun": fun.serializeJsonVariant(),
      "count": count
    };
  }
}

abstract class XCMV3MultiAssetFilter extends SubstrateVariantSerialization
    with XCMMultiAssetFilter, Equality {
  const XCMV3MultiAssetFilter();
  factory XCMV3MultiAssetFilter.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMMultiAssetFilterType.fromName(decode.variantName);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV3MultiAssetFilterDefinite.deserializeJson(decode.value),
      XCMMultiAssetFilterType.wild =>
        XCMV3MultiAssetFilterWild.deserializeJson(decode.value)
    };
  }
  factory XCMV3MultiAssetFilter.fromJson(Map<String, dynamic> json) {
    final type = XCMMultiAssetFilterType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV3MultiAssetFilterDefinite.fromJson(json),
      XCMMultiAssetFilterType.wild => XCMV3MultiAssetFilterWild.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3MultiAssetFilterDefinite.layout_(property: property),
        property: XCMMultiAssetFilterType.definite.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV3MultiAssetFilterWild.layout_(property: property),
        property: XCMMultiAssetFilterType.wild.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  XCMVersion get version => XCMVersion.v3;
}

class XCMV3MultiAssetFilterDefinite extends XCMV3MultiAssetFilter
    with XCMMultiAssetFilterDefinite {
  @override
  final XCMV3MultiAssets assets;
  XCMV3MultiAssetFilterDefinite({required this.assets}) : super();
  factory XCMV3MultiAssetFilterDefinite.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV3MultiAssetFilterDefinite(
        assets: XCMV3MultiAssets.deserializeJson(json.valueAs("assets")));
  }

  factory XCMV3MultiAssetFilterDefinite.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMMultiAssetFilterType.definite.type);
    return XCMV3MultiAssetFilterDefinite(
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
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.definite;
}

class XCMV3MultiAssetFilterWild extends XCMV3MultiAssetFilter
    with XCMMultiAssetFilterWild {
  @override
  final XCMV3WildMultiAsset asset;
  XCMV3MultiAssetFilterWild({required this.asset}) : super();

  factory XCMV3MultiAssetFilterWild.deserializeJson(Map<String, dynamic> json) {
    return XCMV3MultiAssetFilterWild(
        asset: XCMV3WildMultiAsset.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV3MultiAssetFilterWild.fromJson(Map<String, dynamic> json) {
    return XCMV3MultiAssetFilterWild(
        asset: XCMV3WildMultiAsset.fromJson(
            json.valueAs(XCMMultiAssetFilterType.wild.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV3WildMultiAsset.layout_(property: "asset")],
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
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.wild;
}
