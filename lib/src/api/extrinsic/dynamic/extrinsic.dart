import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/binary/bytes_tracker.dart'
    show DynamicByteTracker;
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/extrinsic/utils/utils.dart';
import 'package:polkadot_dart/src/api/extrinsic/v4/generic_extrinsic_payload.dart';
import 'package:polkadot_dart/src/api/models/models/transaction.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

class SubstrateNetworkCryptoInfo {
  final SubstrateChainType type;
  final List<SubstrateKeyAlgorithm> cryptoAlgoritms;
  final SubstrateSignatureEncodingType signaturePalletType;
  final SubstrateAddressEncodingType addressPalletType;
  SubstrateNetworkCryptoInfo({
    required this.type,
    required List<SubstrateKeyAlgorithm> cryptoAlgoritms,
    required this.signaturePalletType,
    required this.addressPalletType,
  }) : cryptoAlgoritms = cryptoAlgoritms.immutable;
}

class ExtrinsicLookupField {
  final MetadataTypeInfo call;
  final MetadataTypeInfo address;
  final MetadataTypeInfo signature;
  final List<MetadataTypeInfo> extrinsicValidators;
  final List<MetadataTypeInfo> extrinsicPayloadValidators;
  final TransactionExtrinsicInfo extrinsicInfo;
  final SubstrateNetworkCryptoInfo crypto;
  final bool chargeAssetTxPayment;
  final bool checkMetadataHash;

  ExtrinsicLookupField({
    required List<MetadataTypeInfo> extrinsicValidators,
    required List<MetadataTypeInfo> extrinsicPayloadValidators,
    required this.call,
    required this.extrinsicInfo,
    required this.address,
    required this.signature,
    required this.crypto,
    required this.chargeAssetTxPayment,
    required this.checkMetadataHash,
  })  : extrinsicValidators = extrinsicValidators.immutable,
        extrinsicPayloadValidators = extrinsicPayloadValidators.immutable;

  /// encode signature with current signature template.
  List<int> encodeSignature(
      {EllipticCurveTypes? algorithm,
      List<int>? signature,
      List<int>? encodedSignature,
      required MetadataApi metadata}) {
    if (encodedSignature != null) {
      return encodedSignature;
    }
    if (signature == null) {
      throw DartSubstratePluginException("Signature missing.");
    }
    final type = extrinsicInfo.signatureType;
    if (type == null) {
      throw DartSubstratePluginException(
          "Missing extrinsic signature lookup id.");
    }
    switch (crypto.signaturePalletType) {
      case SubstrateSignatureEncodingType.signature:
        return metadata.metadata
            .encodeLookup(id: type, value: signature, fromTemplate: false);
      default:
        if (algorithm == null) {
          throw DartSubstratePluginException(
              "Signature algorithm missing for encode signature.");
        }
        return metadata.metadata.encodeLookup(
            id: type,
            value: ExtrinsicBuilderUtils.buildMultiSignatureTemplate(
                algorithm: algorithm, signature: signature),
            fromTemplate: false);
    }
  }

  /// encode address with current address template.
  List<int> encodeSigner(
      {required BaseSubstrateAddress address, required MetadataApi metadata}) {
    final type = extrinsicInfo.addressType;
    if (type == null) {
      throw DartSubstratePluginException(
          "Missing extrinsic address lookup id.");
    }
    switch (crypto.addressPalletType) {
      case SubstrateAddressEncodingType.ethereum:
      case SubstrateAddressEncodingType.key32:
        return metadata.metadata.encodeLookup(
            id: type, value: address.toBytes(), fromTemplate: false);
      default:
        return metadata.metadata.encodeLookup(
            id: type, value: {"Id": address.toBytes()}, fromTemplate: false);
    }
  }

