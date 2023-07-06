import 'package:equatable/equatable.dart';

/// Every [BlocEvent] has corresponding [BlocEventType]. This specifies the
/// type of the bloc event as well as differentiating it from other events.
///
/// Also contains metadata such as [userInitiated] that gives extra information
/// as to the circumstances of the this event type.
///
/// When comparing equality, only the [eventName] is taken into account.
class BlocEventType<T> extends Equatable {
  /// [eventName] is a unique identifier for this event type. This needs to be
  /// fairly unique.
  ///
  /// A good way to generate this is using an enum and using its [toString]
  /// method.
  ///
  /// [userInitiated] indicates whether the event was fired directly by the user
  const BlocEventType(this.eventName, {this.userInitiated = true});

  /// Uses [eventType]s [Object.toString] method to create the [eventName]
  ///
  /// [userInitiated] indicates whether the event was fired directly by the user
  const BlocEventType.fromObject(Object eventType, {this.userInitiated = true})
      : eventName = '$eventType';

  /// Unique identifier for this event type. This needs to be fairly unique.
  ///
  /// A good way to generate this is using an enum and using its [toString]
  /// method.
  final String eventName;

  /// Indicates whether the action was fired because of a specific action taken
  /// by the user or if it was fired automatically because of some other means.
  final bool userInitiated;

  /// Creates a new copy of this event type with the specified values.
  BlocEventType<T> copyWith({String? eventName, bool? userInitiated}) {
    return BlocEventType(
      eventName ?? this.eventName,
      userInitiated: userInitiated ?? this.userInitiated,
    );
  }

  /// Returns this value if already [userInitiated]. Otherwise will copy this
  /// event type with [userInitiated] set to true.
  BlocEventType<T> get asUserInitiated =>
      userInitiated ? this : copyWith(userInitiated: true);

  /// Returns this value if already not [userInitiated]. Otherwise will copy
  /// this event type with [userInitiated] set to false.
  BlocEventType<T> get asNotUserInitiated =>
      !userInitiated ? this : copyWith(userInitiated: false);

  @override
  List<Object?> get props => [eventName];
}

/// These are the objects that are propagated up
class BlocEvent<T> {
  /// [eventType] helps categorize this event for its listeners.
  BlocEvent(this.eventType);

  /// Helps categorize this event for its listeners.
  ///
  /// Also has metadata regarding the factors that lead to this event being
  /// fired.
  final BlocEventType<T> eventType;

  /// This is a flag that tells event listeners that this
  /// has been handled already. Note that this flag can be ignored.
  bool propagate = true;

  /// Whether this event was userInitiated or not.
  bool get isUserInitiated => eventType.userInitiated;

  /// Shows how many listeners have reacted to this event.
  int timesHandled = 0;

  /// Shows how many event channels this event has passed through.
  int depth = 0;
}
