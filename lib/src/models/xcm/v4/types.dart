import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/layout/core/types/lazy_union.dart';
import 'package:blockchain_utils/utils/equatable/equatable.dart';
import 'package:blockchain_utils/utils/json/json.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/core/asset.dart';
import 'package:polkadot_dart/src/models/xcm/core/fungibility.dart';
import 'package:polkadot_dart/src/models/xcm/core/junction.dart';
import 'package:polkadot_dart/src/models/xcm/core/location.dart';
import 'package:polkadot_dart/src/models/xcm/core/network_id.dart';
import 'package:polkadot_dart/src/models/xcm/core/versioned.dart';
import 'package:polkadot_dart/src/models/xcm/v2/types.dart';
import 'package:polkadot_dart/src/models/xcm/v3/types.dart';
import 'package:polkadot_dart/src/models/xcm/v5/types.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class XCMV4NetworkId extends SubstrateVariantSerialization
    with XCMNetworkId, Equality {
  const XCMV4NetworkId();

  factory XCMV4NetworkId.fromJson(Map<String, dynamic> json) {
    final type = XCMNetworkIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMNetworkIdType.byGenesis => XCMV4ByGenesis.fromJson(json),
      XCMNetworkIdType.byFork => XCMV4ByFork.fromJson(json),
      XCMNetworkIdType.polkadot => XCMV4Polkadot.fromJson(json),
      XCMNetworkIdType.kusama => XCMV4Kusama.fromJson(json),
      XCMNetworkIdType.ethereum => XCMV4Ethereum.fromJson(json),
      XCMNetworkIdType.rococo => XCMV4Rococo.fromJson(json),
      XCMNetworkIdType.wococo => XCMV4Wococo.fromJson(json),
      XCMNetworkIdType.bitcoinCash => XCMV4BitcoinCash.fromJson(json),
      XCMNetworkIdType.bitcoinCore => XCMV4BitcoinCore.fromJson(json),
      XCMNetworkIdType.polkadotBulletIn => XCMV4PolkadotBulletIn.fromJson(json),
      XCMNetworkIdType.westend => XCMV4Westend.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 4.",
          details: {"type": type.name})
    };
  }

  factory XCMV4NetworkId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMNetworkIdType.fromName(decode.variantName);
    return switch (type) {
      XCMNetworkIdType.byGenesis =>
        XCMV4ByGenesis.deserializeJson(decode.value),
      XCMNetworkIdType.byFork => XCMV4ByFork.deserializeJson(decode.value),
      XCMNetworkIdType.polkadot => XCMV4Polkadot.deserializeJson(decode.value),
      XCMNetworkIdType.kusama => XCMV4Kusama.deserializeJson(decode.value),
      XCMNetworkIdType.ethereum => XCMV4Ethereum.deserializeJson(decode.value),
      XCMNetworkIdType.rococo => XCMV4Rococo.deserializeJson(decode.value),
      XCMNetworkIdType.wococo => XCMV4Wococo.deserializeJson(decode.value),
      XCMNetworkIdType.bitcoinCash =>
        XCMV4BitcoinCash.deserializeJson(decode.value),
      XCMNetworkIdType.bitcoinCore =>
        XCMV4BitcoinCore.deserializeJson(decode.value),
      XCMNetworkIdType.polkadotBulletIn =>
        XCMV4PolkadotBulletIn.deserializeJson(decode.value),
      XCMNetworkIdType.westend => XCMV4Westend.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 4.",
          details: {"type": type.name})
    };
  }

  factory XCMV4NetworkId.from(XCMNetworkId network) {
    if (network is XCMV4NetworkId) return network;
    final type = network.type;
    return switch (type) {
      XCMNetworkIdType.byGenesis =>
        XCMV4ByGenesis(genesis: (network as XCMNetworkIdByGenesis).genesis),
      XCMNetworkIdType.byFork => () {
          final fork = network as XCMNetworkIdByFork;
          return XCMV4ByFork(
              blockHash: fork.blockHash, blockNumber: fork.blockNumber);
        }(),
      XCMNetworkIdType.polkadot => XCMV4Polkadot(),
      XCMNetworkIdType.kusama => XCMV4Kusama(),
      XCMNetworkIdType.wococo => XCMV4Wococo(),
      XCMNetworkIdType.rococo => XCMV4Rococo(),
      XCMNetworkIdType.westend => XCMV4Westend(),
      XCMNetworkIdType.ethereum =>
        XCMV4Ethereum(chainId: (network as XCMNetworkIdEthereum).chainId),
      XCMNetworkIdType.bitcoinCash => XCMV4BitcoinCash(),
      XCMNetworkIdType.bitcoinCore => XCMV4BitcoinCore(),
      XCMNetworkIdType.polkadotBulletIn => XCMV4PolkadotBulletIn(),
      _ => throw DartSubstratePluginException(
          "Unsuported network type by version 4.",
          details: {"type": type.name})
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdByGenesis.layout_(property: property),
        property: XCMNetworkIdType.byGenesis.name,
        index: 0,
      ),
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4ByGenesis extends XCMV4NetworkId with XCMNetworkIdByGenesis {
  @override
  final List<int> genesis;
  XCMV4ByGenesis({required List<int> genesis})
      : genesis = genesis
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes;

  factory XCMV4ByGenesis.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ByGenesis(genesis: (json["genesis"] as List).cast());
  }
  factory XCMV4ByGenesis.fromJson(Map<String, dynamic> json) {
    return XCMV4ByGenesis(
        genesis: json.valueAsBytes(XCMNetworkIdType.byGenesis.type));
  }
}

class XCMV4ByFork extends XCMV4NetworkId with XCMNetworkIdByFork {
  @override
  final List<int> blockHash;
  @override
  final BigInt blockNumber;
  XCMV4ByFork({required List<int> blockHash, required BigInt blockNumber})
      : blockHash = blockHash
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes,
        blockNumber = blockNumber.asUint64;

  factory XCMV4ByFork.deserializeJson(Map<String, dynamic> json) {
    return XCMV4ByFork(
        blockNumber: BigintUtils.parse(json["block_number"]),
        blockHash: (json["block_hash"] as List).cast());
  }
  factory XCMV4ByFork.fromJson(Map<String, dynamic> json) {
    final byFork =
        json.valueEnsureAsMap<String, dynamic>(XCMNetworkIdType.byFork.type);
    return XCMV4ByFork(
        blockHash: byFork.valueAsBytes("block_hash"),
        blockNumber: byFork.valueAs("block_number"));
  }
}

