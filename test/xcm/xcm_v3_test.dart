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
  final xcmGenerator = _XCMTestGenerator(FortunaPRNG.fromEntropy(rand));
  final pallet =
      metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
  test(
      '${metadata.runtimeVersion().specName} XCM V3. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    for (int i = 0; i < loop; i++) {
      final send = XCMCallPalletSend(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        message: xcmGenerator.createVersionedXcm(
            types: List.generate(
                48, (index) => XCMInstructionType.values.elementAt(index))),
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

class _XCMTestGenerator {
  final FortunaPRNG prng;
  const _XCMTestGenerator(this.prng);
  List<int> generateRandom([int length = 32]) => prng.nextBytes(length);
  bool _generateBool() {
    final r = prng.nextInt(2);
    if (r == 0) return false;
    return true;
  }

  int _generateRandInt(int max) {
    return prng.nextInt(max);
  }

  XCMV3BodyId createBody() {
    XCMV3BodyId? ccreate() {
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
      final bodyId = ccreate();
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

  XCMV3NetworkId? createNetwork({bool allowNull = true}) {
    XCMV3NetworkId? ccreate() {
      final rand = _generateRandInt(XCMNetworkIdType.values.length);
      final type = XCMNetworkIdType.values.elementAt(rand);
      switch (type) {
        case XCMNetworkIdType.rococo:
          return XCMV3Rococo();
        case XCMNetworkIdType.bitcoinCash:
          return XCMV3BitcoinCash();
        case XCMNetworkIdType.byFork:
          return XCMV3ByFork(
              blockHash: generateRandom(), blockNumber: BigInt.one);
        case XCMNetworkIdType.byGenesis:
          return XCMV3ByGenesis(genesis: generateRandom());
        case XCMNetworkIdType.polkadotBulletIn:
          return XCMV3PolkadotBulletIn();
        case XCMNetworkIdType.ethereum:
          return XCMV3Ethereum(chainId: BigInt.one);
        case XCMNetworkIdType.wococo:
          return XCMV3Wococo();
        case XCMNetworkIdType.kusama:
          return XCMV3Kusama();
        case XCMNetworkIdType.polkadot:
          return XCMV3Polkadot();
        default:
      }
      return null;
    }

    // if (allowNull) return null;
    while (true) {
      final network = ccreate();
      if (network != null || allowNull) return network;
    }
  }

  XCMV3Junction createJunction() {
    final r = XCMJunctionType.values
        .elementAt(_generateRandInt(XCMJunctionType.values.length));
    switch (r) {
      case XCMJunctionType.accountId32:
        return XCMV3JunctionAccountId32(
            id: generateRandom(), network: createNetwork());
      case XCMJunctionType.parachain:
        return XCMV3JunctionParaChain(id: 1000);
      case XCMJunctionType.accountIndex64:
        return XCMV3JunctionAccountIndex64(
            index: BigInt.from(100), network: createNetwork());
      case XCMJunctionType.accountKey20:
        return XCMV3JunctionAccountKey20(
            key: generateRandom(20), network: createNetwork());
      case XCMJunctionType.plurality:
        return XCMV3JunctionPlurality(id: createBody(), part: createBodyPart());
      case XCMJunctionType.generalIndex:
        return XCMV3JunctionGeneralIndex(index: BigInt.from(100));
      case XCMJunctionType.onlyChild:
        return XCMV3JunctionOnlyChild();
      case XCMJunctionType.palletInstance:
        return XCMV3JunctionPalletInstance(index: 2);
      case XCMJunctionType.globalConsensus:
        return XCMV3JunctionGlobalConsensus(
            network: createNetwork(allowNull: false)!);
      case XCMJunctionType.generalKey:
        return XCMV3JunctionGeneralKey(length: 32, data: generateRandom());
    }
  }

  XCMV3Junctions createJunctions({int? length}) {
    length ??= _generateRandInt(8);
    return XCMV3Junctions.fromJunctions(
        List.generate(length, (index) => createJunction()));
  }

  XCMV3MultiLocation createLocation() {
    return XCMV3MultiLocation(parents: 1, interior: createJunctions());
  }

  XCMVersionedLocationV3 createXCMVersionedLocationV3() {
    return XCMVersionedLocationV3(location: createLocation());
  }

  XCMV3Fungibility createFung() {
    switch (_generateBool()) {
      case false:
        return XCMV3FungibilityFungible(units: BigInt.from(1000));
      default:
        final n = _generateRandInt(XCMAssetInstanceType.values.length);
        final type = XCMAssetInstanceType.values.elementAt(n);
        return XCMV3FungibilityNonFungible(
            instance: switch (type) {
          XCMAssetInstanceType.array8 =>
            XCMV3AssetInstanceArray8(datum: generateRandom(8)),
          XCMAssetInstanceType.array4 =>
            XCMV3AssetInstanceArray4(datum: generateRandom(4)),
          XCMAssetInstanceType.array16 =>
            XCMV3AssetInstanceArray16(datum: generateRandom(16)),
          XCMAssetInstanceType.array32 =>
            XCMV3AssetInstanceArray32(datum: generateRandom(32)),
          XCMAssetInstanceType.indexId =>
            XCMV3AssetInstanceIndex(index: BigInt.from(100)),
          XCMAssetInstanceType.undefined => XCMV3AssetInstanceUndefined(),
        });
    }
  }

  XCMV3MultiAsset createAsset() {
    return XCMV3MultiAsset(
        id: XCMV3AssetIdConcrete(location: createLocation()),
        fun: createFung());
  }

  XCMV3MultiAssets createAssets() {
    final int length = _generateRandInt(5);
    return XCMV3MultiAssets(
        assets: List.generate(length, (index) => createAsset()));
  }

  SubstrateWeightV2 createWeight() {
    return SubstrateWeightV2(
        refTime: BigInt.from(10000), proofSize: BigInt.from(100));
  }

  XCMV3MultiAssetFilter createFilterAsset() {
    return XCMV3MultiAssetFilterWild(
        asset: XCMV3WildMultiAssetAllOf(
            id: createAsset().id, fun: XCMV3WildFungibilityFungible()));
  }

  XCMV3Response createResponse() {
    final r = _generateRandInt(XCMV3ResponseType.values.length);
    final t = XCMV3ResponseType.values.elementAt(r);
    switch (t) {
      case XCMV3ResponseType.assets:
        return XCMV3ResponseAssets(assets: createAssets());
      case XCMV3ResponseType.dispatchResult:
        return XCMV3ResponseDispatchResult(error: createMybeErrorCode());
      case XCMV3ResponseType.executionResult:
        final error = createError().error;
        return XCMV3ResponseExecutionResult(
            error: error, index: error == null ? null : 1);
      case XCMV3ResponseType.nullResponse:
        return XCMV3ResponseNull();
      case XCMV3ResponseType.version:
        return XCMV3ResponseVersion(version: 3);
      case XCMV3ResponseType.palletsInfo:
        return XCMV3ResponsePalletsInfo(
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

  XCMV3QueryResponse createQueryResponse() {
    return XCMV3QueryResponse(
        queryId: BigInt.one,
        response: createResponse(),
        maxWeight: createWeight(),
        querier: switch (_generateBool()) {
          false => null,
          true => createLocation()
        });
  }

  XCMV3ExpectError createError() {
    final r = _generateRandInt(XCMV3ErrorType.values.length + 1);
    final type = XCMV3ErrorType.values.elementAtOrNull(r);
    switch (type) {
      case null:
        return XCMV3ExpectError();
      case XCMV3ErrorType.trap:
        return XCMV3ExpectError(
            error: XCMV3ErrorTrap(code: BigInt.from(1)), index: 1);
      case XCMV3ErrorType.weightLimitReached:
        return XCMV3ExpectError(
            error: XCMV3ErrorWeightLimitReached(weight: createWeight()),
            index: 2);
      default:
        return XCMV3ExpectError.fromJson({
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
    final r = _generateRandInt(XCMV3MaybeErrorCodeType.values.length);
    final type = XCMV3MaybeErrorCodeType.values.elementAt(r);
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

  XCMInstructionV3 createInstruction(XCMInstructionType type) {
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV3WithdrawAsset(assets: createAssets()),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV3ReserveAssetDeposited(assets: createAssets()),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV3ReceiveTeleportedAsset(assets: createAssets()),
      XCMInstructionType.queryResponse => createQueryResponse(),
      XCMInstructionType.transferAsset => XCMV3TransferAsset(
          assets: createAssets(), beneficiary: createLocation()),
      XCMInstructionType.transferReserveAsset => XCMV3TransferReserveAsset(
          assets: createAssets(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.transact => XCMV3Transact(
          originKind: XCMV3OriginKindSovereignAccount(),
          requireWeightAtMost: createWeight(),
          call: generateRandom()),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV3HrmpNewChannelOpenRequest(
            sender: 0, maxMessageSize: 1, maxCapacity: 2),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV3HrmpChannelAccepted(recipient: 2),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV3HrmpChannelClosing(sender: 1, initiator: 2, recipient: 3),
      XCMInstructionType.clearOrigin => XCMV3ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV3DescendOrigin(interior: createJunctions()),
      XCMInstructionType.reportError => XCMV3ReportError(
          responseInfo: XCMV3QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(1000),
              maxWeight: createWeight())),
      XCMInstructionType.depositAsset => XCMV3DepositAsset(
          assets: createFilterAsset(), beneficiary: createLocation()),
      XCMInstructionType.depositReserveAsset => XCMV3DepositReserveAsset(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.exchangeAsset => XCMV3ExchangeAsset(
          give: createFilterAsset(), want: createAssets(), maximal: false),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV3InitiateReserveWithdraw(
            assets: createFilterAsset(),
            reserve: createLocation(),
            xcm: createXCM(notIn: [type])),
      XCMInstructionType.initiateTeleport => XCMV3InitiateTeleport(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.reportHolding => XCMV3ReportHolding(
          assets: createFilterAsset(),
          responseInfo: XCMV3QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(12),
              maxWeight: createWeight())),
      XCMInstructionType.buyExecution => XCMV3BuyExecution(
          fees: createAsset(), weightLimit: createWeightLimit()),
      XCMInstructionType.refundSurplus => XCMV3RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV3SetErrorHandler(xcm: createXCM(notIn: [type])),
      XCMInstructionType.setAppendix =>
        XCMV3SetAppendix(xcm: createXCM(notIn: [type])),
      XCMInstructionType.clearError => XCMV3ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV3ClaimAsset(assets: createAssets(), ticket: createLocation()),
      XCMInstructionType.trap => XCMV3Trap(trap: BigInt.from(1)),
      XCMInstructionType.subscribeVersion => XCMV3SubscribeVersion(
          queryId: BigInt.from(1), maxResponseWeight: createWeight()),
      XCMInstructionType.unsubscribeVersion => XCMV3UnsubscribeVersion(),
      XCMInstructionType.burnAsset => XCMV3BurnAsset(assets: createAssets()),
      XCMInstructionType.expectAsset =>
        XCMV3ExpectAsset(assets: createAssets()),
      XCMInstructionType.expectOrigin =>
        XCMV3ExpectOrigin(location: createLocation()),
      XCMInstructionType.expectError => createError(),
      XCMInstructionType.expectTransactStatus =>
        XCMV3ExpectTransactStatus(code: createMybeErrorCode()),
      XCMInstructionType.queryPallet => XCMV3QueryPallet(
          moduleName: "mrtnetwork".codeUnits,
          responseInfo: XCMV3QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(1),
              maxWeight: createWeight())),
      XCMInstructionType.expectPallet => XCMV3ExpectPallet(
          index: 0,
          name: "mrtnetwork".codeUnits,
          moduleName: "mrtnetwork".codeUnits,
          crateMajor: 1,
          minCrateMinor: 1),
      XCMInstructionType.reportTransactStatus => XCMV3ReportTransactStatus(
          responseInfo: XCMV3QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.zero,
              maxWeight: createWeight())),
      XCMInstructionType.clearTransactStatus => XCMV3ClearTransactStatus(),
      XCMInstructionType.universalOrigin => XCMV3UniversalOrigin(
          origin: createJunctions().junctions.firstOrNull ??
              XCMV3JunctionParaChain(id: 1)),
      XCMInstructionType.exportMessage => XCMV3ExportMessage(
          network: createNetwork(allowNull: false)!,
          destination: createJunctions(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.lockAsset =>
        XCMV3LockAsset(asset: createAsset(), unlocker: createLocation()),
      XCMInstructionType.unlockAsset =>
        XCMV3UnlockAsset(asset: createAsset(), target: createLocation()),
      XCMInstructionType.noteUnlockable =>
        XCMV3NoteUnlockable(asset: createAsset(), owner: createLocation()),
      XCMInstructionType.requestUnlock =>
        XCMV3RequestUnlock(asset: createAsset(), locker: createLocation()),
      XCMInstructionType.setFeesMode => XCMV3SetFeesMode(jitWithdraw: false),
      XCMInstructionType.setTopic => XCMV3SetTopic(topic: generateRandom()),
      XCMInstructionType.clearTopic => XCMV3ClearTopic(),
      XCMInstructionType.aliasOrigin =>
        XCMV3AliasOrigin(origin: createLocation()),
      XCMInstructionType.unpaidExecution =>
        XCMV3UnpaidExecution(weightLimit: createWeightLimit()),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 3")
    };
  }

  XCMV3 createXCM(
      {required List<XCMInstructionType> notIn,
      List<XCMInstructionType>? instructionIn}) {
    if (instructionIn != null) {
      instructionIn.remove(XCMInstructionType.queryHolding);
      return XCMV3(
          instructions:
              instructionIn.map((e) => createInstruction(e)).toList());
    }
    List<XCMInstructionType> types = [];
    while (types.length < 3) {
      final type = XCMInstructionType.values.elementAt(_generateRandInt(48));
      if (type == XCMInstructionType.queryHolding) continue;
      if (notIn.contains(type)) continue;
      types.add(type);
    }
    return XCMV3(instructions: types.map((e) => createInstruction(e)).toList());
  }

  XCMVersionedXCM createVersionedXcm({List<XCMInstructionType>? types}) {
    return XCMVersionedXCMV3(xcm: createXCM(notIn: [], instructionIn: types));
  }
}
