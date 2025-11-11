import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum SubstrateAssetType {
  native,
  token;

  bool get isNative => this == native;
  static SubstrateAssetType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }
}

/// Base class for a Substrate network asset, including XCM location and metadata.
abstract class BaseSubstrateNetworkAsset {
  /// XCM versioned location of the asset, if any.
  abstract final XCMVersionedLocation? location;

  /// Internal asset identifier.
  abstract final Object? identifier;

  /// Returns the XToken transfer ID (default: identifier).
  Object? get xTokenTransferId => identifier;

  /// Whether the asset is spendable.
  final bool isSpendable;

  /// Whether the asset can be used for fees.
  final bool isFeeToken;

  /// Minimum balance for the asset, if defined.
  final BigInt? minBalance;

  /// Asset display name.
  final String? name;

  /// Asset symbol (ticker).
  final String? symbol;

  /// Asset decimals.
  final int? decimals;

  /// Pallet used for executing transactions involving this asset.
  final SubtrateMetadataPallet excutionPallet;

  /// Whether to charge this asset for transaction fees.
  final bool chargeAssetTxPayment;

  /// Constructor for initializing a base asset.
  BaseSubstrateNetworkAsset({
    required this.isSpendable,
    required this.isFeeToken,
    required this.minBalance,
    required this.name,
    required this.symbol,
    required int? decimals,
    required this.excutionPallet,
    this.chargeAssetTxPayment = false,
  }) : decimals = decimals?.asUint8;

  /// Construct from JSON.
  BaseSubstrateNetworkAsset.fromJson(Map<String, dynamic> json)
      : isFeeToken = json.valueAs("is_fee_token"),
        isSpendable = json.valueAs("is_fee_token"),
        minBalance = json.valueAs("min_balance"),
        name = json.valueAs("name"),
        symbol = json.valueAs("symbol"),
        decimals = json.valueAsInt("decimals")?.asUint8,
        chargeAssetTxPayment = json.valueAs("charge_asset_tx_payment"),
        excutionPallet =
            SubtrateMetadataPallet.fromName(json.valueAs("excution_pallet"));

  /// Returns the asset type (default: token).
  SubstrateAssetType get type => SubstrateAssetType.token;

  /// Returns true if decimals and symbol are defined.
  bool get hasMetadata => decimals != null && symbol != null;

  /// Returns true if the asset has an identifier.
  bool get hasIdentifier => identifier != null;

  /// Returns a charge transaction payment identifier (default: null).
  Object? asChargeTxPaymentAssetId({
    required BaseSubstrateNetwork network,
    required XCMVersion version,
  }) =>
      null;

  /// Checks equality with another identifier.
  bool identifierEqual(Object? identifier);

  /// Casts the identifier to a specific type T, throwing if mismatch.
  T identifierAs<T extends Object>() {
    if (identifier == null) {
      throw DartSubstratePluginException("Missing asset identifier");
    }
    if (identifier is! T) {
      throw DartSubstratePluginException("Mismatch asset identifier.",
          details: {"expected": "$T", "identifier": identifier.runtimeType});
    }
    return identifier as T;
  }

  /// Casts the xTokenTransferId to type T, throwing if mismatch.
  T xTokenTransferIdAs<T extends Object>() {
    if (xTokenTransferId == null) {
      throw DartSubstratePluginException("Missing asset identifier");
    }
    if (xTokenTransferId is! T) {
      throw DartSubstratePluginException("Mismatch asset identifier.",
          details: {
            "expected": "$T",
            "identifier": xTokenTransferId.runtimeType
          });
    }
    return xTokenTransferId as T;
  }

  /// Returns localized XCM location or null if unavailable.
  XCMVersionedLocation? tryGetlocalizedLocation({
    required XCMVersion version,
    XCMMultiLocation? reserveLocation,
    BaseSubstrateNetwork? reserveNetwork,
  }) {
    final loc = location;
    if (loc == null) return null;
    return SubstrateNetworkControllerUtils.localizeFor(
            reserveLocation: reserveLocation,
            reserveNetwork: reserveNetwork,
            location: loc.location,
            version: version)
        .asVersioned();
  }

