import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/ethereum_runtime_rpcs/types.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/networks/constants/evm.dart';

abstract class SubstrateTransferParams {
  const SubstrateTransferParams();
}

/// Represents the result of a dry-run for a substrate transaction.
/// Includes local dry-run execution, fee calculation, and fee query info.
class SubstrateTransactionDryRunResult {
  /// Information about the fee query for this transaction.
  final QueryFeeInfo queryFeeInfo;

  /// Optional result of executing a local dry-run of the call.
  final SubstrateDispatchResult<CallDryRunEffects>? dryRun;

  /// Calculated fee for executing this transaction, if available.
  /// Exists when the fee is either native or when an asset is used
  /// to pay the execution fee and the `assetConversion` API exists.
  final BigInt? fee;

  /// Constructor for a dry-run result.
  const SubstrateTransactionDryRunResult({
    required this.queryFeeInfo,
    required this.dryRun,
    required this.fee,
  });

  /// Converts the dry-run result to JSON for logging or debugging.
  Map<String, dynamic> toJson() {
    return {
      "query_fee_info": queryFeeInfo.serializeJson(),
      "dry_run": dryRun?.toJson(),
      "fee": fee?.toString(),
    };
  }
}

class SubstrateTransferEncodedParams<CALLPALLET extends SubstrateCallPallet>
    extends SubstrateEncodedCallParams {
  final CALLPALLET transfer;

  SubstrateTransferEncodedParams(
      {required this.transfer,
      required super.pallet,
      required super.method,
      required super.bytes});
  Map<String, dynamic> toJson() {
    return {"transfer": transfer.toJson()};
  }
}

class SubstrateXCMTransferEncodedParams<
        CALLPALLET extends SubstrateXCMCallPallet>
    extends SubstrateTransferEncodedParams<CALLPALLET> {
  final SubstrateXCMTransferParams params;
  SubstrateXCMTransferEncodedParams(
      {required super.transfer,
      required super.pallet,
      required super.method,
      required super.bytes,
      required this.params});
  @override
  Map<String, dynamic> toJson() {
    return {"transfer": transfer.toJson()};
  }
}

/// Status of an XCM dry-run simulation.
enum SubstrateTransactionXCMDryRunStatus {
  /// The network supports XCM but dry-run is not supported.
  unsuportedDryRun,

  /// The network is not supported by the plugin API.
  unsuportedNetwork,

  /// The network supports dry-run but xcm payment api is not supported.
  unsuportedXcmPaymentApi,

  /// Dry-run completed successfully.
  complete;

  /// Returns true if the dry-run completed successfully.
  bool get isComplete => this == complete;
}

/// Result of an XCM dry-run simulation.
class SubstrateTransactionXCMDryRunResult {
  /// The XCM dry-run dispatch result.
  /// Null if the network does not support dry-run.
  final SubstrateDispatchResult<XcmDryRunEffects>? xcmDryRun;

  /// Estimated fee from the dry-run.
  /// Null if dry-run failed or the network does not support XCM payment API.
  final SubstrateDispatchResult<BigInt>? weightToFee;

  /// Delivery fees for multi-chain XCM execution when the current network
  /// is a reserve chain and XCM passes through intermediate chains.
  final List<QueryDeleveriesFeeWithAmount> deleveriesFee;

  /// The network used in the dry-run.
  /// Null if the network is not supported by the plugin API.
  final BaseSubstrateNetwork? network;

  /// The status of the dry-run.
  final SubstrateTransactionXCMDryRunStatus status;

  const SubstrateTransactionXCMDryRunResult._({
    this.xcmDryRun,
    this.weightToFee,
    required this.network,
    required this.status,
    required this.deleveriesFee,
  });

  /// Creates a dry-run result for unsupported networks or dry-run.
  factory SubstrateTransactionXCMDryRunResult.unsupported(
    BaseSubstrateNetwork? network, {
    SubstrateTransactionXCMDryRunStatus? status,
  }) {
    return SubstrateTransactionXCMDryRunResult._(
      network: network,
      deleveriesFee: [],
      status: status ??
          (network == null
              ? SubstrateTransactionXCMDryRunStatus.unsuportedNetwork
              : SubstrateTransactionXCMDryRunStatus.unsuportedDryRun),
    );
  }

  /// Creates a fully populated dry-run result.
  factory SubstrateTransactionXCMDryRunResult({
    required SubstrateDispatchResult<XcmDryRunEffects> xcmDryRun,
    required SubstrateDispatchResult<BigInt>? weightToFee,
    required BaseSubstrateNetwork network,
    required SubstrateTransactionXCMDryRunStatus status,
    required List<QueryDeleveriesFeeWithAmount> deleveriesFee,
  }) {
    return SubstrateTransactionXCMDryRunResult._(
      xcmDryRun: xcmDryRun,
      weightToFee: weightToFee,
      deleveriesFee: deleveriesFee,
      network: network,
      status: status,
    );
  }

  /// Converts the dry-run result to JSON for logging or serialization.
  Map<String, dynamic> toJson() {
    return {
      "xcm_dry_run": xcmDryRun?.toJson(),
      "weight_to_fee": weightToFee?.toJson(),
      "status": status.name,
      "deleveries": deleveriesFee.map((e) => e.toJson()).toList(),
      "network": network?.networkName,
    };
  }
}

/// Result of simulating an XCM transaction, including local and external dry-runs.
class SubstrateTransactionXCMSimulateResult {
  /// The dry-run effects of the local (origin) call.
  final SubstrateDispatchResult<CallDryRunEffects> dryRun;

