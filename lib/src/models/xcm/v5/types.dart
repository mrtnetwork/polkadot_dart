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
import 'package:polkadot_dart/src/models/xcm/v4/types.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class XCMV5NetworkId extends SubstrateVariantSerialization
    with XCMNetworkId, Equality {
  const XCMV5NetworkId();
  factory XCMV5NetworkId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMNetworkIdType.fromName(decode.variantName);
    return switch (type) {
      XCMNetworkIdType.byGenesis =>
        XCMV5ByGenesis.deserializeJson(decode.value),
      XCMNetworkIdType.byFork => XCMV5ByFork.deserializeJson(decode.value),
      XCMNetworkIdType.polkadot => XCMV5Polkadot.deserializeJson(decode.value),
      XCMNetworkIdType.kusama => XCMV5Kusama.deserializeJson(decode.value),
      XCMNetworkIdType.ethereum => XCMV5Ethereum.deserializeJson(decode.value),
      XCMNetworkIdType.bitcoinCash =>
        XCMV5BitcoinCash.deserializeJson(decode.value),
      XCMNetworkIdType.bitcoinCore =>
        XCMV5BitcoinCore.deserializeJson(decode.value),
      XCMNetworkIdType.polkadotBulletIn =>
        XCMV5PolkadotBulletIn.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 5.",
          details: {"type": type.name})
    };
  }
  factory XCMV5NetworkId.fromJson(Map<String, dynamic> json) {
    final type = XCMNetworkIdType.fromType(json.keys.first);
    return switch (type) {
      XCMNetworkIdType.byGenesis => XCMV5ByGenesis.fromJson(json),
      XCMNetworkIdType.byFork => XCMV5ByFork.fromJson(json),
      XCMNetworkIdType.polkadot => XCMV5Polkadot.fromJson(json),
      XCMNetworkIdType.kusama => XCMV5Kusama.fromJson(json),
      XCMNetworkIdType.ethereum => XCMV5Ethereum.fromJson(json),
      XCMNetworkIdType.bitcoinCash => XCMV5BitcoinCash.fromJson(json),
      XCMNetworkIdType.bitcoinCore => XCMV5BitcoinCore.fromJson(json),
      XCMNetworkIdType.polkadotBulletIn => XCMV5PolkadotBulletIn.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 5.",
          details: {"type": type.name})
    };
  }

  factory XCMV5NetworkId.from(XCMNetworkId network) {
    if (network is XCMV5NetworkId) return network;
    final type = network.type;
    return switch (type) {
      XCMNetworkIdType.byGenesis =>
        XCMV5ByGenesis(genesis: (network as XCMNetworkIdByGenesis).genesis),
      XCMNetworkIdType.byFork => () {
          final fork = network as XCMNetworkIdByFork;
          return XCMV5ByFork(
              blockHash: fork.blockHash, blockNumber: fork.blockNumber);
        }(),
      XCMNetworkIdType.polkadot => XCMV5Polkadot(),
      XCMNetworkIdType.kusama => XCMV5Kusama(),
      XCMNetworkIdType.ethereum =>
        XCMV5Ethereum(chainId: (network as XCMNetworkIdEthereum).chainId),
      XCMNetworkIdType.bitcoinCash => XCMV5BitcoinCash(),
      XCMNetworkIdType.bitcoinCore => XCMV5BitcoinCore(),
      XCMNetworkIdType.polkadotBulletIn => XCMV5PolkadotBulletIn(),
      _ => throw DartSubstratePluginException(
          "Unsuported network type by version 5.",
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
        layout: ({property}) => LayoutConst.none(),
        property: 'none',
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) => LayoutConst.none(),
        property: 'none',
        index: 5,
      ),
      LazyVariantModel(
        layout: ({property}) => LayoutConst.none(),
        property: 'none',
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5ByGenesis extends XCMV5NetworkId with XCMNetworkIdByGenesis {
  @override
  final List<int> genesis;
  XCMV5ByGenesis({required List<int> genesis})
      : genesis = genesis
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes;

  factory XCMV5ByGenesis.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ByGenesis(genesis: (json["genesis"] as List).cast());
  }
  factory XCMV5ByGenesis.fromJson(Map<String, dynamic> json) {
    return XCMV5ByGenesis(
        genesis: json.valueAsBytes(XCMNetworkIdType.byGenesis.type));
  }
}

class XCMV5ByFork extends XCMV5NetworkId with XCMNetworkIdByFork {
  @override
  final List<int> blockHash;
  @override
  final BigInt blockNumber;
  XCMV5ByFork({required List<int> blockHash, required BigInt blockNumber})
      : blockHash = blockHash
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes,
        blockNumber = blockNumber.asUint64;

  factory XCMV5ByFork.deserializeJson(Map<String, dynamic> json) {
    return XCMV5ByFork(
      blockNumber: BigintUtils.parse(json["block_number"]),
      blockHash: (json["block_hash"] as List).cast(),
    );
  }
  factory XCMV5ByFork.fromJson(Map<String, dynamic> json) {
    final byFork =
        json.valueEnsureAsMap<String, dynamic>(XCMNetworkIdType.byFork.type);
    return XCMV5ByFork(
        blockHash: byFork.valueAsBytes("block_hash"),
        blockNumber: byFork.valueAs("block_number"));
  }
}

class XCMV5Polkadot extends XCMV5NetworkId with XCMNetworkIdPolkadot {
  XCMV5Polkadot();
  XCMV5Polkadot.deserializeJson(Map<String, dynamic> json);
  factory XCMV5Polkadot.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadot.type);
    return XCMV5Polkadot();
  }
}

class XCMV5Kusama extends XCMV5NetworkId with XCMNetworkIdKusama {
  XCMV5Kusama();
  XCMV5Kusama.deserializeJson(Map<String, dynamic> json);
  factory XCMV5Kusama.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.kusama.type);
    return XCMV5Kusama();
  }
}

