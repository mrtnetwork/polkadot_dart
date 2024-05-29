class DigestResponse {
  final List<String> logs;
  DigestResponse(List<String> logs) : logs = List<String>.unmodifiable(logs);
  DigestResponse.fromJson(Map<String, dynamic> json)
      : logs = List<String>.unmodifiable(json["logs"] ?? []);
  Map<String, dynamic> toJson() {
    return {"logs": logs};
  }
}