class XCMV4Polkadot extends XCMV4NetworkId with XCMNetworkIdPolkadot {
  XCMV4Polkadot();
  XCMV4Polkadot.deserializeJson(Map<String, dynamic> json);
  factory XCMV4Polkadot.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadot.type);
    return XCMV4Polkadot();
  }
}

class XCMV4Kusama extends XCMV4NetworkId with XCMNetworkIdKusama {
  XCMV4Kusama();
  XCMV4Kusama.deserializeJson(Map<String, dynamic> json);
  factory XCMV4Kusama.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.kusama.type);
    return XCMV4Kusama();
  }
}

class XCMV4Westend extends XCMV4NetworkId with XCMNetworkIdWestend {
  XCMV4Westend();
  XCMV4Westend.deserializeJson(Map<String, dynamic> json);

  factory XCMV4Westend.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.westend.type);
    return XCMV4Westend();
  }
}

class XCMV4Rococo extends XCMV4NetworkId with XCMNetworkIdRococo {
  XCMV4Rococo();
  XCMV4Rococo.deserializeJson(Map<String, dynamic> json);
  factory XCMV4Rococo.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.rococo.type);
    return XCMV4Rococo();
  }
}

class XCMV4Wococo extends XCMV4NetworkId with XCMNetworkIdWococo {
  XCMV4Wococo();
  XCMV4Wococo.deserializeJson(Map<String, dynamic> json);
  factory XCMV4Wococo.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.wococo.type);
    return XCMV4Wococo();
  }
}

class XCMV4Ethereum extends XCMV4NetworkId with XCMNetworkIdEthereum {
  @override
  final BigInt chainId;
  const XCMV4Ethereum({required this.chainId});

  factory XCMV4Ethereum.deserializeJson(Map<String, dynamic> json) {
    return XCMV4Ethereum(chainId: BigintUtils.parse(json["chain_id"]));
  }
  factory XCMV4Ethereum.fromJson(Map<String, dynamic> json) {
    final BigInt chainId = json.valueAs(XCMNetworkIdType.ethereum.type);
    return XCMV4Ethereum(chainId: chainId);
  }
}

class XCMV4BitcoinCore extends XCMV4NetworkId with XCMNetworkIdBitcoinCore {
  XCMV4BitcoinCore();
  XCMV4BitcoinCore.deserializeJson(Map<String, dynamic> json);
  factory XCMV4BitcoinCore.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.bitcoinCore.type);
    return XCMV4BitcoinCore();
  }
}

class XCMV4BitcoinCash extends XCMV4NetworkId with XCMNetworkIdBitcoinCash {
  XCMV4BitcoinCash();
  XCMV4BitcoinCash.deserializeJson(Map<String, dynamic> json);
  factory XCMV4BitcoinCash.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.bitcoinCash.type);
    return XCMV4BitcoinCash();
  }
}

class XCMV4PolkadotBulletIn extends XCMV4NetworkId
    with XCMNetworkIdPolkadotBulletIn {
  XCMV4PolkadotBulletIn();
  XCMV4PolkadotBulletIn.deserializeJson(Map<String, dynamic> json);
  factory XCMV4PolkadotBulletIn.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadotBulletIn.type);
    return XCMV4PolkadotBulletIn();
  }
}

abstract class XCMV4Junction extends SubstrateVariantSerialization
    with XCMJunction, Equality {
  const XCMV4Junction();
  factory XCMV4Junction.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV4JunctionParaChain.deserializeJson(decode.value),
      XCMJunctionType.accountId32 =>
        XCMV4JunctionAccountId32.deserializeJson(decode.value),
      XCMJunctionType.accountIndex64 =>
        XCMV4JunctionAccountIndex64.deserializeJson(decode.value),
      XCMJunctionType.accountKey20 =>
        XCMV4JunctionAccountKey20.deserializeJson(decode.value),
      XCMJunctionType.palletInstance =>
        XCMV4JunctionPalletInstance.deserializeJson(decode.value),
      XCMJunctionType.generalIndex =>
        XCMV4JunctionGeneralIndex.deserializeJson(decode.value),
      XCMJunctionType.generalKey =>
        XCMV4JunctionGeneralKey.deserializeJson(decode.value),
      XCMJunctionType.onlyChild =>
        XCMV4JunctionOnlyChild.deserializeJson(decode.value),
      XCMJunctionType.plurality =>
        XCMV4JunctionPlurality.deserializeJson(decode.value),
      XCMJunctionType.globalConsensus =>
        XCMV4JunctionGlobalConsensus.deserializeJson(decode.value),
    };
  }
  factory XCMV4Junction.from(XCMJunction junction) {
    if (junction is XCMV4Junction) return junction;
    final type = junction.type;
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV4JunctionParaChain(id: (junction as XCMJunctionParaChain).id),
      XCMJunctionType.accountId32 => () {
          final account32 = junction as XCMJunctionAccountId32;
          return XCMV4JunctionAccountId32(
              id: account32.id,
              network: account32.network == null
                  ? null
                  : XCMV4NetworkId.from(account32.network!));
        }(),
      XCMJunctionType.accountIndex64 => () {
          final account = junction as XCMJunctionAccountIndex64;
          return XCMV4JunctionAccountIndex64(
              index: account.index,
              network: account.network == null
                  ? null
                  : XCMV4NetworkId.from(account.network!));
        }(),
      XCMJunctionType.accountKey20 => () {
          final account = junction as XCMJunctionAccountKey20;
          return XCMV4JunctionAccountKey20(
              key: account.key,
              network: account.network == null
                  ? null
                  : XCMV4NetworkId.from(account.network!));
        }(),
      XCMJunctionType.palletInstance => XCMV4JunctionPalletInstance(
          index: (junction as XCMJunctionPalletInstance).index),
      XCMJunctionType.generalIndex => XCMV4JunctionGeneralIndex(
          index: (junction as XCMJunctionGeneralIndex).index),
      XCMJunctionType.generalKey => () {
          final account = junction as XCMJunctionGeneralKey;
          return XCMV4JunctionGeneralKey(
              data: account.data, length: account.length);
        }(),
      XCMJunctionType.onlyChild => XCMV4JunctionOnlyChild(),
      XCMJunctionType.plurality => () {
          final plurality = junction as XCMJunctionPlurality;
          return XCMV4JunctionPlurality(
              id: XCMV3BodyId.from(plurality.id),
              part: XCMV3BodyPart.from(plurality.part));
        }(),
      XCMJunctionType.globalConsensus => XCMV4JunctionGlobalConsensus(
          network: XCMV4NetworkId.from(
              (junction as XCMJunctionGlobalConsensus).network)),
    };
  }
  factory XCMV4Junction.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionType.parachain => XCMV4JunctionParaChain.fromJson(json),
      XCMJunctionType.accountId32 => XCMV4JunctionAccountId32.fromJson(json),
      XCMJunctionType.accountIndex64 =>
        XCMV4JunctionAccountIndex64.fromJson(json),
      XCMJunctionType.accountKey20 => XCMV4JunctionAccountKey20.fromJson(json),
      XCMJunctionType.palletInstance =>
        XCMV4JunctionPalletInstance.fromJson(json),
      XCMJunctionType.generalIndex => XCMV4JunctionGeneralIndex.fromJson(json),
      XCMJunctionType.generalKey => XCMV4JunctionGeneralKey.fromJson(json),
      XCMJunctionType.onlyChild => XCMV4JunctionOnlyChild.fromJson(json),
      XCMJunctionType.plurality => XCMV4JunctionPlurality.fromJson(json),
      XCMJunctionType.globalConsensus =>
        XCMV4JunctionGlobalConsensus.fromJson(json),
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
            XCMV4JunctionAccountId32.layout_(property: property),
        property: XCMJunctionType.accountId32.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4JunctionAccountIndex64.layout_(property: property),
        property: XCMJunctionType.accountIndex64.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4JunctionAccountKey20.layout_(property: property),
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
            XCMV4JunctionGlobalConsensus.layout_(property: property),
        property: XCMJunctionType.globalConsensus.name,
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4JunctionParaChain extends XCMV4Junction with XCMJunctionParaChain {
  @override
  final int id;
  XCMV4JunctionParaChain({required int id}) : id = id.asUint32;

  factory XCMV4JunctionParaChain.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionParaChain(id: IntUtils.parse(json["id"]));
  }
  factory XCMV4JunctionParaChain.fromJson(Map<String, dynamic> json) {
    return XCMV4JunctionParaChain(
        id: json.valueAs(XCMJunctionType.parachain.type));
  }
}