class XCMV5Ethereum extends XCMV5NetworkId with XCMNetworkIdEthereum {
  @override
  final BigInt chainId;
  const XCMV5Ethereum({required this.chainId});

  factory XCMV5Ethereum.deserializeJson(Map<String, dynamic> json) {
    return XCMV5Ethereum(chainId: BigintUtils.parse(json["chain_id"]));
  }
  factory XCMV5Ethereum.fromJson(Map<String, dynamic> json) {
    final BigInt chainId = json.valueAs(XCMNetworkIdType.ethereum.type);
    return XCMV5Ethereum(chainId: chainId);
  }
}

class XCMV5BitcoinCore extends XCMV5NetworkId with XCMNetworkIdBitcoinCore {
  XCMV5BitcoinCore();
  XCMV5BitcoinCore.deserializeJson(Map<String, dynamic> json);
  factory XCMV5BitcoinCore.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.bitcoinCore.type);
    return XCMV5BitcoinCore();
  }
}

class XCMV5BitcoinCash extends XCMV5NetworkId with XCMNetworkIdBitcoinCash {
  XCMV5BitcoinCash();
  XCMV5BitcoinCash.deserializeJson(Map<String, dynamic> json);
  factory XCMV5BitcoinCash.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.bitcoinCash.type);
    return XCMV5BitcoinCash();
  }
}

class XCMV5PolkadotBulletIn extends XCMV5NetworkId
    with XCMNetworkIdPolkadotBulletIn {
  XCMV5PolkadotBulletIn();
  XCMV5PolkadotBulletIn.deserializeJson(Map<String, dynamic> json);
  factory XCMV5PolkadotBulletIn.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadotBulletIn.type);
    return XCMV5PolkadotBulletIn();
  }
}

abstract class XCMV5AssetInstance extends SubstrateVariantSerialization
    with XCMAssetInstance, Equality {
  const XCMV5AssetInstance();
  factory XCMV5AssetInstance.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMAssetInstanceType.fromName(decode.variantName);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV5AssetInstanceUndefined.deserializeJson(decode.value),
      XCMAssetInstanceType.indexId =>
        XCMV5AssetInstanceIndex.deserializeJson(decode.value),
      XCMAssetInstanceType.array4 =>
        XCMV5AssetInstanceArray4.deserializeJson(decode.value),
      XCMAssetInstanceType.array8 =>
        XCMV5AssetInstanceArray8.deserializeJson(decode.value),
      XCMAssetInstanceType.array16 =>
        XCMV5AssetInstanceArray16.deserializeJson(decode.value),
      XCMAssetInstanceType.array32 =>
        XCMV5AssetInstanceArray32.deserializeJson(decode.value)
    };
  }
  factory XCMV5AssetInstance.fromJson(Map<String, dynamic> json) {
    final type = XCMAssetInstanceType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV5AssetInstanceUndefined.fromJson(json),
      XCMAssetInstanceType.indexId => XCMV5AssetInstanceIndex.fromJson(json),
      XCMAssetInstanceType.array4 => XCMV5AssetInstanceArray4.fromJson(json),
      XCMAssetInstanceType.array8 => XCMV5AssetInstanceArray8.fromJson(json),
      XCMAssetInstanceType.array16 => XCMV5AssetInstanceArray16.fromJson(json),
      XCMAssetInstanceType.array32 => XCMV5AssetInstanceArray32.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return XCMAssetInstance.layout_(property: property);
  }

  @override
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5AssetInstanceUndefined extends XCMV5AssetInstance
    with XCMAssetInstanceUndefined {
  XCMV5AssetInstanceUndefined();

  factory XCMV5AssetInstanceUndefined.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5AssetInstanceUndefined();
  }
  factory XCMV5AssetInstanceUndefined.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMAssetInstanceType.undefined.type);
    return XCMV5AssetInstanceUndefined();
  }
}

class XCMV5AssetInstanceIndex extends XCMV5AssetInstance
    with XCMAssetInstanceIndex {
  @override
  final BigInt index;
  XCMV5AssetInstanceIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV5AssetInstanceIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV5AssetInstanceIndex.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceIndex(
        index: json.valueAs(XCMAssetInstanceType.indexId.type));
  }
}

class XCMV5AssetInstanceArray4 extends XCMV5AssetInstance
    with XCMAssetInstanceArray4 {
  @override
  final List<int> datum;
  XCMV5AssetInstanceArray4({required List<int> datum})
      : datum = datum.exc(4).asImmutableBytes;

  factory XCMV5AssetInstanceArray4.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray4(datum: (json["datum"] as List).cast());
  }
  factory XCMV5AssetInstanceArray4.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray4(
        datum: json.valueAsBytes(XCMAssetInstanceType.array4.type));
  }
}

class XCMV5AssetInstanceArray8 extends XCMV5AssetInstance
    with XCMAssetInstanceArray8 {
  @override
  final List<int> datum;
  XCMV5AssetInstanceArray8({required List<int> datum})
      : datum = datum.exc(8).asImmutableBytes;

  factory XCMV5AssetInstanceArray8.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray8(datum: (json["datum"] as List).cast());
  }
  factory XCMV5AssetInstanceArray8.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray8(
        datum: json.valueAsBytes(XCMAssetInstanceType.array8.type));
  }
}

class XCMV5AssetInstanceArray16 extends XCMV5AssetInstance
    with XCMAssetInstanceArray16 {
  @override
  final List<int> datum;
  XCMV5AssetInstanceArray16({required List<int> datum})
      : datum = datum.exc(16).asImmutableBytes;

  factory XCMV5AssetInstanceArray16.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray16(datum: (json["datum"] as List).cast());
  }
  factory XCMV5AssetInstanceArray16.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray16(
        datum: json.valueAsBytes(XCMAssetInstanceType.array16.type));
  }
}

