/// Contains constant values related to metadata in the Substrate blockchain framework.
class MetadataConstant {
  /// The path to the event record in the frame system.
  static const List<String> eventPath = ["frame_system", "EventRecord"];

  /// The list of supported metadata versions.
  static const List<int> supportedMetadataVersion = [14, 15];

  /// The name of the generic system pallet.
  static const String genericSystemPalletName = "System";

  /// The length of the metadata magic number and version.
  static const int metadataMagicNumberAndVersionLength = 5;

  /// Metadata version 14.
  static const int v14 = 14;

  /// Metadata version 15.
  static const int v15 = 15;

  static const List<int> supportRuntimeApi = [15];

  /// unsuported template
  static const List<String> unsuportedTemplatePath = [
    "RuntimeCall",
    "Instruction"
  ];

  static const String queryBlockWeightMethodName = "BlockWeight";

  static const String checkMetadataHashExtensionIdentifier =
      "CheckMetadataHash";
}
