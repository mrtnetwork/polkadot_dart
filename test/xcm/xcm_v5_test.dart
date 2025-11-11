import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:test/test.dart';

import '../metadata/metadata_kusama_asset_hub_v14.dart';
import '../metadata/metadata_kusama_asset_hub_v15.dart';
import '../metadata/metadata_kusama_v14.dart';
import '../metadata/metadata_kusama_v15.dart';
import '../metadata/metadata_polkadot_asset_hub_v15.dart';
import '../metadata/metadata_polkadot_v15.dart';

void main() {
  final List<String> metadatas = [
    metadataKusamaV14,
    metadataKusamaV15,
    metadataPolkadotV15,
    metadataPolkadotAssetHubV15,
    metadataKusamaAssetHubV14,
    metadataKusamaAssetHubV15,
  ];
  for (final i in metadatas) {
    final bytes = LayoutConst.optional(LayoutConst.bytes())
        .deserialize(BytesUtils.fromHexString(i));
    final metadata = VersionedMetadata.fromBytes(bytes.value);
    _xcmPalletSend(metadata.toApi());
  }
}

void _xcmPalletSend(MetadataApi metadata, {int loop = 5}) {
  final rand = QuickCrypto.generateRandom();
  final xcmGenerator = _XCMTestGenerate(FortunaPRNG.fromEntropy(rand));

  test(
      '${metadata.runtimeVersion().specName} XCM Send V5. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    for (int i = 0; i < loop; i++) {
      final send = XCMCallPalletSend(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        message: xcmGenerator.createVersionedXcm(List.generate(
            48, (index) => XCMInstructionType.values.elementAt(index))),
      );
      final bytes = send.serializeVariant();
      final decode = XCMCallPallet.deserialize(bytes);
      expect(decode.serializeVariant(), bytes);
      final encode = metadata.encodeCall(
          palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));
      final decodeCall = metadata.decodeCall(encode,
          params: LookupDecodeParams(bytesAsHex: false));
      final fromJson = XCMCallPalletSend.fromJson(decodeCall.data);
      expect(fromJson.serializeVariant(), encode.sublist(1));
      expect(fromJson.toJson(), decodeCall.data);
      expect(decode.toJson(), decodeCall.data);
      for (int i = 0; i < fromJson.message.xcm.instructions.length; i++) {
        final a = send.message.xcm.instructions[i].cast();
        final b = fromJson.message.xcm.instructions[i];
        expect(a, b);
      }
    }
  });

  test(
      '${metadata.runtimeVersion().specName} XCM V5 / Transfer Assets Using Type And Then. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    final teleport = XCMCallPalletTransferAssetsUsingTypeAndThen(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        assets: xcmGenerator.createVersionedAssets(),
        assetsTransferType: xcmGenerator.createTransferType(),
        customXcmOnDest: xcmGenerator.createVersionedXcm(null),
        feesTransferType: xcmGenerator.createTransferType(),
        remoteFeesId: xcmGenerator.createAsset().id.asVersioned(),
        version: XCMVersion.v5,
        weightLimit: xcmGenerator.createWeightLimit());
    final bytes = teleport.serializeVariant();
    final decode = XCMCallPallet.deserialize(bytes);
    expect(decode.serializeVariant(), bytes);
    final encode = metadata.encodeCall(
        palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));
    final decodeCall = metadata.decodeCall(encode,
        params: LookupDecodeParams(bytesAsHex: false));
    final fromJson =
        XCMCallPalletTransferAssetsUsingTypeAndThen.fromJson(decodeCall.data);
    expect(fromJson.serializeVariant(), encode.sublist(1));
    expect(fromJson.toJson(), decodeCall.data);
  });
  // return;
  test(
      '${metadata.runtimeVersion().specName} XCM V5 / Teleport assets. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    final teleport = XCMCallPalletTeleportAssets(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        assets: xcmGenerator.createVersionedAssets(),
        beneficiary: xcmGenerator.createXCMVersionedLocationV3(),
        feeAssetItem: 0);
    final bytes = teleport.serializeVariant();
    final encode = metadata.encodeCall(
        palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));

    final decodeCall = metadata.decodeCall(encode,
        params: LookupDecodeParams(bytesAsHex: false));
    final fromJson = XCMCallPalletTeleportAssets.fromJson(decodeCall.data);
    expect(fromJson.serializeVariant(), encode.sublist(1));
    expect(fromJson.toJson(), decodeCall.data);
    final decode = XCMCallPallet.deserialize(bytes);
    expect(decode.serializeVariant(), bytes);
  });
  test(
      '${metadata.runtimeVersion().specName}  XCM V5 / limited Teleport assets. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    final teleport = XCMCallPalletLimitedTeleportAssets(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        assets: xcmGenerator.createVersionedAssets(),
        beneficiary: xcmGenerator.createXCMVersionedLocationV3(),
        feeAssetItem: 0,
        version: XCMVersion.v5,
        weightLimit: XCMV3WeightLimitUnlimited());
    final bytes = teleport.serializeVariant();
    final encode = metadata.encodeCall(
        palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));
    final decodeCall = metadata.decodeCall(encode,
        params: LookupDecodeParams(bytesAsHex: false));
    final fromJson =
        XCMCallPalletLimitedTeleportAssets.fromJson(decodeCall.data);
    expect(fromJson.serializeVariant(), encode.sublist(1));
    expect(fromJson.toJson(), decodeCall.data);
    final decode = XCMCallPallet.deserialize(bytes);
    expect(decode.serializeVariant(), bytes);
  });
  test(
      '${metadata.runtimeVersion().specName} XCM V5 / Reserve Teleport assets. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    final teleport = XCMCallPalletReserveTransferAssets(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        assets: xcmGenerator.createVersionedAssets(),
        beneficiary: xcmGenerator.createXCMVersionedLocationV3(),
        feeAssetItem: 0);
    final bytes = teleport.serializeVariant();
    final encode = metadata.encodeCall(
        palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));
    final decodeCall = metadata.decodeCall(encode,
        params: LookupDecodeParams(bytesAsHex: false));
    final fromJson =
        XCMCallPalletReserveTransferAssets.fromJson(decodeCall.data);
    expect(fromJson.serializeVariant(), encode.sublist(1));
    expect(fromJson.toJson(), decodeCall.data);
    final decode = XCMCallPallet.deserialize(bytes);
    expect(decode.serializeVariant(), bytes);
  });

  test(
      '${metadata.runtimeVersion().specName} XCM V5 / Limited reserve Teleport assets . Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    final teleport = XCMCallPalletLimitedReserveTransferAssets(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        assets: xcmGenerator.createVersionedAssets(),
        beneficiary: xcmGenerator.createXCMVersionedLocationV3(),
        feeAssetItem: 0,
        version: XCMVersion.v5,
        weightLimit: XCMV3WeightLimitUnlimited());
    final bytes = teleport.serializeVariant();
    final encode = metadata.encodeCall(
        palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));
    final decodeCall = metadata.decodeCall(encode,
        params: LookupDecodeParams(bytesAsHex: false));
    final fromJson =
        XCMCallPalletLimitedReserveTransferAssets.fromJson(decodeCall.data);
    expect(fromJson.serializeVariant(), encode.sublist(1));
    expect(fromJson.toJson(), decodeCall.data);
    final decode = XCMCallPallet.deserialize(bytes);
    expect(decode.serializeVariant(), bytes);
  });

  test(
      '${metadata.runtimeVersion().specName} XCM V5 / Limited reserve Teleport assets . Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    final teleport = XCMCallPalletClaimAssets(
      assets: xcmGenerator.createVersionedAssets(),
      beneficiary: xcmGenerator.createXCMVersionedLocationV3(),
    );
    final bytes = teleport.serializeVariant();
    final encode = metadata.encodeCall(
        palletNameOrIndex: pallet, value: LookupRawParam(bytes: bytes));
    final decodeCall = metadata.decodeCall(encode,
        params: LookupDecodeParams(bytesAsHex: false));
    final fromJson = XCMCallPalletClaimAssets.fromJson(decodeCall.data);
    expect(fromJson.serializeVariant(), encode.sublist(1));
    expect(fromJson.toJson(), decodeCall.data);
    final decode = XCMCallPallet.deserialize(bytes);
    expect(decode.serializeVariant(), bytes);
  });
}

