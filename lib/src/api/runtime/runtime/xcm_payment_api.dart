import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/models/modesl.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

enum SubstrateRuntimeApiXCMPaymentMethods
    implements SubstrateRuntimeApiMethods {
  queryAcceptablePaymentAssets("query_acceptable_payment_assets"),
  queryXcmWeight("query_xcm_weight"),
  queryWeightToAssetFee("query_weight_to_asset_fee"),
  queryDeliveryFees("query_delivery_fees");

  @override
  final String method;
  const SubstrateRuntimeApiXCMPaymentMethods(this.method);
}

/// safexcmversion
class SubstrateRuntimeApiXCMPayment extends SubstrateRuntimeApi {
  const SubstrateRuntimeApiXCMPayment();

  Future<SubstrateDispatchResult<XCMVersionedAssetIds>>
      queryAcceptablePaymentAsset(
          {required MetadataApi api,
          required SubstrateProvider rpc,
          required XCMVersion version}) async {
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        method:
            SubstrateRuntimeApiXCMPaymentMethods.queryAcceptablePaymentAssets,
        api: api,
        provider: rpc,
        params: [version.version]);
    return SubstrateDispatchResult.fromJson<XCMVersionedAssetIds,
        List<Map<String, dynamic>>>(
      result,
      (result) => XCMVersionedAssetIds(
          assets: result.map((e) => XCMVersionedAssetId.fromJson(e)).toList()),
    );
  }

  Future<XCMVersionedAssetIds> tryQueryAcceptablePaymentAsset(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required XCMVersion version}) async {
    if (!methodExists(
        method:
            SubstrateRuntimeApiXCMPaymentMethods.queryAcceptablePaymentAssets,
        api: api)) {
      return XCMVersionedAssetIds(assets: []);
    }
    final result =
        await queryAcceptablePaymentAsset(api: api, rpc: rpc, version: version);
    return result.ok ?? XCMVersionedAssetIds(assets: []);
  }

  Future<SubstrateDispatchResult<SubstrateWeightV2>> queryXcmWeight(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required XCMVersionedXCM xcm}) async {
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryXcmWeight,
        api: api,
        provider: rpc,
        params: [xcm.toJson()]);
    return SubstrateDispatchResult.fromJson<SubstrateWeightV2,
        Map<String, dynamic>>(result, SubstrateWeightV2.fromJson);
  }

  Future<SubstrateDispatchResult<BigInt>> queryWeightToAssetFee(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required SubstrateWeightV2 weight,
      required XCMVersionedAssetId asset}) async {
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryWeightToAssetFee,
        api: api,
        provider: rpc,
        params: [
          weight.toJson(),
          asset.toJson(),
        ]);
    return SubstrateDispatchResult.fromJson<BigInt, BigInt>(
        result, (result) => result);
  }

  Future<SubstrateDispatchResult<XCMVersionedAssets>> queryDeliveryFees(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required XCMVersionedLocation destination,
      required XCMVersionedXCM xcm}) async {
    final result = await callRuntimeApiInternal<Map<String, dynamic>>(
        method: SubstrateRuntimeApiXCMPaymentMethods.queryDeliveryFees,
        api: api,
        provider: rpc,
        params: [destination.toJson(), xcm.toJson()]);
    return SubstrateDispatchResult.fromJson<XCMVersionedAssets,
            Map<String, dynamic>>(
        result, (json) => XCMVersionedAssets.fromJson(json));
  }

  @override
  SubstrateRuntimeApis get api => SubstrateRuntimeApis.xcmPaymentApi;
}
