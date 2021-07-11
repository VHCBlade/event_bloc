/// Event Listener, return value is true if the event is to be stopped from propagating
typedef BlocEventListener = bool Function(dynamic);

class BlocEventChannel implements Disposable {
  final BlocEventChannel? _parentChannel;
  final Map<String, List<BlocEventListener>> _listeners = {};

  BlocEventChannel([this._parentChannel]);

  /// Helper function to simplify making a [BlocEventListener] by calling
  /// [listener] and then returning [stopPropagation]
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

  /// Adds a listener for the specific event type.
  void addEventListener(String eventType, BlocEventListener listener) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    if (potListeners == null) {
      potListeners = [];
      _listeners[eventType] = potListeners;
    }

    potListeners.add(listener);
  }

  /// Adds a listener for the specific event type.
  void removeEventListener(String eventType, BlocEventListener listener) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    potListeners?.remove(listener);
  }

  /// Executes the listeners for the [eventType] with the given [payload]
  ///
  /// Will return true if the event should no longer be propagated up the event
  /// channel.
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

abstract class Disposable {
  void dispose() {}
}