  /// Estimated delivery fees for local execution of the XCM transaction.
  final List<QueryDeleveriesFeeWithAmount> localDeliveryFees;

  /// Dry-run results for any external XCM calls that will be forwarded
  /// to other networks during this transaction.
  final List<SubstrateTransactionXCMDryRunResult> externalXcm;

  /// The status of the dry-run.
  final SubstrateTransactionXCMDryRunStatus status;

  // /// Returns true if the local dry-run was successful and all external
  // /// XCM dry-runs have completed successfully.
  // bool get complete =>
  //     (dryRun.ok?.executionResult.type.isOk ?? false) &&
  //     externalXcm.every(
  //         (e) => e.status == SubstrateTransactionXCMDryRunStatus.complete);

  /// Creates a new XCM simulation result.
  const SubstrateTransactionXCMSimulateResult(
      {required this.dryRun,
      this.externalXcm = const [],
      this.localDeliveryFees = const [],
      required this.status});

  /// Converts the XCM simulation result to JSON for logging, debugging, or serialization.
  Map<String, dynamic> toJson() {
    return {
      "local_dry_run": dryRun.toJson(),
      "dry_runs": externalXcm.map((e) => e.toJson()).toList(),
      "local_delivery_fee": localDeliveryFees.map((e) => e.toJson()).toList(),
    };
  }
}

/// Parameters for a local asset transfer within a Substrate network.
class SubstrateLocalTransferAssetParams extends SubstrateTransferParams {
  /// Asset to transfer, must belong to the origin network.
  /// null means you want to transfer native asset
  final BaseSubstrateNetworkAsset? asset;

  /// Amount to transfer; null transfer_all will be used.
  final BigInt? amount;

  /// Recipient address.
  final BaseSubstrateAddress destinationAddress;

  /// Transfer method (e.g., "transfer", "transfer_all", "transfer_keep_alive").
  final String? method;

  /// Whether to use keep-alive variant; conflicts with [method] throw exception.
  final bool? keepAlive;

  /// Creates parameters for a local transfer.
  const SubstrateLocalTransferAssetParams({
    required this.asset,
    required this.destinationAddress,
    this.keepAlive,
    this.amount,
    this.method,
  });
}

/// Parameters for transferring the native asset on a Substrate network.
class SubstrateNativeAssetTransferParams extends SubstrateTransferParams {
  /// Amount of native asset to transfer; null means full balance.
  final BigInt? amount;

  /// Destination address for the transfer.
  final BaseSubstrateAddress destinationAddress;

  /// Optional transfer method (e.g., "transfer", "transfer_keep_alive").
  final String? method;

  /// Whether to use the keep-alive variant to prevent account reaping.
  final bool? keepAlive;

  /// Creates a new set of parameters for a native asset transfer.
  const SubstrateNativeAssetTransferParams({
    required this.destinationAddress,
    this.keepAlive,
    this.amount,
    this.method,
  });
}

/// Represents a single asset for XCM (cross-chain) transfers.
class SubstrateXCMTransferAsset {
  /// Amount of the asset to transfer (stored as Uint256).
  final BigInt amount;

  /// The network asset being transferred.
  final BaseSubstrateNetworkAsset asset;

  /// Creates a new XCM transfer asset.
  SubstrateXCMTransferAsset({
    required BigInt amount,
    required this.asset,
  })  : amount = amount.asUint256,
        super();

  /// Returns the XCMMultiLocation for a given XCM version.
  XCMMultiLocation getLocation(XCMVersion xcmVersion) {
    final foreignLocation = asset.location?.location;
    if (foreignLocation == null) {
      throw DartSubstratePluginException("Missing asset location");
    }
    return foreignLocation.asVersion(xcmVersion);
  }

  /// Returns the localized asset location for XCM transfers.
  XCMMultiLocation getlocalizedLocation({
    BaseSubstrateNetwork? reserveNetwork,
    XCMMultiLocation? reserveLocation,
    required XCMVersion version,
  }) {
    return asset
        .getlocalizedLocation(
            reserveNetwork: reserveNetwork,
            reserveLocation: reserveLocation,
            version: version)
        .location;
  }

  /// Attempts to get the XCMMultiLocation; returns null if unavailable.
  XCMMultiLocation? tryGetLocation(XCMVersion xcmVersion) {
    try {
      return getLocation(xcmVersion);
    } catch (e) {
      return null;
    }
  }

  /// Checks whether the asset has a defined location.
  bool hasLocation() => asset.location != null;

  /// Returns the localized XCM asset ID for this asset.
  XCMAssetId asLocalizedAssetId({
    BaseSubstrateNetwork? reserveNetwork,
    XCMMultiLocation? reserveLocation,
    required XCMVersion xcmVersion,
  }) =>
      asset.getAssetId(
          reserveLocation: reserveLocation,
          reserveNetwork: reserveNetwork,
          version: xcmVersion);

  /// Returns a localized fungible XCM asset.
  XCMAsset aslocalizedFungibleAsset({
    BaseSubstrateNetwork? reserveNetwork,
    XCMMultiLocation? reserveLocation,
    required XCMVersion xcmVersion,
    required BigInt amount,
  }) =>
      XCMAsset.fungibleAsset(
          amount: amount,
          id: asLocalizedAssetId(
              reserveLocation: reserveLocation,
              reserveNetwork: reserveNetwork,
              xcmVersion: xcmVersion));