class XCMV5AssetInstanceArray32 extends XCMV5AssetInstance
    with XCMAssetInstanceArray32 {
  @override
  final List<int> datum;
  XCMV5AssetInstanceArray32({required List<int> datum})
      : datum = datum.exc(32).asImmutableBytes;

  factory XCMV5AssetInstanceArray32.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray32(datum: (json["datum"] as List).cast());
  }
  factory XCMV5AssetInstanceArray32.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetInstanceArray32(
        datum: json.valueAsBytes(XCMAssetInstanceType.array32.type));
  }
}

abstract class XCMV5Junction extends SubstrateVariantSerialization
    with XCMJunction, Equality {
  const XCMV5Junction();
  factory XCMV5Junction.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV5JunctionParaChain.deserializeJson(decode.value),
      XCMJunctionType.accountId32 =>
        XCMV5JunctionAccountId32.deserializeJson(decode.value),
      XCMJunctionType.accountIndex64 =>
        XCMV5JunctionAccountIndex64.deserializeJson(decode.value),
      XCMJunctionType.accountKey20 =>
        XCMV5JunctionAccountKey20.deserializeJson(decode.value),
      XCMJunctionType.palletInstance =>
        XCMV5JunctionPalletInstance.deserializeJson(decode.value),
      XCMJunctionType.generalIndex =>
        XCMV5JunctionGeneralIndex.deserializeJson(decode.value),
      XCMJunctionType.generalKey =>
        XCMV5JunctionGeneralKey.deserializeJson(decode.value),
      XCMJunctionType.onlyChild =>
        XCMV5JunctionOnlyChild.deserializeJson(decode.value),
      XCMJunctionType.plurality =>
        XCMV5JunctionPlurality.deserializeJson(decode.value),
      XCMJunctionType.globalConsensus =>
        XCMV5JunctionGlobalConsensus.deserializeJson(decode.value),
    };
  }
  factory XCMV5Junction.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionType.parachain => XCMV5JunctionParaChain.fromJson(json),
      XCMJunctionType.accountId32 => XCMV5JunctionAccountId32.fromJson(json),
      XCMJunctionType.accountIndex64 =>
        XCMV5JunctionAccountIndex64.fromJson(json),
      XCMJunctionType.accountKey20 => XCMV5JunctionAccountKey20.fromJson(json),
      XCMJunctionType.palletInstance =>
        XCMV5JunctionPalletInstance.fromJson(json),
      XCMJunctionType.generalIndex => XCMV5JunctionGeneralIndex.fromJson(json),
      XCMJunctionType.generalKey => XCMV5JunctionGeneralKey.fromJson(json),
      XCMJunctionType.onlyChild => XCMV5JunctionOnlyChild.fromJson(json),
      XCMJunctionType.plurality => XCMV5JunctionPlurality.fromJson(json),
      XCMJunctionType.globalConsensus =>
        XCMV5JunctionGlobalConsensus.fromJson(json),
    };
  }

  factory XCMV5Junction.from(XCMJunction junction) {
    if (junction is XCMV5Junction) return junction;
    final type = junction.type;
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV5JunctionParaChain(id: (junction as XCMJunctionParaChain).id),
      XCMJunctionType.accountId32 => () {
          final account32 = junction as XCMJunctionAccountId32;
          return XCMV5JunctionAccountId32(
              id: account32.id,
              network: account32.network == null
                  ? null
                  : XCMV5NetworkId.from(account32.network!));
        }(),
      XCMJunctionType.accountIndex64 => () {
          final account = junction as XCMJunctionAccountIndex64;
          return XCMV5JunctionAccountIndex64(
              index: account.index,
              network: account.network == null
                  ? null
                  : XCMV5NetworkId.from(account.network!));
        }(),
      XCMJunctionType.accountKey20 => () {
          final account = junction as XCMJunctionAccountKey20;
          return XCMV5JunctionAccountKey20(
              key: account.key,
              network: account.network == null
                  ? null
                  : XCMV5NetworkId.from(account.network!));
        }(),
      XCMJunctionType.palletInstance => XCMV5JunctionPalletInstance(
          index: (junction as XCMJunctionPalletInstance).index),
      XCMJunctionType.generalIndex => XCMV5JunctionGeneralIndex(
          index: (junction as XCMJunctionGeneralIndex).index),
      XCMJunctionType.generalKey => () {
          final account = junction as XCMJunctionGeneralKey;
          return XCMV5JunctionGeneralKey(
              data: account.data, length: account.length);
        }(),
      XCMJunctionType.onlyChild => XCMV5JunctionOnlyChild(),
      XCMJunctionType.plurality => () {
          final plurality = junction as XCMJunctionPlurality;
          return XCMV5JunctionPlurality(
              id: XCMV3BodyId.from(plurality.id),
              part: XCMV3BodyPart.from(plurality.part));
        }(),
      XCMJunctionType.globalConsensus => XCMV5JunctionGlobalConsensus(
          network: XCMV5NetworkId.from(
              (junction as XCMJunctionGlobalConsensus).network)),
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
            XCMV5JunctionAccountId32.layout_(property: property),
        property: XCMJunctionType.accountId32.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5JunctionAccountIndex64.layout_(property: property),
        property: XCMJunctionType.accountIndex64.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5JunctionAccountKey20.layout_(property: property),
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
            XCMV5JunctionGlobalConsensus.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5JunctionParaChain extends XCMV5Junction with XCMJunctionParaChain {
  @override
  final int id;
  XCMV5JunctionParaChain({required int id}) : id = id.asUint32;

  factory XCMV5JunctionParaChain.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionParaChain(id: IntUtils.parse(json["id"]));
  }
  factory XCMV5JunctionParaChain.fromJson(Map<String, dynamic> json) {
    return XCMV5JunctionParaChain(
        id: json.valueAs(XCMJunctionType.parachain.type));
  }
}

