import 'package:polkadot_dart/src/networks/controllers/bridge_hub/controller.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';

class PolkadotCoretimeNetworkController
    extends PolkadotBridgeHubNetworkController {
  PolkadotCoretimeNetworkController({required super.params});

  @override
  PolkadotNetwork get network => PolkadotNetwork.polkadotCoretime;
}

class KusamaCoretimeNetworkController extends KusamaBridgeHubNetworkController {
  KusamaCoretimeNetworkController({required super.params});

  @override
  KusamaNetwork get network => KusamaNetwork.kusamaCoretime;
}

class WestendCoretimeNetworkController
    extends WestendBridgeHubNetworkController {
  WestendCoretimeNetworkController({required super.params});

  @override
  WestendNetwork get network => WestendNetwork.westendCoretime;
}

class PaseoCoretimeNetworkController extends PaseoBridgeHubNetworkController {
  PaseoCoretimeNetworkController({required super.params});

  @override
  PaseoNetwork get network => PaseoNetwork.paseoCoretime;
}