  /// Returns a versioned localized fungible XCM asset.
  XCMVersionedAsset aslocalizedFungibleVersionedAsset({
    BaseSubstrateNetwork? reserveNetwork,
    XCMMultiLocation? reserveLocation,
    required XCMVersion xcmVersion,
    required BigInt amount,
  }) =>
      aslocalizedFungibleAsset(
              reserveNetwork: reserveNetwork,
              reserveLocation: reserveLocation,
              xcmVersion: xcmVersion,
              amount: amount)
          .asVersioned();

  /// Converts this asset to a localized fungible asset using its amount.
  XCMAsset tolocalizedFungibleAsset({
    BaseSubstrateNetwork? reserveNetwork,
    XCMMultiLocation? reserveLocation,
    required XCMVersion xcmVersion,
  }) =>
      aslocalizedFungibleAsset(
          reserveLocation: reserveLocation,
          reserveNetwork: reserveNetwork,
          amount: amount,
          xcmVersion: xcmVersion);

  /// Converts this asset to a versioned localized fungible asset.
  XCMVersionedAsset tolocalizedFungibleVersionedAsset({
    BaseSubstrateNetwork? reserveNetwork,
    XCMMultiLocation? reserveLocation,
    required XCMVersion xcmVersion,
  }) =>
      tolocalizedFungibleAsset(
              reserveLocation: reserveLocation,
              reserveNetwork: reserveNetwork,
              xcmVersion: xcmVersion)
          .asVersioned();
}

/// Parameters for executing an XCM (Cross-Consensus Message) transfer on a Substrate-based network.
///
/// This class extends [SubstrateTransferParams] and adds the fields and validation
/// required for multi-asset, cross-chain transfers within the Substrate ecosystem.
class SubstrateXCMTransferParams extends SubstrateTransferParams {
  /// List of assets to transfer.
  ///
  /// All assets must originate from the same reserve network and share
  /// a common reserve location.
  final List<SubstrateXCMTransferAsset> assets;

  /// The destination network where the assets will be received.
  ///
  /// Must be a valid target network that can be reached from the
  /// origin’s system role (e.g., relay → parachain or parachain → relay).
  final BaseSubstrateNetwork destinationNetwork;

  /// The recipient’s address on the destination network.
  ///
  /// for non-EthereumNetwork Must be a valid SS58-encoded Substrate address corresponding to
  /// the destination network.
  final BaseSubstrateAddress destinationAddress;

  /// Index of the asset used to pay transfer fees on the destination network.
  ///
  /// If not specified, the first fee-eligible asset is used automatically.
  final int feeIndex;

  /// The XCM weight limit configuration for the destination.
  ///
  /// Determines the maximum computational weight that can be used
  /// for XCM message execution. See [XCMV3WeightLimit] for supported versions.
  final WeightLimit? destinationWeightLimit;

  /// Computed list of asset locations (multi-locations).
  ///
  /// Each corresponds to the canonical on-chain representation of an asset’s location.
  final List<XCMMultiLocation> locations;

  /// The network from which the transfer originates.
  final BaseSubstrateNetwork origin;

  /// Indicates whether the transfer includes the relay chain’s native asset.
  final bool hasRelayAsset;

  final bool isLocalAssets;

  /// Creates a validated instance of [SubstrateXCMTransferParams].
  ///
  /// Throws a [DartSubstratePluginException] if:
  ///  - No assets are provided.
  ///  - The fee index is out of range.
  ///  - Any asset lacks a valid location.
  ///  - Duplicate or external asset locations are detected.
  ///  - Assets do not share the same reserve location.
  factory SubstrateXCMTransferParams({
    /// The assets to transfer. Must all share the same reserve.
    required List<SubstrateXCMTransferAsset> assets,

    /// The target network where the assets will be received.
    required BaseSubstrateNetwork destinationNetwork,

    /// The destination address (valid Substrate SS58 format).
    required BaseSubstrateAddress destinationAddress,

    /// The network from which the transfer originates.
    required BaseSubstrateNetwork origin,

    /// Optional XCM weight limit for destination execution.
    WeightLimit? destinationWeightLimit,

    /// Optional index of the asset to pay destination fees with.
    int? feeIndex,
  }) {
    if (assets.isEmpty) {
      throw DartSubstratePluginException(
          "At least one asset required for transfer.");
    }
    if (feeIndex != null &&
        (feeIndex.isNegative || feeIndex >= assets.length)) {
      throw DartSubstratePluginException("Fee index out of range.");
    }
    feeIndex ??= assets.indexWhere((e) => e.asset.isFeeToken);
    if (feeIndex.isNegative) feeIndex = 0;
    List<XCMMultiLocation> locations = [];
    for (final i in assets) {
      if (!i.hasLocation()) {
        throw DartSubstratePluginException("Asset location is missing.",
            details: {"asset": i.asset.name ?? i.asset.symbol});
      }
      locations.add(i.getlocalizedLocation(
          version: origin.defaultXcmVersion, reserveNetwork: origin));
    }
    if (locations.toSet().length != locations.length) {
      throw DartSubstratePluginException(
          "Duplicate asset not allowed. multiple assets share the same location.");
    }
    if (locations.any((e) => e.isExternalLocation())) {
      throw DartSubstratePluginException(
          "External asset transfers are not supported in this version.");
    }

    final parents = locations.map((e) => e.parents).toSet();
    final paras = locations.map((e) => e.getParachain()?.id).toSet();
    if (parents.length != 1 || paras.length != 1) {
      throw DartSubstratePluginException(
          "All assets in a transfer must share the same reserve location.");
    }
    bool hasRelayAsset = false;
    if (origin.role.isRelay) {
      hasRelayAsset = locations.any((e) => e.isZeroParentsAndHere());
    } else {
      hasRelayAsset = locations.any((e) => e.isOneParentsAndHere());
    }
    bool isLocalAssets = locations.every((e) => e.isZeroParents());

    return SubstrateXCMTransferParams._(
        destinationNetwork: destinationNetwork,
        hasRelayAsset: hasRelayAsset,
        isLocalAssets: isLocalAssets,
        assets: assets,
        destinationAddress: destinationAddress,
        feeIndex: feeIndex,
        locations: locations,
        destinationWeightLimit: destinationWeightLimit,
        origin: origin);
  }
  SubstrateXCMTransferParams._({
    required this.destinationNetwork,
    required this.assets,
    required this.destinationAddress,
    required List<XCMMultiLocation> locations,
    this.destinationWeightLimit,
    required this.feeIndex,
    required this.origin,
    required this.isLocalAssets,
    required this.hasRelayAsset,
  }) : locations = locations.immutable;
}