class XCMV4JunctionAccountId32 extends XCMV4Junction
    with XCMJunctionAccountId32 {
  @override
  final XCMV4NetworkId? network;
  @override
  final List<int> id;
  XCMV4JunctionAccountId32({this.network, required List<int> id})
      : id = id.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;

  factory XCMV4JunctionAccountId32.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionAccountId32(
        network: json["network"] == null
            ? null
            : XCMV4NetworkId.deserializeJson(json["network"]),
        id: (json["id"] as List).cast());
  }
  factory XCMV4JunctionAccountId32.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountId32.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV4JunctionAccountId32(
        network: network == null ? null : XCMV4NetworkId.fromJson(network),
        id: accountId.valueAsBytes("id"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV4NetworkId.layout_(), property: "network"),
      LayoutConst.fixedBlob32(property: "id")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV4JunctionAccountIndex64 extends XCMV4Junction
    with XCMJunctionAccountIndex64 {
  @override
  final XCMV4NetworkId? network;
  @override
  final BigInt index;
  XCMV4JunctionAccountIndex64({this.network, required BigInt index})
      : index = index.asUint64;

  factory XCMV4JunctionAccountIndex64.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4JunctionAccountIndex64(
        network: json["network"] == null
            ? null
            : XCMV4NetworkId.deserializeJson(json["network"]),
        index: BigintUtils.parse(json["index"]));
  }
  factory XCMV4JunctionAccountIndex64.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountIndex64.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV4JunctionAccountIndex64(
        network: network == null ? null : XCMV4NetworkId.fromJson(network),
        index: accountId.valueAs("index"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV4NetworkId.layout_(), property: "network"),
      LayoutConst.compactBigintU64(property: "index")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV4JunctionAccountKey20 extends XCMV4Junction
    with XCMJunctionAccountKey20 {
  @override
  final XCMV4NetworkId? network;
  @override
  final List<int> key;
  XCMV4JunctionAccountKey20({this.network, required List<int> key})
      : key = key
            .exc(SubstrateConstant.accountId20LengthInBytes)
            .asImmutableBytes;

  factory XCMV4JunctionAccountKey20.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionAccountKey20(
        network: json["network"] == null
            ? null
            : XCMV4NetworkId.deserializeJson(json["network"]),
        key: (json["key"] as List).cast());
  }
  factory XCMV4JunctionAccountKey20.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountKey20.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV4JunctionAccountKey20(
        network: network == null ? null : XCMV4NetworkId.fromJson(network),
        key: accountId.valueAsBytes("key"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV4NetworkId.layout_(), property: "network"),
      LayoutConst.fixedBlobN(SubstrateConstant.accountId20LengthInBytes,
          property: "key")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV4JunctionPalletInstance extends XCMV4Junction
    with XCMJunctionPalletInstance {
  @override
  final int index;
  XCMV4JunctionPalletInstance({required int index}) : index = index.asUint8;

  factory XCMV4JunctionPalletInstance.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4JunctionPalletInstance(index: IntUtils.parse(json["index"]));
  }
  factory XCMV4JunctionPalletInstance.fromJson(Map<String, dynamic> json) {
    return XCMV4JunctionPalletInstance(
        index: json.valueAs(XCMJunctionType.palletInstance.type));
  }
}

class XCMV4JunctionGeneralIndex extends XCMV4Junction
    with XCMJunctionGeneralIndex {
  @override
  final BigInt index;
  XCMV4JunctionGeneralIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV4JunctionGeneralIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionGeneralIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV4JunctionGeneralIndex.fromJson(Map<String, dynamic> json) {
    return XCMV4JunctionGeneralIndex(
        index: json.valueAs(XCMJunctionType.generalIndex.type));
  }
}

class XCMV4JunctionGeneralKey extends XCMV4Junction with XCMJunctionGeneralKey {
  @override
  final int length;
  @override
  final List<int> data;
  XCMV4JunctionGeneralKey._({required int length, required List<int> data})
      : length = length.asUint8,
        data =
            data.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;
  factory XCMV4JunctionGeneralKey(
      {required int length, required List<int> data}) {
    if (data.length < length ||
        length > SubstrateConstant.accountIdLengthInBytes ||
        data.length > SubstrateConstant.accountIdLengthInBytes) {
      throw DartSubstratePluginException(
          "Invalid V4 Junction GeneralKey bytes.");
    }
    if (data.length != SubstrateConstant.accountIdLengthInBytes) {
      final dataBytes =
          List<int>.filled(SubstrateConstant.accountIdLengthInBytes, 0);
      dataBytes.setAll(0, data);
      data = dataBytes;
    }

    return XCMV4JunctionGeneralKey._(length: length, data: data);
  }
  factory XCMV4JunctionGeneralKey.fromJson(Map<String, dynamic> json) {
    final key = json.valueEnsureAsMap(XCMJunctionType.generalKey.type);
    return XCMV4JunctionGeneralKey(
        length: key.valueAs("length"), data: key.valueAsBytes("data"));
  }

  factory XCMV4JunctionGeneralKey.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionGeneralKey(
        length: IntUtils.parse(json["length"]),
        data: (json["data"] as List).cast());
  }
}

class XCMV4JunctionOnlyChild extends XCMV4Junction with XCMJunctionOnlyChild {
  XCMV4JunctionOnlyChild();

  factory XCMV4JunctionOnlyChild.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionOnlyChild();
  }
  factory XCMV4JunctionOnlyChild.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionType.onlyChild.type);
    return XCMV4JunctionOnlyChild();
  }
}

