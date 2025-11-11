/// Contains constant values related to metadata in the Substrate blockchain framework.
class MetadataConstant {
  /// The path to the event record in the frame system.
  static const List<String> eventPath = ["frame_system", "EventRecord"];

  /// The list of supported metadata versions.
  static const List<int> supportedMetadataVersion = [15, 14, 16];

  /// The name of the generic system pallet.
  static const String genericSystemPalletName = "System";

  /// The length of the metadata magic number and version.
  static const int metadataMagicNumberAndVersionLength = 5;

  /// Metadata version 14.
  static const int v14 = 14;

  /// Metadata version 15.
  static const int v15 = 15;

  static const int v16 = 16;

  static const List<int> supportRuntimeApi = [15, 16];

  /// unsuported template
  static const List<String> unsuportedTemplatePath = [
    "RuntimeCall",
    "Instruction"
  ];

  static const List<String> accountIndexPaths = [
    "sp_runtime",
    "multiaddress",
    "MultiAddress"
  ];
  static const List<String> account32IndexPaths = [
    "sp_core",
    "crypto",
    "AccountId32"
  ];
  // sp_core, crypto, AccountId32
  static const List<String> signaturePath = ["sp_runtime", "MultiSignature"];

  static const String queryBlockWeightMethodName = "BlockWeight";

  static const String checkMetadataHash = "CheckMetadataHash";

  static const String chargeAssetTxPayment = "ChargeAssetTxPayment";

  static const List<String> knownNonceExtrinsicFieldNames = [
    "T::Nonce",
    "CheckNonce",
    "nonce"
  ];
}
