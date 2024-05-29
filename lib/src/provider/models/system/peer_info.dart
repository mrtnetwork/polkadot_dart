import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class PeerInfo with JsonSerialization {
  final String peerId;
  final String roles;
  final int protocolVersion;
  final String bestHash;
  final int bestNumber;

  const PeerInfo({
    required this.peerId,
    required this.roles,
    required this.protocolVersion,
    required this.bestHash,
    required this.bestNumber,
  });

  factory PeerInfo.fromJson(Map<String, dynamic> json) {
    return PeerInfo(
      peerId: json['peerId'] as String,
      roles: json['roles'] as String,
      protocolVersion: json['protocolVersion'] as int,
      bestHash: json['bestHash'] as String,
      bestNumber: json['bestNumber'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'peerId': peerId,
      'roles': roles,
      'protocolVersion': protocolVersion,
      'bestHash': bestHash,
      'bestNumber': bestNumber,
    };
  }
}