  /// Returns the asset's XCM location, throwing if missing.
  XCMVersionedLocation getLocation({XCMVersion? version}) {
    final loc = location;
    if (loc == null) {
      throw DartSubstratePluginException("Missing asset location.");
    }
    return version != null ? loc.asVersion(version) : loc;
  }

  /// Returns localized XCM location, throwing if missing.
  XCMVersionedLocation getlocalizedLocation({
    required XCMVersion version,
    XCMMultiLocation? reserveLocation,
    BaseSubstrateNetwork? reserveNetwork,
  }) =>
      SubstrateNetworkControllerUtils.localizeFor(
        reserveLocation: reserveLocation,
        version: version,
        reserveNetwork: reserveNetwork,
        location: getLocation(version: version).location,
      ).asVersioned();

  /// Attempts to get XCM asset ID or null if unavailable.
  XCMAssetId? tryGetAssetId({
    required XCMVersion version,
    XCMMultiLocation? reserveLocation,
    BaseSubstrateNetwork? reserveNetwork,
  }) {
    final loc = tryGetlocalizedLocation(
        version: version,
        reserveLocation: reserveLocation,
        reserveNetwork: reserveNetwork);
    return loc?.location.toAssetId();
  }

  /// Returns the XCM asset ID, throwing if missing.
  XCMAssetId getAssetId({
    required XCMVersion version,
    XCMMultiLocation? reserveLocation,
    BaseSubstrateNetwork? reserveNetwork,
  }) =>
      getlocalizedLocation(
              reserveLocation: reserveLocation,
              reserveNetwork: reserveNetwork,
              version: version)
          .location
          .toAssetId();

  /// Converts the asset to JSON.
  Map<String, dynamic> toJson() => {
        "is_spendable": isSpendable,
        "is_fee_token": isFeeToken,
        "min_balance": minBalance?.toString(),
        "name": name,
        "symbol": symbol,
        "decimals": decimals,
        "excution_pallet": excutionPallet.name,
        "charge_asset_tx_payment": chargeAssetTxPayment
      };

  /// Returns the reserve parachain ID if any.
  int? reserveChain() => location?.location.getParachain()?.id;

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! BaseSubstrateNetworkAsset) return false;
    if (other.runtimeType != runtimeType) return false;
    if (type != other.type) return false;
    if (excutionPallet != other.excutionPallet) return false;
    if (type.isNative) {
      if (identifier == null) return other.identifier == null;
    }
    return identifierEqual(other.identifier);
  }

  @override
  int get hashCode =>
      HashCodeGenerator.generateHashCodeNew([type, excutionPallet, identifier]);
}

class GenericBaseSubstrateNativeAsset extends BaseSubstrateNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier;

  GenericBaseSubstrateNativeAsset.withLocation(
      {required super.name,
      required super.decimals,
      required super.symbol,
      super.isFeeToken = true,
      super.isSpendable = true,
      required this.identifier,
      required this.location,
      required super.excutionPallet,
      super.minBalance});
  GenericBaseSubstrateNativeAsset.withParaLocation({
    required super.name,
    required super.decimals,
    required super.symbol,
    required super.excutionPallet,
    super.minBalance,
    int? parachain,
    int? parents,
    required XCMVersion version,
    super.isFeeToken = true,
    super.isSpendable = true,
  })  : location = XCMMultiLocation.fromVersion(
                parents: parents ?? (parachain == null ? 0 : 1),
                version: version,
                interior: XCMJunctions.fromVersion(junctions: [
                  if (parachain != null)
                    XCMJunctionParaChain.fromVersion(
                        id: parachain, version: version)
                ], version: version))
            .asVersioned(),
        identifier = null;

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }
}

/// Concrete implementation of [BaseSubstrateNetworkAssets] for a given network.
class SubstrateNetworkAssets<ASSET extends BaseSubstrateNetworkAsset>
    with BaseSubstrateNetworkAssets<ASSET> {
  /// The network these assets belong to.
  @override
  final BaseSubstrateNetwork network;

  /// List of assets in this network.
  @override
  final List<ASSET> assets;

  /// Creates a new network assets container.
  SubstrateNetworkAssets({required List<ASSET> assets, required this.network})
      : assets = assets.immutable;
}

