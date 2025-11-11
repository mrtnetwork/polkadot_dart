import 'package:blockchain_utils/bip/address/eth_addr.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/runtime/runtime.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/ethereum_rpc_apis.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

class SubstrateRuntimeApiConstants {
  static final Map<String, SubstrateRuntimeApiLayoutBuilder> apis = {
    SubstrateRuntimeApiDryRunMethods.dryRunCall.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, v) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            return LayoutConst.struct([
              api.tryTypeLayoutByPathTail("DispatchResultWithPostInfo",
                      property: "execution_result") ??
                  DispatchResultWithPostInfo.buildDispatchLayout(
                      metadata: api, property: "execution_result"),
              LayoutConst.compactVec(api.typeLayoutByPathTail("RuntimeEvent"),
                  property: "emitted_events"),
              MetadataUtils.optionalLayout(
                  ({property}) => api.typeLayoutByPathTail("VersionedXcm",
                      property: property),
                  property: "local_xcm"),
              LayoutConst.compactVec(
                  LayoutConst.tuple([
                    api.typeLayoutByPathTail("VersionedLocation"),
                    LayoutConst.compactVec(
                        api.typeLayoutByPathTail("VersionedXcm"))
                  ]),
                  property: "forwarded_xcms"),
            ], property: property);
          },
        );
      },
      inputBuilder: (api, version) {
        final origin = api.typeLayoutByPathTail("OriginCaller");
        final call = api.typeLayoutByPathTail("RuntimeCall");
        final xcmVersion = api.typeLayoutByName("U32");
        return LayoutConst.tuple([origin, call, if (version > 1) xcmVersion]);
      },
    ),
    SubstrateRuntimeApiDryRunMethods.dryRunXcm.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            return LayoutConst.struct([
              api.typeLayoutByName("Outcome", property: "execution_result"),
              LayoutConst.compactVec(api.typeLayoutByPathTail("RuntimeEvent"),
                  property: "emitted_events"),
              LayoutConst.compactVec(
                  LayoutConst.tuple([
                    api.typeLayoutByPathTail("VersionedLocation"),
                    LayoutConst.compactVec(
                        api.typeLayoutByPathTail("VersionedXcm"))
                  ]),
                  property: "forwarded_xcms"),
            ], property: property);
          },
        );
      },
      inputBuilder: (api, _) {
        final xcm = api.typeLayoutByPathTail("VersionedXcm");
        final location = api.typeLayoutByPathTail("VersionedLocation");
        return LayoutConst.tuple([location, xcm]);
      },
    ),
    SubstrateRuntimeApiXCMPaymentMethods.queryXcmWeight.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            final layout =
                api.typeLayoutByPathTail("Weight", property: property);
            return layout;
          },
        );
      },
      inputBuilder: (api, _) {
        final xcm = api.typeLayoutByPathTail("VersionedXcm");
        return LayoutConst.tuple([xcm]);
      },
    ),
    SubstrateRuntimeApiXCMPaymentMethods.queryWeightToAssetFee.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            return LayoutConst.u128(property: property);
          },
        );
      },
      inputBuilder: (api, _) {
        final weight = api.typeLayoutByPathTail("Weight");
        final assetId = api.typeLayoutByPathTail("VersionedAssetId");
        return LayoutConst.tuple([weight, assetId]);
      },
    ),
    SubstrateRuntimeApiXCMPaymentMethods.queryDeliveryFees.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            final layout =
                api.typeLayoutByPathTail("VersionedAssets", property: property);
            return layout;
          },
        );
      },
      inputBuilder: (api, _) {
        final xcm = api.typeLayoutByPathTail("VersionedXcm");
        final location = api.typeLayoutByPathTail("VersionedLocation");
        return LayoutConst.tuple([location, xcm]);
      },
    ),
    SubstrateRuntimeApiXCMPaymentMethods.queryAcceptablePaymentAssets.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            final layout = api.typeLayoutByPathTail("VersionedAssetId");
            return LayoutConst.compactVec(layout, property: property);
          },
        );
      },
      inputBuilder: (api, _) {
        return LayoutConst.tuple([LayoutConst.u32()]);
      },
    ),
    SubstrateRuntimeApiAssetConversionMethods.quotePriceExactTokensForTokens
        .method: SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return MetadataUtils.optionalLayout(
            ({property}) => LayoutConst.u128(property: property));
      },
      inputBuilder: (api, _) {
        final location = api.typeLayoutByPathTail("Location");
        return LayoutConst.tuple(
            [location, location, LayoutConst.u128(), LayoutConst.boolean()]);
      },
    ),
    SubstrateRuntimeApiAssetConversionMethods.quotePriceTokensForExactTokens
        .method: SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return MetadataUtils.optionalLayout(
            ({property}) => LayoutConst.u128(property: property));
      },
      inputBuilder: (api, _) {
        final location = api.typeLayoutByPathTail("Location");
        return LayoutConst.tuple(
            [location, location, LayoutConst.u128(), LayoutConst.boolean()]);
      },
    ),
    SubstrateRuntimeApiEthereumRuntimeRPCApisMethods.call.method:
        SubstrateRuntimeApiLayoutBuilder(
      outputBuilder: (api, _) {
        return SubstrateDispatchResult.buildDispatchLayout(
          metadata: api,
          onOk: ({property}) {
            final layout =
                api.typeLayoutByPathTail("ExecutionInfoV2", property: property);
            return layout;
          },
        );
      },
      inputBuilder: (api, _) {
        return LayoutConst.tuple([
          LayoutConst.fixedBlobN(EthAddrConst.addrLenBytes),
          LayoutConst.fixedBlobN(EthAddrConst.addrLenBytes),
          LayoutConst.compactBytes(),
          LayoutConst.array(LayoutConst.u64(), 4),
          LayoutConst.array(LayoutConst.u64(), 4),
          MetadataUtils.optionalLayout(
              ({property}) => LayoutConst.array(LayoutConst.u64(), 4)),
          MetadataUtils.optionalLayout(
              ({property}) => LayoutConst.array(LayoutConst.u64(), 4)),
          MetadataUtils.optionalLayout(
              ({property}) => LayoutConst.array(LayoutConst.u64(), 4)),
          LayoutConst.boolean(),
          MetadataUtils.optionalLayout(({property}) => LayoutConst.none()),
          MetadataUtils.optionalLayout(({property}) => LayoutConst.none()),
        ]);
      },
    ),
  }.immutable;
}