class _XCMTestGenerate {
  final FortunaPRNG prng;
  const _XCMTestGenerate(this.prng);
  List<int> generateRandom([int length = 32]) => prng.nextBytes(length);

  bool _generateBool() {
    final r = prng.nextInt(2);
    if (r == 0) return false;
    return true;
  }

  int _generateRandInt(int max) {
    return prng.nextInt(max);
  }

  XCMV5NetworkId? createNetwork({bool allowNull = true}) {
    XCMV5NetworkId? create() {
      final rand = _generateRandInt(XCMNetworkIdType.values.length);
      final type = XCMNetworkIdType.values.elementAt(rand);
      switch (type) {
        case XCMNetworkIdType.bitcoinCash:
          return XCMV5BitcoinCash();
        case XCMNetworkIdType.byFork:
          return XCMV5ByFork(
              blockHash: generateRandom(), blockNumber: BigInt.one);
        case XCMNetworkIdType.byGenesis:
          return XCMV5ByGenesis(genesis: generateRandom());
        case XCMNetworkIdType.polkadotBulletIn:
          return XCMV5PolkadotBulletIn();
        case XCMNetworkIdType.ethereum:
          return XCMV5Ethereum(chainId: BigInt.one);
        case XCMNetworkIdType.kusama:
          return XCMV5Kusama();
        case XCMNetworkIdType.polkadot:
          return XCMV5Polkadot();
        default:
      }
      return null;
    }

    while (true) {
      final network = create();
      if (network != null || allowNull) return network;
    }
  }