class QueryDeleveriesFeeWithAmount {
  final SubstrateDispatchResult<XCMVersionedAssets>? result;
  final List<QueryDeleveriesFeeAmount> amounts;
  const QueryDeleveriesFeeWithAmount._({this.result, this.amounts = const []});
  factory QueryDeleveriesFeeWithAmount.unsuportedApi() {
    return QueryDeleveriesFeeWithAmount._();
  }
  factory QueryDeleveriesFeeWithAmount(
      {required SubstrateDispatchResult<XCMVersionedAssets> result,
      List<QueryDeleveriesFeeAmount> amounts = const []}) {
    return QueryDeleveriesFeeWithAmount._(result: result, amounts: amounts);
  }
  Map<String, dynamic> toJson() {
    return {"result": result?.toJson()};
  }

  bool get isSuccess => result?.success ?? false;
}

class QueryDeleveriesFeeAmount {
  final BigInt amount;
  final BaseSubstrateNetworkAsset? asset;
  const QueryDeleveriesFeeAmount({required this.amount, required this.asset});

  Map<String, dynamic> toJson() {
    return {"amount": amount, "asset": asset?.toJson()};
  }
}

enum SubstrateXCMTransctionTrackerStatus {
  /// find in block
  success,

  /// find in block but failed.
  failed,

  /// not found in block
  notFound,

  /// error when extraction deposit message ids or etc.
  error;
}

class SubstrateXCMTransctionTrackerResult {
  final SubstrateXCMTransctionTrackerStatus status;
  final List<SubstrateAssetDepositEvent> deposits;
  final SubstrateGroupEvents? blockEvent;
  final int? blockNumber;
  const SubstrateXCMTransctionTrackerResult(
      {this.deposits = const [],
      required this.status,
      this.blockNumber,
      this.blockEvent});
  Map<String, dynamic> toJson() {
    return {
      "status": status.name,
      "deposits": deposits.map((e) => e.toJson()).toList(),
      "block_events": blockEvent?.events.map((e) => e.toJson()).toList(),
      "block_number": blockNumber
    }.notNullValue;
  }
}

enum SubstrateAggregateMessageOriginType {
  here("Here"),
  parent("Parent"),
  sibling("Sibling"),
  ump("Ump"),
  unknown("Unknown");

  final String type;
  const SubstrateAggregateMessageOriginType(this.type);
  static SubstrateAggregateMessageOriginType fromType(
      Map<String, dynamic>? json) {
    final type = json?.keys.firstOrNull;
    return values.firstWhere((e) => e.type == type,
        orElse: () => SubstrateAggregateMessageOriginType.unknown);
  }
}

abstract class SubstrateAggregateMessageOrigin {
  final SubstrateAggregateMessageOriginType type;
  const SubstrateAggregateMessageOrigin({required this.type});
  Map<String, dynamic> toJson();
  XCMMultiLocation? get originLocation;
  factory SubstrateAggregateMessageOrigin.fromJson(Map<String, dynamic> json) {
    final type = SubstrateAggregateMessageOriginType.fromType(json);
    return switch (type) {
      SubstrateAggregateMessageOriginType.here =>
        SubstrateAggregateMessageOriginHere(),
      SubstrateAggregateMessageOriginType.parent =>
        SubstrateAggregateMessageOriginParent(),
      SubstrateAggregateMessageOriginType.sibling =>
        SubstrateAggregateMessageOriginSibling.fromJson(json),
      SubstrateAggregateMessageOriginType.ump =>
        SubstrateAggregateMessageOriginUmp.fromJson(json),
      SubstrateAggregateMessageOriginType.unknown =>
        SubstrateAggregateMessageOriginUnknown.fromJson(json),
    };
  }
}

enum SustrateUmpQueueIdType {
  para("Para"),
  unknown("Unknown");

  final String type;
  const SustrateUmpQueueIdType(this.type);
  static SustrateUmpQueueIdType fromType(Map<String, dynamic>? json) {
    final type = json?.keys.firstOrNull;
    return values.firstWhere((e) => e.type == type,
        orElse: () => SustrateUmpQueueIdType.unknown);
  }
}