class XCMV5JunctionAccountId32 extends XCMV5Junction
    with XCMJunctionAccountId32 {
  @override
  final XCMV5NetworkId? network;
  @override
  final List<int> id;
  XCMV5JunctionAccountId32({this.network, required List<int> id})
      : id = id.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;
  factory XCMV5JunctionAccountId32.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountId32.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV5JunctionAccountId32(
        network: network == null ? null : XCMV5NetworkId.fromJson(network),
        id: accountId.valueAsBytes("id"));
  }

  factory XCMV5JunctionAccountId32.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionAccountId32(
        network: json["network"] == null
            ? null
            : XCMV5NetworkId.deserializeJson(json["network"]),
        id: (json["id"] as List).cast());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV5NetworkId.layout_(), property: "network"),
      LayoutConst.fixedBlob32(property: "id")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV5JunctionAccountIndex64 extends XCMV5Junction
    with XCMJunctionAccountIndex64 {
  @override
  final XCMV5NetworkId? network;
  @override
  final BigInt index;
  XCMV5JunctionAccountIndex64({this.network, required BigInt index})
      : index = index.asUint64;

  factory XCMV5JunctionAccountIndex64.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5JunctionAccountIndex64(
        network: json["network"] == null
            ? null
            : XCMV5NetworkId.deserializeJson(json["network"]),
        index: BigintUtils.parse(json["index"]));
  }

  factory XCMV5JunctionAccountIndex64.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountIndex64.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV5JunctionAccountIndex64(
        network: network == null ? null : XCMV5NetworkId.fromJson(network),
        index: accountId.valueAs("index"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV5NetworkId.layout_(), property: "network"),
      LayoutConst.compactBigintU64(property: "index")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV5JunctionAccountKey20 extends XCMV5Junction
    with XCMJunctionAccountKey20 {
  @override
  final XCMV5NetworkId? network;
  @override
  final List<int> key;
  XCMV5JunctionAccountKey20({this.network, required List<int> key})
      : key = key
            .exc(SubstrateConstant.accountId20LengthInBytes)
            .asImmutableBytes;

  factory XCMV5JunctionAccountKey20.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionAccountKey20(
        network: json["network"] == null
            ? null
            : XCMV5NetworkId.deserializeJson(json["network"]),
        key: (json["key"] as List).cast());
  }
  factory XCMV5JunctionAccountKey20.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountKey20.type);
    final Map<String, dynamic>? network = MetadataUtils.parseOptional(
        accountId.valueEnsureAsMap<String, dynamic>("network"));
    return XCMV5JunctionAccountKey20(
        network: network == null ? null : XCMV5NetworkId.fromJson(network),
        key: accountId.valueAsBytes("key"));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(XCMV5NetworkId.layout_(), property: "network"),
      LayoutConst.fixedBlobN(SubstrateConstant.accountId20LengthInBytes,
          property: "key")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV5JunctionPalletInstance extends XCMV5Junction
    with XCMJunctionPalletInstance {
  @override
  final int index;
  XCMV5JunctionPalletInstance({required int index}) : index = index.asUint8;
  factory XCMV5JunctionPalletInstance.fromJson(Map<String, dynamic> json) {
    return XCMV5JunctionPalletInstance(
        index: json.valueAs(XCMJunctionType.palletInstance.type));
  }
  factory XCMV5JunctionPalletInstance.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5JunctionPalletInstance(index: IntUtils.parse(json["index"]));
  }
}

class XCMV5JunctionGeneralIndex extends XCMV5Junction
    with XCMJunctionGeneralIndex {
  @override
  final BigInt index;
  XCMV5JunctionGeneralIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV5JunctionGeneralIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionGeneralIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV5JunctionGeneralIndex.fromJson(Map<String, dynamic> json) {
    return XCMV5JunctionGeneralIndex(
        index: json.valueAs(XCMJunctionType.generalIndex.type));
  }
}

class XCMV5JunctionGeneralKey extends XCMV5Junction with XCMJunctionGeneralKey {
  @override
  final int length;
  @override
  final List<int> data;
  XCMV5JunctionGeneralKey._({required int length, required List<int> data})
      : length = length.asUint8,
        data =
            data.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;

  factory XCMV5JunctionGeneralKey(
      {required int length, required List<int> data}) {
    if (data.length < length ||
        length > SubstrateConstant.accountIdLengthInBytes ||
        data.length > SubstrateConstant.accountIdLengthInBytes) {
      throw DartSubstratePluginException(
          "Invalid V5 Junction GeneralKey bytes.");
    }
    if (data.length != SubstrateConstant.accountIdLengthInBytes) {
      final dataBytes =
          List<int>.filled(SubstrateConstant.accountIdLengthInBytes, 0);
      dataBytes.setAll(0, data);
      data = dataBytes;
    }

    return XCMV5JunctionGeneralKey._(length: length, data: data);
  }

  factory XCMV5JunctionGeneralKey.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionGeneralKey(
        length: IntUtils.parse(json["length"]),
        data: (json["data"] as List).cast());
  }
  factory XCMV5JunctionGeneralKey.fromJson(Map<String, dynamic> json) {
    final key = json.valueEnsureAsMap(XCMJunctionType.generalKey.type);
    return XCMV5JunctionGeneralKey(
        length: key.valueAs("length"), data: key.valueAsBytes("data"));
  }
}

class XCMV5JunctionOnlyChild extends XCMV5Junction with XCMJunctionOnlyChild {
  XCMV5JunctionOnlyChild();

  factory XCMV5JunctionOnlyChild.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionOnlyChild();
  }
  factory XCMV5JunctionOnlyChild.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionType.onlyChild.type);
    return XCMV5JunctionOnlyChild();
  }
}

class XCMV5JunctionPlurality extends XCMV5Junction with XCMJunctionPlurality {
  @override
  final XCMV3BodyId id;
  @override
  final XCMV3BodyPart part;
  XCMV5JunctionPlurality({required this.id, required this.part});
  factory XCMV5JunctionPlurality.fromJson(Map<String, dynamic> json) {
    final plurality =
        json.valueEnsureAsMap<String, dynamic>(XCMJunctionType.plurality.type);
    return XCMV5JunctionPlurality(
        id: XCMV3BodyId.fromJson(plurality.valueAs("id")),
        part: XCMV3BodyPart.fromJson(plurality.valueAs("part")));
  }
  factory XCMV5JunctionPlurality.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionPlurality(
        id: XCMV3BodyId.deserializeJson(json["id"]),
        part: XCMV3BodyPart.deserializeJson(json["part"]));
  }
}

