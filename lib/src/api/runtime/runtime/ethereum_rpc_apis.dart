import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/ethereum_runtime_rpcs/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

enum SubstrateRuntimeApiEthereumRuntimeRPCApisMethods
    implements SubstrateRuntimeApiMethods {
  call("call");

  @override
  final String method;
  const SubstrateRuntimeApiEthereumRuntimeRPCApisMethods(this.method);
}

/// safexcmversion
class SubstrateRuntimeApiEthereumRuntimeRPCApis extends SubstrateRuntimeApi {
  const SubstrateRuntimeApiEthereumRuntimeRPCApis();
  @override
  SubstrateRuntimeApis get api => SubstrateRuntimeApis.ethereumRuntimeRPCApi;

  Future<SubstrateDispatchResult<EthereumRuntimeRpcsApiCall>> call({
    required MetadataApi api,
    required SubstrateProvider rpc,
    required SubstrateEthereumAddress from,
    required SubstrateEthereumAddress to,
    required List<int> inputs,
    BigInt? value,
    BigInt? gasLmit,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    BigInt? nonce,
    bool estimate = true,
  }) async {
    value ??= BigInt.zero;
    gasLmit ??= BigInt.zero;
    const method = SubstrateRuntimeApiEthereumRuntimeRPCApisMethods.call;
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        api: api,
        method: method,
        provider: rpc,
        params: [
          from.toBytes(),
          to.toBytes(),
          inputs,
          BigintUtils.splitU256ToU64Parts(value),
          BigintUtils.splitU256ToU64Parts(gasLmit),
          MetadataUtils.toOptionalJson(maxFeePerGas == null
              ? null
              : BigintUtils.splitU256ToU64Parts(maxFeePerGas)),
          MetadataUtils.toOptionalJson(maxPriorityFeePerGas == null
              ? null
              : BigintUtils.splitU256ToU64Parts(maxPriorityFeePerGas)),
          MetadataUtils.toOptionalJson(
              nonce == null ? null : BigintUtils.splitU256ToU64Parts(nonce)),
          estimate,
          MetadataUtils.toOptionalJson(null),
          MetadataUtils.toOptionalJson(null),
        ]);
    return SubstrateDispatchResult.fromJson<EthereumRuntimeRpcsApiCall,
            Map<String, dynamic>>(
        result, (result) => EthereumRuntimeRpcsApiCall.fromJson(result));
  }
}
