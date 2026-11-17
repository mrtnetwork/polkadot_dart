import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:test/test.dart';
import '../utils.dart';

/// Registry guard: every known network must resolve to its controller.
///
/// Catches wiring breaks (new enum value without a finder arm, removed
/// controller, wrong network mapping) without any chain access — controller
/// construction is lazy and performs no RPC.
void controllerFinderTest() {
  final params = SubstrateNetworkApiDefaultParams(
    (_) async => throw UnimplementedError('no RPC in registry test'),
  );
  group('controller-registry', () {
    test('every network resolves to its own controller', () {
      expect(BaseSubstrateNetwork.values, isNotEmpty);
      for (final network in BaseSubstrateNetwork.values) {
        final controller = SubstrateNetworkControllerFinder.buildApi(
          network: network,
          params: params,
        );
        expect(
          controller.network,
          equals(network),
          reason: 'controller mismatch for ${network.networkName}',
        );
        expect(controller.network.networkName, isNotEmpty);
        expect(controller.defaultNativeAsset.symbol, isNotNull);
        expect(controller.defaultNativeAsset.decimals, isNotNull);
      }
    });

    test('retired networks stay resolvable (historical reads)', () {
      final List<BaseSubstrateNetwork> retired = [
        PolkadotNetwork.moonbeam,
        KusamaNetwork.moonriver,
        PolkadotNetwork.phala,
      ];
      for (final network in retired) {
        final controller = SubstrateNetworkControllerFinder.buildApi(
          network: network,
          params: params,
        );
        expect(controller.network, equals(network));
      }
    });

    test('frequency wiring', () {
      const network = PolkadotNetwork.frequency;
      expect(network.paraId, 2091);
      expect(network.ss58, 90);
      final controller = SubstrateNetworkControllerFinder.buildApi(
        network: network,
        params: params,
      );
      expect(controller.network, equals(network));
      expect(controller.defaultNativeAsset.symbol, 'FRQCY');
      expect(controller.defaultNativeAsset.decimals, 8);
    });
  });
}

void main() {
  PolkadotDartUtilsTestApi.runTest(controllerFinderTest, 'Controller Finder');
}
