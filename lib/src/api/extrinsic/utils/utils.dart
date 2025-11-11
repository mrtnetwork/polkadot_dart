import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/extrinsic/dynamic/extrinsic.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';

class ExtrinsicBuilderUtils {
  static MetadataTypeInfo? getLookupTypeInfo(
      {required MetadataApi metadata, int? lockupId, String? name}) {
    if (lockupId == null) return null;
    final info = metadata.metadata
        .getLookup(lockupId)
        .typeInfo(metadata.registry, lockupId);
    if (name == null) return info;
    return info.copyWith(name: name);
  }

  static ExtrinsicLookupField buildExtrinsicFieldsAtVersion(
      MetadataApi metadata,
      {int? version}) {
    final metadataInfos = metadata.metadata.palletsInfos();
    const List<int> supportedExtrinsicVersions = [4, 5];
    final extrinsic = metadataInfos.extrinsic.firstWhere(
        (e) =>
            supportedExtrinsicVersions.contains(e.version) &&
            e.addressType != null &&
            e.signatureType != null,
        orElse: () => throw DartSubstratePluginException(
            'Unsuported metadata extrinsic.'));
    return buildExtrinsicFields(metadata, extrinsic);
  }

  static ExtrinsicLookupField buildExtrinsicFields(
      MetadataApi metadata, TransactionExtrinsicInfo extrinsic) {
    List<MetadataTypeInfo> payloadTypes = [];
    List<MetadataTypeInfo> extrinsicTypes = [];
    if (extrinsic.addressType == null) {
      throw DartSubstratePluginException(
          "Failed to find metadata address type.");
    }
    if (extrinsic.signatureType == null) {
      throw DartSubstratePluginException(
          "Failed to find metadata signature type.");
    }
    MetadataTypeInfo address = getLookupTypeInfo(
        metadata: metadata, lockupId: extrinsic.addressType!, name: "Address")!;

    MetadataTypeInfo signature = getLookupTypeInfo(
        metadata: metadata, lockupId: extrinsic.addressType!, name: "Address")!;

    MetadataTypeInfo call;
    if (extrinsic.callType == null) {
      final pallets =
          metadata.metadata.pallets.values.where((e) => e.calls != null);
      final variants = pallets.map((e) => Si1Variant(
          name: e.name,
          fields: [
            Si1Field(name: null, type: e.calls!.type, typeName: null, docs: [])
          ],
          index: e.index,
          docs: e.docs ?? []));
      call = MetadataTypeInfoVariant(
          variants: variants.toList(), typeId: -1, name: "Call");
    } else {
      call = getLookupTypeInfo(
          metadata: metadata, lockupId: extrinsic.callType!, name: "Call")!;
    }

    for (final i in extrinsic.payloadExtrinsic) {
      MetadataTypeInfo loockup =
          getLookupTypeInfo(metadata: metadata, lockupId: i.id, name: i.name)!;
      payloadTypes.add(loockup);
    }
    for (final i in extrinsic.extrinsic) {
      MetadataTypeInfo loockup =
          getLookupTypeInfo(metadata: metadata, lockupId: i.id, name: i.name)!;
      extrinsicTypes.add(loockup);
    }

    final algorithm =
        getNetworkCryptoInfo(metadata: metadata, extrinsic: extrinsic);
    return ExtrinsicLookupField(
        call: call,
        extrinsicValidators: extrinsicTypes,
        extrinsicPayloadValidators: payloadTypes,
        extrinsicInfo: extrinsic,
        address: address,
        signature: signature,
        crypto: algorithm,
        chargeAssetTxPayment: payloadTypes
            .any((e) => e.name == MetadataConstant.chargeAssetTxPayment),
        checkMetadataHash: payloadTypes
            .any((e) => e.name == MetadataConstant.checkMetadataHash));
  }