  XCMV3BodyId createBody() {
    XCMV3BodyId? create() {
      final type = XCMBodyIdType.values
          .elementAt(_generateRandInt(XCMBodyIdType.values.length));
      switch (type) {
        case XCMBodyIdType.administration:
          return XCMV3BodyIdAdministration();
        case XCMBodyIdType.defense:
          return XCMV3BodyIdDefense();
        case XCMBodyIdType.executive:
          return XCMV3BodyIdExecutive();
        case XCMBodyIdType.indexId:
          return XCMV3BodyIdIndex(index: 1);
        case XCMBodyIdType.judical:
          return XCMV3BodyIdJudical();
        case XCMBodyIdType.legislative:
          return XCMV3BodyIdLegislative();
        case XCMBodyIdType.moniker:
          return XCMV3BodyIdMoniker(moniker: generateRandom(4));
        case XCMBodyIdType.technical:
          return XCMV3BodyIdTechnical();
        case XCMBodyIdType.treasury:
          return XCMV3BodyIdTreasury();
        case XCMBodyIdType.unit:
          return XCMV3BodyIdUnit();
        case XCMBodyIdType.named:
          return null;
      }
    }

    while (true) {
      final bodyId = create();
      if (bodyId != null) return bodyId;
    }
  }

  XCMV3BodyPart createBodyPart() {
    final type = XCMBodyPartType.values
        .elementAt(_generateRandInt(XCMBodyPartType.values.length));
    switch (type) {
      case XCMBodyPartType.voice:
        return XCMV3BodyPartVoice();
      case XCMBodyPartType.members:
        return XCMV3BodyPartMembers(count: 1);
      case XCMBodyPartType.fraction:
        return XCMV3BodyPartFraction(nom: 1, denom: 2);
      case XCMBodyPartType.atLeastProportion:
        return XCMV3BodyPartAtLeastProportion(nom: 2, denom: 1);
      case XCMBodyPartType.moreThanProportion:
        return XCMV3BodyPartMoreThanProportion(nom: 3, denom: 2);
    }
  }

  XCMV5Junction createJunction() {
    final r = XCMJunctionType.values
        .elementAt(_generateRandInt(XCMJunctionType.values.length));
    switch (r) {
      case XCMJunctionType.accountId32:
        return XCMV5JunctionAccountId32(
            id: generateRandom(), network: createNetwork());
      case XCMJunctionType.parachain:
        return XCMV5JunctionParaChain(id: 1000);
      case XCMJunctionType.accountIndex64:
        return XCMV5JunctionAccountIndex64(
            index: BigInt.from(100), network: createNetwork());
      case XCMJunctionType.accountKey20:
        return XCMV5JunctionAccountKey20(
            key: generateRandom(20), network: createNetwork());
      case XCMJunctionType.plurality:
        return XCMV5JunctionPlurality(id: createBody(), part: createBodyPart());
      case XCMJunctionType.generalIndex:
        return XCMV5JunctionGeneralIndex(index: BigInt.from(100));
      case XCMJunctionType.onlyChild:
        return XCMV5JunctionOnlyChild();
      case XCMJunctionType.palletInstance:
        return XCMV5JunctionPalletInstance(index: 2);
      case XCMJunctionType.globalConsensus:
        return XCMV5JunctionGlobalConsensus(
            network: createNetwork(allowNull: false)!);
      case XCMJunctionType.generalKey:
        return XCMV5JunctionGeneralKey(length: 32, data: generateRandom());
    }
  }

