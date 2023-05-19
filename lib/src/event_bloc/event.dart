import 'package:equatable/equatable.dart';

/// Every [BlocEvent] has corresponding [BlocEventType]. This specifies the
/// type of the bloc event as well as differentiating it from other events.
class BlocEventType<T> extends Equatable {
  /// [eventName] is a unique identifier for this event type. This needs to be
  /// fairly unique.
  ///
  /// A good way to generate this is using an enum and using its [toString]
  /// method.
  const BlocEventType(this.eventName);

  /// Uses [eventType]s [Object.toString] method to create the [eventName]
  const BlocEventType.fromObject(Object eventType) : eventName = '$eventType';

  /// Unique identifier for this event type. This needs to be fairly unique.
  ///
  /// A good way to generate this is using an enum and using its [toString]
  /// method.
  final String eventName;

  @override
  List<Object?> get props => [eventName];
}

/// These are the objects that are propagated up
class BlocEvent<T> {
  /// [eventType] helps categorize this event for its listeners.
  BlocEvent(this.eventType);

  /// Helps categorize this event for its listeners.
  final BlocEventType<T> eventType;

  /// This is a flag that tells event listeners that this
  /// has been handled already. Note that this flag can be ignored.
  bool propagate = true;

  /// Shows how many listeners have reacted to this event.
  int timesHandled = 0;

  /// Shows how many event channels this event has passed through.
  int depth = 0;
}
