class SubstrateEvent {
  final String pallet;
  final List<String> topic;
  final String method;
  final Object input;
  final int? applyExtrinsic;

  bool get isfinalization => applyExtrinsic == null;
  const SubstrateEvent(
      {required this.pallet,
      required this.topic,
      required this.method,
      required this.input,
      required this.applyExtrinsic});

  factory SubstrateEvent.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> event = (json["event"] as Map).cast<String, dynamic>();
    final pallet = event.keys.first;
    event = (event[pallet] as Map).cast<String, dynamic>();
    final method = event.keys.first;
    Object input = event[method];
    return SubstrateEvent(
        pallet: pallet,
        topic: (json["topics"] as List).cast(),
        method: method,
        input: input,
        applyExtrinsic: (json["phase"] as Map).cast()["ApplyExtrinsic"]);
  }
}
