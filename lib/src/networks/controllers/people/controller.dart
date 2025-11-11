import 'package:polkadot_dart/src/networks/controllers/bridge_hub/controller.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';

class PolkadotPeopleNetworkController
    extends PolkadotBridgeHubNetworkController {
  PolkadotPeopleNetworkController({required super.params});
  @override
  PolkadotNetwork get network => PolkadotNetwork.polkadotPeople;
}

class KusamaPeopleNetworkController extends KusamaBridgeHubNetworkController {
  KusamaPeopleNetworkController({required super.params});

  @override
  KusamaNetwork get network => KusamaNetwork.kusamaPeople;
}

class WestendPeopleNetworkController extends WestendBridgeHubNetworkController {
  WestendPeopleNetworkController({required super.params});

  @override
  WestendNetwork get network => WestendNetwork.westendPeople;
}

class PaseoPeopleNetworkController extends PaseoBridgeHubNetworkController {
  PaseoPeopleNetworkController({required super.params});

  @override
  PaseoNetwork get network => PaseoNetwork.paseoPeople;
}