class XCMV4JunctionPlurality extends XCMV4Junction with XCMJunctionPlurality {
  @override
  final XCMV3BodyId id;
  @override
  final XCMV3BodyPart part;
  XCMV4JunctionPlurality({required this.id, required this.part});

  factory XCMV4JunctionPlurality.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionPlurality(
        id: XCMV3BodyId.deserializeJson(json["id"]),
        part: XCMV3BodyPart.deserializeJson(json["part"]));
  }

  factory XCMV4JunctionPlurality.fromJson(Map<String, dynamic> json) {
    final plurality =
        json.valueEnsureAsMap<String, dynamic>(XCMJunctionType.plurality.type);
    return XCMV4JunctionPlurality(
        id: XCMV3BodyId.fromJson(plurality.valueAs("id")),
        part: XCMV3BodyPart.fromJson(plurality.valueAs("part")));
  }
}

class XCMV4JunctionGlobalConsensus extends XCMV4Junction
    with XCMJunctionGlobalConsensus {
  @override
  final XCMV4NetworkId network;
  XCMV4JunctionGlobalConsensus({required this.network});

  factory XCMV4JunctionGlobalConsensus.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4JunctionGlobalConsensus(
        network: XCMV4NetworkId.deserializeJson(json["network"]));
  }
  factory XCMV4JunctionGlobalConsensus.fromJson(Map<String, dynamic> json) {
    final network = json.valueEnsureAsMap<String, dynamic>(
        XCMJunctionType.globalConsensus.type);
    return XCMV4JunctionGlobalConsensus(
        network: XCMV4NetworkId.fromJson(network));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4NetworkId.layout_(property: "network"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

typedef XCMV4InteriorMultiLocation = XCMV4Junctions;

abstract class XCMV4Junctions extends XCMJunctions<XCMV4Junction> {
  XCMV4Junctions({required super.type, required super.junctions});
  factory XCMV4Junctions.fromJunctions(List<XCMV4Junction> junctions) {
    final type = XCMJunctionsType.fromLength(junctions.length);
    return switch (type) {
      XCMJunctionsType.here => XCMV4JunctionsHere(),
      XCMJunctionsType.x1 => XCMV4JunctionsX1(junctions: junctions),
      XCMJunctionsType.x2 => XCMV4JunctionsX2(junctions: junctions),
      XCMJunctionsType.x3 => XCMV4JunctionsX3(junctions: junctions),
      XCMJunctionsType.x4 => XCMV4JunctionsX4(junctions: junctions),
      XCMJunctionsType.x5 => XCMV4JunctionsX5(junctions: junctions),
      XCMJunctionsType.x6 => XCMV4JunctionsX6(junctions: junctions),
      XCMJunctionsType.x7 => XCMV4JunctionsX7(junctions: junctions),
      XCMJunctionsType.x8 => XCMV4JunctionsX8(junctions: junctions),
    };
  }
  factory XCMV4Junctions.from(XCMJunctions junctions) {
    if (junctions is XCMV4Junctions) return junctions;
    final type = junctions.type;
    final vJunctions =
        junctions.junctions.map((e) => XCMV4Junction.from(e)).toList();
    return switch (type) {
      XCMJunctionsType.here => XCMV4JunctionsHere(),
      XCMJunctionsType.x1 => XCMV4JunctionsX1(junctions: vJunctions),
      XCMJunctionsType.x2 => XCMV4JunctionsX2(junctions: vJunctions),
      XCMJunctionsType.x3 => XCMV4JunctionsX3(junctions: vJunctions),
      XCMJunctionsType.x4 => XCMV4JunctionsX4(junctions: vJunctions),
      XCMJunctionsType.x5 => XCMV4JunctionsX5(junctions: vJunctions),
      XCMJunctionsType.x6 => XCMV4JunctionsX6(junctions: vJunctions),
      XCMJunctionsType.x7 => XCMV4JunctionsX7(junctions: vJunctions),
      XCMJunctionsType.x8 => XCMV4JunctionsX8(junctions: vJunctions),
    };
  }
  factory XCMV4Junctions.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionsType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionsType.here => XCMV4JunctionsHere.fromJson(json),
      XCMJunctionsType.x1 => XCMV4JunctionsX1.fromJson(json),
      XCMJunctionsType.x2 => XCMV4JunctionsX2.fromJson(json),
      XCMJunctionsType.x3 => XCMV4JunctionsX3.fromJson(json),
      XCMJunctionsType.x4 => XCMV4JunctionsX4.fromJson(json),
      XCMJunctionsType.x5 => XCMV4JunctionsX5.fromJson(json),
      XCMJunctionsType.x6 => XCMV4JunctionsX6.fromJson(json),
      XCMJunctionsType.x7 => XCMV4JunctionsX7.fromJson(json),
      XCMJunctionsType.x8 => XCMV4JunctionsX8.fromJson(json),
    };
  }

  factory XCMV4Junctions.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionsType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionsType.here => XCMV4JunctionsHere.deserializeJson(decode.value),
      XCMJunctionsType.x1 => XCMV4JunctionsX1.deserializeJson(decode.value),
      XCMJunctionsType.x2 => XCMV4JunctionsX2.deserializeJson(decode.value),
      XCMJunctionsType.x3 => XCMV4JunctionsX3.deserializeJson(decode.value),
      XCMJunctionsType.x4 => XCMV4JunctionsX4.deserializeJson(decode.value),
      XCMJunctionsType.x5 => XCMV4JunctionsX5.deserializeJson(decode.value),
      XCMJunctionsType.x6 => XCMV4JunctionsX6.deserializeJson(decode.value),
      XCMJunctionsType.x7 => XCMV4JunctionsX7.deserializeJson(decode.value),
      XCMJunctionsType.x8 => XCMV4JunctionsX8.deserializeJson(decode.value),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsHere.layout_(property: property),
          property: XCMJunctionsType.here.name,
          index: 0),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x1, property: property),
          property: XCMJunctionsType.x1.name,
          index: 1),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x2, property: property),
          property: XCMJunctionsType.x2.name,
          index: 2),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x3, property: property),
          property: XCMJunctionsType.x3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x4, property: property),
          property: XCMJunctionsType.x4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x5, property: property),
          property: XCMJunctionsType.x5.name,
          index: 5),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x6, property: property),
          property: XCMJunctionsType.x6.name,
          index: 6),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x7, property: property),
          property: XCMJunctionsType.x7.name,
          index: 7),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV4JunctionsX1.layout_(XCMJunctionsType.x8, property: property),
          property: XCMJunctionsType.x8.name,
          index: 8)
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> toJson();
  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4JunctionsHere extends XCMV4Junctions {
  XCMV4JunctionsHere() : super(type: XCMJunctionsType.here, junctions: []);

  factory XCMV4JunctionsHere.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionsHere();
  }
  factory XCMV4JunctionsHere.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionsType.here.type);
    return XCMV4JunctionsHere();
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