class XCMV5JunctionGlobalConsensus extends XCMV5Junction
    with XCMJunctionGlobalConsensus {
  @override
  final XCMV5NetworkId network;
  XCMV5JunctionGlobalConsensus({required this.network});

  factory XCMV5JunctionGlobalConsensus.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5JunctionGlobalConsensus(
        network: XCMV5NetworkId.deserializeJson(json["network"]));
  }
  factory XCMV5JunctionGlobalConsensus.fromJson(Map<String, dynamic> json) {
    final network = json.valueEnsureAsMap<String, dynamic>(
        XCMJunctionType.globalConsensus.type);
    return XCMV5JunctionGlobalConsensus(
        network: XCMV5NetworkId.fromJson(network));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5NetworkId.layout_(property: "network"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

typedef XCMV5InteriorMultiLocation = XCMV5Junctions;

abstract class XCMV5Junctions extends XCMJunctions<XCMV5Junction> {
  XCMV5Junctions({required super.type, required super.junctions});
  factory XCMV5Junctions.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionsType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionsType.here => XCMV5JunctionsHere.deserializeJson(decode.value),
      XCMJunctionsType.x1 => XCMV5JunctionsX1.deserializeJson(decode.value),
      XCMJunctionsType.x2 => XCMV5JunctionsX2.deserializeJson(decode.value),
      XCMJunctionsType.x3 => XCMV5JunctionsX3.deserializeJson(decode.value),
      XCMJunctionsType.x4 => XCMV5JunctionsX4.deserializeJson(decode.value),
      XCMJunctionsType.x5 => XCMV5JunctionsX5.deserializeJson(decode.value),
      XCMJunctionsType.x6 => XCMV5JunctionsX6.deserializeJson(decode.value),
      XCMJunctionsType.x7 => XCMV5JunctionsX7.deserializeJson(decode.value),
      XCMJunctionsType.x8 => XCMV5JunctionsX8.deserializeJson(decode.value),
    };
  }
  factory XCMV5Junctions.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionsType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionsType.here => XCMV5JunctionsHere.fromJson(json),
      XCMJunctionsType.x1 => XCMV5JunctionsX1.fromJson(json),
      XCMJunctionsType.x2 => XCMV5JunctionsX2.fromJson(json),
      XCMJunctionsType.x3 => XCMV5JunctionsX3.fromJson(json),
      XCMJunctionsType.x4 => XCMV5JunctionsX4.fromJson(json),
      XCMJunctionsType.x5 => XCMV5JunctionsX5.fromJson(json),
      XCMJunctionsType.x6 => XCMV5JunctionsX6.fromJson(json),
      XCMJunctionsType.x7 => XCMV5JunctionsX7.fromJson(json),
      XCMJunctionsType.x8 => XCMV5JunctionsX8.fromJson(json),
    };
  }
  factory XCMV5Junctions.fromJunctions(List<XCMV5Junction> junctions) {
    final type = XCMJunctionsType.fromLength(junctions.length);
    return switch (type) {
      XCMJunctionsType.here => XCMV5JunctionsHere(),
      XCMJunctionsType.x1 => XCMV5JunctionsX1(junctions: junctions),
      XCMJunctionsType.x2 => XCMV5JunctionsX2(junctions: junctions),
      XCMJunctionsType.x3 => XCMV5JunctionsX3(junctions: junctions),
      XCMJunctionsType.x4 => XCMV5JunctionsX4(junctions: junctions),
      XCMJunctionsType.x5 => XCMV5JunctionsX5(junctions: junctions),
      XCMJunctionsType.x6 => XCMV5JunctionsX6(junctions: junctions),
      XCMJunctionsType.x7 => XCMV5JunctionsX7(junctions: junctions),
      XCMJunctionsType.x8 => XCMV5JunctionsX8(junctions: junctions),
    };
  }
  factory XCMV5Junctions.from(XCMJunctions junctions) {
    if (junctions is XCMV5Junctions) return junctions;
    final type = junctions.type;
    final vJunctions =
        junctions.junctions.map((e) => XCMV5Junction.from(e)).toList();
    return switch (type) {
      XCMJunctionsType.here => XCMV5JunctionsHere(),
      XCMJunctionsType.x1 => XCMV5JunctionsX1(junctions: vJunctions),
      XCMJunctionsType.x2 => XCMV5JunctionsX2(junctions: vJunctions),
      XCMJunctionsType.x3 => XCMV5JunctionsX3(junctions: vJunctions),
      XCMJunctionsType.x4 => XCMV5JunctionsX4(junctions: vJunctions),
      XCMJunctionsType.x5 => XCMV5JunctionsX5(junctions: vJunctions),
      XCMJunctionsType.x6 => XCMV5JunctionsX6(junctions: vJunctions),
      XCMJunctionsType.x7 => XCMV5JunctionsX7(junctions: vJunctions),
      XCMJunctionsType.x8 => XCMV5JunctionsX8(junctions: vJunctions),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsHere.layout_(property: property),
          property: XCMJunctionsType.here.name,
          index: 0),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x1, property: property),
          property: XCMJunctionsType.x1.name,
          index: 1),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x2, property: property),
          property: XCMJunctionsType.x2.name,
          index: 2),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x3, property: property),
          property: XCMJunctionsType.x3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x4, property: property),
          property: XCMJunctionsType.x4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x5, property: property),
          property: XCMJunctionsType.x5.name,
          index: 5),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x6, property: property),
          property: XCMJunctionsType.x6.name,
          index: 6),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x7, property: property),
          property: XCMJunctionsType.x7.name,
          index: 7),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV5JunctionsX1.layout_(XCMJunctionsType.x8, property: property),
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5JunctionsHere extends XCMV5Junctions {
  XCMV5JunctionsHere() : super(type: XCMJunctionsType.here, junctions: []);

  factory XCMV5JunctionsHere.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionsHere();
  }
  factory XCMV5JunctionsHere.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionsType.here.type);
    return XCMV5JunctionsHere();
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