  /// decode signature with current signature template.
  List<int> decodeSignature(
      {required List<int> serializedSignature, required MetadataApi metadata}) {
    final type = extrinsicInfo.signatureType;
    if (type == null) {
      throw DartSubstratePluginException(
          "Missing extrinsic signature lookup id.");
    }
    switch (crypto.signaturePalletType) {
      case SubstrateSignatureEncodingType.signature:
        return metadata.metadata.decodeLookup(type, serializedSignature);
      default:
        return ExtrinsicBuilderUtils.getSignaturePart(
            metadata.metadata.decodeLookup(type, serializedSignature));
    }
  }

  /// build address with current address template.
  Object encodeAddress(BaseSubstrateAddress address) {
    switch (crypto.addressPalletType) {
      case SubstrateAddressEncodingType.ethereum:
      case SubstrateAddressEncodingType.key32:
        return address.toBytes();
      case SubstrateAddressEncodingType.substrate:
        return {"Id": address.toBytes()};
    }
  }
}

enum SubstrateChainType {
  substrate(value: 0, name: "Substrate"),
  ethereum(value: 1, name: "Ethereum");

  bool get isEthereum => this == ethereum;

  const SubstrateChainType({required this.value, required this.name});
  final int value;
  final String name;

  static SubstrateChainType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }
}

enum SubstrateAddressEncodingType {
  /// default substrate multi address template (Id, accounts32, ...)
  substrate(
      value: 0,
      name: "Substrate",
      accountIdLength: SubstrateConstant.accountIdLengthInBytes),

  /// raw bytes 32.
  key32(
      value: 1,
      name: "Key32",
      accountIdLength: SubstrateConstant.accountIdLengthInBytes),

  /// raw bytes 20.
  ethereum(
      value: 2,
      name: "Ethereum",
      accountIdLength: SubstrateConstant.accountId20LengthInBytes);

  final int accountIdLength;
  bool get isEthereum => this == ethereum;

  const SubstrateAddressEncodingType(
      {required this.value, required this.name, required this.accountIdLength});
  final int value;
  final String name;

  static SubstrateAddressEncodingType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }
}

enum SubstrateSignatureEncodingType {
  /// default substrate signature template (Ed25519, Ecdsa, Sr25519)
  substrate(value: 0, name: "Substrate"),

  /// raw bytes
  signature(value: 1, name: "Signature");

  const SubstrateSignatureEncodingType(
      {required this.value, required this.name});
  final int value;
  final String name;

  static SubstrateSignatureEncodingType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw ItemNotFoundException(value: value));
  }
}

/// Base interface for dynamic extrinsic builders; defines encoding and payload creation logic.
abstract class BaseDynamicExtrinsicBuilder {
  /// Extrinsic metadata lookup fields.
  ExtrinsicLookupField get metadataFields;

  /// Transaction lifetime (mortal era).
  MortalEra get era;

  /// Sender account nonce.
  BigInt get nonce;

  /// Runtime spec version.
  int get specVersion;

  /// Transaction version.
  int get transactionVersion;

  /// Genesis block hash bytes.
  List<int> get genesis;

  /// Mortality block hash bytes.
  List<int> get mortality;

  /// Optional metadata hash reference.
  List<int>? get metadataHash;

  /// Optional mode flag for encoding variations.
  int? get mode;

  /// Optional tip to prioritize transaction.
  BigInt? get tip;

  /// Optional encoded bytes for asset-based fee payment.
  List<int>? get chargeAssetTxPaymentBytes;

  /// Optional asset used to pay transaction fee.
  Object? get chargeAssetTxPayment;

  /// Encodes transaction era.
  List<int> encodeEra(MetadataApi metadata);

  /// Encodes account nonce.
  List<int> encodeNonce(MetadataApi metadata);

  /// Encodes transaction tip.
  List<int> encodeTip(MetadataApi metadata);

  /// Encodes fee payment asset ID (if applicable).
  List<int> encodeAssetId(MetadataApi metadata);

  /// Encodes runtime spec version.
  List<int> encodeSpecVersion(MetadataApi metadata);