abstract class SustrateUmpQueueId {
  final SustrateUmpQueueIdType type;
  const SustrateUmpQueueId({required this.type});
  factory SustrateUmpQueueId.fromJson(Map<String, dynamic> json) {
    final type = SustrateUmpQueueIdType.fromType(json);
    return switch (type) {
      SustrateUmpQueueIdType.para => SustrateUmpQueueIdPara.fromJson(json),
      SustrateUmpQueueIdType.unknown => SustrateUmpQueueIdUnknown.fromJson(json)
    };
  }
  Map<String, dynamic> toJson();
  XCMMultiLocation? get originLocation => null;
}

class SustrateUmpQueueIdPara extends SustrateUmpQueueId {
  final int id;
  SustrateUmpQueueIdPara({required this.id})
      : super(type: SustrateUmpQueueIdType.para);
  factory SustrateUmpQueueIdPara.fromJson(Map<String, dynamic> json) {
    return SustrateUmpQueueIdPara(
        id: json.valueAs(SustrateUmpQueueIdType.para.type));
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: id};
  }

  @override
  late final XCMMultiLocation originLocation = XCMMultiLocation.fromVersion(
      parents: 1,
      version: SubstrateNetworkControllerConstants.latestXCMVersion,
      interior: XCMJunctions.fromVersion(
          version: SubstrateNetworkControllerConstants.latestXCMVersion,
          junctions: [
            XCMJunctionParaChain.fromVersion(
              id: id,
              version: SubstrateNetworkControllerConstants.latestXCMVersion,
            )
          ]));
}

class SustrateUmpQueueIdUnknown extends SustrateUmpQueueId {
  final Map<String, dynamic> data;
  const SustrateUmpQueueIdUnknown({required this.data})
      : super(type: SustrateUmpQueueIdType.para);
  factory SustrateUmpQueueIdUnknown.fromJson(Map<String, dynamic> json) {
    return SustrateUmpQueueIdUnknown(data: json);
  }
  @override
  Map<String, dynamic> toJson() {
    return data;
  }
}

class SubstrateAggregateMessageOriginHere
    extends SubstrateAggregateMessageOrigin {
  SubstrateAggregateMessageOriginHere()
      : super(type: SubstrateAggregateMessageOriginType.here);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  late final XCMMultiLocation originLocation = XCMMultiLocation.fromVersion(
      parents: 0,
      version: SubstrateNetworkControllerConstants.latestXCMVersion);
}

class SubstrateAggregateMessageOriginParent
    extends SubstrateAggregateMessageOrigin {
  SubstrateAggregateMessageOriginParent()
      : super(type: SubstrateAggregateMessageOriginType.parent);

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  @override
  late final XCMMultiLocation originLocation = XCMMultiLocation.fromVersion(
      parents: 1,
      version: SubstrateNetworkControllerConstants.latestXCMVersion);
}

class SubstrateAggregateMessageOriginSibling
    extends SubstrateAggregateMessageOrigin {
  final int paraId;
  SubstrateAggregateMessageOriginSibling({required this.paraId})
      : super(type: SubstrateAggregateMessageOriginType.sibling);
  factory SubstrateAggregateMessageOriginSibling.fromJson(
      Map<String, dynamic> json) {
    return SubstrateAggregateMessageOriginSibling(
        paraId: json.valueAs(SubstrateAggregateMessageOriginType.sibling.type));
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: paraId};
  }

  @override
  late final XCMMultiLocation originLocation = XCMMultiLocation.fromVersion(
      parents: 1,
      version: SubstrateNetworkControllerConstants.latestXCMVersion,
      interior: XCMJunctions.fromVersion(
          version: SubstrateNetworkControllerConstants.latestXCMVersion,
          junctions: [
            XCMJunctionParaChain.fromVersion(
                id: paraId,
                version: SubstrateNetworkControllerConstants.latestXCMVersion)
          ]));
}

class SubstrateAggregateMessageOriginUmp
    extends SubstrateAggregateMessageOrigin {
  final SustrateUmpQueueId ump;
  SubstrateAggregateMessageOriginUmp({required this.ump})
      : super(type: SubstrateAggregateMessageOriginType.ump);
  factory SubstrateAggregateMessageOriginUmp.fromJson(
      Map<String, dynamic> json) {
    return SubstrateAggregateMessageOriginUmp(
        ump: SustrateUmpQueueId.fromJson(
            json.valueAs(SubstrateAggregateMessageOriginType.ump.type)));
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: ump.toJson()};
  }

  @override
  XCMMultiLocation? get originLocation => ump.originLocation;
}

class SubstrateAggregateMessageOriginUnknown
    extends SubstrateAggregateMessageOrigin {
  final Map<String, dynamic> data;
  const SubstrateAggregateMessageOriginUnknown({required this.data})
      : super(type: SubstrateAggregateMessageOriginType.unknown);
  factory SubstrateAggregateMessageOriginUnknown.fromJson(
      Map<String, dynamic> json) {
    return SubstrateAggregateMessageOriginUnknown(data: json);
  }
  @override
  Map<String, dynamic> toJson() {
    return data;
  }

  @override
  XCMMultiLocation? get originLocation => null;
}

enum SubstrateProcessMessageErrorType {
  badFormat("BadFormat"),
  corrupt("Corrupt"),
  unsupported("Unsupported"),
  overweight("Overweight"),
  yield("Yield"),
  stackLimitReached("StackLimitReached"),
  unknown("Unknown");

