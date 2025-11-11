import 'package:polkadot_dart/src/networks/controllers/bridge_hub/controller.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';

class EncointerNetworkController extends KusamaBridgeHubNetworkController {
  EncointerNetworkController({required super.params});

  @override
  KusamaNetwork get network => KusamaNetwork.encointer;
}

class PolkadotCollectivesNetworkController
    extends PolkadotBridgeHubNetworkController {
  PolkadotCollectivesNetworkController({required super.params});

  @override
  PolkadotNetwork get network => PolkadotNetwork.polkadotCollectives;
}

class WestendCollectivesNetworkController
    extends WestendBridgeHubNetworkController {
  WestendCollectivesNetworkController({required super.params});

  @override
  WestendNetwork get network => WestendNetwork.westendCollectives;
}

class PaseoCollectivesNetworkController
    extends PaseoBridgeHubNetworkController {
  PaseoCollectivesNetworkController({required super.params});

  @override
  PaseoNetwork get network => PaseoNetwork.paseoCollectives;
}