  /// Encodes transaction version.
  List<int> encodeTxVersion(MetadataApi metadata);

  /// Encodes full extrinsic with signature and method bytes.
  List<int> encodeExtrinsic(MetadataApi metadata);

  /// Encodes unsigned extrinsic payload.
  List<int> encodeExtrinsicPayload(MetadataApi metadata);

  /// Encodes unsigned extrinsic payload (for signing).
  List<int> encodeSignExtrinsicPayload(
      {required MetadataApi metadata, required List<int> callBytes});

  /// Creates signed extrinsic.
  List<int> createExtrinsic({
    List<int>? signature,
    List<int>? encodedSignature,
    SubstrateKeyAlgorithm? algorithm,
    required MetadataApi api,
    required BaseSubstrateAddress owner,
  });

  /// Creates final extrinsic. ready for excution
  SubstrateSubmitableTransaction createFinalExtrinsic({
    required List<int> callBytes,
    List<int>? signature,
    List<int>? encodedSignature,
    SubstrateKeyAlgorithm? algorithm,
    required MetadataApi api,
    required BaseSubstrateAddress owner,
  });
}

/// dynamic extrinsic builders; defines encoding and payload creation
class DynamicExtrinsicBuilder implements BaseDynamicExtrinsicBuilder {
  @override
  final ExtrinsicLookupField metadataFields;
  @override
  final MortalEra era;
  @override
  final BigInt nonce;
  @override
  final int specVersion;
  @override
  final int transactionVersion;
  @override
  final List<int> genesis;
  @override
  final List<int> mortality;
  @override
  final List<int>? metadataHash;
  @override
  final int? mode;
  @override
  final BigInt? tip;
  @override
  final List<int>? chargeAssetTxPaymentBytes;
  @override
  final Object? chargeAssetTxPayment;

  DynamicExtrinsicBuilder._(
      {required this.era,
      required this.nonce,
      required this.specVersion,
      required this.transactionVersion,
      required List<int> genesis,
      required List<int> mortality,
      required this.metadataFields,
      this.chargeAssetTxPayment,
      this.metadataHash,
      this.mode,
      this.tip,
      this.chargeAssetTxPaymentBytes})
      : genesis = genesis.asImmutableBytes,
        mortality = mortality.asImmutableBytes;
  factory DynamicExtrinsicBuilder(
      {required ExtrinsicLookupField metadataFields,
      required MortalEra era,
      required BigInt nonce,
      required int specVersion,
      required int transactionVersion,
      required List<int> genesis,
      required List<int> mortality,
      List<int>? chargeAssetTxPaymentBytes,
      Object? chargeAssetTxPayment,
      List<int>? metadataHash,
      int? mode,
      BigInt? tip}) {
    Object? assetTxPayment;
    final immutableGenesis = genesis.asImmutableBytes;
    final immutableMortality = mortality.asImmutableBytes;
    if (chargeAssetTxPaymentBytes != null && chargeAssetTxPayment != null) {
      throw DartSubstratePluginException(
          "Only one payment configuration should be provided `chargeAssetTxPaymentBytes` or `chargeAssetTxPayment`.");
    }
    if (chargeAssetTxPayment != null) {
      assetTxPayment = MetadataUtils.parseOptional(chargeAssetTxPayment);
    }
    return DynamicExtrinsicBuilder._(
        era: era,
        nonce: nonce,
        specVersion: specVersion,
        transactionVersion: transactionVersion,
        metadataFields: metadataFields,
        genesis: immutableGenesis,
        mortality: immutableMortality,
        metadataHash: metadataHash,
        mode: mode,
        tip: tip,
        chargeAssetTxPaymentBytes: chargeAssetTxPaymentBytes,
        chargeAssetTxPayment: assetTxPayment);
  }
  static bool hasField<E extends MetadataTypeInfo>(
      List<MetadataTypeInfo<dynamic>> ext, String name) {
    for (final i in ext) {
      final type = i.findType<E>(name);
      if (type != null) {
        return true;
      }
    }
    return false;
  }

