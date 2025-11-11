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

void _xcmPalletSend(MetadataApi metadata) {
  final rand = QuickCrypto.generateRandom();
  final xcmGenerator = _XCMTestGenerator(FortunaPRNG.fromEntropy(rand));
  final pallet =
      metadata.palletExists("XcmPallet") ? "XcmPallet" : "PolkadotXcm";
  test(
      '${metadata.runtimeVersion().specName} XCM V4. Entropy ${BytesUtils.toHexString(rand)}',
      () {
    for (int i = 0; i < 5; i++) {
      final send = XCMCallPalletSend(
        dest: xcmGenerator.createXCMVersionedLocationV3(),
        message: xcmGenerator.createVersionedXcm(List.generate(
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
        final a = send.message.xcm.instructions[i];
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

  XCMV4 createXCM(
      {required List<XCMInstructionType> notIn,
      List<XCMInstructionType>? instructionIn}) {
    if (instructionIn != null) {
      instructionIn.remove(XCMInstructionType.queryHolding);
      return XCMV4(
          instructions:
              instructionIn.map((e) => createInstruction(e)).toList());
    }
    List<XCMInstructionType> types = [];
    while (types.length < 5) {
      final r = _generateRandInt(48);
      final type = XCMInstructionType.values.elementAt(r);
      if (type == XCMInstructionType.queryHolding) continue;
      if (notIn.contains(type)) continue;
      types.add(type);
    }
    return XCMV4(instructions: types.map((e) => createInstruction(e)).toList());
  }

  XCMVersionedXCM createVersionedXcm(List<XCMInstructionType>? types) {
    return XCMVersionedXCMV4(xcm: createXCM(notIn: [], instructionIn: types));
  }

  bool _generateBool() {
    final r = prng.nextInt(2);
    if (r == 0) return false;
    return true;
  }

  int _generateRandInt(int max) {
    return prng.nextInt(max);
  }

  XCMV4NetworkId? createNetwork({bool allowNull = true}) {
    XCMV4NetworkId? create() {
      final rand = _generateRandInt(XCMNetworkIdType.values.length);
      final type = XCMNetworkIdType.values.elementAt(rand);
      switch (type) {
        case XCMNetworkIdType.rococo:
          return XCMV4Rococo();
        case XCMNetworkIdType.bitcoinCash:
          return XCMV4BitcoinCash();
        case XCMNetworkIdType.byFork:
          return XCMV4ByFork(
              blockHash: generateRandom(), blockNumber: BigInt.one);
        case XCMNetworkIdType.byGenesis:
          return XCMV4ByGenesis(genesis: generateRandom());
        case XCMNetworkIdType.polkadotBulletIn:
          return XCMV4PolkadotBulletIn();
        case XCMNetworkIdType.ethereum:
          return XCMV4Ethereum(chainId: BigInt.one);
        case XCMNetworkIdType.wococo:
          return XCMV4Wococo();
        case XCMNetworkIdType.kusama:
          return XCMV4Kusama();
        case XCMNetworkIdType.polkadot:
          return XCMV4Polkadot();
        default:
      }
      return null;
    }

    // if (allowNull) return null;
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

  XCMV4Junction createJunction() {
    final r = XCMJunctionType.values
        .elementAt(_generateRandInt(XCMJunctionType.values.length));
    switch (r) {
      case XCMJunctionType.accountId32:
        return XCMV4JunctionAccountId32(
            id: generateRandom(), network: createNetwork());
      case XCMJunctionType.parachain:
        return XCMV4JunctionParaChain(id: 1000);
      case XCMJunctionType.accountIndex64:
        return XCMV4JunctionAccountIndex64(
            index: BigInt.from(100), network: createNetwork());
      case XCMJunctionType.accountKey20:
        return XCMV4JunctionAccountKey20(
            key: generateRandom(20), network: createNetwork());
      case XCMJunctionType.plurality:
        return XCMV4JunctionPlurality(id: createBody(), part: createBodyPart());
      case XCMJunctionType.generalIndex:
        return XCMV4JunctionGeneralIndex(index: BigInt.from(100));
      case XCMJunctionType.onlyChild:
        return XCMV4JunctionOnlyChild();
      case XCMJunctionType.palletInstance:
        return XCMV4JunctionPalletInstance(index: 2);
      case XCMJunctionType.globalConsensus:
        return XCMV4JunctionGlobalConsensus(
            network: createNetwork(allowNull: false)!);
      case XCMJunctionType.generalKey:
        return XCMV4JunctionGeneralKey(length: 32, data: generateRandom());
    }
  }

  XCMV4Junctions createJunctions({int? length}) {
    length ??= _generateRandInt(8);
    return XCMV4Junctions.fromJunctions(
        List.generate(length, (index) => createJunction()));
  }

  XCMV4Location createLocation() {
    return XCMV4Location(parents: 1, interior: createJunctions());
  }

  XCMVersionedLocationV4 createXCMVersionedLocationV3() {
    return XCMVersionedLocationV4(location: createLocation());
  }

  XCMV4Fungibility createFung() {
    switch (_generateBool()) {
      case false:
        return XCMV4FungibilityFungible(units: BigInt.from(1000));
      default:
        final n = _generateRandInt(XCMAssetInstanceType.values.length);
        final type = XCMAssetInstanceType.values.elementAt(n);
        return XCMV4FungibilityNonFungible(
            instance: switch (type) {
          XCMAssetInstanceType.array8 =>
            XCMV4AssetInstanceArray8(datum: generateRandom(8)),
          XCMAssetInstanceType.array4 =>
            XCMV4AssetInstanceArray4(datum: generateRandom(4)),
          XCMAssetInstanceType.array16 =>
            XCMV4AssetInstanceArray16(datum: generateRandom(16)),
          XCMAssetInstanceType.array32 =>
            XCMV4AssetInstanceArray32(datum: generateRandom(32)),
          XCMAssetInstanceType.indexId =>
            XCMV4AssetInstanceIndex(index: BigInt.from(100)),
          XCMAssetInstanceType.undefined => XCMV4AssetInstanceUndefined(),
        });
    }
  }

  XCMV4Asset createAsset() {
    return XCMV4Asset(
        id: XCMV4AssetId(location: createLocation()), fun: createFung());
  }

  XCMV4Assets createAssets() {
    final int length = _generateRandInt(5);
    return XCMV4Assets(assets: List.generate(length, (index) => createAsset()));
  }

  SubstrateWeightV2 createWeight() {
    return SubstrateWeightV2(
        refTime: BigInt.from(10000), proofSize: BigInt.from(100));
  }

  XCMV4AssetFilter createFilterAsset() {
    return XCMV4AssetFilterWild(
        asset: XCMV4WildAssetAllOf(
            id: createAsset().id, fun: XCMV4WildFungibilityFungible()));
  }

  XCMV4Response createResponse() {
    final r = _generateRandInt(XCMV4ResponseType.values.length);
    final t = XCMV4ResponseType.values.elementAt(r);
    switch (t) {
      case XCMV4ResponseType.assets:
        return XCMV4ResponseAssets(assets: createAssets());
      case XCMV4ResponseType.dispatchResult:
        return XCMV4ResponseDispatchResult(error: createMybeErrorCode());
      case XCMV4ResponseType.executionResult:
        final error = createError().error;
        return XCMV4ResponseExecutionResult(
            error: error, index: error == null ? null : 1);
      case XCMV4ResponseType.nullResponse:
        return XCMV4ResponseNull();
      case XCMV4ResponseType.version:
        return XCMV4ResponseVersion(version: 3);
      case XCMV4ResponseType.palletsInfo:
        return XCMV4ResponsePalletsInfo(
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

  XCMV4QueryResponse createQueryResponse() {
    return XCMV4QueryResponse(
        queryId: BigInt.one,
        response: createResponse(),
        maxWeight: createWeight(),
        querier: switch (_generateBool()) {
          false => null,
          true => createLocation()
        });
  }

  XCMV4ExpectError createError() {
    final r = _generateRandInt(XCMV3ErrorType.values.length + 1);
    final type = XCMV3ErrorType.values.elementAtOrNull(r);
    switch (type) {
      case null:
        return XCMV4ExpectError();
      case XCMV3ErrorType.trap:
        return XCMV4ExpectError(
            error: XCMV3ErrorTrap(code: BigInt.from(1)), index: 1);
      case XCMV3ErrorType.weightLimitReached:
        return XCMV4ExpectError(
            error: XCMV3ErrorWeightLimitReached(weight: createWeight()),
            index: 2);
      default:
        return XCMV4ExpectError.fromJson({
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

  XCMInstructionV4 createInstruction(XCMInstructionType type) {
    return switch (type) {
      XCMInstructionType.withdrawAsset =>
        XCMV4WithdrawAsset(assets: createAssets()),
      XCMInstructionType.reserveAssetDeposited =>
        XCMV4ReserveAssetDeposited(assets: createAssets()),
      XCMInstructionType.receiveTeleportedAsset =>
        XCMV4ReceiveTeleportedAsset(assets: createAssets()),
      XCMInstructionType.queryResponse => createQueryResponse(),
      XCMInstructionType.transferAsset => XCMV4TransferAsset(
          assets: createAssets(), beneficiary: createLocation()),
      XCMInstructionType.transferReserveAsset => XCMV4TransferReserveAsset(
          assets: createAssets(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.transact => XCMV4Transact(
          originKind: XCMV3OriginKindSovereignAccount(),
          requireWeightAtMost: createWeight(),
          call: generateRandom()),
      XCMInstructionType.hrmpNewChannelOpenRequest =>
        XCMV4HrmpNewChannelOpenRequest(
            sender: 0, maxMessageSize: 1, maxCapacity: 2),
      XCMInstructionType.hrmpChannelAccepted =>
        XCMV4HrmpChannelAccepted(recipient: 2),
      XCMInstructionType.hrmpChannelClosing =>
        XCMV4HrmpChannelClosing(sender: 1, initiator: 2, recipient: 3),
      XCMInstructionType.clearOrigin => XCMV4ClearOrigin(),
      XCMInstructionType.descendOrigin =>
        XCMV4DescendOrigin(interior: createJunctions()),
      XCMInstructionType.reportError => XCMV4ReportError(
          responseInfo: XCMV4QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(1000),
              maxWeight: createWeight())),
      XCMInstructionType.depositAsset => XCMV4DepositAsset(
          assets: createFilterAsset(), beneficiary: createLocation()),
      XCMInstructionType.depositReserveAsset => XCMV4DepositReserveAsset(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.exchangeAsset => XCMV4ExchangeAsset(
          give: createFilterAsset(), want: createAssets(), maximal: false),
      XCMInstructionType.initiateReserveWithdraw =>
        XCMV4InitiateReserveWithdraw(
            assets: createFilterAsset(),
            reserve: createLocation(),
            xcm: createXCM(notIn: [type])),
      XCMInstructionType.initiateTeleport => XCMV4InitiateTeleport(
          assets: createFilterAsset(),
          dest: createLocation(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.reportHolding => XCMV4ReportHolding(
          assets: createFilterAsset(),
          responseInfo: XCMV4QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(12),
              maxWeight: createWeight())),
      XCMInstructionType.buyExecution => XCMV4BuyExecution(
          fees: createAsset(), weightLimit: createWeightLimit()),
      XCMInstructionType.refundSurplus => XCMV4RefundSurplus(),
      XCMInstructionType.setErrorHandler =>
        XCMV4SetErrorHandler(xcm: createXCM(notIn: [type])),
      XCMInstructionType.setAppendix =>
        XCMV4SetAppendix(xcm: createXCM(notIn: [type])),
      XCMInstructionType.clearError => XCMV4ClearError(),
      XCMInstructionType.claimAsset =>
        XCMV4ClaimAsset(assets: createAssets(), ticket: createLocation()),
      XCMInstructionType.trap => XCMV4Trap(trap: BigInt.from(1)),
      XCMInstructionType.subscribeVersion => XCMV4SubscribeVersion(
          queryId: BigInt.from(1), maxResponseWeight: createWeight()),
      XCMInstructionType.unsubscribeVersion => XCMV4UnsubscribeVersion(),
      XCMInstructionType.burnAsset => XCMV4BurnAsset(assets: createAssets()),
      XCMInstructionType.expectAsset =>
        XCMV4ExpectAsset(assets: createAssets()),
      XCMInstructionType.expectOrigin =>
        XCMV4ExpectOrigin(location: createLocation()),
      XCMInstructionType.expectError => createError(),
      XCMInstructionType.expectTransactStatus =>
        XCMV4ExpectTransactStatus(code: createMybeErrorCode()),
      XCMInstructionType.queryPallet => XCMV4QueryPallet(
          moduleName: "mrtnetwork".codeUnits,
          responseInfo: XCMV4QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.from(1),
              maxWeight: createWeight())),
      XCMInstructionType.expectPallet => XCMV4ExpectPallet(
          index: 0,
          name: "mrtnetwork".codeUnits,
          moduleName: "mrtnetwork".codeUnits,
          crateMajor: 1,
          minCrateMinor: 1),
      XCMInstructionType.reportTransactStatus => XCMV4ReportTransactStatus(
          responseInfo: XCMV4QueryResponseInfo(
              destination: createLocation(),
              queryId: BigInt.zero,
              maxWeight: createWeight())),
      XCMInstructionType.clearTransactStatus => XCMV4ClearTransactStatus(),
      XCMInstructionType.universalOrigin => XCMV4UniversalOrigin(
          origin: createJunctions().junctions.firstOrNull ??
              XCMV4JunctionParaChain(id: 1)),
      XCMInstructionType.exportMessage => XCMV4ExportMessage(
          network: createNetwork(allowNull: false)!,
          destination: createJunctions(),
          xcm: createXCM(notIn: [type])),
      XCMInstructionType.lockAsset =>
        XCMV4LockAsset(asset: createAsset(), unlocker: createLocation()),
      XCMInstructionType.unlockAsset =>
        XCMV4UnlockAsset(asset: createAsset(), target: createLocation()),
      XCMInstructionType.noteUnlockable =>
        XCMV4NoteUnlockable(asset: createAsset(), owner: createLocation()),
      XCMInstructionType.requestUnlock =>
        XCMV4RequestUnlock(asset: createAsset(), locker: createLocation()),
      XCMInstructionType.setFeesMode => XCMV4SetFeesMode(jitWithdraw: false),
      XCMInstructionType.setTopic => XCMV4SetTopic(topic: generateRandom()),
      XCMInstructionType.clearTopic => XCMV4ClearTopic(),
      XCMInstructionType.aliasOrigin =>
        XCMV4AliasOrigin(origin: createLocation()),
      XCMInstructionType.unpaidExecution =>
        XCMV4UnpaidExecution(weightLimit: createWeightLimit()),
      _ => throw DartSubstratePluginException(
          "Unsuported xcm instruction by version 4")
    };
  }
}
