import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

enum SubtrateMetadataPallet {
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
  erc20XcmBridge("Erc20XcmBridge"),
  ;

  static SubtrateMetadataPallet fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  final String name;
  const SubtrateMetadataPallet(this.name);
}

abstract mixin class SubstrateCallPallet {
  SubtrateMetadataPallet get pallet;
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method});
  Map<String, dynamic> toJson({String? method});

  T cast<T extends SubstrateCallPallet>() {
    if (this is! T) {
      throw CastFailedException<T>(value: this);
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