  void _encodeField(
      {required int lookupId,
      required Object? input,
      required MetadataApi metadata,
      required DynamicByteTracker buffer}) {
    final encode =
        metadata.encodeLookup(id: lookupId, value: input, fromTemplate: false);
    buffer.add(encode);
  }

  /// Encodes transaction era.
  @override
  List<int> encodeEra(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("Era")?.typeId;
      if (typeId != null) break;
      final type = i.findType("CheckMortality");
      if (type != null && type.typeName == MetadataTypes.variant) {
        typeId = type.typeId;
        break;
      }
    }
    if (typeId == null) {
      throw DartSubstratePluginException("Extrinsic era type not found.");
    }
    return metadata.encodeLookup(id: typeId, value: era, fromTemplate: false);
  }

  /// Encodes account nonce.
  @override
  List<int> encodeNonce(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("T::Nonce")?.typeId;
      typeId ??= i.findType("CheckNonce")?.typeId;
      typeId ??= i.findType("nonce")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw DartSubstratePluginException("Extrinsic nonce type not found.");
    }
    return metadata.encodeLookup(id: typeId, value: nonce, fromTemplate: false);
  }

  /// Encodes transaction tip.
  @override
  List<int> encodeTip(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("tip")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw DartSubstratePluginException("Extrinsic tip type not found.");
    }
    return metadata.encodeLookup(id: typeId, value: nonce, fromTemplate: false);
  }

  /// Encodes runtime spec version
  @override
  List<int> encodeSpecVersion(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("CheckSpecVersion")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw DartSubstratePluginException(
          "Extrinsic spec version type not found.");
    }
    return metadata.encodeLookup(
        id: typeId, value: specVersion, fromTemplate: false);
  }

  /// Encodes fee payment asset ID (if applicable).
  @override
  List<int> encodeAssetId(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("asset_id")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw DartSubstratePluginException(
          "Extrinsic spec version type not found.");
    }
    if (chargeAssetTxPaymentBytes != null) {
      return metadata.encodeLookup(
          id: typeId,
          value: LookupRawParam(bytes: chargeAssetTxPaymentBytes!),
          fromTemplate: false);
    } else {
      Object chargeAssetTxPayment =
          MetadataUtils.toOptionalJson(this.chargeAssetTxPayment);
      return metadata.encodeLookup(
          id: typeId, value: chargeAssetTxPayment, fromTemplate: false);
    }
  }

  /// Encodes transaction version.
  @override
  List<int> encodeTxVersion(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("CheckTxVersion")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw DartSubstratePluginException(
          "Extrinsic transaction version type not found.");
    }
    return metadata.encodeLookup(
        id: typeId, value: transactionVersion, fromTemplate: false);
  }

  List<int> _encode(
      {required List<MetadataTypeInfo<dynamic>> fields,
      required MetadataApi metadata}) {
    final buffer = DynamicByteTracker();
    for (final i in fields) {
      final names = i.getTypeNames();
      if (names.isEmpty) continue;
      for (final n in names) {
        final typeId = i.findType(n)!.typeId;
        try {
          switch (n) {
            case "Era":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: era.serializeJson(),
                  metadata: metadata);
              break;
            case "T::Nonce":
            case "CheckNonce":
            case "nonce":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: nonce,
                  metadata: metadata);

              break;
            case "BalanceOf<T>":
            case "PalletBalanceOf<T>":
            case "ChargeTransactionPayment":
            case "ChargeTransactionPayment<T>":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: BigInt.zero,
                  metadata: metadata);
              break;
            case "tip":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: tip ?? BigInt.zero,
                  metadata: metadata);
              break;
            case "CheckSpecVersion":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: specVersion,
                  metadata: metadata);
              break;
            case "CheckTxVersion":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: transactionVersion,
                  metadata: metadata);
              break;
            case "CheckGenesis":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: genesis,
                  metadata: metadata);
              break;
            case "CheckMortality":
              if (i.typeName == MetadataTypes.variant) {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: era.serializeJson(),
                    metadata: metadata);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: mortality,
                    metadata: metadata);
              }
              break;
            case "mode":
              if (mode == 1) {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: {"Enabled": null},
                    metadata: metadata);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: {"Disabled": null},
                    metadata: metadata);
              }

              break;
            case "CheckMetadataHash":
              if (metadataHash != null) {
                buffer.add(metadataHash!);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: MetadataUtils.toOptionalJson(null),
                    metadata: metadata);
              }

              break;
            case "asset_id":
              if (chargeAssetTxPaymentBytes != null) {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: LookupRawParam(bytes: chargeAssetTxPaymentBytes!),
                    metadata: metadata);
              } else {
                Object chargeAssetTxPayment =
                    MetadataUtils.toOptionalJson(this.chargeAssetTxPayment);
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: chargeAssetTxPayment,
                    metadata: metadata);
              }

              break;
            default:
              throw DartSubstratePluginException(
                  "Unknown extrinsic field name.",
                  details: {"name": n});
          }
        } catch (e) {
          throw DartSubstratePluginException(
              'Failed to encode extrinsic field.',
              details: {"name": n, "error": e.toString()});
        }
      }
    }
    return buffer.toBytes();
  }

  /// Encodes full extrinsic without address and signature.
  @override
  List<int> encodeExtrinsic(MetadataApi metadata) {
    return _encode(
        fields: metadataFields.extrinsicValidators, metadata: metadata);
  }

  /// Encodes unsigned extrinsic payload
  @override
  List<int> encodeExtrinsicPayload(MetadataApi metadata) {
    return _encode(
        fields: metadataFields.extrinsicPayloadValidators, metadata: metadata);
  }

  /// Encodes unsigned extrinsic payload (for signing)
  @override
  List<int> encodeSignExtrinsicPayload(
      {required MetadataApi metadata, required List<int> callBytes}) {
    final extrinsic = encodeExtrinsicPayload(metadata);
    final payload = [...callBytes, ...extrinsic];
    if (payload.length > TransactionPalyloadConst.requiredHashDigestLength) {
      return QuickCrypto.blake2b256Hash(payload);
    }
    return payload;
  }

  /// Encodes full extrinsic with signature and method bytes.
  @override
  List<int> createExtrinsic(
      {List<int>? signature,
      List<int>? encodedSignature,
      SubstrateKeyAlgorithm? algorithm,
      required MetadataApi api,
      required BaseSubstrateAddress owner}) {
    final buffer = DynamicByteTracker();
    final encodedAddress =
        metadataFields.encodeSigner(address: owner, metadata: api);
    buffer.add(encodedAddress);
    if (signature != null || encodedSignature != null) {
      buffer.add(metadataFields.encodeSignature(
          algorithm: algorithm?.curve,
          signature: signature,
          encodedSignature: encodedSignature,
          metadata: api));
    }
    buffer.add(encodeExtrinsic(api));
    final encodeBytes = buffer.toBytes().asImmutableBytes;
    return encodeBytes;
  }

  @override
  SubstrateSubmitableTransaction createFinalExtrinsic(
      {required List<int> callBytes,
      List<int>? signature,
      List<int>? encodedSignature,
      SubstrateKeyAlgorithm? algorithm,
      required MetadataApi api,
      required BaseSubstrateAddress owner}) {
    final ext = createExtrinsic(
        api: api,
        owner: owner,
        algorithm: algorithm,
        encodedSignature: encodedSignature,
        signature: signature);
    return SubstrateSubmitableTransaction.build(
        signature: signature,
        extrinsic: ext,
        version: metadataFields.extrinsicInfo.version,
        callBytes: callBytes);
  }
}
