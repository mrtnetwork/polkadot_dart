import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class SystemHealthResppnse with JsonSerialization {
  final int peers;
  final bool isSyncing;
  final bool shouldHavePeers;

  const SystemHealthResppnse({
    required this.peers,
    required this.isSyncing,
    required this.shouldHavePeers,
  });

  factory SystemHealthResppnse.fromJson(Map<String, dynamic> json) {
    return SystemHealthResppnse(
      peers: json['peers'] as int,
      isSyncing: json['isSyncing'] as bool,
      shouldHavePeers: json['shouldHavePeers'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'peers': peers,
      'isSyncing': isSyncing,
      'shouldHavePeers': shouldHavePeers,
    };
  }
}
