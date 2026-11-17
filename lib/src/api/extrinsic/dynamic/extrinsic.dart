import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/extrinsic/utils/utils.dart';
import 'package:polkadot_dart/src/api/extrinsic/v4/generic_extrinsic_payload.dart';
import 'package:polkadot_dart/src/api/models/models/transaction.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/keypair/core/keypair.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/models.dart';

class SubstrateNetworkCryptoInfo {
  final SubstrateChainType type;
  final List<SubstrateKeyAlgorithm> cryptoAlgorithms;
  final SubstrateSignatureEncodingType signaturePalletType;
  final SubstrateAddressEncodingType addressPalletType;
  SubstrateNetworkCryptoInfo({
    required this.type,
    required List<SubstrateKeyAlgorithm> cryptoAlgorithms,
    required this.signaturePalletType,
    required this.addressPalletType,
  }) : cryptoAlgorithms = cryptoAlgorithms.immutable;
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
  }) : extrinsicValidators = extrinsicValidators.immutable,
       extrinsicPayloadValidators = extrinsicPayloadValidators.immutable;

  /// encode signature with current signature template.
  BuBytes encodeSignature({
    CryptoKeyType? algorithm,
    List<int>? signature,
    List<int>? encodedSignature,
    required MetadataApi metadata,
  }) {
    if (encodedSignature != null) {
      return encodedSignature.asImmutableBytes;
    }
    if (signature == null) {
      throw BuError(DefaultErrorType.invalidArgument, "Signature missing.");
    }
    final type = extrinsicInfo.signatureType;
    if (type == null) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "Missing extrinsic signature lookup id.",
      );
    }
    switch (crypto.signaturePalletType) {
      case SubstrateSignatureEncodingType.signature:
        return metadata.metadata
            .encodeLookup(id: type, value: signature, fromTemplate: false)
            .asImmutableBytes;
      default:
        if (algorithm == null) {
          throw BuError(
            DefaultErrorType.invalidArgument,
            "Signature algorithm missing for encode signature.",
          );
        }
        return metadata.metadata
            .encodeLookup(
              id: type,
              value: ExtrinsicBuilderUtils.buildMultiSignatureTemplate(
                algorithm: algorithm,
                signature: signature,
              ),
              fromTemplate: false,
            )
            .asImmutableBytes;
    }
  }

  /// encode address with current address template.
  BuBytes encodeSigner({
    required BaseSubstrateAddress address,
    required MetadataApi metadata,
  }) {
    final type = extrinsicInfo.addressType;
    if (type == null) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "Missing extrinsic address lookup id.",
      );
    }
    switch (crypto.addressPalletType) {
      case SubstrateAddressEncodingType.ethereum:
      case SubstrateAddressEncodingType.key32:
        return metadata.metadata
            .encodeLookup(
              id: type,
              value: address.toBytes(),
              fromTemplate: false,
            )
            .asImmutableBytes;
      default:
        return metadata.metadata
            .encodeLookup(
              id: type,
              value: {"Id": address.toBytes()},
              fromTemplate: false,
            )
            .asImmutableBytes;
    }
  }

  /// decode signature with current signature template.
  BuBytes decodeSignature({
    required List<int> serializedSignature,
    required MetadataApi metadata,
  }) {
    final type = extrinsicInfo.signatureType;
    if (type == null) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "Missing extrinsic signature lookup id.",
      );
    }
    switch (crypto.signaturePalletType) {
      case SubstrateSignatureEncodingType.signature:
        final List<int> decoded = metadata.metadata.decodeLookup(
          type,
          serializedSignature,
        );
        return decoded.asImmutableBytes;
      default:
        final Map<String, dynamic> decodedSig = metadata.metadata.decodeLookup(
          type,
          serializedSignature,
        );
        return ExtrinsicBuilderUtils.getSignaturePart(decodedSig);
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
    return values.firstWhere(
      (e) => e.value == value,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown SubstrateChainType value "$value".',
              ),
    );
  }
}

enum SubstrateAddressEncodingType {
  /// default substrate multi address template (Id, accounts32, ...)
  substrate(
    value: 0,
    name: "Substrate",
    accountIdLength: SubstrateConstant.accountIdLengthInBytes,
  ),

  /// raw bytes 32.
  key32(
    value: 1,
    name: "Key32",
    accountIdLength: SubstrateConstant.accountIdLengthInBytes,
  ),

  /// raw bytes 20.
  ethereum(
    value: 2,
    name: "Ethereum",
    accountIdLength: SubstrateConstant.accountId20LengthInBytes,
  );