class XCMV4JunctionsX1 extends XCMV4Junctions {
  XCMV4JunctionsX1._({required super.junctions, required super.type});
  XCMV4JunctionsX1({required super.junctions})
      : super(type: XCMJunctionsType.x1);
  XCMV4JunctionsX1._deserialize(Map<String, dynamic> json,
      {required super.type})
      : super(
            junctions: (json["junctions"] as List)
                .map((e) => XCMV4Junction.deserializeJson(e))
                .toList());
  factory XCMV4JunctionsX1.deserializeJson(Map<String, dynamic> json) {
    return XCMV4JunctionsX1(
        junctions: (json["junctions"] as List)
            .map((e) => XCMV4Junction.deserializeJson(e))
            .toList());
  }
  factory XCMV4JunctionsX1.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x1.type);
    return XCMV4JunctionsX1(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  static Layout<Map<String, dynamic>> layout_(XCMJunctionsType type,
      {String? property}) {
    return LayoutConst.struct([
      LayoutConst.tuple(
          List.filled(type.junctionsLength, XCMV4Junction.layout_()),
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
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX2 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX2.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x2);
  XCMV4JunctionsX2({required super.junctions})
      : super._(type: XCMJunctionsType.x2);
  factory XCMV4JunctionsX2.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x2.type);
    return XCMV4JunctionsX2(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX3 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX3.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x3);
  XCMV4JunctionsX3({required super.junctions})
      : super._(type: XCMJunctionsType.x3);
  factory XCMV4JunctionsX3.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x3.type);
    return XCMV4JunctionsX3(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX4 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX4.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x4);
  XCMV4JunctionsX4({required super.junctions})
      : super._(type: XCMJunctionsType.x4);
  factory XCMV4JunctionsX4.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x4.type);
    return XCMV4JunctionsX4(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX5 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX5.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x5);
  XCMV4JunctionsX5({required super.junctions})
      : super._(type: XCMJunctionsType.x5);
  factory XCMV4JunctionsX5.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x5.type);
    return XCMV4JunctionsX5(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX6 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX6.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x6);
  XCMV4JunctionsX6({required super.junctions})
      : super._(type: XCMJunctionsType.x6);
  factory XCMV4JunctionsX6.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x6.type);
    return XCMV4JunctionsX6(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX7 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX7.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x7);
  XCMV4JunctionsX7({required super.junctions})
      : super._(type: XCMJunctionsType.x7);
  factory XCMV4JunctionsX7.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x7.type);
    return XCMV4JunctionsX7(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4JunctionsX8 extends XCMV4JunctionsX1 {
  XCMV4JunctionsX8.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x8);
  XCMV4JunctionsX8({required super.junctions})
      : super._(type: XCMJunctionsType.x8);

  factory XCMV4JunctionsX8.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x8.type);
    return XCMV4JunctionsX8(
        junctions: junctions.map((e) => XCMV4Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV4Location extends XCMMultiLocation with Equality {
  @override
  final int parents;
  @override
  final XCMV4Junctions interior;

  @override
  XCMVersion get version => XCMVersion.v4;
  XCMV4Location({required int parents, required this.interior})
      : parents = parents.asUint8;
  factory XCMV4Location.deserialize(List<int> bytes) {
    final json =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMV4Location.deserializeJson(json.value);
  }
  factory XCMV4Location.deserializeJson(Map<String, dynamic> json) {
    return XCMV4Location(
        parents: IntUtils.parse(json["parents"]),
        interior: XCMV4Junctions.deserializeJson(json["interior"]));
  }
  factory XCMV4Location.fromJson(Map<String, dynamic> json) {
    return XCMV4Location(
        parents: json.valueAs("parents"),
        interior: XCMV4Junctions.fromJson(json.valueAs("interior")));
  }

  factory XCMV4Location.from(XCMMultiLocation location) {
    if (location is XCMV4Location) return location;
    return XCMV4Location(
        parents: location.parents,
        interior: XCMV4Junctions.from(location.interior));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "parents"),
      XCMV4Junctions.layout_(property: "interior")
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

abstract class XCMV4AssetInstance extends SubstrateVariantSerialization
    with XCMAssetInstance, Equality {
  const XCMV4AssetInstance();
  factory XCMV4AssetInstance.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMAssetInstanceType.fromName(decode.variantName);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV4AssetInstanceUndefined.deserializeJson(decode.value),
      XCMAssetInstanceType.indexId =>
        XCMV4AssetInstanceIndex.deserializeJson(decode.value),
      XCMAssetInstanceType.array4 =>
        XCMV4AssetInstanceArray4.deserializeJson(decode.value),
      XCMAssetInstanceType.array8 =>
        XCMV4AssetInstanceArray8.deserializeJson(decode.value),
      XCMAssetInstanceType.array16 =>
        XCMV4AssetInstanceArray16.deserializeJson(decode.value),
      XCMAssetInstanceType.array32 =>
        XCMV4AssetInstanceArray32.deserializeJson(decode.value)
    };
  }

  factory XCMV4AssetInstance.fromJson(Map<String, dynamic> json) {
    final type = XCMAssetInstanceType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV4AssetInstanceUndefined.fromJson(json),
      XCMAssetInstanceType.indexId => XCMV4AssetInstanceIndex.fromJson(json),
      XCMAssetInstanceType.array4 => XCMV4AssetInstanceArray4.fromJson(json),
      XCMAssetInstanceType.array8 => XCMV4AssetInstanceArray8.fromJson(json),
      XCMAssetInstanceType.array16 => XCMV4AssetInstanceArray16.fromJson(json),
      XCMAssetInstanceType.array32 => XCMV4AssetInstanceArray32.fromJson(json)
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4AssetInstanceUndefined extends XCMV4AssetInstance
    with XCMAssetInstanceUndefined {
  XCMV4AssetInstanceUndefined();

  factory XCMV4AssetInstanceUndefined.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4AssetInstanceUndefined();
  }
  factory XCMV4AssetInstanceUndefined.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMAssetInstanceType.undefined.type);
    return XCMV4AssetInstanceUndefined();
  }
}

