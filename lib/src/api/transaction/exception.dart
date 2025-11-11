import 'package:polkadot_dart/src/exception/exception.dart';

class SubstrateLookupBlockExceptionConst {
  static const DartSubstratePluginException notFound =
      DartSubstratePluginException("Failed to locate block: item not found.");
  static const DartSubstratePluginException blockNotFound =
      DartSubstratePluginException("Failed to locate block: block not found.");
}