  final int accountIdLength;
  bool get isEthereum => this == ethereum;

  const SubstrateAddressEncodingType({
    required this.value,
    required this.name,
    required this.accountIdLength,
  });
  final int value;
  final String name;

  static SubstrateAddressEncodingType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown SubstrateAddressEncodingType value "$value".',
              ),
    );
  }
}

enum SubstrateSignatureEncodingType {
  /// default substrate signature template (Ed25519, Ecdsa, Sr25519)
  substrate(value: 0, name: "Substrate"),

  /// raw bytes
  signature(value: 1, name: "Signature");

  const SubstrateSignatureEncodingType({
    required this.value,
    required this.name,
  });
  final int value;
  final String name;

  static SubstrateSignatureEncodingType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown SubstrateSignatureEncodingType value "$value".',
              ),
    );
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
  BuBytes get genesis;

  /// Mortality block hash bytes.
  BuBytes get mortality;

  /// Optional metadata hash reference.
  BuBytes? get metadataHash;

  /// Optional mode flag for encoding variations.
  int? get mode;

  /// Optional tip to prioritize transaction.
  BigInt? get tip;

  /// Optional encoded bytes for asset-based fee payment.
  BuBytes? get chargeAssetTxPaymentBytes;

  /// Optional asset used to pay transaction fee.
  Object? get chargeAssetTxPayment;

  /// Encodes transaction era.
  BuBytes encodeEra(MetadataApi metadata);

  /// Encodes account nonce.
  BuBytes encodeNonce(MetadataApi metadata);

  /// Encodes transaction tip.
  BuBytes encodeTip(MetadataApi metadata);

  /// Encodes fee payment asset ID (if applicable).
  BuBytes encodeAssetId(MetadataApi metadata);

  /// Encodes runtime spec version.
  BuBytes encodeSpecVersion(MetadataApi metadata);

  /// Encodes transaction version.
  BuBytes encodeTxVersion(MetadataApi metadata);

  /// Encodes full extrinsic with signature and method bytes.
  BuBytes encodeExtrinsic(MetadataApi metadata);

  /// Encodes unsigned extrinsic payload.
  BuBytes encodeExtrinsicPayload(MetadataApi metadata);

  /// Encodes unsigned extrinsic payload (for signing).
  BuBytes encodeSignExtrinsicPayload({
    required MetadataApi metadata,
    required List<int> callBytes,
  });

  /// Creates signed extrinsic.
  BuBytes createExtrinsic({
    List<int>? signature,
    List<int>? encodedSignature,
    SubstrateKeyAlgorithm? algorithm,
    required MetadataApi api,
    required BaseSubstrateAddress owner,
  });

  /// Creates the final extrinsic, ready for execution.
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
  final BuBytes genesis;
  @override
  final BuBytes mortality;
  @override
  final BuBytes? metadataHash;
  @override
  final int? mode;
  @override
  final BigInt? tip;
  @override
  final BuBytes? chargeAssetTxPaymentBytes;
  @override
  final Object? chargeAssetTxPayment;

  DynamicExtrinsicBuilder._({
    required this.era,
    required this.nonce,
    required this.specVersion,
    required this.transactionVersion,
    required List<int> genesis,
    required List<int> mortality,
    required this.metadataFields,
    this.chargeAssetTxPayment,
    List<int>? metadataHash,
    this.mode,
    this.tip,
    List<int>? chargeAssetTxPaymentBytes,
  }) : genesis = genesis.asImmutableBytes,
       mortality = mortality.asImmutableBytes,
       metadataHash = metadataHash?.asImmutableBytes,
       chargeAssetTxPaymentBytes = chargeAssetTxPaymentBytes?.asImmutableBytes;
  factory DynamicExtrinsicBuilder({
    required ExtrinsicLookupField metadataFields,
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
    BigInt? tip,
  }) {
    Object? assetTxPayment;
    final immutableGenesis = genesis.asImmutableBytes;
    final immutableMortality = mortality.asImmutableBytes;
    if (chargeAssetTxPaymentBytes != null && chargeAssetTxPayment != null) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "Only one payment configuration should be provided `chargeAssetTxPaymentBytes` or `chargeAssetTxPayment`.",
      );
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
      chargeAssetTxPayment: assetTxPayment,
    );
  }
  static bool hasField<E extends MetadataTypeInfo>(
    List<MetadataTypeInfo<dynamic>> ext,
    String name,
  ) {
    for (final i in ext) {
      final type = i.findType<E>(name);
      if (type != null) {
        return true;
      }
    }
    return false;
  }

  void _encodeField({
    required int lookupId,
    required Object? input,
    required MetadataApi metadata,
    required BuBytes buffer,
  }) {
    final encode = metadata.encodeLookup(
      id: lookupId,
      value: input,
      fromTemplate: false,
    );
    buffer.addAll(encode);
  }

  /// Encodes transaction era.
  @override
  BuBytes encodeEra(MetadataApi metadata) {
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
      throw BuError(
        DefaultErrorType.notFound,
        "Extrinsic era type not found: no Era/CheckMortality extension.",
      );
    }
    return metadata
        .encodeLookup(id: typeId, value: era, fromTemplate: false)
        .asImmutableBytes;
  }

  /// Encodes account nonce.
  @override
  BuBytes encodeNonce(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("T::Nonce")?.typeId;
      typeId ??= i.findType("CheckNonce")?.typeId;
      typeId ??= i.findType("nonce")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw BuError(
        DefaultErrorType.notFound,
        "Extrinsic nonce type not found: no T::Nonce/CheckNonce/nonce extension.",
      );
    }
    return metadata
        .encodeLookup(id: typeId, value: nonce, fromTemplate: false)
        .asImmutableBytes;
  }

  /// Encodes transaction tip.
  @override
  BuBytes encodeTip(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("tip")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw BuError(
        DefaultErrorType.notFound,
        "Extrinsic tip type not found: no tip extension.",
      );
    }
    return metadata
        .encodeLookup(id: typeId, value: nonce, fromTemplate: false)
        .asImmutableBytes;
  }

  /// Encodes runtime spec version
  @override
  BuBytes encodeSpecVersion(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("CheckSpecVersion")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw BuError(
        DefaultErrorType.notFound,
        "Extrinsic spec version type not found: no CheckSpecVersion extension.",
      );
    }
    return metadata
        .encodeLookup(id: typeId, value: specVersion, fromTemplate: false)
        .asImmutableBytes;
  }

  /// Encodes fee payment asset ID (if applicable).
  @override
  BuBytes encodeAssetId(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("asset_id")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw BuError(
        DefaultErrorType.notFound,
        "Extrinsic asset id type not found: no asset_id extension.",
      );
    }
    if (chargeAssetTxPaymentBytes != null) {
      return metadata
          .encodeLookup(
            id: typeId,
            value: LookupRawParam(bytes: chargeAssetTxPaymentBytes!),
            fromTemplate: false,
          )
          .asImmutableBytes;
    } else {
      Object chargeAssetTxPayment = MetadataUtils.toOptionalJson(
        this.chargeAssetTxPayment,
      );
      return metadata
          .encodeLookup(
            id: typeId,
            value: chargeAssetTxPayment,
            fromTemplate: false,
          )
          .asImmutableBytes;
    }
  }

  /// Encodes transaction version.
  @override
  BuBytes encodeTxVersion(MetadataApi metadata) {
    final fields = metadataFields.extrinsicPayloadValidators;
    int? typeId;
    for (final i in fields) {
      typeId = i.findType("CheckTxVersion")?.typeId;
      if (typeId != null) break;
    }
    if (typeId == null) {
      throw BuError(
        DefaultErrorType.notFound,
        "Extrinsic transaction version type not found: no CheckTxVersion extension.",
      );
    }
    return metadata
        .encodeLookup(
          id: typeId,
          value: transactionVersion,
          fromTemplate: false,
        )
        .asImmutableBytes;
  }

  BuBytes _encode({
    required List<MetadataTypeInfo<dynamic>> fields,
    required MetadataApi metadata,
  }) {
    final buffer = BuBytes.empty();
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
                metadata: metadata,
              );
              break;
            case "T::Nonce":
            case "CheckNonce":
            case "nonce":
              _encodeField(
                lookupId: typeId,
                buffer: buffer,
                input: nonce,
                metadata: metadata,
              );

              break;
            case "BalanceOf<T>":
            case "PalletBalanceOf<T>":
            case "ChargeTransactionPayment":
            case "ChargeTransactionPayment<T>":
              _encodeField(
                lookupId: typeId,
                buffer: buffer,
                input: BigInt.zero,
                metadata: metadata,
              );
              break;
            case "tip":
              _encodeField(
                lookupId: typeId,
                buffer: buffer,
                input: tip ?? BigInt.zero,
                metadata: metadata,
              );
              break;
            case "CheckSpecVersion":
              _encodeField(
                lookupId: typeId,
                buffer: buffer,
                input: specVersion,
                metadata: metadata,
              );
              break;
            case "CheckTxVersion":
              _encodeField(
                lookupId: typeId,
                buffer: buffer,
                input: transactionVersion,
                metadata: metadata,
              );
              break;
            case "CheckGenesis":
              _encodeField(
                lookupId: typeId,
                buffer: buffer,
                input: genesis,
                metadata: metadata,
              );
              break;
            case "CheckMortality":
              if (i.typeName == MetadataTypes.variant) {
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: era.serializeJson(),
                  metadata: metadata,
                );
              } else {
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: mortality,
                  metadata: metadata,
                );
              }
              break;
            case "mode":
              if (mode == 1) {
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: {"Enabled": null},
                  metadata: metadata,
                );
              } else {
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: {"Disabled": null},
                  metadata: metadata,
                );
              }

              break;
            case "CheckMetadataHash":
              if (metadataHash != null) {
                buffer.addAll(metadataHash!);
              } else {
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: MetadataUtils.toOptionalJson(null),
                  metadata: metadata,
                );
              }

              break;
            case "asset_id":
              if (chargeAssetTxPaymentBytes != null) {
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: LookupRawParam(bytes: chargeAssetTxPaymentBytes!),
                  metadata: metadata,
                );
              } else {
                Object chargeAssetTxPayment = MetadataUtils.toOptionalJson(
                  this.chargeAssetTxPayment,
                );
                _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: chargeAssetTxPayment,
                  metadata: metadata,
                );
              }

              break;
            default:
              throw BuError(
                DefaultErrorType.invalidArgument,
                "Unknown extrinsic field name.",
                details: {"name": n},
              );
          }
        } catch (e) {
          throw BuError(
            DefaultErrorType.invalidArgument,
            'Failed to encode extrinsic field.',
            details: {"name": n, "error": e.toString()},
          );
        }
      }
    }
    return buffer;
  }

  /// Encodes full extrinsic without address and signature.
  @override
  BuBytes encodeExtrinsic(MetadataApi metadata) {
    return _encode(
      fields: metadataFields.extrinsicValidators,
      metadata: metadata,
    );
  }

  /// Encodes unsigned extrinsic payload
  @override
  BuBytes encodeExtrinsicPayload(MetadataApi metadata) {
    return _encode(
      fields: metadataFields.extrinsicPayloadValidators,
      metadata: metadata,
    );
  }

  /// Encodes unsigned extrinsic payload (for signing)
  @override
  BuBytes encodeSignExtrinsicPayload({
    required MetadataApi metadata,
    required List<int> callBytes,
  }) {
    final extrinsic = encodeExtrinsicPayload(metadata);
    final payload = [...callBytes, ...extrinsic];
    if (payload.length > TransactionPalyloadConst.requiredHashDigestLength) {
      return QuickCrypto.blake2b256Hash(payload).asImmutableBytes;
    }
    return payload.asImmutableBytes;
  }

  /// Encodes full extrinsic with signature and method bytes.
  @override
  BuBytes createExtrinsic({
    List<int>? signature,
    List<int>? encodedSignature,
    SubstrateKeyAlgorithm? algorithm,
    required MetadataApi api,
    required BaseSubstrateAddress owner,
  }) {
    final buffer = BuBytes.empty();
    final encodedAddress = metadataFields.encodeSigner(
      address: owner,
      metadata: api,
    );
    buffer.addAll(encodedAddress);
    if (signature != null || encodedSignature != null) {
      buffer.addAll(
        metadataFields.encodeSignature(
          algorithm: algorithm?.curve,
          signature: signature,
          encodedSignature: encodedSignature,
          metadata: api,
        ),
      );
    }
    buffer.addAll(encodeExtrinsic(api));
    return buffer;
  }

  @override
  SubstrateSubmitableTransaction createFinalExtrinsic({
    required List<int> callBytes,
    List<int>? signature,
    List<int>? encodedSignature,
    SubstrateKeyAlgorithm? algorithm,
    required MetadataApi api,
    required BaseSubstrateAddress owner,
  }) {
    final ext = createExtrinsic(
      api: api,
      owner: owner,
      algorithm: algorithm,
      encodedSignature: encodedSignature,
      signature: signature,
    );
    return SubstrateSubmitableTransaction.build(
      signature: signature,
      extrinsic: ext,
      version: metadataFields.extrinsicInfo.version,
      callBytes: callBytes,
    );
  }
}
