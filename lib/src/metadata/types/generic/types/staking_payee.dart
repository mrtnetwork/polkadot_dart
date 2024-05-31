import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class _StakingPayeeOptions {
  static const String staked = "Staked";
  static const String controller = "Controller";
  static const String stash = "Stash";
  static const String sccount = "Account";
  static const String none = "None";
}

abstract class StakingPayeeOption
    extends SubstrateSerialization<Map<String, dynamic>> {
  const StakingPayeeOption();
  static const StakingPayeeOption staked =
      StakingPayee._(_StakingPayeeOptions.staked);
  static const StakingPayeeOption stash =
      StakingPayee._(_StakingPayeeOptions.stash);
  static const StakingPayeeOption controller =
      StakingPayee._(_StakingPayeeOptions.controller);
  static const StakingPayeeOption none =
      StakingPayee._(_StakingPayeeOptions.none);
  static StakingPayeeAccount account(SubstrateAddress account) =>
      StakingPayeeAccount(account);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    throw UnimplementedError();
  }
}

class StakingPayeeAccount extends StakingPayeeOption {
  final SubstrateAddress account;
  const StakingPayeeAccount(this.account);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {_StakingPayeeOptions.sccount: account.toBytes()};
  }
}

class StakingPayee extends StakingPayeeOption {
  final String option;
  const StakingPayee._(this.option);
  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {option: null};
  }
}

// class StakingPayee {
//   final String option;
//   final 
// }
//  "Staked": null,
//               "Stash": null,
//               "Controller": null,
//               "Account": {"type": "[U8;32]", "value": null},
//               "None": null