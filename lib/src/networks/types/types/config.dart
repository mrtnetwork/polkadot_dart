import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/substrate.dart';

enum SubstrateConsensusRole {
  relay(0),
  system(1),
  parachain(2);

  bool get isSystem => this == system;
  bool get isRelay => this == relay;
  bool get isPara => this == parachain;
  final int value;
  const SubstrateConsensusRole(this.value);
  static SubstrateConsensusRole fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }
}

enum SubstrateRelaySystem {
  polkadot(0),
  kusama(1),
  westend(2),
  paseo(3);

  final int value;
  const SubstrateRelaySystem(this.value);

  static SubstrateRelaySystem fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }

  List<BaseSubstrateNetwork> get networks {
    return switch (this) {
      SubstrateRelaySystem.polkadot => PolkadotNetwork.values,
      SubstrateRelaySystem.kusama => KusamaNetwork.values,
      SubstrateRelaySystem.westend => WestendNetwork.values,
      SubstrateRelaySystem.paseo => PaseoNetwork.values,
    }
        .cast();
  }
}

abstract class BaseSubstrateNetwork {
  abstract final String networkName;
  abstract final String genesis;
  abstract final int paraId;
  abstract final int ss58;
  abstract final SubstrateConsensusRole role;
  abstract final SubstrateRelaySystem relaySystem;
  abstract final SubstrateChainType chainType;
  abstract final XCMVersion defaultXcmVersion;
  abstract final GenericBaseSubstrateNativeAsset relayAsset;
  abstract final List<XCMVersion> xcmVersions;
  abstract final bool allowLocalTransfer;
  BaseSubstrateNetwork get relayChain;
  BaseSubstrateNetwork get assetHub;
  XCMMultiLocation location({XCMVersion? version});
  XCMVersion findXcmVersion(BaseSubstrateNetwork? network);
  static BaseSubstrateNetwork? fromGenesis(String genesis) {
    return values
        .firstWhereNullable((e) => StringUtils.hexEqual(genesis, e.genesis));
  }

  static BaseSubstrateNetwork? fromPara(int paraId,
      {SubstrateRelaySystem? relay}) {
    if (relay == null) {
      return values.firstWhereNullable((e) => paraId == e.paraId);
    }
    return values.firstWhereNullable(
        (e) => e.relaySystem == relay && e.paraId == paraId);
  }

  static const List<BaseSubstrateNetwork> values = [
    ...PolkadotNetwork.values,
    ...KusamaNetwork.values,
    ...WestendNetwork.values,
    ...PaseoNetwork.values
  ];
  bool get isAssetHub => this == assetHub;
}