/// Represents a pair of shared assets between two networks.
class SubstrateShareAsset<ASSET extends BaseSubstrateNetworkAsset> {
  /// Asset in the origin network.
  final ASSET origin;

  /// Corresponding asset in the destination network.
  final BaseSubstrateNetworkAsset destination;

  /// Creates a new shared asset mapping.
  const SubstrateShareAsset({required this.origin, required this.destination});
}

/// Mixin for managing a collection of Substrate network assets.
abstract mixin class BaseSubstrateNetworkAssets<
    ASSET extends BaseSubstrateNetworkAsset> {
  /// List of assets in this network.
  List<ASSET> get assets;

  /// The network these assets belong to.
  BaseSubstrateNetwork get network;

  /// Returns all assets that can be used for fees.
  List<ASSET> feeAssets() => assets.where((e) => e.isFeeToken).toList();

  /// Returns fee assets that also have a defined XCM location.
  List<ASSET> feeAssetsWithLocation() =>
      assets.where((e) => e.isFeeToken && e.location != null).toList();

  /// Returns assets with a defined XCM location.
  List<ASSET> getAssetsWithLocation() =>
      assets.where((e) => e.location != null).toList();

  /// Returns assets whose location is foreign to this network.
  List<ASSET> getForeignAssets() => assets.where((e) {
        final loc = e.location?.location;
        return loc != null && !loc.hasParachain(network.paraId);
      }).toList();

  /// Returns assets located on a specific parachain.
  List<ASSET> getParaAssets(int paraId) => assets.where((e) {
        final loc = e.location?.location;
        return loc != null && loc.hasParachain(paraId);
      }).toList();

  /// Returns the first asset whose symbol contains the given string (case-insensitive).
  ASSET? containsSymbol(String symbol) => assets.firstWhereNullable(
      (e) => e.symbol?.contains(symbol.toLowerCase()) ?? false);

  /// Returns the asset corresponding to a given XCM multi-location.
  ASSET? getAssetFromLocation(XCMMultiLocation location) {
    final assets = getAssetsWithLocation();
    if (location.isZeroParents() && !network.role.isRelay) {
      location = SubstrateNetworkControllerUtils.asForeignLocation(
          from: network, location: location);
    }
    return assets.firstWhereNullable(
        (e) => e.location?.location.isEqual(location) ?? false);
  }

  /// Returns the first asset with an exact symbol match.
  ASSET? symbol(String symbol) =>
      assets.firstWhereNullable((e) => e.symbol == symbol);

  /// Returns assets that have metadata (symbol and decimals defined).
  List<ASSET> withMetadata() => assets.where((e) => e.hasMetadata).toList();

  /// Returns assets that are spendable.
  List<ASSET> spendableAssets() => assets.where((e) => e.isSpendable).toList();

  List<SubstrateNetworkAssets> sameReserve() {
    final Map<int?, List<ASSET>> reverse = {};
    final assets = getAssetsWithLocation();
    for (final i in assets) {
      final location = i.location;
      if (location == null || location.location.isExternalLocation()) continue;
      reverse[location.location.getParachain()?.id] ??= [];
      reverse[location.location.getParachain()?.id]?.add(i);
    }
    return reverse.values
        .map((e) => SubstrateNetworkAssets(assets: e, network: network))
        .toList();
  }

  /// Finds shared assets between this network and a destination network.
  List<SubstrateShareAsset<ASSET>> findShareAssets(
      BaseSubstrateNetworkAssets destination,
      {bool canPayFee = false}) {
    List<SubstrateShareAsset<ASSET>> shareAssets = [];
    final assets = getAssetsWithLocation();
    final destinationAssets = canPayFee
        ? destination.feeAssetsWithLocation()
        : destination.getAssetsWithLocation();
    for (final asset in assets) {
      for (final destAsset in destinationAssets) {
        final oLocation = asset.location?.location;
        final dLocation = destAsset.location?.location;
        if (SubstrateNetworkControllerUtils.locationEquality(
            networkA: network,
            networkB: destination.network,
            a: oLocation,
            b: dLocation)) {
          shareAssets
              .add(SubstrateShareAsset(origin: asset, destination: destAsset));
        }
      }
    }
    return shareAssets;
  }
}
