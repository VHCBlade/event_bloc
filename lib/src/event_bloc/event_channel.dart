/// Event Listener, return value is true if the event is to be stopped from propagating
typedef BlocEventListener = bool Function(dynamic);

class BlocEventChannel {
  final BlocEventChannel? _parentChannel;
  final Map<String, List<BlocEventListener>> _listeners = {};

  BlocEventChannel([this._parentChannel]);

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

  /// Listens for the event, will return whether the event should be
  /// propagated up the channel or not.
  bool _listenForEvent(String eventType, dynamic payload) {
    List<BlocEventListener>? potListeners = _listeners[eventType];

    if (potListeners == null || potListeners.isEmpty) {
      return false;
    }

    return potListeners
        .map((listener) => listener(payload))
        .reduce((a, b) => a || b);
  }

  void dispose() {
    _listeners.clear();
  }
}
