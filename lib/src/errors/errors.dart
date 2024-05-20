import 'package:event_bloc/event_bloc.dart';

/// Data object that represents a TrackedError, mostly used for events
class TrackedError {
  /// Data object that represents a TrackedError, mostly used for events
  TrackedError({
    required this.error,
    required this.stackTrace,
    this.associatedEvent,
    this.message,
  });

  /// The error that was initially caught
  final Object error;

  /// The associated stackTrace when the exception was caught.
  final StackTrace stackTrace;

  /// The associated event that was being responded to when the error occurred.
  final BlocEventType<dynamic>? associatedEvent;

  /// A custom message related to the error
  final String? message;
}
