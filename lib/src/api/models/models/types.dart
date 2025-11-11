import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/extrinsic/dynamic/extrinsic.dart';
import 'package:polkadot_dart/src/api/extrinsic/utils/utils.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

class MetadataWithExtrinsic {
  final MetadataApi api;
  final ExtrinsicLookupField extrinsic;
  const MetadataWithExtrinsic({required this.api, required this.extrinsic});
  factory MetadataWithExtrinsic.fromMetadata(MetadataApi api) {
    return MetadataWithExtrinsic(
        api: api,
        extrinsic: ExtrinsicBuilderUtils.buildExtrinsicFieldsAtVersion(api));
  }
}

class MetadataWithProvider {
  final SubstrateProvider provider;
  final MetadataWithExtrinsic metadata;
  const MetadataWithProvider({required this.provider, required this.metadata});
}

enum SubtrateMetadataUtilityMethods {
  batch("batch"),
  asDerivative("as_derivative"),
  batchAll("batch_all"),
  dispatchAs("dispatch_as"),
  forceBatch("force_batch"),
  withWeight("with_weight"),
  ifElse("if_else"),
  dispatchAsFallible("dispatch_as_fallible");

  final String name;
  const SubtrateMetadataUtilityMethods(this.name);
}
