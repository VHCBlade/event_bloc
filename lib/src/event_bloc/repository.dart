import 'package:event_bloc/event_bloc_no_widgets.dart';

class Repository implements Disposable {
  late final BlocEventChannel channel;
  late final Map<String, BlocEventListener> _listenerMap;

  /// Initializes this repository, adding the listeners produced by
  /// [generateListenerMap] to the given [channel].
  ///
  /// This can only be used a single time.
  void initialize(BlocEventChannel channel) {
    this.channel = channel;
    _listenerMap = generateListenerMap();
    _listenerMap.forEach((key, value) => channel.addEventListener(key, value));
  }

  /// Generates the listener map that this [Repository] will add to the
  Map<String, BlocEventListener> generateListenerMap() => {};

  @override
  void dispose() {
    _listenerMap.forEach(channel.removeEventListener);
  }
}

class RepositorySource {
  final BlocEventChannel channel = BlocEventChannel();
}
