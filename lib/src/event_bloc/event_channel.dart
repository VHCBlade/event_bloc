/// Event Listener, return value is true if the event is to be stopped from propagating
typedef BlocEventListener = bool Function(dynamic);

/// [BlocEventChannel] represents a node in a tree of event channels, mirroring the widget tree to an extent. The tree is only connected upwards (child knows its parent).
///
/// [BlocEventListeners] can be added to each [BlocEventChannel]. These will listen to events fired directly to the event channel. By default, these events will also be propagated up the tree, effectively refiring the event to each parent.
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
  static BlocEventListener simpleListener(Function(dynamic) listener,
          {stopPropagation = false}) =>
      (dynamic) {
        listener(dynamic);
        return stopPropagation;
      };

  /// Fires and event that is sent up the event channel, stopping only
  /// when it reaches the top or an event stops the propagation.
  void fireEvent(String eventType, dynamic payload) {
    final shouldStopPropagation = _listenForEvent(eventType, payload);

    if (!shouldStopPropagation) {
      _parentChannel?.fireEvent(eventType, payload);
    }
  }

  /// Adds a [listener] for the specific [eventType]. Multiple listeners can be added for each [eventType]
  void addEventListener(String eventType, BlocEventListener listener) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    if (potListeners == null) {
      potListeners = [];
      _listeners[eventType] = potListeners;
    }

    potListeners.add(listener);
  }

  /// Removes the given [listener] from the given [eventType]. Will do nothing if [listener] doesn't exist.
  void removeEventListener(String eventType, BlocEventListener listener) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    potListeners?.remove(listener);
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
