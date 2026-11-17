import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:test/test.dart';
import '../utils.dart';

/// Offline tests for [SubstrateQuickClientApi] (fake provider, no network).
void quickClientTest() {
  SubstrateQuickClientApi quickWith(
    Map<Type, dynamic Function()> handlers,
  ) {
    return _Quick(_FakeProvider(handlers));
  }

  test('getBlockHash passes the hash through', () async {
    final quick = quickWith({
      SubstrateRequestChainGetBlockHash: () => 'ab' * 32,
    });
    expect(await quick.getBlockHash(atNumber: 1), 'ab' * 32);

    final missing = quickWith({
      SubstrateRequestChainGetBlockHash: () => null,
    });
    expect(await missing.getBlockHash(atNumber: 999999999), isNull);
  });

  test('getFinalizedHead reads the head hash', () async {
    final quick = quickWith({
      SubstrateRequestChainChainGetFinalizedHead: () => 'cd' * 32,
    });
    expect(await quick.getFinalizedHead(), 'cd' * 32);
  });

  test('getBlockHeader reads the header', () async {
    final quick = quickWith({
      SubstrateRequestChainChainGetHeader: () =>
          SubstrateHeaderResponse(
            parentHash: '00' * 32,
            number: 100,
            stateRoot: '11' * 32,
            extrinsicsRoot: '22' * 32,
            digest: null,
          ),
    });
    final header = await quick.getBlockHeader();
    expect(header.number, 100);
  });

  test('systemProperties and systemChain pass through', () async {
    final quick = quickWith({
      SubstrateRequestSystemProperties: () => ChainProperties.fromJson({
        'tokenSymbol': 'DOT',
        'tokenDecimals': 10,
        'ss58Format': 0,
      }),
      SubstrateRequestSystemChain: () => 'Polkadot',
    });
    final props = await quick.systemProperties();
    expect(props.tokens.single.tokenSymbol, 'DOT');
    expect(await quick.systemChain(), 'Polkadot');
  });

  test('submitExtrinsic returns the hash', () async {
    final quick = quickWith({
      SubstrateRequestAuthorSubmitExtrinsic: () => 'ef' * 32,
    });
    expect(await quick.submitExtrinsic('0x00'), 'ef' * 32);
  });

  test('fee queries pass through', () async {
    final quick = quickWith({
      SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails: () => QueryFeeDetails(tip: BigInt.zero),
      SubstrateRequestRuntimeTransactionPaymentApiQueryInfo: () =>
          QueryFeeInfo(
            weight: SubstrateWeightV2(
              refTime: BigInt.zero,
              proofSize: BigInt.zero,
            ),
            className: QueryFeeInfoClass.normal,
            partialFee: BigInt.from(100),
          ),
    });
    final details = await quick.queryFeeDetails(extrinsic: [0]);
    expect(details.tip, BigInt.zero);
    final info = await quick.queryFeeInfo(extrinsic: [0]);
    expect(info.partialFee, BigInt.from(100));
  });

  test('rpcMethods and metadataVersions pass through', () async {
    final quick = quickWith({
      SubstrateRequestRpcMethods: () =>
          RpcMethods(version: 1, methods: const ['chain_getBlockHash']),
      SubstrateRequestRuntimeMetadataGetVersions: () => [14],
    });
    expect((await quick.rpcMethods()).methods, ['chain_getBlockHash']);
    expect(await quick.metadataVersions(), [14]);
  });
}

class _Quick with SubstrateQuickClientApi {
  _Quick(this._provider);
  final IProvider<IServiceProvider, SubstrateRequestDetails> _provider;
  @override
  IProvider<IServiceProvider, SubstrateRequestDetails> get provider =>
      _provider;
}

class _FakeProvider
    implements IProvider<IServiceProvider, SubstrateRequestDetails> {
  final Map<Type, dynamic Function()> handlers;
  _FakeProvider(this.handlers);

  @override
  IServiceProvider get service => throw UnimplementedError();

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
    IServiceRequest<RESULT, SERVICERESPONSE, SubstrateRequestDetails> request, {
    Duration? timeout,
  }) async {
    final handler = handlers[request.runtimeType];
    if (handler == null) {
      throw StateError('Unexpected request ${request.runtimeType}');
    }
    return handler() as RESULT;
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
    IServiceRequest<RESULT, SERVICERESPONSE, SubstrateRequestDetails> request, {
    Duration? timeout,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  PolkadotDartUtilsTestApi.runTest(quickClientTest, 'Quick Client');
}