  final String type;
  const SubstrateProcessMessageErrorType(this.type);
  static SubstrateProcessMessageErrorType fromType(Map<String, dynamic>? json) {
    final type = json?.keys.firstOrNull;
    return values.firstWhere((e) => e.type == type,
        orElse: () => SubstrateProcessMessageErrorType.unknown);
  }
}

class SubstrateProcessMessageError {
  final SubstrateProcessMessageErrorType type;
  final SubstrateWeightV2? weight;
  const SubstrateProcessMessageError(
      {required this.type, required this.weight});
  factory SubstrateProcessMessageError.fromJson(Map<String, dynamic> json) {
    final type = SubstrateProcessMessageErrorType.fromType(json);
    SubstrateWeightV2? weight;
    if (type == SubstrateProcessMessageErrorType.overweight) {
      weight = SubstrateWeightV2.fromJson(json.valueAs(type.type));
    }
    return SubstrateProcessMessageError(
        type: SubstrateProcessMessageErrorType.fromType(json), weight: weight);
  }
  Map<String, dynamic> toJson() {
    return {type.type: weight?.toJson()};
  }
}

enum SubstrateXcmErrorType {
  overflow("Overflow"),
  unimplemented("Unimplemented"),
  untrustedReserveLocation("UntrustedReserveLocation"),
  untrustedTeleportLocation("UntrustedTeleportLocation"),
  locationFull("LocationFull"),
  locationNotInvertible("LocationNotInvertible"),
  badOrigin("BadOrigin"),
  invalidLocation("InvalidLocation"),
  assetNotFound("AssetNotFound"),
  failedToTransactAsset("FailedToTransactAsset"),
  notWithdrawable("NotWithdrawable"),
  locationCannotHold("LocationCannotHold"),
  exceedsMaxMessageSize("ExceedsMaxMessageSize"),
  destinationUnsupported("DestinationUnsupported"),
  transport("Transport"),
  unroutable("Unroutable"),
  unknownClaim("UnknownClaim"),
  failedToDecode("FailedToDecode"),
  maxWeightInvalid("MaxWeightInvalid"),
  notHoldingFees("NotHoldingFees"),
  tooExpensive("TooExpensive"),
  trap("Trap"), // has u64 field
  expectationFalse("ExpectationFalse"),
  palletNotFound("PalletNotFound"),
  nameMismatch("NameMismatch"),
  versionIncompatible("VersionIncompatible"),
  holdingWouldOverflow("HoldingWouldOverflow"),
  exportError("ExportError"),
  reanchorFailed("ReanchorFailed"),
  noDeal("NoDeal"),
  feesNotMet("FeesNotMet"),
  lockError("LockError"),
  noPermission("NoPermission"),
  unanchored("Unanchored"),
  notDepositable("NotDepositable"),
  unhandledXcmVersion("UnhandledXcmVersion"),
  weightLimitReached("WeightLimitReached"), // has Weight field
  barrier("Barrier"),
  weightNotComputable("WeightNotComputable"),
  exceedsStackLimit("ExceedsStackLimit"),
  unknown("Unknown");

  final String type;
  const SubstrateXcmErrorType(this.type);

  static SubstrateXcmErrorType fromType(Map<String, dynamic>? json) {
    final type = json?.keys.firstOrNull;
    return values.firstWhere(
      (e) => e.type == type,
      orElse: () => SubstrateXcmErrorType.unknown,
    );
  }
}

class SubstrateXcmError {
  final SubstrateXcmErrorType type;
  final Map<String, dynamic> data;
  const SubstrateXcmError({required this.type, required this.data});
  factory SubstrateXcmError.fromJson(Map<String, dynamic> json) {
    return SubstrateXcmError(
        type: SubstrateXcmErrorType.fromType(json), data: json);
  }
  Map<String, dynamic> toJson() => data;
}

abstract class SubstrateXcmProcessEvent {
  bool get success;
  String get xcmMessageId;
  XCMMultiLocation? get originLocation;
  Map<String, dynamic> toJson();
}

class SubstrateMessageQueueEvent implements SubstrateXcmProcessEvent {
  final String id;
  final SubstrateAggregateMessageOrigin origin;
  final SubstrateWeightV2? weight;
  @override
  final bool success;
  final SubstrateProcessMessageError? error;
  const SubstrateMessageQueueEvent(
      {required this.origin,
      required this.weight,
      required this.success,
      required this.id,
      this.error});
  factory SubstrateMessageQueueEvent.processingFailed(
      Map<String, dynamic> json) {
    return SubstrateMessageQueueEvent(
        id: json.valueAs("id"),
        origin: SubstrateAggregateMessageOrigin.fromJson(
            json.valueEnsureAsMap<String, dynamic>("origin")),
        weight: null,
        success: false,
        error: SubstrateProcessMessageError.fromJson(json.valueAs("error")));
  }
  factory SubstrateMessageQueueEvent.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("ProcessingFailed")) {
      return SubstrateMessageQueueEvent.processingFailed(
          json.valueAs("ProcessingFailed"));
    }
    return SubstrateMessageQueueEvent.processed(json.valueAs("Processed"));
  }
  factory SubstrateMessageQueueEvent.processed(Map<String, dynamic> json) {
    return SubstrateMessageQueueEvent(
        id: json.valueAs("id"),
        origin: SubstrateAggregateMessageOrigin.fromJson(
            json.valueEnsureAsMap<String, dynamic>("origin")),
        weight: SubstrateWeightV2.fromJson(json.valueAs("weight_used")),
        success: json.valueAs("success"));
  }

  @override
  String get xcmMessageId => id;

  @override
  XCMMultiLocation? get originLocation => origin.originLocation;

  @override
  Map<String, dynamic> toJson() {
    final json = {
      "id": id,
      "origin": origin.toJson(),
      "weight_used": weight?.toJson(),
      "success": success,
      "error": error?.toJson()
    };
    if (error != null) {
      return {"ProcessingFailed": json};
    }
    return {"Processed": json};
  }
}