  XCMV5Junctions createJunctions({int? length}) {
    length ??= _generateRandInt(8);
    return XCMV5Junctions.fromJunctions(
        List.generate(length, (index) => createJunction()));
  }

  XCMV5Location createLocation() {
    return XCMV5Location(parents: 1, interior: createJunctions());
  }

  XCMVersionedLocationV5 createXCMVersionedLocationV3() {
    return XCMVersionedLocationV5(location: createLocation());
  }

  XCMV5Fungibility createFung() {
    switch (_generateBool()) {
      case false:
        return XCMV5FungibilityFungible(units: BigInt.from(1000));
      default:
        final n = _generateRandInt(XCMAssetInstanceType.values.length);
        final type = XCMAssetInstanceType.values.elementAt(n);
        return XCMV5FungibilityNonFungible(
            instance: switch (type) {
          XCMAssetInstanceType.array8 =>
            XCMV5AssetInstanceArray8(datum: generateRandom(8)),
          XCMAssetInstanceType.array4 =>
            XCMV5AssetInstanceArray4(datum: generateRandom(4)),
          XCMAssetInstanceType.array16 =>
            XCMV5AssetInstanceArray16(datum: generateRandom(16)),
          XCMAssetInstanceType.array32 =>
            XCMV5AssetInstanceArray32(datum: generateRandom(32)),
          XCMAssetInstanceType.indexId =>
            XCMV5AssetInstanceIndex(index: BigInt.from(100)),
          XCMAssetInstanceType.undefined => XCMV5AssetInstanceUndefined(),
        });
    }
  }

  XCMV5Asset createAsset() {
    return XCMV5Asset(
        id: XCMV5AssetId(location: createLocation()), fun: createFung());
  }

  XCMV5Assets createAssets() {
    final int length = _generateRandInt(5);
    return XCMV5Assets(assets: List.generate(length, (index) => createAsset()));
  }

  XCMVersionedAssets createVersionedAssets() {
    return XCMVersionedAssetsV5(assets: createAssets());
  }

  XCMTransferType createTransferType() {
    final type = XCMTransferTypeType.values
        .elementAt(_generateRandInt(XCMTransferTypeType.values.length));
    switch (type) {
      case XCMTransferTypeType.teleport:
        return XCMTransferTypeTeleport();
      case XCMTransferTypeType.remoteReserve:
        return XCMTransferTypeRemoteReserve(
            location: createXCMVersionedLocationV3());
      case XCMTransferTypeType.localReserve:
        return XCMTransferTypeLocalReserve();
      case XCMTransferTypeType.destinationReserve:
        return XCMTransferTypeDestinationReserve();
    }
  }

  SubstrateWeightV2 createWeight() {
    return SubstrateWeightV2(
        refTime: BigInt.from(10000), proofSize: BigInt.from(100));
  }

  XCMV5AssetFilter createFilterAsset() {
    return XCMV5AssetFilterWild(
        asset: XCMV5WildAssetAllOf(
            id: createAsset().id, fun: XCMV5WildFungibilityFungible()));
  }

  XCMV5Response createResponse() {
    final r = _generateRandInt(XCMV5ResponseType.values.length);
    final t = XCMV5ResponseType.values.elementAt(r);
    switch (t) {
      case XCMV5ResponseType.assets:
        return XCMV5ResponseAssets(assets: createAssets());
      case XCMV5ResponseType.dispatchResult:
        return XCMV5ResponseDispatchResult(error: createMybeErrorCode());
      case XCMV5ResponseType.executionResult:
        final error = createError().error;
        return XCMV5ResponseExecutionResult(
            error: error, index: error == null ? null : 1);
      case XCMV5ResponseType.nullResponse:
        return XCMV5ResponseNull();
      case XCMV5ResponseType.version:
        return XCMV5ResponseVersion(version: 3);
      case XCMV5ResponseType.palletsInfo:
        return XCMV5ResponsePalletsInfo(
            pallets: List.generate(
          _generateRandInt(3),
          (index) => XCMPalletInfo(
              index: index * 2,
              name: generateRandom(10),
              moduleName: generateRandom(20),
              major: index + 1,
              minor: index + 2,
              patch: index + 3),
        ));
    }
  }

  XCMV5QueryResponse createQueryResponse() {
    return XCMV5QueryResponse(
        queryId: BigInt.one,
        response: createResponse(),
        maxWeight: createWeight(),
        querier: switch (_generateBool()) {
          false => null,
          true => createLocation()
        });
  }

