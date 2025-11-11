import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:test/test.dart';

import '../metadata/metadata_acala_v15.dart';
import '../metadata/metadata_basilisk_v15.dart';

void main() {
  final List<String> metadatas = [metadataBasiliskV15, metadataAcalaV15];
  for (final i in metadatas) {
    final bytes = LayoutConst.optional(LayoutConst.bytes())
        .deserialize(BytesUtils.fromHexString(i));
    final metadata = VersionedMetadata.fromBytes(bytes.value);
    _xcmPalletSend(metadata.toApi());
  }
}

void _xcmPalletSend(MetadataApi metadata) {
  final rand = QuickCrypto.generateRandom();
  final xcmGenerator = _XCMTestGenerate(FortunaPRNG.fromEntropy(rand));

  test(
      '${metadata.runtimeVersion().specName} XCM V2. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    final pallet =
        metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
    for (int i = 0; i < 50; i++) {
      final send = XCMCallPalletSend(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        message: xcmGenerator.createVersionedXcm(
          List.generate(
              28, (index) => XCMInstructionType.values.elementAt(index)),
        ),
      );
      final bytes = send.serializeVariant();
      final decode = XCMCallPallet.deserialize(bytes);
      expect(bytes, decode.serializeVariant());
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

  XCMV2NetworkId? createNetwork({bool allowNull = true}) {
    XCMV2NetworkId? create() {
      final types = [
        XCMNetworkIdType.any,
        XCMNetworkIdType.named,
        XCMNetworkIdType.kusama,
        XCMNetworkIdType.polkadot
      ];
      final rand = _generateRandInt(types.length);
      final type = types.elementAt(rand);
      switch (type) {
        case XCMNetworkIdType.any:
          return XCMV2Any();
        case XCMNetworkIdType.named:
          return XCMV2Named(name: generateRandom(12));
        case XCMNetworkIdType.kusama:
          return XCMV2Kusama();
        case XCMNetworkIdType.polkadot:
          return XCMV2Polkadot();
        default:
      }
      return null;
    }

    while (true) {
      final network = create();
      if (network != null || allowNull) return network;
    }
  }

  XCMV2BodyId createBody() {
    XCMV2BodyId? create() {
      final type = XCMBodyIdType.values
          .elementAt(_generateRandInt(XCMBodyIdType.values.length));
      switch (type) {
        case XCMBodyIdType.administration:
          return XCMV2BodyIdAdministration();
        case XCMBodyIdType.defense:
          return XCMV2BodyIdDefense();
        case XCMBodyIdType.executive:
          return XCMV2BodyIdExecutive();
        case XCMBodyIdType.indexId:
          return XCMV2BodyIdIndex(index: 1);
        case XCMBodyIdType.judical:
          return XCMV2BodyIdJudical();
        case XCMBodyIdType.legislative:
          return XCMV2BodyIdLegislative();
        case XCMBodyIdType.named:
          return XCMV2BodyIdNamed(name: generateRandom(4));
        case XCMBodyIdType.technical:
          return XCMV2BodyIdTechnical();
        case XCMBodyIdType.treasury:
          return XCMV2BodyIdTreasury();
        case XCMBodyIdType.unit:
          return XCMV2BodyIdUnit();
        default:
          return null;
      }
    }

    while (true) {
      final bodyId = create();
      if (bodyId != null) return bodyId;
    }
  }

  XCMV2BodyPart createBodyPart() {
    final type = XCMBodyPartType.values
        .elementAt(_generateRandInt(XCMBodyPartType.values.length));
    switch (type) {
      case XCMBodyPartType.voice:
        return XCMV2BodyPartVoice();
      case XCMBodyPartType.members:
        return XCMV2BodyPartMembers(count: 1);
      case XCMBodyPartType.fraction:
        return XCMV2BodyPartFraction(nom: 1, denom: 2);
      case XCMBodyPartType.atLeastProportion:
        return XCMV2BodyPartAtLeastProportion(nom: 2, denom: 1);
      case XCMBodyPartType.moreThanProportion:
        return XCMV2BodyPartMoreThanProportion(nom: 3, denom: 2);
    }
  }

  XCMV2Junction createJunction() {
    XCMV2Junction? create() {
      final r = XCMJunctionType.values
          .elementAt(_generateRandInt(XCMJunctionType.values.length));
      switch (r) {
        case XCMJunctionType.accountId32:
          return XCMV2JunctionAccountId32(
              id: generateRandom(), network: createNetwork(allowNull: false)!);
        case XCMJunctionType.parachain:
          return XCMV2JunctionParaChain(id: 1000);
        case XCMJunctionType.accountIndex64:
          return XCMV2JunctionAccountIndex64(
              index: BigInt.from(100),
              network: createNetwork(allowNull: false)!);
        case XCMJunctionType.accountKey20:
          return XCMV2JunctionAccountKey20(
              key: generateRandom(20),
              network: createNetwork(allowNull: false)!);
        case XCMJunctionType.plurality:
          return XCMV2JunctionPlurality(
              id: createBody(), part: createBodyPart());
        case XCMJunctionType.generalIndex:
          return XCMV2JunctionGeneralIndex(index: BigInt.from(100));
        case XCMJunctionType.onlyChild:
          return XCMV2JunctionOnlyChild();
        case XCMJunctionType.palletInstance:
          return XCMV2JunctionPalletInstance(index: 2);
        case XCMJunctionType.globalConsensus:
          return null;
        case XCMJunctionType.generalKey:
          return XCMV2JunctionGeneralKey(length: 32, data: generateRandom());
      }
    }

    while (true) {
      final jinction = create();
      if (jinction != null) return jinction;
    }
  }

  XCMV2Junctions createJunctions({int? length}) {
    length ??= _generateRandInt(8);
    return XCMV2Junctions.fromJunctions(
        List.generate(length, (index) => createJunction()));
  }

  XCMV2MultiLocation createLocation() {
    return XCMV2MultiLocation(parents: 1, interior: createJunctions());
  }

  XCMVersionedLocationV2 createXCMVersionedLocationV3() {
    return XCMVersionedLocationV2(location: createLocation());
  }

  XCMV2Fungibility createFung() {
    switch (_generateBool()) {
      case false:
        return XCMV2FungibilityFungible(units: BigInt.from(1000));
      default:
        final n = _generateRandInt(XCMAssetInstanceType.values.length);
        final type = XCMAssetInstanceType.values.elementAt(n);
        return XCMV2FungibilityNonFungible(
            instance: switch (type) {
          XCMAssetInstanceType.array8 =>
            XCMV2AssetInstanceArray8(datum: generateRandom(8)),
          XCMAssetInstanceType.array4 =>
            XCMV2AssetInstanceArray4(datum: generateRandom(4)),
          XCMAssetInstanceType.array16 =>
            XCMV2AssetInstanceArray16(datum: generateRandom(16)),
          XCMAssetInstanceType.array32 =>
            XCMV2AssetInstanceArray32(datum: generateRandom(32)),
          XCMAssetInstanceType.indexId =>
            XCMV2AssetInstanceIndex(index: BigInt.from(100)),
          XCMAssetInstanceType.undefined => XCMV2AssetInstanceUndefined(),
        });
    }
  }

  XCMV2MultiAsset createAsset() {
    return XCMV2MultiAsset(
        id: XCMV2AssetIdConcrete(location: createLocation()),
        fun: createFung());
  }

  XCMV2MultiAssets createAssets() {
    final int length = _generateRandInt(5);
    return XCMV2MultiAssets(
        assets: List.generate(length, (index) => createAsset()));
  }

  BigInt createWeight() {
    return BigInt.from(100);
  }

  XCMV2MultiAssetFilter createFilterAsset() {
    return XCMV2MultiAssetFilterWild(
        asset: XCMV2WildMultiAssetAllOf(
            id: createAsset().id, fun: XCMV2WildFungibilityFungible()));
  }

  XCMV2Response createResponse() {
    final r = _generateRandInt(XCMV2ResponseType.values.length);
    final t = XCMV2ResponseType.values.elementAt(r);
    switch (t) {
      case XCMV2ResponseType.assets:
        return XCMV2ResponseAssets(assets: createAssets());
      case XCMV2ResponseType.executionResult:
        final error = createError();
        return XCMV2ResponseExecutionResult(
            error: error, index: error == null ? null : 1);
      case XCMV2ResponseType.nullResponse:
        return XCMV2ResponseNull();
      case XCMV2ResponseType.version:
        return XCMV2ResponseVersion(version: 3);
    }
  }

  XCMV2QueryResponse createQueryResponse() {
    return XCMV2QueryResponse(
      queryId: BigInt.one,
      response: createResponse(),
      maxWeight: createWeight(),
    );
  }

  XCMV2Error? createError() {
    final r = _generateRandInt(
        XCMV2ErrorType.values.length + (XCMV2ErrorType.values.length ~/ 10));
    final type = XCMV2ErrorType.values.elementAtOrNull(r);
    switch (type) {
      case null:
        return null;
      case XCMV2ErrorType.trap:
        return XCMV2ErrorTrap(code: BigInt.from(1));
      case XCMV2ErrorType.weightLimitReached:
        return XCMV2ErrorWeightLimitReached(weight: createWeight());
      default:
        return XCMV2Error.fromJson({type.type: null});
    }
  }

  XCMV2WeightLimit createWeightLimit() {
    switch (_generateBool()) {
      case false:
        return XCMV2WeightLimitUnlimited();
      default:
        return XCMV2WeightLimitLimited(weight: createWeight());
    }
  }

  XCMInstructionV2 createInstruction(XCMInstructionType type) {
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV2WithdrawAsset(assets: createAssets()),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV2ReserveAssetDeposited(assets: createAssets()),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV2ReceiveTeleportedAsset(assets: createAssets()),
      XCMInstructionType.queryResponse => createQueryResponse(),
      XCMInstructionType.transferAsset => XCMV2TransferAsset(
          assets: createAssets(), beneficiary: createLocation()),
      XCMInstructionType.transferReserveAsset => XCMV2TransferReserveAsset(
          assets: createAssets(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.transact => XCMV2Transact(
          originKind: XCMV2OriginKindSovereignAccount(),
          requireWeightAtMost: createWeight(),
          call: generateRandom()),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV2HrmpNewChannelOpenRequest(
            sender: 0, maxMessageSize: 1, maxCapacity: 2),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV2HrmpChannelAccepted(recipient: 2),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV2HrmpChannelClosing(sender: 1, initiator: 2, recipient: 3),
      XCMInstructionType.clearOrigin => XCMV2ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV2DescendOrigin(interior: createJunctions()),
      XCMInstructionType.reportError => XCMV2ReportError(
          dest: createLocation(),
          queryId: BigInt.from(1000),
          maxResponseWeight: createWeight(),
        ),
      XCMInstructionType.depositAsset => XCMV2DepositAsset(
          assets: createFilterAsset(),
          beneficiary: createLocation(),
          maxAssets: 1),
      XCMInstructionType.depositReserveAsset => XCMV2DepositReserveAsset(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type]),
          maxAssets: 1),
      XCMInstructionType.exchangeAsset =>
        XCMV2ExchangeAsset(give: createFilterAsset(), receive: createAssets()),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV2InitiateReserveWithdraw(
            assets: createFilterAsset(),
            reserve: createLocation(),
            xcm: createXCM(notIn: [type])),
      XCMInstructionType.initiateTeleport => XCMV2InitiateTeleport(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.queryHolding => XCMV2QueryHolding(
          assets: createFilterAsset(),
          dest: createLocation(),
          queryId: BigInt.from(12),
          maxResponseWeight: createWeight()),
      XCMInstructionType.buyExecution => XCMV2BuyExecution(
          fees: createAsset(), weightLimit: createWeightLimit()),
      XCMInstructionType.refundSurplus => XCMV2RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV2SetErrorHandler(xcm: createXCM(notIn: [type])),
      XCMInstructionType.setAppendix =>
        XCMV2SetAppendix(xcm: createXCM(notIn: [type])),
      XCMInstructionType.clearError => XCMV2ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV2ClaimAsset(assets: createAssets(), ticket: createLocation()),
      XCMInstructionType.trap => XCMV2Trap(trap: BigInt.from(1)),
      XCMInstructionType.subscribeVersion => XCMV2SubscribeVersion(
          queryId: BigInt.from(1), maxResponseWeight: createWeight()),
      XCMInstructionType.unsubscribeVersion => XCMV2UnsubscribeVersion(),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 2 ${type.type}")
    };
  }

  XCMV2 createXCM(
      {required List<XCMInstructionType> notIn,
      List<XCMInstructionType>? instructionIn}) {
    if (instructionIn != null) {
      instructionIn.remove(XCMInstructionType.reportHolding);
      return XCMV2(
          instructions:
              instructionIn.map((e) => createInstruction(e)).toList());
    }
    List<XCMInstructionType> types = [];
    while (types.length < 2) {
      final type = XCMInstructionType.values.elementAt(_generateRandInt(28));
      if (type == XCMInstructionType.reportHolding) continue;
      if (notIn.contains(type)) continue;
      types.add(type);
    }
    return XCMV2(instructions: types.map((e) => createInstruction(e)).toList());
  }

  XCMVersionedXCM createVersionedXcm(List<XCMInstructionType>? types) {
    return XCMVersionedXCMV2(xcm: createXCM(notIn: [], instructionIn: types));
  }
}
