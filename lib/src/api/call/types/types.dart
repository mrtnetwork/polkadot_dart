import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/models/models.dart';

enum SubstrateMetadataPallet {
  assets("Assets"),
  foreignAssets("ForeignAssets"),
  assetRegistry("AssetRegistry"),
  assetManager("AssetManager"),
  assetsRegistry("AssetsRegistry"),
  balances("Balances"),
  tokens("Tokens"),
  xTokens("xTokens"),
  ormlTokens("OrmlTokens"),
  currencies("Currencies"),
  xcAssetConfig("XcAssetConfig"),
  fungibles("Fungibles"),
  xcmPallet("XcmPallet"),
  polkadotXcm("PolkadotXcm"),
  xcmpQueue("XcmpQueue"),
  utility("Utility"),
  xTransfer("XTransfer"),
  multisig("Multisig"),
  system("System"),
  evm("EVM"),
  common("Common"),
  erc20XcmBridge("Erc20XcmBridge");

  static SubstrateMetadataPallet fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown SubstrateMetadataPallet name "$name".',
              ),
    );
  }

  final String name;
  const SubstrateMetadataPallet(this.name);
}

abstract mixin class SubstrateCallPallet {
  SubstrateMetadataPallet get pallet;
  BuBytes encodeCall({
    required MetadataWithExtrinsic extrinsic,
    String? pallet,
    String? method,
  });
  Map<String, dynamic> toJson({String? method});

  T cast<T extends SubstrateCallPallet>() {
    if (this is! T) {
      throw BuError(
        DefaultErrorType.castFailed,
        "Failed to cast value",
        details: {"expected": "T", "value": runtimeType.toString()},
      );
    }
    return this as T;
  }
}

abstract mixin class SubstrateLocalTransferCallPallet
    implements SubstrateCallPallet {
  SubstrateCallPalletTransferMethod get type;
}

abstract mixin class SubstrateXCMCallPallet implements SubstrateCallPallet {
  SubstrateCallPalletXCMTransferMethod get type;
  XCMMultiLocation get destination;
}

abstract mixin class SubstrateCallPalletMethod {
  String get method;
}

abstract mixin class SubstrateCallPalletTransferMethod
    implements SubstrateCallPalletMethod {
  bool get keepAlive;
  bool get isTransferAll;
}

abstract mixin class SubstrateCallPalletXCMTransferMethod
    implements SubstrateCallPalletMethod {}