class XCMV5JunctionsX1 extends XCMV5Junctions {
  XCMV5JunctionsX1._({required super.junctions, required super.type});
  XCMV5JunctionsX1({required super.junctions})
      : super(type: XCMJunctionsType.x1);
  XCMV5JunctionsX1._deserialize(Map<String, dynamic> json,
      {required super.type})
      : super(
            junctions: (json["junctions"] as List)
                .map((e) => XCMV5Junction.deserializeJson(e))
                .toList());
  factory XCMV5JunctionsX1.deserializeJson(Map<String, dynamic> json) {
    return XCMV5JunctionsX1(
        junctions: (json["junctions"] as List)
            .map((e) => XCMV5Junction.deserializeJson(e))
            .toList());
  }
  factory XCMV5JunctionsX1.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x1.type);
    return XCMV5JunctionsX1(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  static Layout<Map<String, dynamic>> layout_(XCMJunctionsType type,
      {String? property}) {
    return LayoutConst.struct([
      LayoutConst.tuple(
          List.filled(type.junctionsLength, XCMV5Junction.layout_()),
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

class XCMV5JunctionsX2 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX2.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x2);
  XCMV5JunctionsX2({required super.junctions})
      : super._(type: XCMJunctionsType.x2);
  factory XCMV5JunctionsX2.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x2.type);
    return XCMV5JunctionsX2(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5JunctionsX3 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX3.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x3);
  XCMV5JunctionsX3({required super.junctions})
      : super._(type: XCMJunctionsType.x3);
  factory XCMV5JunctionsX3.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x3.type);
    return XCMV5JunctionsX3(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5JunctionsX4 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX4.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x4);
  XCMV5JunctionsX4({required super.junctions})
      : super._(type: XCMJunctionsType.x4);
  factory XCMV5JunctionsX4.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x4.type);
    return XCMV5JunctionsX4(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5JunctionsX5 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX5.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x5);
  XCMV5JunctionsX5({required super.junctions})
      : super._(type: XCMJunctionsType.x5);
  factory XCMV5JunctionsX5.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x5.type);
    return XCMV5JunctionsX5(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5JunctionsX6 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX6.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x6);
  XCMV5JunctionsX6({required super.junctions})
      : super._(type: XCMJunctionsType.x6);
  factory XCMV5JunctionsX6.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x6.type);
    return XCMV5JunctionsX6(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5JunctionsX7 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX7.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x7);
  XCMV5JunctionsX7({required super.junctions})
      : super._(type: XCMJunctionsType.x7);
  factory XCMV5JunctionsX7.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x7.type);
    return XCMV5JunctionsX7(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5JunctionsX8 extends XCMV5JunctionsX1 {
  XCMV5JunctionsX8.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x8);
  XCMV5JunctionsX8({required super.junctions})
      : super._(type: XCMJunctionsType.x8);
  factory XCMV5JunctionsX8.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x8.type);
    return XCMV5JunctionsX8(
        junctions: junctions.map((e) => XCMV5Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV5Location extends XCMMultiLocation with Equality {
  @override
  final int parents;
  @override
  final XCMV5Junctions interior;

  factory XCMV5Location.deserialize(List<int> bytes) {
    final json =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMV5Location.deserializeJson(json.value);
  }
  factory XCMV5Location.from(XCMMultiLocation location) {
    if (location is XCMV5Location) return location;
    return XCMV5Location(
        parents: location.parents,
        interior: XCMV5Junctions.from(location.interior));
  }
  XCMV5Location({required int parents, required this.interior})
      : parents = parents.asUint8;

  factory XCMV5Location.deserializeJson(Map<String, dynamic> json) {
    return XCMV5Location(
        parents: IntUtils.parse(json["parents"]),
        interior: XCMV5Junctions.deserializeJson(json["interior"]));
  }
  factory XCMV5Location.fromJson(Map<String, dynamic> json) {
    return XCMV5Location(
        parents: json.valueAs("parents"),
        interior: XCMV5Junctions.fromJson(json.valueAs("interior")));
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

  @override
  XCMVersion get version => XCMVersion.v5;
}

abstract class XCMV5Fungibility extends SubstrateVariantSerialization
    with XCMFungibility, Equality {
  const XCMV5Fungibility();
  factory XCMV5Fungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMFungibilityType.fungible =>
        XCMV5FungibilityFungible.deserializeJson(decode.value),
      XCMFungibilityType.nonFungible =>
        XCMV5FungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV5Fungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMFungibilityType.fungible => XCMV5FungibilityFungible.fromJson(json),
      XCMFungibilityType.nonFungible =>
        XCMV5FungibilityNonFungible.fromJson(json)
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
            XCMV5FungibilityNonFungible.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5FungibilityFungible extends XCMV5Fungibility
    with XCMFungibilityFungible {
  @override
  final BigInt units;

  XCMV5FungibilityFungible({required BigInt units}) : units = units.asUint128;

  factory XCMV5FungibilityFungible.deserializeJson(Map<String, dynamic> json) {
    return XCMV5FungibilityFungible(units: BigintUtils.parse(json["units"]));
  }
  factory XCMV5FungibilityFungible.fromJson(Map<String, dynamic> json) {
    return XCMV5FungibilityFungible(
        units: json.valueAs(XCMFungibilityType.fungible.type));
  }
}

class XCMV5FungibilityNonFungible extends XCMV5Fungibility
    with XCMFungibilityNonFungible {
  @override
  final XCMV5AssetInstance instance;

  XCMV5FungibilityNonFungible({required this.instance});

  factory XCMV5FungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5FungibilityNonFungible(
        instance: XCMV5AssetInstance.deserializeJson(json["instance"]));
  }
  factory XCMV5FungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    return XCMV5FungibilityNonFungible(
        instance: XCMV5AssetInstance.fromJson(
            json.valueAs(XCMFungibilityType.nonFungible.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV5AssetInstance.layout_(property: "instance")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"instance": instance.serializeJsonVariant()};
  }
}

abstract class XCMV5WildFungibility extends SubstrateVariantSerialization
    with XCMWildFungibility, Equality {
  const XCMV5WildFungibility();
  factory XCMV5WildFungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV5WildFungibilityFungible.deserializeJson(decode.value),
      XCMWildFungibilityType.nonFungible =>
        XCMV5WildFungibilityNonFungible.deserializeJson(decode.value)
    };
  }

  factory XCMV5WildFungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMWildFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV5WildFungibilityFungible.fromJson(json),
      XCMWildFungibilityType.nonFungible =>
        XCMV5WildFungibilityNonFungible.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5WildFungibilityFungible.layout_(property: property),
        property: XCMWildFungibilityType.fungible.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5WildFungibilityNonFungible.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5WildFungibilityFungible extends XCMV5WildFungibility
    with XCMWildFungibilityFungible {
  XCMV5WildFungibilityFungible();
  factory XCMV5WildFungibilityFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.fungible.type);
    return XCMV5WildFungibilityFungible();
  }
  factory XCMV5WildFungibilityFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5WildFungibilityFungible();
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

class XCMV5WildFungibilityNonFungible extends XCMV5WildFungibility
    with XCMWildFungibilityNonFungible {
  XCMV5WildFungibilityNonFungible();

  factory XCMV5WildFungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5WildFungibilityNonFungible();
  }
  factory XCMV5WildFungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.nonFungible.type);
    return XCMV5WildFungibilityNonFungible();
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

class XCMV5AssetId extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAssetId, Equality {
  @override
  final XCMV5Location location;
  XCMV5AssetId({required this.location});

  factory XCMV5AssetId.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetId(
        location: XCMV5Location.deserializeJson(json["location"]));
  }
  factory XCMV5AssetId.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetId(location: XCMV5Location.fromJson(json));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5Location.layout_(property: "location")],
        property: property);
  }

  factory XCMV5AssetId.from(XCMAssetId id) {
    return switch (id) {
      final XCMV5AssetId assetId => assetId,
      final XCMV2AssetId assetId => switch (assetId.type) {
          XCMV2AssetIdType.abtract => throw DartSubstratePluginException(
              "Unsuported AssetId v2 ${XCMV2AssetIdType.abtract.type} by version 5"),
          XCMV2AssetIdType.concrete => XCMV5AssetId(
              location: assetId
                  .cast<XCMV2AssetIdConcrete>()
                  .location
                  .asVersion(XCMVersion.v5)),
        },
      final XCMV3AssetId assetId => switch (assetId.type) {
          XCMV3AssetIdType.abtract => throw DartSubstratePluginException(
              "Unsuported AssetId v3 ${XCMV3AssetIdType.abtract.type} by version 5"),
          XCMV3AssetIdType.concrete => XCMV5AssetId(
              location: assetId
                  .cast<XCMV3AssetIdConcrete>()
                  .location
                  .asVersion(XCMVersion.v5)),
        },
      final XCMV4AssetId assetId =>
        XCMV5AssetId(location: assetId.location.asVersion(XCMVersion.v5)),
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
  Map<String, dynamic> toJson() {
    return location.toJson();
  }

  @override
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5Asset extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAsset, Equality {
  @override
  final XCMV5AssetId id;
  @override
  final XCMV5Fungibility fun;
  @override
  XCMVersion get version => XCMVersion.v5;
  XCMV5Asset({required this.id, required this.fun}) : super();

  factory XCMV5Asset.deserializeJson(Map<String, dynamic> json) {
    return XCMV5Asset(
        id: XCMV5AssetId.deserializeJson(json["id"]),
        fun: XCMV5Fungibility.deserializeJson(json["fun"]));
  }
  factory XCMV5Asset.fromJson(Map<String, dynamic> json) {
    return XCMV5Asset(
        id: XCMV5AssetId.fromJson(json.valueAs("id")),
        fun: XCMV5Fungibility.fromJson(json["fun"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetId.layout_(property: "id"),
      XCMV5Fungibility.layout_(property: "fun"),
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

class XCMV5Assets extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAssets<XCMV5Asset>, Equality {
  @override
  final List<XCMV5Asset> assets;

  XCMV5Assets({required List<XCMV5Asset> assets}) : assets = assets.immutable;

  factory XCMV5Assets.deserializeJson(Map<String, dynamic> json) {
    return XCMV5Assets(
        assets: (json["assets"] as List)
            .map((e) => XCMV5Asset.deserializeJson(e))
            .toList());
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactArray(XCMV5Asset.layout_(), property: "assets")],
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
  XCMVersion get version => XCMVersion.v5;
}

abstract class XCMV5WildAsset extends SubstrateVariantSerialization
    with XCMWildMultiAsset, Equality {
  const XCMV5WildAsset();
  factory XCMV5WildAsset.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildAssetType.fromName(decode.variantName);
    return switch (type) {
      XCMWildAssetType.all => XCMV5WildAssetAll.deserializeJson(decode.value),
      XCMWildAssetType.allOf =>
        XCMV5WildAssetAllOf.deserializeJson(decode.value),
      XCMWildAssetType.allCounted =>
        XCMV5WildAssetAllCounted.deserializeJson(decode.value),
      XCMWildAssetType.allOfCounted =>
        XCMV5WildAssetAllOfCounted.deserializeJson(decode.value)
    };
  }
  factory XCMV5WildAsset.fromJson(Map<String, dynamic> json) {
    final type = XCMWildAssetType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildAssetType.all => XCMV5WildAssetAll.fromJson(json),
      XCMWildAssetType.allOf => XCMV5WildAssetAllOf.fromJson(json),
      XCMWildAssetType.allCounted => XCMV5WildAssetAllCounted.fromJson(json),
      XCMWildAssetType.allOfCounted => XCMV5WildAssetAllOfCounted.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMV5WildAssetAll.layout_(property: property),
        property: XCMWildAssetType.all.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMV5WildAssetAllOf.layout_(property: property),
        property: XCMWildAssetType.allOf.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5WildAssetAllCounted.layout_(property: property),
        property: XCMWildAssetType.allCounted.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5WildAssetAllOfCounted.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5WildAssetAll extends XCMV5WildAsset with XCMWildMultiAssetAll {
  XCMV5WildAssetAll();

  factory XCMV5WildAssetAll.deserializeJson(Map<String, dynamic> json) {
    return XCMV5WildAssetAll();
  }
  factory XCMV5WildAssetAll.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildAssetType.all.type);
    return XCMV5WildAssetAll();
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

class XCMV5WildAssetAllOf extends XCMV5WildAsset with XCMWildMultiAssetAllOf {
  @override
  final XCMV5AssetId id;
  @override
  final XCMV5WildFungibility fun;
  XCMV5WildAssetAllOf({required this.id, required this.fun});

  factory XCMV5WildAssetAllOf.deserializeJson(Map<String, dynamic> json) {
    return XCMV5WildAssetAllOf(
        id: XCMV5AssetId.deserializeJson(json["id"]),
        fun: XCMV5WildFungibility.deserializeJson(json["fun"]));
  }
  factory XCMV5WildAssetAllOf.fromJson(Map<String, dynamic> json) {
    final allOf =
        json.valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOf.type);
    return XCMV5WildAssetAllOf(
        id: XCMV5AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV5WildFungibility.fromJson(allOf.valueAs("fun")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetId.layout_(property: "id"),
      XCMV5WildFungibility.layout_(property: "fun"),
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

class XCMV5WildAssetAllCounted extends XCMV5WildAsset
    with XCMWildMultiAssetAllCounted {
  @override
  final int count;
  XCMV5WildAssetAllCounted({required int count}) : count = count.asUint32;

  factory XCMV5WildAssetAllCounted.deserializeJson(Map<String, dynamic> json) {
    return XCMV5WildAssetAllCounted(count: IntUtils.parse(json["count"]));
  }
  factory XCMV5WildAssetAllCounted.fromJson(Map<String, dynamic> json) {
    return XCMV5WildAssetAllCounted(
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

class XCMV5WildAssetAllOfCounted extends XCMV5WildAsset
    with XCMWildMultiAssetAllOfCounted {
  @override
  final XCMV5AssetId id;
  @override
  final XCMV5WildFungibility fun;
  @override
  final int count;
  XCMV5WildAssetAllOfCounted(
      {required this.id, required this.fun, required int count})
      : count = count.asUint32;

  factory XCMV5WildAssetAllOfCounted.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV5WildAssetAllOfCounted(
        id: XCMV5AssetId.deserializeJson(json["id"]),
        fun: XCMV5WildFungibility.deserializeJson(json["fun"]),
        count: IntUtils.parse(json["count"]));
  }

  factory XCMV5WildAssetAllOfCounted.fromJson(Map<String, dynamic> json) {
    final allOf = json
        .valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOfCounted.type);
    return XCMV5WildAssetAllOfCounted(
        id: XCMV5AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV5WildFungibility.fromJson(allOf.valueAs("fun")),
        count: allOf.valueAs("count"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV5AssetId.layout_(property: "id"),
      XCMV5WildFungibility.layout_(property: "fun"),
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

abstract class XCMV5AssetFilter extends SubstrateVariantSerialization
    with XCMMultiAssetFilter, Equality {
  const XCMV5AssetFilter();
  factory XCMV5AssetFilter.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMMultiAssetFilterType.fromName(decode.variantName);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV5AssetFilterDefinite.deserializeJson(decode.value),
      XCMMultiAssetFilterType.wild =>
        XCMV5AssetFilterWild.deserializeJson(decode.value)
    };
  }
  factory XCMV5AssetFilter.fromJson(Map<String, dynamic> json) {
    final type = XCMMultiAssetFilterType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV5AssetFilterDefinite.fromJson(json),
      XCMMultiAssetFilterType.wild => XCMV5AssetFilterWild.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5AssetFilterDefinite.layout_(property: property),
        property: XCMMultiAssetFilterType.definite.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV5AssetFilterWild.layout_(property: property),
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
  XCMVersion get version => XCMVersion.v5;
}

class XCMV5AssetFilterDefinite extends XCMV5AssetFilter
    with XCMMultiAssetFilterDefinite {
  @override
  final XCMV5Assets assets;
  XCMV5AssetFilterDefinite({required this.assets}) : super();

  factory XCMV5AssetFilterDefinite.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMMultiAssetFilterType.definite.type);
    return XCMV5AssetFilterDefinite(
        assets: XCMV5Assets(
            assets: assets.map((e) => XCMV5Asset.fromJson(e)).toList()));
  }
  factory XCMV5AssetFilterDefinite.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetFilterDefinite(
        assets: XCMV5Assets.deserializeJson(json.valueAs("assets")));
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
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.definite;
}

class XCMV5AssetFilterWild extends XCMV5AssetFilter
    with XCMMultiAssetFilterWild {
  @override
  final XCMV5WildAsset asset;
  XCMV5AssetFilterWild({required this.asset}) : super();
  factory XCMV5AssetFilterWild.fromJson(Map<String, dynamic> json) {
    return XCMV5AssetFilterWild(
        asset: XCMV5WildAsset.fromJson(
            json.valueAs(XCMMultiAssetFilterType.wild.type)));
  }
  factory XCMV5AssetFilterWild.deserializeJson(Map<String, dynamic> json) {
    return XCMV5AssetFilterWild(
        asset: XCMV5WildAsset.deserializeJson(json.valueAs("asset")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV5WildAsset.layout_(property: "asset")],
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