enum PolkadotNetwork implements BaseSubstrateNetwork {
  polkadot(
    networkName: "Polkadot",
    ss58: 0,
    paraId: 0,
    role: SubstrateConsensusRole.relay,
    chainType: SubstrateChainType.substrate,
    genesis:
        "0x91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  polkadotAssetHub(
    networkName: "Polkadot Asset Hub",
    ss58: 0,
    paraId: 1000,
    role: SubstrateConsensusRole.system,
    genesis:
        '0x68d56f15f85d3136970ec16946040bc1752654e906147f7e43e9d539d7c3de2f',
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  astar(
    networkName: "Astar",
    paraId: 2006,
    ss58: 5,
    genesis:
        "0x9eb76c5184c4ab8679d2d5d819fdf90b9c001403e9e17da2e14b6d8aec4029c6",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  xode(
      networkName: "Xode",
      paraId: 3417,
      ss58: 280,
      genesis:
          "0xb2985e778bb748c70e450dcc084cc7da79fe742cc23d3b040abd7028187de69c",
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour),
  polkadotBridgeHub(
    networkName: "Polkadot BridgeHub",
    ss58: 0,
    paraId: 1002,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xdcf691b5a3fbe24adc99ddc959c0561b973e329b1aef4c4b22e7bb2ddecb4464",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  polkadotCollectives(
    networkName: "Polkadot Collectives",
    ss58: 0,
    paraId: 1001,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x46ee89aa2eedd13e988962630ec9fb7565964cf5023bb351f2b6b25c1b68b0b2",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  polkadotPeople(
      networkName: "Polkadot People",
      paraId: 1004,
      role: SubstrateConsensusRole.system,
      genesis:
          "0x67fa177a097bfa18f77ea95ab56e9bcdfeb0e5b8a40e46298bb93e16b6fc5008",
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      ss58: 0),
  polkadotCoretime(
    networkName: "Polkadot Coretime",
    paraId: 1005,
    ss58: 0,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xefb56e30d9b4a24099f88820987d0f45fb645992416535d87650d98e00f46fc4",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  acala(
    networkName: "Acala",
    paraId: 2000,
    ss58: 10,
    genesis:
        "0xfc41b9bd8ef8fe53d58c7ea67c794c7ec9a73daf05e6d54b14ff6342c99ba64c",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  hydration(
      networkName: "Hydration",
      paraId: 2034,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
      ss58: 0,
      genesis:
          "0xafdc188f45c71dacbaa0b62e16a91f726c7b8699a9748cdf715459de6b7f366d"),

  interlay(
    networkName: "Interlay",
    paraId: 2032,
    ss58: 2032,
    genesis:
        "0xbf88efe70e9e0e916416e8bed61f2b45717f517d7f3523e33c7b001e5ffcbc72",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
  ),
  bifrostPolkadot(
    networkName: "Bifrost Polkadot",
    paraId: 2030,
    ss58: 0,
    genesis:
        "0x262e1b2ad728475fd6fe88e62d34c200abe6fd693931ddad144059b1eb884e5b",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  centrifuge(
    networkName: "Centrifuge",
    paraId: 2031,
    ss58: 36,
    genesis:
        "0xb3db41421702df9a7fcac62b53ffeac85f7853cc4e689e0b93aeb3db18c09d82",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
  ),
  zeitgeist(
    networkName: "Zeitgeist",
    paraId: 2092,
    ss58: 73,
    genesis:
        "0x1bf2a2ecb4a868de66ea8610f2ce7c8c43706561b6476031315f6640fe38e060",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
  ),

  phala(
    networkName: "Phala",
    paraId: 2035,
    ss58: 30,
    genesis:
        "0x1bb969d85965e4bb5a651abbedf21a54b6b31a21f66b5401cc3f1e286268d736",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
  ),
  manta(
      networkName: "Manta Parachain",
      paraId: 2104,
      ss58: 77,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
      genesis:
          "0xf3c7ad88f6a80f366c4be216691411ef0622e8b809b1046ea297ef106058d4eb"),

  pendulum(
    networkName: "Pendulum",
    paraId: 2094,
    ss58: 0,
    genesis:
        "0x5d3c298622d5634ed019bf61ea4b71655030015bde9beb0d6a24743714462c86",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
  ),
  mythos(
    networkName: "Mythos",
    paraId: 3369,
    ss58: 29972,
    chainType: SubstrateChainType.ethereum,
    genesis:
        "0xf6ee56e9c5277df5b4ce6ae9983ee88f3cbed27d31beeb98f9f84f997a1ab0b9",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  kiltSpiritnet(
    networkName: "KILT Spiritnet",
    paraId: 2086,
    ss58: 38,
    genesis:
        "0x411f057b9107718c9624d6aa4a3f23c1653898297f3d4d529d9bb6511a39dd21",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
  ),

  unique(
    networkName: "Unique",
    paraId: 2037,
    allowLocalTransfer: false,
    ss58: 7391,
    genesis:
        "0x84322d9cddbf35088f1e54e9a85c967a41a56a4f43445768125e61af166c7d31",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  laos(
    networkName: "Laos Network",
    paraId: 3370,
    ss58: 42,
    chainType: SubstrateChainType.ethereum,
    genesis:
        "0xe8aecc950e82f1a375cf650fa72d07e0ad9bef7118f49b92283b63e88b1de88b",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
  ),
  nodle(
    networkName: "Nodle Parachain",
    paraId: 2026,
    ss58: 37,
    genesis:
        "0x97da7ede98d7bad4e36b4d734b6055425a3be036da2a332ea5a7037656427a21",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
  ),
  neuroWeb(
    networkName: "NeuroWeb",
    paraId: 2043,
    ss58: 101,
    genesis:
        "0xe7e0962324a3b86c83404dbea483f25fb5dab4c224791c81b756cfc948006174",
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
  ),
  moonbeam(
      networkName: "Moonbeam",
      paraId: 2004,
      ss58: 1284,
      chainType: SubstrateChainType.ethereum,
      allowLocalTransfer: false,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      genesis:
          "0xfe58ea77779b7abda7da4ec526d14db9b1e9cd40a217c34892af80a9b332b76d"),

  jamton(
      networkName: "JAMTON",
      paraId: 3397,
      ss58: 5589,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
      genesis:
          "0xbb9233e202ec014707f82ddb90e84ee9efece8fefee287ad4ad646d869a6c24a"),

  integritee(
      networkName: "Integritee Network (Polkadot)",
      paraId: 2039,
      ss58: 13,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      genesis:
          "0xe13e7af377c64e83f95e0d70d5e5c3c01d697a84538776c5b9bbe0e7d7b6034c"),

  energyWebX(
      networkName: "Energy Web X",
      paraId: 3345,
      ss58: 42,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
      genesis:
          "0x5a51e04b88a4784d205091aa7bada002f3e5da3045e5b05655ee4db2589c33b5"),
  darwinia2(
      networkName: "Darwinia2",
      paraId: 2046,
      ss58: 18,
      chainType: SubstrateChainType.ethereum,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
      genesis:
          "0xf0b8924b12e8108550d28870bc03f7b45a947e1b2b9abf81bfb0b89ecb60570e"),
  crust(
      networkName: "Crust",
      paraId: 2008,
      ss58: 0,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
      genesis:
          "0x4319cc49ee79495b57a1fec4d2bd43f59052dcc690276de566c2691d6df4f7b8"),
  ajuna(
      networkName: "Ajuna",
      paraId: 2051,
      ss58: 1328,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      genesis:
          "0xe358eb1d11b31255a286c12e44fe6780b7edb171d657905a97e39f71d9c6c3ee"),
  ;

  const PolkadotNetwork(
      {required this.networkName,
      required this.genesis,
      required this.paraId,
      required this.ss58,
      this.allowLocalTransfer = true,
      this.chainType = SubstrateChainType.substrate,
      this.role = SubstrateConsensusRole.parachain,
      this.xcmVersions = const []});

  @override
  final String networkName;
  @override
  final String genesis;
  @override
  final int paraId;
  @override
  final int ss58;
  @override
  final SubstrateConsensusRole role;
  @override
  final SubstrateRelaySystem relaySystem = SubstrateRelaySystem.polkadot;
  @override
  final SubstrateChainType chainType;
  @override
  final bool allowLocalTransfer;
  String get name => networkName;

  @override
  PolkadotNetwork get relayChain {
    return PolkadotNetwork.polkadot;
  }

  @override
  BaseSubstrateNetwork get assetHub => polkadotAssetHub;

  @override
  XCMMultiLocation location({XCMVersion? version}) {
    version ??= defaultXcmVersion;
    if (role.isRelay) {
      return XCMMultiLocation.fromVersion(parents: 0, version: version);
    }
    return XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          XCMJunctionParaChain.fromVersion(id: paraId, version: version)
        ], version: version),
        version: version);
  }

  @override
  bool get isAssetHub => this == assetHub;

  static List<PolkadotNetwork> get systemChains =>
      values.where((e) => e.role.isSystem).toList();

  @override
  final List<XCMVersion> xcmVersions;

  @override
  XCMVersion get defaultXcmVersion => xcmVersions.last;

  @override
  XCMVersion findXcmVersion(BaseSubstrateNetwork? network) {
    if (network == null) {
      if (xcmVersions.contains(XCMVersion.v3)) return XCMVersion.v3;
      throw DartSubstratePluginException("Unsupported xcm version");
    }
    final versions = network.xcmVersions;
    for (final version in versions.reversed) {
      if (xcmVersions.contains(version)) {
        return version;
      }
    }
    throw DartSubstratePluginException("Unsupported xcm version");
  }

  @override
  GenericBaseSubstrateNativeAsset get relayAsset =>
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "DOT",
          decimals: 10,
          symbol: "DOT",
          parents: 1,
          version: defaultXcmVersion,
          excutionPallet: SubtrateMetadataPallet.balances);
}

enum KusamaNetwork implements BaseSubstrateNetwork {
  kusama(
      networkName: "Kusama",
      ss58: 2,
      paraId: 0,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      role: SubstrateConsensusRole.relay,
      chainType: SubstrateChainType.substrate,
      genesis:
          "0xb0a8d493285c2df73290dfb7e61f870f17b41801197a149ca93654499ea3dafe"),
  kusamaAssetHub(
      networkName: "Kusama Asset Hub",
      ss58: 2,
      paraId: 1000,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      role: SubstrateConsensusRole.system,
      genesis:
          '0x48239ef607d7928874027a43a67689209727dfb3d3dc5e5b03a39bdc2eda771a'),
  kusamaBridgeHub(
    networkName: "Kusama BridgeHub",
    ss58: 2,
    paraId: 1002,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x00dcb981df86429de8bbacf9803401f09485366c44efbf53af9ecfab03adc7e5",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  kusamaCoretime(
    networkName: "Kusama Coretime",
    paraId: 1005,
    ss58: 2,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x638cd2b9af4b3bb54b8c1f0d22711fc89924ca93300f0caf25a580432b29d050",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  kusamaPeople(
    networkName: "Kusama People",
    paraId: 1004,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xc1af4cb4eb3918e5db15086c0cc5ec17fb334f728b7c65dd44bfe1e174ff8b3f",
    ss58: 2,
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  // polkadotCollectives
  encointer(
    networkName: "Encointer on Kusama",
    ss58: 2,
    paraId: 1001,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x7dd99936c1e9e6d1ce7d90eb6f33bea8393b4bf87677d675aa63c9cb3e8c5b5b",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  /// hydration
  basilisk(
      networkName: "Basilisk",
      paraId: 2090,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
      ss58: 10041,
      genesis:
          "0xa85cfb9b9fd4d622a5b28289a02347af987d8f73fa3108450e2b4a11c1ce5755"),
  bifrostKusama(
    networkName: "Bifrost Kusama",
    paraId: 2001,
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
    ss58: 0,
    genesis:
        "0x9f28c6a68e0fc9646eff64935684f6eeeece527e37bbe1f213d22caa1d9d6bed",
  ),

  /// acala
  karura(
    networkName: "Karura",
    paraId: 2000,
    ss58: 8,
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
    genesis:
        "0xbaf5aabe40646d11f0ee8abbdc64f4a4b7674925cba08e4a05ff9ebed6e2126b",
  ),

  /// astar
  shiden(
    networkName: "Shiden",
    paraId: 2007,
    ss58: 5,
    genesis:
        "0xf1cf9022c7ebb34b162d5b5e34e705a5a740b2d0ecc1009fb89023e62a488108",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  /// centrifuge
  altair(
    networkName: "Altair",
    paraId: 2088,
    ss58: 136,
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
    genesis:
        "0xaa3876c1dc8a1afcc2e9a685a49ff7704cfd36ad8c90bf2702b9d1b00cc40011",
  ),
//  interlay
  kintsugi(
      networkName: "Kintsugi",
      paraId: 2092,
      ss58: 2092,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
      genesis:
          "0x9af9a64e6e4da8e3073901c3ff0cc4c3aad9563786d89daf6ad820b6e14a0b8b"),
  // pendulum
  amplitude(
    networkName: "Amplitude",
    paraId: 2124,
    xcmVersions:
        SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToThree,
    ss58: 0,
    genesis:
        "0xcceae7f3b9947cdb67369c026ef78efa5f34a08fe5808d373c04421ecf4f1aaf",
  ),
  moonriver(
      networkName: "Moonriver",
      paraId: 2023,
      ss58: 1285,
      chainType: SubstrateChainType.ethereum,
      allowLocalTransfer: false,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      genesis:
          "0x401a1f9dca3da46f5c4091016c8a2f26dcea05865116b286f60f668207d1474b"),
  ;

  const KusamaNetwork(
      {required this.networkName,
      required this.genesis,
      required this.paraId,
      required this.ss58,
      this.chainType = SubstrateChainType.substrate,
      this.role = SubstrateConsensusRole.parachain,
      this.allowLocalTransfer = true,
      required this.xcmVersions});

  @override
  final String networkName;
  @override
  final String genesis;
  @override
  final int paraId;
  @override
  final int ss58;
  @override
  final SubstrateConsensusRole role;
  @override
  final SubstrateRelaySystem relaySystem = SubstrateRelaySystem.kusama;
  @override
  final SubstrateChainType chainType;

  @override
  final bool allowLocalTransfer;
  String get name => networkName;

  @override
  KusamaNetwork get relayChain {
    return KusamaNetwork.kusama;
  }

  @override
  BaseSubstrateNetwork get assetHub => kusamaAssetHub;

  @override
  XCMMultiLocation location({XCMVersion? version}) {
    version ??= defaultXcmVersion;
    if (role.isRelay) {
      return XCMMultiLocation.fromVersion(parents: 0, version: version);
    }
    return XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          XCMJunctionParaChain.fromVersion(id: paraId, version: version)
        ], version: version),
        version: version);
  }

  @override
  bool get isAssetHub => this == assetHub;

  @override
  final List<XCMVersion> xcmVersions;

  @override
  XCMVersion get defaultXcmVersion => xcmVersions.last;

  @override
  XCMVersion findXcmVersion(BaseSubstrateNetwork? network) {
    if (network == null) {
      if (xcmVersions.contains(XCMVersion.v3)) return XCMVersion.v3;
      throw DartSubstratePluginException("Unsupported xcm version");
    }
    final versions = network.xcmVersions;
    for (final version in versions.reversed) {
      if (xcmVersions.contains(version)) {
        return version;
      }
    }
    throw DartSubstratePluginException("Unsupported xcm version");
  }

  @override
  GenericBaseSubstrateNativeAsset get relayAsset =>
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Kusama",
          decimals: 12,
          symbol: "KSM",
          minBalance: BigInt.parse("333333333"),
          version: defaultXcmVersion,
          parents: 1,
          excutionPallet: SubtrateMetadataPallet.balances);
}

enum WestendNetwork implements BaseSubstrateNetwork {
  westend(
      networkName: "Westend",
      ss58: 42,
      paraId: 0,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      role: SubstrateConsensusRole.relay,
      chainType: SubstrateChainType.substrate,
      allowLocalTransfer: true,
      genesis:
          "0xe143f23803ac50e8f6f8e62695d1ce9e4e1d68aa36c1cd2cfd15340213f3423e"),
  westendAssetHub(
      networkName: "Westend Asset Hub",
      ss58: 42,
      paraId: 1000,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      role: SubstrateConsensusRole.system,
      genesis:
          '0x67f9723393ef76214df0118c34bbbd3dbebc8ed46a10973a8c969d48fe7598c9'),
  westendBridgeHub(
    networkName: "Westend BridgeHub",
    ss58: 42,
    paraId: 1002,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x0441383e31d1266a92b4cb2ddd4c2e3661ac476996db7e5844c52433b81fe782",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  westendCoretime(
    networkName: "Westend Coretime",
    paraId: 1005,
    ss58: 42,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xf938510edee7c23efa6e9db74f227c827a1b518bffe92e2f6c9842dc53d38840",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  westendPeople(
    networkName: "Westend People",
    paraId: 1004,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x1eb6fb0ba5187434de017a70cb84d4f47142df1d571d0ef9e7e1407f2b80b93c",
    ss58: 42,
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  westendCollectives(
    networkName: "Westend Collectives",
    ss58: 42,
    paraId: 1001,
    role: SubstrateConsensusRole.system,
    genesis:
        "0x713daf193a6301583ff467be736da27ef0a72711b248927ba413f573d2b38e44",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  penpal(
      networkName: "Penpal",
      paraId: 2042,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      ss58: 42,
      genesis:
          "0xafb18a620de2f0a9bf9c56cf8c8b05cacc6c608754959f3020e4fc90f9ae0c9f");

  const WestendNetwork(
      {required this.networkName,
      required this.genesis,
      required this.paraId,
      required this.ss58,
      this.chainType = SubstrateChainType.substrate,
      this.role = SubstrateConsensusRole.parachain,
      this.allowLocalTransfer = true,
      required this.xcmVersions});

  @override
  final String networkName;
  @override
  final String genesis;
  @override
  final int paraId;
  @override
  final int ss58;
  @override
  final SubstrateConsensusRole role;
  @override
  final SubstrateRelaySystem relaySystem = SubstrateRelaySystem.westend;
  @override
  final SubstrateChainType chainType;

  @override
  final bool allowLocalTransfer;
  String get name => networkName;

  @override
  WestendNetwork get relayChain {
    return WestendNetwork.westend;
  }

  @override
  BaseSubstrateNetwork get assetHub => westendAssetHub;

  @override
  XCMMultiLocation location({XCMVersion? version}) {
    version ??= defaultXcmVersion;
    if (role.isRelay) {
      return XCMMultiLocation.fromVersion(parents: 0, version: version);
    }
    return XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          XCMJunctionParaChain.fromVersion(id: paraId, version: version)
        ], version: version),
        version: version);
  }

