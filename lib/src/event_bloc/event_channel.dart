import 'package:event_bloc/event_bloc.dart';

/// Event Listener, return value is true if the event is to be stopped from propagating
typedef BlocEventListener<T> = bool Function(T);

/// [BlocEventChannel] represents a node in a tree of event channels, mirroring the widget tree to an extent. The tree is only connected upwards (child knows its parent).
///
/// [BlocEventListener]s can be added to each [BlocEventChannel]. These will listen to events fired directly to the event channel. By default, these events will also be propagated up the tree, effectively refiring the event to each parent.
///
/// [BlocProvider] and [RepositoryProvider] will both automatically Provide the event channel down the widget tree.
///
/// While the event channel system might mirror the widget tree, it doesn't need to be used alongside it. This lets you use the [BlocEventChannel] in non-Widget environments.
class BlocEventChannel implements Disposable {
  final BlocEventChannel? _parentChannel;
  final Map<String, List<BlocEventListener>> _listeners = {};

  /// [_parentChannel] is the parent of this channel. This can only be set in the constructor to ensure that the [BlocEventChannel] tree does in fact remain a tree with no cycles.
  BlocEventChannel([this._parentChannel]);

  /// Helper function to simplify making a [BlocEventListener] by calling [listener] and then returning [stopPropagation]
  static BlocEventListener<T> simpleListener<T>(Function(T) listener,
          {stopPropagation = false}) =>
      (dynamic) {
        listener(dynamic);
        return stopPropagation;
      };

  /// Fires an event that is sent up the event channel, stopping only
  /// when it reaches the top or an event stops the propagation.
  void fireEvent(String eventType, dynamic payload) {
    final shouldStopPropagation = _listenForEvent(eventType, payload);

    if (!shouldStopPropagation) {
      _parentChannel?.fireEvent(eventType, payload);
    }
  }

  /// Fires an events that is sent up the event channel, stopping only
  /// when it reaches the top or an event stops the propagation.
  ///
  /// This version allows you to define a list of events with an enforced type of payload.
  void fireBlocEvent<T>(BlocEvent<T> eventType, T payload) {
    fireEvent(eventType.eventName, payload);
  }

  /// Adds a [listener] for the specific [eventType]. Multiple listeners can be added for each [eventType]
  ///
  /// Returns the added [listener] which when called with [removeEventListener] will remove the listener added with this function.
  BlocEventListener addEventListener(
      String eventType, BlocEventListener listener) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    if (potListeners == null) {
      potListeners = [];
      _listeners[eventType] = potListeners;
    }

    potListeners.add(listener);

    return listener;
  }

  /// Adds a [BlocEventListener] which listens for the same type as the [event]. Multiple listeners can be added for each [event]
  ///
  /// This should be called with the generic [T] specified to ensure type safety.
  ///
  /// Returns the wrapped [listener]. You can then call [removeEventListener] to remove the listener added with this function.
  BlocEventListener addBlocEventListener<T>(
      BlocEvent<T> event, BlocEventListener<T> listener) {
    return addEventListener(
        event.eventName, _wrapSpecificListener(event, listener));
  }

  /// Wraps the specific [BlocEventListener] with type [T] into a [BlocEventListener] with a dynamic type.
  BlocEventListener _wrapSpecificListener<T>(
          BlocEvent<T> event, BlocEventListener<T> listener) =>
      (val) {
        if (val is! T) {
          throw "Payload recieved for ${event.eventName} does not match the type $T and is ${val.runtimeType} instead.";
        }
        return listener(val);
      };

  /// Removes the given [listener] from the given [eventType]. Will do nothing if [listener] doesn't exist.
  ///
  /// This is the method you call if you added the listener through [addEventListener]. [listener] being the returned
  /// value from the function.
  void removeEventListener(String eventType, BlocEventListener listener) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    potListeners?.remove(listener);
  }

  /// Removes the given [listener] from the given [eventType]. Will do nothing if [listener] doesn't exist.
  ///
  /// This is the method you call if you added the listener through [addBlocEventListener]. [listener] being the returned
  /// value from the function.
  void removeBlocEventListener<T>(
      BlocEvent<T> eventType, BlocEventListener listener) {
    removeEventListener(eventType.eventName, listener);
  }

  /// Executes the listeners for the [eventType] with the given [payload]
  ///
  /// Will return true if the event should no longer be propagated up the event channel.
  bool _listenForEvent(String eventType, dynamic payload) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    if (potListeners == null || potListeners.isEmpty) {
      return false;
    }

    return potListeners
        .map((listener) => listener(payload))
        .reduce((a, b) => a || b);
  }

  @override
  void dispose() {
    _listeners.clear();
  }
}

/// Interface that implements a dispose method.
abstract class Disposable {
  void dispose() {}
}
