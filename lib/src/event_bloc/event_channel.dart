import 'package:event_bloc/src/event_bloc/event.dart';

/// Event Listener
typedef BlocEventListenerAction<T> = void Function(BlocEvent<T> event, T value);

class BlocEventListener<T> {
  final BlocEventListenerAction<T> eventListenerAction;

  /// If true, this event listener will listen for [BlocEvent]s that have
  /// [stopPropagation] set to true.
  final bool ignoreStopPropagation;

  /// Convenience function that will unsubscribe this from the [BlocEventChannel]
  /// that this is subscribed to. This function is idempotent so it can be called
  /// multiple times.
  late final void Function() unsubscribe;

  BlocEventListener({
    required this.eventListenerAction,
    this.ignoreStopPropagation = false,
  });
}

/// [BlocEventChannel] represents a node in a tree of event channels, mirroring
/// the widget tree to an extent. The tree is only connected upwards
/// (child knows its parent).
///
/// [BlocEventListener]s can be added to each [BlocEventChannel]. These will
/// listen to events fired directly to the event channel. By default, these
/// events will also be propagated up the tree, effectively refiring the event
/// to each parent.
///
/// [BlocProvider] and [RepositoryProvider] will both automatically Provide the
/// event channel down the widget tree.
///
/// While the event channel system might mirror the widget tree, it doesn't
/// need to be used alongside it. This lets you use the [BlocEventChannel]
/// in non-Widget environments.
class BlocEventChannel implements Disposable {
  final BlocEventChannel? _parentChannel;
  final Map<BlocEventType, List<BlocEventListener>> _listeners = {};
  final List<BlocEventListener> _genericListeners = [];
  final BlocEventListenerAction? allListener;

  int get parentCount =>
      _parentChannel == null ? 0 : 1 + _parentChannel!.parentCount;

  /// [_parentChannel] is the parent of this channel.
  /// This can only be set in the constructor to ensure that the
  /// [BlocEventChannel] tree does in fact remain a tree with no cycles.
  ///
  /// [allListener] is called for every single event that passed through this event channel.
  /// Regardless of the type of the event. This should mostly be used for debugging.
  BlocEventChannel([this._parentChannel, this.allListener]);

  /// Fires an event that is sent up the event channel, stopping only
  /// when it reaches the top or an event stops the propagation.
  void fireEvent<T>(BlocEventType<T> eventType, T payload) {
    final event = BlocEvent<T>(eventType);
    fireBlocEvent<T>(event, payload);
  }

  /// Fires an event that is sent up the event channel, stopping only
  /// when it reaches the top or an event stops the propagation.
  ///
  /// This is the internal function used for propagating events up the event tree.
  /// You should generally use [fireEvent] unless you know what you're doing.
  void fireBlocEvent<T>(BlocEvent<T> event, T payload) {
    _listenForEvent<T>(event, payload);

    _parentChannel?.fireBlocEvent<T>(event, payload);
  }

  /// Adds a [BlocEventListner] for the specific [eventType]. The created listener
  /// will run the provided [listenerAction] and
  ///
  /// Multiple listeners can be added for each [eventType].
  ///
  /// If [ignoreStopPropagation] is true, the created listener will still react
  /// to a [BlocEvent] that has had its [propagate] set to false.
  ///
  /// Returns the added [BlocEventListener] which when called with
  /// [removeEventListener] will remove the listener added with this function.
  /// Alternatively, you could simply call the [unsubscribe] function provided
  /// in [BlocEventListener]
  BlocEventListener<T> addEventListener<T>(
    BlocEventType<T> eventType,
    BlocEventListenerAction<T> listenerAction, {
    bool ignoreStopPropagation = false,
  }) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    if (potListeners == null) {
      potListeners = <BlocEventListener<T>>[];
      _listeners[eventType] = potListeners;
    }

    final listener = BlocEventListener(
      eventListenerAction: listenerAction,
      ignoreStopPropagation: ignoreStopPropagation,
    );

    potListeners.add(listener);
    listener.unsubscribe = () => potListeners!.remove(listener);

    return listener;
  }

  /// Adds a [BlocEventListener] that listens for ALL eventTypes. This is generally
  /// too generic for most use cases. You should use [addEventListener] with your
  /// specific [BlocEventType] instead unless you know what you're doing.
  BlocEventListener addGenericEventListener(
      BlocEventListenerAction listenerAction) {
    final listener = BlocEventListener(
      eventListenerAction: listenerAction,
      ignoreStopPropagation: true,
    );

    _genericListeners.add(listener);
    listener.unsubscribe = () => _genericListeners.remove(listener);

    return listener;
  }

  /// Removes the given [listener] from the given [eventType]. Will do nothing
  /// if [listener] doesn't exist.
  ///
  /// This is the method you call if you added the listener through
  /// [addEventListener]. [listener] being the returned value from the function.
  void removeEventListener<T>(
    BlocEventType<T> eventType,
    BlocEventListener<T> listener,
  ) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    potListeners?.remove(listener);
  }

  /// Removes the given [listener] from the generic listeners. Will do nothing
  /// if [listener] doesn't exist.
  ///
  /// This is the method you call if you added the listener through
  /// [addGenericEventListener]. [listener] being the returned value from the function.
  void removeGenericEventListener<T>(BlocEventListener<T> listener) {
    _genericListeners.remove(listener);
  }

  /// Executes the listeners for the [event] with the given [payload]
  ///
  /// The event listeners will modify the [event] and possibly change how the
  /// [event] is handled further up the event channel tree.
  void _listenForEvent<T>(BlocEvent<T> event, T payload) {
    if (allListener != null) {
      allListener!(event, payload);
    }

    List<BlocEventListener<T>>? potListeners =
        _listeners[event.eventType] as List<BlocEventListener<T>>?;

    if (potListeners == null || potListeners.isEmpty) {
      return;
    }

    potListeners
        .where((listener) => event.propagate || listener.ignoreStopPropagation)
        .forEach((listener) {
      event.timesHandled++;
      listener.eventListenerAction(event, payload);
    });
  }

  @override
  void dispose() {
    _listeners.clear();
    _genericListeners.clear();
  }
}

/// Interface that implements a dispose method.
abstract class Disposable {
  void dispose() {}
}
