import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/models/generic/models/module_error.dart';

typedef ONEVENTDISPATCHERROR = Map<String, dynamic>? Function(
    ModuleError error);

class SubstrateEventConst {
  static const String extrinsicFailed = "ExtrinsicFailed";
  static const String dispatchError = "dispatch_error";
  static const String system = "System";
  static const String module = "Module";
}

enum SubstrateEventPhase {
  initialization("Initialization"),
  applyExtrinsic("ApplyExtrinsic"),
  finalization("Finalization"),
  unknown("Unknown");

  final String type;
  const SubstrateEventPhase(this.type);
  static SubstrateEventPhase fromJson(Map<String, dynamic>? json) {
    final type = json?.keys.firstOrNull;
    return values.firstWhere((e) => e.type == type,
        orElse: () => SubstrateEventPhase.unknown);
  }
}

/// Represents a single Substrate event with pallet, method, input, and phase information.
class SubstrateEvent {
  /// Raw event data as received from the chain.
  final Map<String, dynamic> rawEvent;

  /// Pallet name of the event.
  final String pallet;

  /// Event topics.
  final List<String> topic;

  /// Event method name.
  final String method;

  /// Event input data of method.
  final Object? input;

  /// Index of the extrinsic that applied this event, null if Finalization or Initialization.
  final int? applyExtrinsic;

  /// Event phase information.
  final SubstrateEventPhase phase;

  /// Optional human-readable description of the event.
  Map<String, dynamic>? description;

  SubstrateEvent({
    required this.pallet,
    required this.topic,
    required this.method,
    required this.input,
    required this.applyExtrinsic,
    required Map<String, dynamic> rawEvent,
    required this.phase,
    Map<String, dynamic>? description,
  })  : rawEvent = rawEvent.immutable,
        description = description?.immutable;

  /// Creates a `SubstrateEvent` from JSON and optionally handles dispatch errors.
  factory SubstrateEvent.fromJson(Map<String, dynamic> json,
      {ONEVENTDISPATCHERROR? onDispatchError}) {
    Map<String, dynamic> event = json;
    if (json.containsKey("event")) {
      event = json.valueEnsureAsMap<String, dynamic>("event");
    }
    final pallet = event.keys.first;
    event = event.valueEnsureAsMap<String, dynamic>(pallet);
    final method = event.keys.first;
    final Object? input = event[method];
    Map<String, dynamic>? description;
    if (method == SubstrateEventConst.extrinsicFailed) {
      if (input is Map &&
          input.containsKey(SubstrateEventConst.dispatchError)) {
        final dispatchError = input[SubstrateEventConst.dispatchError];
        if (onDispatchError != null &&
            dispatchError is Map &&
            dispatchError.containsKey(SubstrateEventConst.module)) {
          final mError = ModuleError.tryFromJson(
              dispatchError[SubstrateEventConst.module]);
          if (mError != null) {
            description = onDispatchError(mError);
          }
        }
      }
    }
    final Map<String, dynamic> phase =
        json.valueAsMap<Map<String, dynamic>?>("phase") ?? {};
    return SubstrateEvent(
        pallet: pallet,
        topic: json.valueAsList<List<String>?>("topics") ?? [],
        method: method,
        input: input,
        applyExtrinsic: phase.valueAs(SubstrateEventPhase.applyExtrinsic.type),
        rawEvent: json,
        phase: SubstrateEventPhase.fromJson(phase),
        description: description);
  }

  /// Converts the event to JSON including optional description.
  Map<String, dynamic> toJson() => {...rawEvent, "description": description};

  /// Attempts to cast input to the specified type, returns null on failure.
  T? tryInputAs<T extends Object>() {
    try {
      return JsonParser.valueAs<T>(input);
    } catch (_) {
      return null;
    }
  }

  /// Casts input to the specified type, throws if casting fails.
  T inputAs<T extends Object>() {
    final input = this.input;
    try {
      return JsonParser.valueAs<T>(input);
    } catch (_) {
      throw CastFailedException(
          message: "Failed to cast event input.",
          value: input,
          details: {"expected": "$T", "input": input.runtimeType});
    }
  }

  /// Returns a simple map of method name to input data.
  Map<String, dynamic> getMethodData() {
    return {method: input};
  }
}

/// Represents a group of Substrate events and provides helper methods to query them.
class SubstrateGroupEvents {
  /// List of all events in the group.
  final List<SubstrateEvent> events;

  SubstrateGroupEvents({required List<SubstrateEvent> events})
      : events = events.immutable;

  /// Converts all events to JSON.
  Map<String, dynamic> toJson() {
    return {
      "events": events.map((e) => e.toJson()).toList(),
    };
  }

  /// Returns the first matching event input for a given pallet/method and optional phase.
  T? getMethodEvnet<T extends Object>(String pallet, String method,
      {SubstrateEventPhase? phase}) {
    List<SubstrateEvent> events = this.events;
    if (phase != null) {
      events = events.where((e) => e.phase == phase).toList();
    }
    final event = events
        .firstWhereNullable((e) => e.pallet == pallet && e.method == method);
    if (event != null) return event.input as T?;
    return null;
  }

  /// Returns a list of all matching event inputs for a given pallet/method and optional phase.
  List<T> getMethodEvnets<T extends Object>(String pallet, String method,
      {SubstrateEventPhase? phase}) {
    List<SubstrateEvent> events = this.events;
    if (phase != null) {
      events = events.where((e) => e.phase == phase).toList();
    }
    final event = events.where((e) => e.pallet == pallet && e.method == method);
    return event.map((e) => e.inputAs<T>()).toList();
  }

  /// Returns the first event satisfying [test], optionally filtering by pallets, methods, and phase.
  T? firstWhereOrNull<T extends Object>(T? Function(SubstrateEvent) test,
      {List<String> pallets = const [],
      List<String> methods = const [],
      SubstrateEventPhase? phase,
      bool catchError = false}) {
    Iterable<SubstrateEvent> events = this.events;
    if (phase != null) {
      events = getPhaseEvents(phase);
    }
    if (pallets.isNotEmpty) {
      events = events.where((e) => pallets.contains(e.pallet));
    }
    if (methods.isNotEmpty) {
      events = events.where((e) => methods.contains(e.method));
    }
    for (final i in events) {
      try {
        final r = test(i);
        if (r != null) return r;
      } catch (_) {
        if (!catchError) rethrow;
      }
    }
    return null;
  }

  /// Returns all events in a specific phase.
  List<SubstrateEvent> getPhaseEvents(SubstrateEventPhase phase) {
    return events.where((e) => e.phase == phase).toList();
  }

  /// Returns all event inputs that satisfy [test], optionally filtering by pallets, methods, and phase.
  List<T> where<T extends Object>(T? Function(SubstrateEvent) test,
      {List<String> pallets = const [],
      List<String> methods = const [],
      SubstrateEventPhase? phase,
      bool catchError = false}) {
    Iterable<SubstrateEvent> events = this.events;
    if (phase != null) {
      events = getPhaseEvents(phase);
    }
    if (pallets.isNotEmpty) {
      events = events.where((e) => pallets.contains(e.pallet));
    }
    if (methods.isNotEmpty) {
      events = events.where((e) => methods.contains(e.method));
    }

    List<T> results = [];
    for (final i in events) {
      try {
        final r = test(i);
        if (r != null) {
          results.add(r);
        }
      } catch (_) {
        if (!catchError) rethrow;
      }
    }
    return results;
  }
}