  XCMV5ExpectError createError() {
    final r = _generateRandInt(XCMV5ErrorType.values.length + 1);
    final type = XCMV5ErrorType.values.elementAtOrNull(r);
    switch (type) {
      case null:
        return XCMV5ExpectError();
      case XCMV5ErrorType.trap:
        return XCMV5ExpectError(
            error: XCMV5ErrorTrap(code: BigInt.from(1)), index: 1);
      case XCMV5ErrorType.weightLimitReached:
        return XCMV5ExpectError(
            error: XCMV5ErrorWeightLimitReached(weight: createWeight()),
            index: 2);
      default:
        return XCMV5ExpectError.fromJson({
          XCMInstructionType.expectError.type: {
            "Some": [
              2,
              {type.type: null}
            ]
          }
        });
    }
  }

  XCMV3MaybeErrorCode createMybeErrorCode() {
    final type = XCMV3MaybeErrorCodeType.values
        .elementAt(_generateRandInt(XCMV3MaybeErrorCodeType.values.length));
    switch (type) {
      case XCMV3MaybeErrorCodeType.success:
        return XCMV3MaybeErrorCodeSuccess();
      case XCMV3MaybeErrorCodeType.error:
        return XCMV3MaybeErrorCodeError(
            error: generateRandom(_generateRandInt(128)));
      case XCMV3MaybeErrorCodeType.truncatedError:
        return XCMV3MaybeErrorCodeTruncatedError(
            error: generateRandom(_generateRandInt(128)));
    }
  }

  XCMV3WeightLimit createWeightLimit() {
    switch (_generateBool()) {
      case false:
        return XCMV3WeightLimitUnlimited();
      default:
        return XCMV3WeightLimitLimited(weight: createWeight());
    }
  }