class SubstrateXcmpQueueEvent implements SubstrateXcmProcessEvent {
  final String messageHash;
  final String messageId;

  final SubstrateWeightV2 weight;
  @override
  final bool success;
  final SubstrateXcmError? error;
  const SubstrateXcmpQueueEvent(
      {required this.messageHash,
      required this.weight,
      required this.success,
      required this.messageId,
      this.error});
  factory SubstrateXcmpQueueEvent.fail(Map<String, dynamic> json) {
    return SubstrateXcmpQueueEvent(
        messageHash: json.valueAs("message_hash"),
        messageId: json.valueAs("message_id"),
        weight: SubstrateWeightV2.fromJson(json.valueAs("weight")),
        success: false,
        error: SubstrateXcmError.fromJson(json.valueAs("error")));
  }
  factory SubstrateXcmpQueueEvent.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("Fail")) {
      return SubstrateXcmpQueueEvent.fail(json.valueAs("Fail"));
    }
    return SubstrateXcmpQueueEvent.success(json.valueAs("Success"));
  }
  factory SubstrateXcmpQueueEvent.success(Map<String, dynamic> json) {
    return SubstrateXcmpQueueEvent(
        messageHash: json.valueAs("message_hash"),
        messageId: json.valueAs("message_id"),
        weight: SubstrateWeightV2.fromJson(json.valueAs("weight")),
        success: true);
  }

  @override
  String get xcmMessageId => messageId;

  @override
  XCMMultiLocation? get originLocation => null;

  @override
  Map<String, dynamic> toJson() {
    final json = {
      "message_hash": messageHash,
      "message_id": messageId,
      "weight": weight.toJson(),
      "success": success,
      "error": error?.toJson()
    };
    if (error != null) {
      return {"Fail": json};
    }
    return {"Success": json};
  }
}

abstract class SubstrateAssetDepositEvent {
  const SubstrateAssetDepositEvent();
  String? get address;
  Map<String, dynamic> toJson();
}

class SubstrateAssetsDepositedEvent implements SubstrateAssetDepositEvent {
  final Object assetId;
  final String owner;
  final BigInt amount;
  const SubstrateAssetsDepositedEvent(
      {required this.assetId, required this.amount, required this.owner});
  factory SubstrateAssetsDepositedEvent.fromJson(Map<String, dynamic> json) {
    return SubstrateAssetsDepositedEvent(
        assetId: json.valueAs("asset_id"),
        owner: json.valueAs("owner"),
        amount: json.valueAsBigInt("amount"));
  }

  @override
  String? get address => owner;

  @override
  Map<String, dynamic> toJson() {
    return {"asset_id": assetId, "owner": owner, "amount": amount};
  }
}

class SubstrateForeignAssetsDepositedEvent
    implements SubstrateAssetDepositEvent {
  final XCMMultiLocation assetId;
  final String owner;
  final BigInt amount;
  const SubstrateForeignAssetsDepositedEvent(
      {required this.assetId, required this.amount, required this.owner});
  factory SubstrateForeignAssetsDepositedEvent.fromJson(
      Map<String, dynamic> json) {
    return SubstrateForeignAssetsDepositedEvent(
        assetId: XCMMultiLocation.fromJson(
            json: json.valueAs("asset_id"),
            version: SubstrateNetworkControllerConstants.latestXCMVersion),
        owner: json.valueAs("owner"),
        amount: json.valueAsBigInt("amount"));
  }

  @override
  String? get address => owner;

  @override
  Map<String, dynamic> toJson() {
    return {"asset_id": assetId.toJson(), "owner": owner, "amount": amount};
  }
}

class SubstrateCommonItemCreatedEvent implements SubstrateAssetDepositEvent {
  final BigInt assetId;
  @override
  final String address;
  final BigInt amount;
  const SubstrateCommonItemCreatedEvent(
      {required this.address, required this.amount, required this.assetId});
  factory SubstrateCommonItemCreatedEvent.itemCreated(List<dynamic> items) {
    try {
      final addrJson =
          JsonParser.valueEnsureAsMap<String, dynamic>(items.elementAt(2));
      final address = addrJson.valueAs<String?>("Substrate") ??
          addrJson.valueAs<String>("Ethereum");
      return SubstrateCommonItemCreatedEvent(
          amount: JsonParser.valueAsBigInt(items.elementAt(3)),
          assetId: JsonParser.valueAsBigInt(items.elementAt(0)),
          address: address);
    } catch (_) {
      throw DartSubstratePluginException(
          "Invalid Substrate Common ItemCreated event object.");
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "amount": amount,
      "asset_id": assetId.toString()
    };
  }
}