class XCMV4AssetInstanceIndex extends XCMV4AssetInstance
    with XCMAssetInstanceIndex {
  @override
  final BigInt index;
  XCMV4AssetInstanceIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV4AssetInstanceIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV4AssetInstanceIndex.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceIndex(
        index: json.valueAs(XCMAssetInstanceType.indexId.type));
  }
}

class XCMV4AssetInstanceArray4 extends XCMV4AssetInstance
    with XCMAssetInstanceArray4 {
  @override
  final List<int> datum;
  XCMV4AssetInstanceArray4({required List<int> datum})
      : datum = datum.exc(4).asImmutableBytes;

  factory XCMV4AssetInstanceArray4.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray4(datum: (json["datum"] as List).cast());
  }
  factory XCMV4AssetInstanceArray4.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray4(
        datum: json.valueAsBytes(XCMAssetInstanceType.array4.type));
  }
}

class XCMV4AssetInstanceArray8 extends XCMV4AssetInstance
    with XCMAssetInstanceArray8 {
  @override
  final List<int> datum;
  XCMV4AssetInstanceArray8({required List<int> datum})
      : datum = datum.exc(8).asImmutableBytes;

  factory XCMV4AssetInstanceArray8.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray8(datum: (json["datum"] as List).cast());
  }
  factory XCMV4AssetInstanceArray8.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray8(
        datum: json.valueAsBytes(XCMAssetInstanceType.array8.type));
  }
}

class XCMV4AssetInstanceArray16 extends XCMV4AssetInstance
    with XCMAssetInstanceArray16 {
  @override
  final List<int> datum;
  XCMV4AssetInstanceArray16({required List<int> datum})
      : datum = datum.exc(16).asImmutableBytes;

  factory XCMV4AssetInstanceArray16.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray16(datum: (json["datum"] as List).cast());
  }
  factory XCMV4AssetInstanceArray16.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray16(
        datum: json.valueAsBytes(XCMAssetInstanceType.array16.type));
  }
}

class XCMV4AssetInstanceArray32 extends XCMV4AssetInstance
    with XCMAssetInstanceArray32 {
  @override
  final List<int> datum;
  XCMV4AssetInstanceArray32({required List<int> datum})
      : datum = datum.exc(32).asImmutableBytes;
  factory XCMV4AssetInstanceArray32.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray32(datum: (json["datum"] as List).cast());
  }
  factory XCMV4AssetInstanceArray32.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetInstanceArray32(
        datum: json.valueAsBytes(XCMAssetInstanceType.array32.type));
  }
}