  XCMInstructionV5 createInstruction(XCMInstructionType type) {
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV5WithdrawAsset(assets: createAssets()),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV5ReserveAssetDeposited(assets: createAssets()),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV5ReceiveTeleportedAsset(assets: createAssets()),
      XCMInstructionType.queryResponse => createQueryResponse(),
      XCMInstructionType.transferAsset => XCMV5TransferAsset(
          assets: createAssets(), beneficiary: createLocation()),
      XCMInstructionType.transferReserveAsset => XCMV5TransferReserveAsset(
          assets: createAssets(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.transact => XCMV5Transact(
          originKind: XCMV3OriginKindSovereignAccount(),
          fallBackMaxWeight: createWeight(),
          call: generateRandom()),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV5HrmpNewChannelOpenRequest(
            sender: 0, maxMessageSize: 1, maxCapacity: 2),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV5HrmpChannelAccepted(recipient: 2),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV5HrmpChannelClosing(sender: 1, initiator: 2, recipient: 3),
      XCMInstructionType.clearOrigin => XCMV5ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV5DescendOrigin(interior: createJunctions()),
      XCMInstructionType.reportError => XCMV5ReportError(
          responseInfo: XCMV5QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(1000),
              maxWeight: createWeight())),
      XCMInstructionType.depositAsset => XCMV5DepositAsset(
          assets: createFilterAsset(), beneficiary: createLocation()),
      XCMInstructionType.depositReserveAsset => XCMV5DepositReserveAsset(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.exchangeAsset => XCMV5ExchangeAsset(
          give: createFilterAsset(), want: createAssets(), maximal: false),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV5InitiateReserveWithdraw(
            assets: createFilterAsset(),
            reserve: createLocation(),
            xcm: createXCM(notIn: [type])),
      XCMInstructionType.initiateTeleport => XCMV5InitiateTeleport(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.reportHolding => XCMV5ReportHolding(
          assets: createFilterAsset(),
          responseInfo: XCMV5QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(12),
              maxWeight: createWeight())),
      XCMInstructionType.buyExecution => XCMV5BuyExecution(
          fees: createAsset(), weightLimit: createWeightLimit()),
      XCMInstructionType.refundSurplus => XCMV5RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV5SetErrorHandler(xcm: createXCM(notIn: [type])),
      XCMInstructionType.setAppendix =>
        XCMV5SetAppendix(xcm: createXCM(notIn: [type])),
      XCMInstructionType.clearError => XCMV5ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV5ClaimAsset(assets: createAssets(), ticket: createLocation()),
      XCMInstructionType.trap => XCMV5Trap(trap: BigInt.from(1)),
      XCMInstructionType.subscribeVersion => XCMV5SubscribeVersion(
          queryId: BigInt.from(1), maxResponseWeight: createWeight()),
      XCMInstructionType.unsubscribeVersion => XCMV5UnsubscribeVersion(),
      XCMInstructionType.burnAsset => XCMV5BurnAsset(assets: createAssets()),
      XCMInstructionType.expectAsset =>
        XCMV5ExpectAsset(assets: createAssets()),
      XCMInstructionType.expectOrigin =>
        XCMV5ExpectOrigin(location: createLocation()),
      XCMInstructionType.expectError => createError(),
      XCMInstructionType.expectTransactStatus =>
        XCMV5ExpectTransactStatus(code: createMybeErrorCode()),
      XCMInstructionType.queryPallet => XCMV5QueryPallet(
          moduleName: "mrtnetwork".codeUnits,
          responseInfo: XCMV5QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(1),
              maxWeight: createWeight())),
      XCMInstructionType.expectPallet => XCMV5ExpectPallet(
          index: 0,
          name: "mrtnetwork".codeUnits,
          moduleName: "mrtnetwork".codeUnits,
          crateMajor: 1,
          minCrateMinor: 1),
      XCMInstructionType.reportTransactStatus => XCMV5ReportTransactStatus(
          responseInfo: XCMV5QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.zero,
              maxWeight: createWeight())),
      XCMInstructionType.clearTransactStatus => XCMV5ClearTransactStatus(),
      XCMInstructionType.universalOrigin => XCMV5UniversalOrigin(
          origin: createJunctions().junctions.firstOrNull ??
              XCMV5JunctionParaChain(id: 1)),
      XCMInstructionType.exportMessage => XCMV5ExportMessage(
          network: createNetwork(allowNull: false)!,
          destination: createJunctions(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.lockAsset =>
        XCMV5LockAsset(asset: createAsset(), unlocker: createLocation()),
      XCMInstructionType.unlockAsset =>
        XCMV5UnlockAsset(asset: createAsset(), target: createLocation()),
      XCMInstructionType.noteUnlockable =>
        XCMV5NoteUnlockable(asset: createAsset(), owner: createLocation()),
      XCMInstructionType.requestUnlock =>
        XCMV5RequestUnlock(asset: createAsset(), locker: createLocation()),
      XCMInstructionType.setFeesMode => XCMV5SetFeesMode(jitWithdraw: false),
      XCMInstructionType.setTopic => XCMV5SetTopic(topic: generateRandom()),
      XCMInstructionType.clearTopic => XCMV5ClearTopic(),
      XCMInstructionType.aliasOrigin =>
        XCMV5AliasOrigin(origin: createLocation()),
      XCMInstructionType.unpaidExecution =>
        XCMV5UnpaidExecution(weightLimit: createWeightLimit()),
      XCMInstructionType.payFees => XCMV5PayFees(asset: createAsset()),
      XCMInstructionType.initiateTransfer => XCMV5InitiateTransfer(
          destination: createLocation(),
          remoteFees:
              XCMV5AssetTransferReserveDeposit(asset: createFilterAsset()),
          preserveOrigin: false,
          assets: [
            XCMV5AssetTransferTeleport(asset: createFilterAsset()),
            XCMV5AssetTransferReserveWithdraw(asset: createFilterAsset()),
          ],
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.executeWithOrigin => XCMV5ExecuteWithOrigin(
          descendantOrigin: switch (_generateBool()) {
            false => null,
            true => createJunctions()
          },
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.setHints => XCMV5SetHints(
            hints: List.generate(
          2,
          (index) => XCMV5HintAssetClaimer(location: createLocation()),
        )),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 5")
    };
  }

  XCMV5 createXCM(
      {required List<XCMInstructionType> notIn,
      List<XCMInstructionType>? instructionIn}) {
    // return XCMV5(instructions: []);
    if (instructionIn != null) {
      instructionIn.remove(XCMInstructionType.queryHolding);
      return XCMV5(
          instructions:
              instructionIn.map((e) => createInstruction(e)).toList());
    }
    List<XCMInstructionType> types = [];
    while (types.length < 3) {
      final type = XCMInstructionType.values
          .elementAt(_generateRandInt(XCMInstructionType.values.length));
      if (type == XCMInstructionType.queryHolding) continue;
      if (notIn.contains(type)) continue;
      types.add(type);
    }
    return XCMV5(instructions: types.map((e) => createInstruction(e)).toList());
  }

  XCMVersionedXCM createVersionedXcm(List<XCMInstructionType>? types) {
    return XCMVersionedXCMV5(xcm: createXCM(notIn: [], instructionIn: types));
  }
}