  static SubstrateKeyAlgorithm? isEthereum(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    try {
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: List<int>.filled(20, 0),
          fromTemplate: false);
      metadata.metadata.encodeLookup(
          id: extrinsic.signatureType!,
          value: List<int>.filled(SubstrateConstant.ecdsaSignatureLength, 0),
          fromTemplate: false);
      return SubstrateKeyAlgorithm.ethereum;
    } catch (_) {
      return null;
    }
  }

  static SubstrateChainType getChainType(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    try {
      // metadata.getCallLookupId('ethereum');
      // metadata.getCallLookupId('evm');
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: List<int>.filled(20, 0),
          fromTemplate: false);
      metadata.metadata.encodeLookup(
          id: extrinsic.signatureType!,
          value: List<int>.filled(SubstrateConstant.ecdsaSignatureLength, 0),
          fromTemplate: false);
      return SubstrateChainType.ethereum;
    } catch (_) {
      return SubstrateChainType.substrate;
    }
  }

  static SubstrateAddressEncodingType? getAddressPalletType(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    try {
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: List<int>.filled(20, 0),
          fromTemplate: false);
      return SubstrateAddressEncodingType.ethereum;
    } catch (_) {}
    try {
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: {
            "Id": List<int>.filled(SubstrateConstant.accountIdLengthInBytes, 0)
          },
          fromTemplate: false);
      return SubstrateAddressEncodingType.substrate;
    } catch (_) {}
    try {
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: List<int>.filled(32, 0),
          fromTemplate: false);
      return SubstrateAddressEncodingType.key32;
    } catch (_) {}
    return null;
  }

  static List<SubstrateKeyAlgorithm>? getMetadataCryptoAlgorithm(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    try {
      final sigType = getLookupTypeInfo(
          metadata: metadata, lockupId: extrinsic.signatureType!);
      if (sigType == null || sigType is! MetadataTypeInfoVariant) return [];
      List<SubstrateKeyAlgorithm> keyAlgorithms = [];
      for (final i in sigType.variants) {
        final SubstrateKeyAlgorithm? keyAlgorithm = SubstrateKeyAlgorithm.values
            .firstWhereNullable((e) => e.name == i.name);
        if (keyAlgorithm == null ||
            keyAlgorithm == SubstrateKeyAlgorithm.ethereum) {
          continue;
        }
        metadata.metadata.encodeLookup(
            id: extrinsic.signatureType!,
            value: {
              keyAlgorithm.name:
                  List<int>.filled(keyAlgorithm.signatureLength, 0)
            },
            fromTemplate: false);
        keyAlgorithms.add(keyAlgorithm);
      }
      return keyAlgorithms;
    } catch (_) {
      return null;
    }
  }

  static SubstrateNetworkCryptoInfo getNetworkCryptoInfo(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    final eth = isEthereum(metadata: metadata, extrinsic: extrinsic);
    if (eth != null) {
      return SubstrateNetworkCryptoInfo(
          type: SubstrateChainType.ethereum,
          cryptoAlgoritms: [SubstrateKeyAlgorithm.ethereum],
          signaturePalletType: SubstrateSignatureEncodingType.signature,
          addressPalletType: SubstrateAddressEncodingType.ethereum);
    }
    final addressType =
        getAddressPalletType(metadata: metadata, extrinsic: extrinsic);
    if (addressType == null) {
      throw DartSubstratePluginException('Unknown metadata address type.');
    }
    final cryptoAlgoritms =
        getMetadataCryptoAlgorithm(metadata: metadata, extrinsic: extrinsic);
    if (cryptoAlgoritms == null || cryptoAlgoritms.isEmpty) {
      throw DartSubstratePluginException('Unknow metadata crypto type.');
    }
    return SubstrateNetworkCryptoInfo(
        type: SubstrateChainType.substrate,
        cryptoAlgoritms: cryptoAlgoritms,
        signaturePalletType: SubstrateSignatureEncodingType.substrate,
        addressPalletType: addressType);
  }

  static Map<String, dynamic> buildMultiSignatureTemplate({
    required EllipticCurveTypes algorithm,
    required List<int> signature,
  }) {
    switch (algorithm) {
      case EllipticCurveTypes.ed25519:
        return {"Ed25519": signature};
      case EllipticCurveTypes.secp256k1:
        return {"Ecdsa": signature};
      case EllipticCurveTypes.sr25519:
        return {"Sr25519": signature};
      default:
        throw DartSubstratePluginException("invalid substrate curve type");
    }
  }

  static List<int> getSignaturePart(Map<String, dynamic> signature) {
    try {
      if (signature.containsKey("Ed25519")) {
        return signature.valueAsBytes("Ed25519");
      } else if (signature.containsKey("Ecdsa")) {
        return signature.valueAsBytes("Ecdsa");
      } else if (signature.containsKey("Sr25519")) {
        return signature.valueAsBytes("Sr25519");
      }
    } catch (_) {}
    throw DartSubstratePluginException("Failed to extract signature part.");
  }
}
