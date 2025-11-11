import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

enum SubstrateRuntimeApiAssetConversionMethods
    implements SubstrateRuntimeApiMethods {
  quotePriceTokensForExactTokens("quote_price_tokens_for_exact_tokens"),
  quotePriceExactTokensForTokens("quote_price_exact_tokens_for_tokens");

  @override
  final String method;
  const SubstrateRuntimeApiAssetConversionMethods(this.method);
}

/// safexcmversion
class SubstrateRuntimeApiAssetConversion extends SubstrateRuntimeApi {
  const SubstrateRuntimeApiAssetConversion();
  Future<BigInt?> _quotePriceExactTokensForTokens(
      {required QuotePriceParams params,
      required MetadataApi api,
      required SubstrateProvider rpc,
      required SubstrateRuntimeApiAssetConversionMethods method}) async {
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        method: method,
        api: api,
        provider: rpc,
        params: [
          params.assetA.toJson(),
          params.assetB.toJson(),
          params.amount,
          params.includeFee
        ]);
    return MetadataUtils.parseOptional(result);
  }

  Future<BigInt?> quotePriceExactTokensForTokens(
      {required QuotePriceParams params,
      required MetadataApi api,
      required SubstrateProvider rpc}) async {
    return _quotePriceExactTokensForTokens(
        params: params,
        api: api,
        rpc: rpc,
        method: SubstrateRuntimeApiAssetConversionMethods
            .quotePriceExactTokensForTokens);
  }

  Future<BigInt?> quotePriceTokensForExactTokens(
      {required QuotePriceParams params,
      required MetadataApi api,
      required SubstrateProvider rpc}) async {
    return _quotePriceExactTokensForTokens(
        params: params,
        api: api,
        rpc: rpc,
        method: SubstrateRuntimeApiAssetConversionMethods
            .quotePriceTokensForExactTokens);
  }

  @override
  SubstrateRuntimeApis get api => SubstrateRuntimeApis.assetConversionApi;
}
