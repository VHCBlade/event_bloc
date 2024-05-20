import 'package:event_bloc/event_bloc_widgets.dart';

/// Tracks error related events.
enum ErrorEvent<T> {
  /// Signifies that an error was unexpected
  unexpectedError<TrackedError>(),

  /// Signifies that an error may have been expected and handled already
  /// but it might be desirable to track it for debugging purposes.
  debugError<TrackedError>(),
  ;

  /// The [BlocEventType] associated with this specific event.
  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
