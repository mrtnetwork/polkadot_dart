import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';

class SubstrateNetworkControllerConstants {
  static const XCMVersion latestXCMVersion = XCMVersion.v5;
  static final XCMVersionedLocationV3 relayLocation = XCMVersionedLocationV3(
      location: XCMV3MultiLocation(parents: 1, interior: XCMV3JunctionsHere()));
  static const List<XCMVersion> defaultNetworksXCMSupportedVersion = [
    XCMVersion.v3,
    XCMVersion.v4,
    XCMVersion.v5,
  ];
  static const List<XCMVersion> xcmSupportedVersionTwoToFour = [
    XCMVersion.v2,
    XCMVersion.v3,
    XCMVersion.v4,
  ];
  static const List<XCMVersion> xcmSupportedVersionTwoToThree = [
    XCMVersion.v2,
    XCMVersion.v3,
  ];

  static const DartSubstratePluginException transferDisabled =
      DartSubstratePluginException(
          "XCM transfer is currently disabled for this network.");

  static const List<BaseSubstrateNetwork> disabledDotReserve = [
    KusamaNetwork.altair,
    PolkadotNetwork.centrifuge,
    PolkadotNetwork.interlay,
    PolkadotNetwork.manta,
    PolkadotNetwork.phala,
    PolkadotNetwork.crust,
    PolkadotNetwork.energyWebX,
    PolkadotNetwork.xode,
  ];
}