  @override
  bool get isAssetHub => this == assetHub;

  @override
  final List<XCMVersion> xcmVersions;

  @override
  XCMVersion get defaultXcmVersion => xcmVersions.last;

  @override
  XCMVersion findXcmVersion(BaseSubstrateNetwork? network) {
    if (network == null) {
      if (xcmVersions.contains(XCMVersion.v3)) return XCMVersion.v3;
      throw DartSubstratePluginException("Unsupported xcm version");
    }
    final versions = network.xcmVersions;
    for (final version in versions.reversed) {
      if (xcmVersions.contains(version)) {
        return version;
      }
    }
    throw DartSubstratePluginException("Unsupported xcm version");
  }

  @override
  GenericBaseSubstrateNativeAsset get relayAsset =>
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Westend",
          decimals: 12,
          symbol: "WND",
          minBalance: BigInt.parse("10000000000"),
          version: defaultXcmVersion,
          parents: 1,
          excutionPallet: SubtrateMetadataPallet.balances);
}

enum PaseoNetwork implements BaseSubstrateNetwork {
  paseo(
      networkName: "Paseo Testnet",
      ss58: 0,
      paraId: 0,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      role: SubstrateConsensusRole.relay,
      chainType: SubstrateChainType.substrate,
      allowLocalTransfer: true,
      genesis:
          "0x77afd6190f1554ad45fd0d31aee62aacc33c6db0ea801129acb813f913e0764f"),
  paseoAssetHub(
      networkName: "Paseo Asset Hub",
      ss58: 0,
      paraId: 1000,
      xcmVersions: SubstrateNetworkControllerConstants
          .defaultNetworksXCMSupportedVersion,
      role: SubstrateConsensusRole.system,
      genesis:
          '0xd6eec26135305a8ad257a20d003357284c8aa03d0bdb2b357ab0a22371e11ef2'),
  paseoBridgeHub(
    networkName: "Paseo Bridge Hub",
    ss58: 0,
    paraId: 1002,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xcc624979479dc37afee4cb23cb72b1772bbf377c0d3e8fa257c0fe6146572e3e",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  paseoCoretime(
    networkName: "Paseo Coretime",
    paraId: 1005,
    ss58: 0,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xc806038cc1d06766f23074ade7c5511326be41646deabc259970ff280c82a464",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),
  paseoPeople(
    networkName: "Paseo People",
    paraId: 1004,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xe6c30d6e148f250b887105237bcaa5cb9f16dd203bf7b5b9d4f1da7387cb86ec",
    ss58: 0,
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  paseoCollectives(
    networkName: "Paseo Collectives",
    ss58: 0,
    paraId: 1001,
    role: SubstrateConsensusRole.system,
    genesis:
        "0xbc56cf00c4a27f1e07e3a6c51ad427a1adc1d1109ed47a1e941f187e95012a33",
    xcmVersions:
        SubstrateNetworkControllerConstants.defaultNetworksXCMSupportedVersion,
  ),

  hydration(
      networkName: "Hydration Paseo Testnet",
      paraId: 2034,
      xcmVersions:
          SubstrateNetworkControllerConstants.xcmSupportedVersionTwoToFour,
      ss58: 0,
      genesis:
          "0x5f52a76d9a13fcc0c9094ba62c284f4f2f5e5f031f7e60eecaa7339f7f77c23f");

  const PaseoNetwork(
      {required this.networkName,
      required this.genesis,
      required this.paraId,
      required this.ss58,
      this.chainType = SubstrateChainType.substrate,
      this.role = SubstrateConsensusRole.parachain,
      this.allowLocalTransfer = true,
      required this.xcmVersions});

  @override
  final String networkName;
  @override
  final String genesis;
  @override
  final int paraId;
  @override
  final int ss58;
  @override
  final SubstrateConsensusRole role;
  @override
  final SubstrateRelaySystem relaySystem = SubstrateRelaySystem.paseo;
  @override
  final SubstrateChainType chainType;

  @override
  final bool allowLocalTransfer;
  String get name => networkName;

  @override
  PaseoNetwork get relayChain {
    return PaseoNetwork.paseo;
  }

  @override
  BaseSubstrateNetwork get assetHub => paseoAssetHub;

  @override
  XCMMultiLocation location({XCMVersion? version}) {
    version ??= defaultXcmVersion;
    if (role.isRelay) {
      return XCMMultiLocation.fromVersion(parents: 0, version: version);
    }
    return XCMMultiLocation.fromVersion(
        parents: 1,
        interior: XCMJunctions.fromVersion(junctions: [
          XCMJunctionParaChain.fromVersion(id: paraId, version: version)
        ], version: version),
        version: version);
  }

  @override
  bool get isAssetHub => this == assetHub;

  @override
  final List<XCMVersion> xcmVersions;

  @override
  XCMVersion get defaultXcmVersion => xcmVersions.last;

  @override
  XCMVersion findXcmVersion(BaseSubstrateNetwork? network) {
    if (network == null) {
      if (xcmVersions.contains(XCMVersion.v3)) return XCMVersion.v3;
      throw DartSubstratePluginException("Unsupported xcm version");
    }
    final versions = network.xcmVersions;
    for (final version in versions.reversed) {
      if (xcmVersions.contains(version)) {
        return version;
      }
    }
    throw DartSubstratePluginException("Unsupported xcm version");
  }

  @override
  GenericBaseSubstrateNativeAsset get relayAsset =>
      GenericBaseSubstrateNativeAsset.withParaLocation(
          name: "Paseo",
          decimals: 10,
          symbol: "PAS",
          minBalance: BigInt.parse("10000000000"),
          version: defaultXcmVersion,
          parents: 1,
          excutionPallet: SubtrateMetadataPallet.balances);
}