class SubstrateEthereumEvmLogEvent implements SubstrateAssetDepositEvent {
  final String contractAddress;
  final List<String> topics;
  final String data;
  @override
  final String? address;
  final BigInt? amount;
  const SubstrateEthereumEvmLogEvent(
      {required this.contractAddress,
      required this.topics,
      required this.data,
      required this.address,
      this.amount});
  factory SubstrateEthereumEvmLogEvent.fromJson(Map<String, dynamic> json) {
    final List<String> topics = json.valueEnsureAsList<String>("topics");
    final String? signature = topics.firstOrNull;
    String? address;
    BigInt? amount;
    if (topics.length >= 3 &&
        signature != null &&
        StringUtils.hexEqual(
            signature, SubstratemEVMNetworkUtils.erc20TransferSignature)) {
      address = SubstrateAddressUtils.tryDecodeFromSolidityAddress(
              topics.elementAt(2))
          ?.address;
      amount =
          BigintUtils.fromBytes(BytesUtils.fromHexString(json.valueAs("data")));
    }

    /// ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
    return SubstrateEthereumEvmLogEvent(
        contractAddress: json.valueAs("address"),
        topics: topics,
        data: json.valueAs("data"),
        amount: amount,
        address: address);
  }
  @override
  Map<String, dynamic> toJson() {
    return {"address": address, "topics": topics, "data": data};
  }
}

class SubstrateExecutedFromXcmEvent {
  final String xcmMessageHash;
  final String ethTxHash;
  const SubstrateExecutedFromXcmEvent(
      {required this.xcmMessageHash, required this.ethTxHash});
  factory SubstrateExecutedFromXcmEvent.fromJson(Map<String, dynamic> json) {
    return SubstrateExecutedFromXcmEvent(
        xcmMessageHash: json.valueAs("xcm_msg_hash"),
        ethTxHash: json.valueAs("eth_tx_hash"));
  }
}

class SubstrateEthereumExecutedEvent {
  final BaseEthereumRuntimeRpcsApiCallExitReason exitReason;
  final String from;
  final String to;
  final String transactonHash;
  const SubstrateEthereumExecutedEvent(
      {required this.from,
      required this.to,
      required this.transactonHash,
      required this.exitReason});
  factory SubstrateEthereumExecutedEvent.fromJson(Map<String, dynamic> json) {
    return SubstrateEthereumExecutedEvent(
        from: json.valueAs("from"),
        to: json.valueAs("to"),
        exitReason: BaseEthereumRuntimeRpcsApiCallExitReason.fromJson(
            json.valueAs("exit_reason")),
        transactonHash: json.valueAs("extra_data"));
  }
}

class SubstrateTokensDepositedEvent implements SubstrateAssetDepositEvent {
  final Object currencyId;
  final String who;
  final BigInt amount;

  const SubstrateTokensDepositedEvent(
      {required this.currencyId, required this.amount, required this.who});
  factory SubstrateTokensDepositedEvent.fromJson(Map<String, dynamic> json) {
    return SubstrateTokensDepositedEvent(
        currencyId: json.valueAs("currency_id"),
        who: json.valueAs("who"),
        amount: json.valueAsBigInt("amount"));
  }
  @override
  Map<String, dynamic> toJson() {
    return {"currency_id": currencyId, "who": who, "amount": amount.toString()};
  }

  @override
  String get address => who;
}

class SubstrateXTransferDepositedEvent implements SubstrateAssetDepositEvent {
  final XCMV3MultiAsset what;
  final XCMV3MultiLocation who;
  @override
  final String? address;

  const SubstrateXTransferDepositedEvent(
      {required this.what, required this.who, this.address});
  factory SubstrateXTransferDepositedEvent.fromJson(Map<String, dynamic> json) {
    final location = XCMV3MultiLocation.fromJson(json.valueAs("who"));
    final account32 = location.interior.junctions
        .whereType<XCMJunctionAccountId32>()
        .firstOrNull
        ?.id;
    return SubstrateXTransferDepositedEvent(
        what: XCMV3MultiAsset.fromJson(json.valueAs("what")),
        who: XCMV3MultiLocation.fromJson(json.valueAs("who")),
        address: BytesUtils.tryToHexString(account32));
  }
  @override
  Map<String, dynamic> toJson() {
    return {"what": what.toJson(), "who": who.toJson(), "address": address};
  }
}

class SubstrateCurrenciesDepositedEvent implements SubstrateAssetDepositEvent {
  final Object currencyId;
  final String who;
  final BigInt amount;
  const SubstrateCurrenciesDepositedEvent(
      {required this.currencyId, required this.amount, required this.who});
  factory SubstrateCurrenciesDepositedEvent.fromJson(
      Map<String, dynamic> json) {
    return SubstrateCurrenciesDepositedEvent(
        currencyId: json.valueAs("currency_id"),
        who: json.valueAs("who"),
        amount: json.valueAsBigInt("amount"));
  }

  @override
  String? get address => who;

  @override
  Map<String, dynamic> toJson() {
    return {
      "currency_id": currencyId,
      "who": who,
      "amount": amount.toString(),
    };
  }
}

class SubstrateBalancesMintedEvent implements SubstrateAssetDepositEvent {
  final String who;
  final BigInt amount;
  const SubstrateBalancesMintedEvent({required this.amount, required this.who});
  factory SubstrateBalancesMintedEvent.fromJson(Map<String, dynamic> json) {
    return SubstrateBalancesMintedEvent(
        who: json.valueAs("who"), amount: json.valueAsBigInt("amount"));
  }

  @override
  String? get address => who;

  @override
  Map<String, dynamic> toJson() {
    return {"who": who, "amount": amount};
  }
}