abstract class XCMV4Fungibility extends SubstrateVariantSerialization
    with XCMFungibility, Equality {
  const XCMV4Fungibility();
  factory XCMV4Fungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMFungibilityType.fungible =>
        XCMV4FungibilityFungible.deserializeJson(decode.value),
      XCMFungibilityType.nonFungible =>
        XCMV4FungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV4Fungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMFungibilityType.fungible => XCMV4FungibilityFungible.fromJson(json),
      XCMFungibilityType.nonFungible =>
        XCMV4FungibilityNonFungible.fromJson(json)
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
            XCMV4FungibilityNonFungible.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4FungibilityFungible extends XCMV4Fungibility
    with XCMFungibilityFungible {
  @override
  final BigInt units;
  XCMV4FungibilityFungible({required BigInt units}) : units = units.asUint128;

  factory XCMV4FungibilityFungible.deserializeJson(Map<String, dynamic> json) {
    return XCMV4FungibilityFungible(units: BigintUtils.parse(json["units"]));
  }
  factory XCMV4FungibilityFungible.fromJson(Map<String, dynamic> json) {
    return XCMV4FungibilityFungible(
        units: json.valueAs(XCMFungibilityType.fungible.type));
  }
}

class XCMV4FungibilityNonFungible extends XCMV4Fungibility
    with XCMFungibilityNonFungible {
  @override
  final XCMV4AssetInstance instance;

  XCMV4FungibilityNonFungible({required this.instance});

  factory XCMV4FungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4FungibilityNonFungible(
        instance: XCMV4AssetInstance.deserializeJson(json["instance"]));
  }
  factory XCMV4FungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    return XCMV4FungibilityNonFungible(
        instance: XCMV4AssetInstance.fromJson(
            json.valueAs(XCMFungibilityType.nonFungible.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV4AssetInstance.layout_(property: "instance")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

abstract class XCMV4WildFungibility extends SubstrateVariantSerialization
    with XCMWildFungibility, Equality {
  const XCMV4WildFungibility();
  factory XCMV4WildFungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV4WildFungibilityFungible.deserializeJson(decode.value),
      XCMWildFungibilityType.nonFungible =>
        XCMV4WildFungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV4WildFungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMWildFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV4WildFungibilityFungible.fromJson(json),
      XCMWildFungibilityType.nonFungible =>
        XCMV4WildFungibilityNonFungible.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4WildFungibilityFungible.layout_(property: property),
        property: XCMWildFungibilityType.fungible.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4WildFungibilityNonFungible.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4WildFungibilityFungible extends XCMV4WildFungibility
    with XCMWildFungibilityFungible {
  XCMV4WildFungibilityFungible();

  factory XCMV4WildFungibilityFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4WildFungibilityFungible();
  }
  factory XCMV4WildFungibilityFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.fungible.type);
    return XCMV4WildFungibilityFungible();
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

class XCMV4WildFungibilityNonFungible extends XCMV4WildFungibility
    with XCMWildFungibilityNonFungible {
  XCMV4WildFungibilityNonFungible();

  factory XCMV4WildFungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4WildFungibilityNonFungible();
  }
  factory XCMV4WildFungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.nonFungible.type);
    return XCMV4WildFungibilityNonFungible();
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

class XCMV4AssetId extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAssetId, Equality {
  @override
  final XCMV4Location location;

  XCMV4AssetId({required this.location});

  factory XCMV4AssetId.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetId(
        location: XCMV4Location.deserializeJson(json["location"]));
  }
  factory XCMV4AssetId.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetId(location: XCMV4Location.fromJson(json));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4Location.layout_(property: "location")],
        property: property);
  }

  factory XCMV4AssetId.from(XCMAssetId id) {
    return switch (id) {
      final XCMV4AssetId assetId => assetId,
      final XCMV2AssetId assetId => switch (assetId.type) {
          XCMV2AssetIdType.abtract => throw DartSubstratePluginException(
              "Unsuported AssetId v2 ${XCMV2AssetIdType.abtract.type} by version 4"),
          XCMV2AssetIdType.concrete => XCMV4AssetId(
              location: assetId
                  .cast<XCMV2AssetIdConcrete>()
                  .location
                  .asVersion(XCMVersion.v4)),
        },
      final XCMV3AssetId assetId => switch (assetId.type) {
          XCMV3AssetIdType.abtract => throw DartSubstratePluginException(
              "Unsuported AssetId v3 ${XCMV3AssetIdType.abtract.type} by version 4"),
          XCMV3AssetIdType.concrete => XCMV4AssetId(
              location: assetId
                  .cast<XCMV3AssetIdConcrete>()
                  .location
                  .asVersion(XCMVersion.v4)),
        },
      final XCMV5AssetId assetId =>
        XCMV4AssetId(location: assetId.location.asVersion(XCMVersion.v4)),
      _ => throw DartSubstratePluginException("Unknow asset id.")
    };
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
  List get variabels => [location];
  @override
  XCMVersion get version => XCMVersion.v4;

  @override
  Map<String, dynamic> toJson() {
    return location.toJson();
  }
}

class XCMV4Asset extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAsset, Equality {
  @override
  final XCMV4AssetId id;
  @override
  final XCMV4Fungibility fun;
  @override
  XCMVersion get version => XCMVersion.v4;
  XCMV4Asset({required this.id, required this.fun}) : super();

