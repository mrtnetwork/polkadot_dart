import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/networks/controllers/kilt_spiritnet/controller.dart';
import 'package:polkadot_dart/src/networks/controllers/mythos/controller.dart';
import 'package:polkadot_dart/src/networks/controllers/networks.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';

/// Helper class to find and instantiate the correct network controller
/// based on the provided [BaseSubstrateNetwork] and [SubstrateNetworkControllerParams].
/// Returns null if no matching controller is available.
class SubstrateNetworkControllerFinder {
  static BaseSubstrateNetworkController buildApi(
      {required BaseSubstrateNetwork network,
      required SubstrateNetworkControllerParams params}) {
    return switch (network) {
      PolkadotNetwork.acala => AcalaNetworkController(params: params),
      PolkadotNetwork.polkadotAssetHub =>
        PolkadotAssetHubNetworkController(params: params),
      PolkadotNetwork.polkadot => PolkadotNetworkController(params: params),
      PolkadotNetwork.polkadotBridgeHub =>
        PolkadotBridgeHubNetworkController(params: params),
      PolkadotNetwork.polkadotCollectives =>
        PolkadotCollectivesNetworkController(params: params),
      PolkadotNetwork.polkadotPeople =>
        PolkadotPeopleNetworkController(params: params),
      PolkadotNetwork.polkadotCoretime =>
        PolkadotCoretimeNetworkController(params: params),
      PolkadotNetwork.astar => AstarNetworkController(params: params),
      PolkadotNetwork.hydration => HydrationNetworkController(params: params),
      PolkadotNetwork.interlay => InterlayNetworkController(params: params),
      PolkadotNetwork.bifrostPolkadot =>
        BifrostNetworkController(params: params),
      PolkadotNetwork.centrifuge => CentrifugeNetworkController(params: params),
      PolkadotNetwork.zeitgeist => ZeitgeistNetworkController(params: params),
      PolkadotNetwork.phala => PhalaNetworkController(params: params),
      PolkadotNetwork.manta => MantaNetworkController(params: params),
      PolkadotNetwork.pendulum => PendulumNetworkController(params: params),
      PolkadotNetwork.mythos => MythosNetworkController(params: params),
      PolkadotNetwork.kiltSpiritnet =>
        KILTSpiritnetNetworkController(params: params),
      PolkadotNetwork.moonbeam => MoonbeamNetworkController(params: params),
      PolkadotNetwork.ajuna => AjunaNetworkController(params: params),
      PolkadotNetwork.crust => CrustNetworkController(params: params),
      PolkadotNetwork.energyWebX => EnergyWebXNetworkController(params: params),
      PolkadotNetwork.integritee => IntegriteeNetworkController(params: params),
      PolkadotNetwork.jamton => JamtonNetworkController(params: params),
      PolkadotNetwork.neuroWeb => NeuroNetworkController(params: params),
      PolkadotNetwork.laos => LaosNetworkController(params: params),
      PolkadotNetwork.nodle => NodleNetworkController(params: params),
      PolkadotNetwork.unique => UniqueworkController(params: params),
      PolkadotNetwork.darwinia2 => Darwinia2NetworkController(params: params),
      PolkadotNetwork.xode => XodeNetworkController(params: params),
      KusamaNetwork.karura => KaruraNetworkController(params: params),
      KusamaNetwork.kusamaAssetHub =>
        KusamaAssetHubNetworkController(params: params),
      KusamaNetwork.shiden => ShidenNetworkController(params: params),
      KusamaNetwork.basilisk => BasiliskNetworkController(params: params),
      KusamaNetwork.kintsugi => KintsugiNetworkController(params: params),
      KusamaNetwork.kusama => KusamaNetworkController(params: params),
      KusamaNetwork.kusamaBridgeHub =>
        KusamaBridgeHubNetworkController(params: params),
      KusamaNetwork.encointer => EncointerNetworkController(params: params),
      KusamaNetwork.kusamaPeople =>
        KusamaPeopleNetworkController(params: params),
      KusamaNetwork.kusamaCoretime =>
        KusamaCoretimeNetworkController(params: params),
      KusamaNetwork.bifrostKusama =>
        BifrostKusamaNetworkController(params: params),
      KusamaNetwork.altair => AltairNetworkController(params: params),
      KusamaNetwork.amplitude => AmplitudeNetworkController(params: params),
      KusamaNetwork.moonriver => MoonriverNetworkController(params: params),

      ///
      WestendNetwork.westendAssetHub =>
        WestendAssetHubNetworkController(params: params),
      WestendNetwork.westend => WestendNetworkController(params: params),
      WestendNetwork.westendBridgeHub =>
        WestendBridgeHubNetworkController(params: params),
      WestendNetwork.westendCollectives =>
        WestendCollectivesNetworkController(params: params),
      WestendNetwork.westendPeople =>
        WestendPeopleNetworkController(params: params),
      WestendNetwork.westendCoretime =>
        WestendCoretimeNetworkController(params: params),
      WestendNetwork.penpal => WestendPenpalNetworkController(params: params),

      ///
      PaseoNetwork.paseoAssetHub =>
        PaseoAssetHubNetworkController(params: params),
      PaseoNetwork.paseo => PaseoNetworkController(params: params),
      PaseoNetwork.paseoBridgeHub =>
        PaseoBridgeHubNetworkController(params: params),
      PaseoNetwork.paseoCollectives =>
        PaseoCollectivesNetworkController(params: params),
      PaseoNetwork.paseoPeople => PaseoPeopleNetworkController(params: params),
      PaseoNetwork.paseoCoretime =>
        PaseoCoretimeNetworkController(params: params),
      PaseoNetwork.hydration => HydrationPaseoNetworkController(params: params),
      _ => throw DartSubstratePluginException(
          "Network controller not found for '${network.networkName}'.")
    } as BaseSubstrateNetworkController;
  }
}