  factory XCMV4Asset.deserializeJson(Map<String, dynamic> json) {
    return XCMV4Asset(
        id: XCMV4AssetId.deserializeJson(json["id"]),
        fun: XCMV4Fungibility.deserializeJson(json["fun"]));
  }
  factory XCMV4Asset.fromJson(Map<String, dynamic> json) {
    return XCMV4Asset(
        id: XCMV4AssetId.fromJson(json.valueAs("id")),
        fun: XCMV4Fungibility.fromJson(json["fun"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetId.layout_(property: "id"),
      XCMV4Fungibility.layout_(property: "fun"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id.serializeJson(), "fun": fun.serializeJsonVariant()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {"id": id.toJson(), "fun": fun.toJson()};
  }
}

class XCMV4Assets extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAssets<XCMV4Asset>, Equality {
  @override
  final List<XCMV4Asset> assets;

  XCMV4Assets({required List<XCMV4Asset> assets}) : assets = assets.immutable;

  factory XCMV4Assets.deserializeJson(Map<String, dynamic> json) {
    return XCMV4Assets(
        assets: (json["assets"] as List)
            .map((e) => XCMV4Asset.deserializeJson(e))
            .toList());
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactArray(XCMV4Asset.layout_(), property: "assets")],
        property: property);
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
  XCMVersion get version => XCMVersion.v4;
}

abstract class XCMV4WildAsset extends SubstrateVariantSerialization
    with XCMWildMultiAsset, Equality {
  const XCMV4WildAsset();
  factory XCMV4WildAsset.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildAssetType.fromName(decode.variantName);
    return switch (type) {
      XCMWildAssetType.all => XCMV4WildAssetAll.deserializeJson(decode.value),
      XCMWildAssetType.allOf =>
        XCMV4WildAssetAllOf.deserializeJson(decode.value),
      XCMWildAssetType.allCounted =>
        XCMV4WildAssetAllCounted.deserializeJson(decode.value),
      XCMWildAssetType.allOfCounted =>
        XCMV4WildAssetAllOfCounted.deserializeJson(decode.value)
    };
  }
  factory XCMV4WildAsset.fromJson(Map<String, dynamic> json) {
    final type = XCMWildAssetType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildAssetType.all => XCMV4WildAssetAll.fromJson(json),
      XCMWildAssetType.allOf => XCMV4WildAssetAllOf.fromJson(json),
      XCMWildAssetType.allCounted => XCMV4WildAssetAllCounted.fromJson(json),
      XCMWildAssetType.allOfCounted => XCMV4WildAssetAllOfCounted.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMV4WildAssetAll.layout_(property: property),
        property: XCMWildAssetType.all.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV4WildAssetAllOf.layout_(property: property),
        property: XCMWildAssetType.allOf.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4WildAssetAllCounted.layout_(property: property),
        property: XCMWildAssetType.allCounted.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4WildAssetAllOfCounted.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4WildAssetAll extends XCMV4WildAsset with XCMWildMultiAssetAll {
  XCMV4WildAssetAll();

  factory XCMV4WildAssetAll.deserializeJson(Map<String, dynamic> json) {
    return XCMV4WildAssetAll();
  }
  factory XCMV4WildAssetAll.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildAssetType.all.type);
    return XCMV4WildAssetAll();
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

class XCMV4WildAssetAllOf extends XCMV4WildAsset with XCMWildMultiAssetAllOf {
  @override
  final XCMV4AssetId id;
  @override
  final XCMV4WildFungibility fun;

  XCMV4WildAssetAllOf({required this.id, required this.fun});

  factory XCMV4WildAssetAllOf.deserializeJson(Map<String, dynamic> json) {
    return XCMV4WildAssetAllOf(
        id: XCMV4AssetId.deserializeJson(json["id"]),
        fun: XCMV4WildFungibility.deserializeJson(json["fun"]));
  }
  factory XCMV4WildAssetAllOf.fromJson(Map<String, dynamic> json) {
    final allOf =
        json.valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOf.type);
    return XCMV4WildAssetAllOf(
        id: XCMV4AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV4WildFungibility.fromJson(allOf.valueAs("fun")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetId.layout_(property: "id"),
      XCMV4WildFungibility.layout_(property: "fun"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id.serializeJson(), "fun": fun.serializeJsonVariant()};
  }
}

class XCMV4WildAssetAllCounted extends XCMV4WildAsset
    with XCMWildMultiAssetAllCounted {
  @override
  final int count;
  XCMV4WildAssetAllCounted({required int count}) : count = count.asUint32;

  factory XCMV4WildAssetAllCounted.deserializeJson(Map<String, dynamic> json) {
    return XCMV4WildAssetAllCounted(count: IntUtils.parse(json["count"]));
  }
  factory XCMV4WildAssetAllCounted.fromJson(Map<String, dynamic> json) {
    return XCMV4WildAssetAllCounted(
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

class XCMV4WildAssetAllOfCounted extends XCMV4WildAsset
    with XCMWildMultiAssetAllOfCounted {
  @override
  final XCMV4AssetId id;
  @override
  final XCMV4WildFungibility fun;
  @override
  final int count;
  XCMV4WildAssetAllOfCounted(
      {required this.id, required this.fun, required int count})
      : count = count.asUint32;

  factory XCMV4WildAssetAllOfCounted.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV4WildAssetAllOfCounted(
        id: XCMV4AssetId.deserializeJson(json["id"]),
        fun: XCMV4WildFungibility.deserializeJson(json["fun"]),
        count: IntUtils.parse(json["count"]));
  }
  factory XCMV4WildAssetAllOfCounted.fromJson(Map<String, dynamic> json) {
    final allOf = json
        .valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOfCounted.type);
    return XCMV4WildAssetAllOfCounted(
        id: XCMV4AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV4WildFungibility.fromJson(allOf.valueAs("fun")),
        count: allOf.valueAs("count"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV4AssetId.layout_(property: "id"),
      XCMV4WildFungibility.layout_(property: "fun"),
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
      "id": id.serializeJson(),
      "fun": fun.serializeJsonVariant(),
      "count": count
    };
  }
}

abstract class XCMV4AssetFilter extends SubstrateVariantSerialization
    with XCMMultiAssetFilter, Equality {
  @override
  XCMMultiAssetFilterType get type;
  const XCMV4AssetFilter();
  factory XCMV4AssetFilter.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMMultiAssetFilterType.fromName(decode.variantName);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV4AssetFilterDefinite.deserializeJson(decode.value),
      XCMMultiAssetFilterType.wild =>
        XCMV4AssetFilterWild.deserializeJson(decode.value)
    };
  }
  factory XCMV4AssetFilter.fromJson(Map<String, dynamic> json) {
    final type = XCMMultiAssetFilterType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV4AssetFilterDefinite.fromJson(json),
      XCMMultiAssetFilterType.wild => XCMV4AssetFilterWild.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4AssetFilterDefinite.layout_(property: property),
        property: XCMMultiAssetFilterType.definite.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV4AssetFilterWild.layout_(property: property),
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
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v4;
}

class XCMV4AssetFilterDefinite extends XCMV4AssetFilter
    with XCMMultiAssetFilterDefinite {
  @override
  final XCMV4Assets assets;
  XCMV4AssetFilterDefinite({required this.assets}) : super();

  factory XCMV4AssetFilterDefinite.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetFilterDefinite(
        assets: XCMV4Assets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV4AssetFilterDefinite.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMMultiAssetFilterType.definite.type);
    return XCMV4AssetFilterDefinite(
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
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.definite;
}

class XCMV4AssetFilterWild extends XCMV4AssetFilter
    with XCMMultiAssetFilterWild {
  @override
  final XCMV4WildAsset asset;
  XCMV4AssetFilterWild({required this.asset}) : super();

  factory XCMV4AssetFilterWild.deserializeJson(Map<String, dynamic> json) {
    return XCMV4AssetFilterWild(
        asset: XCMV4WildAsset.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV4AssetFilterWild.fromJson(Map<String, dynamic> json) {
    return XCMV4AssetFilterWild(
        asset: XCMV4WildAsset.fromJson(
            json.valueAs(XCMMultiAssetFilterType.wild.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV4WildAsset.layout_(property: "asset")],
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
