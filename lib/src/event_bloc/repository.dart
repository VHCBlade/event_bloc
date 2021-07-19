import 'package:event_bloc/event_bloc_no_widgets.dart';
import 'package:flutter/material.dart';

class Repository implements Disposable {
  late final BlocEventChannel channel;
  late final Map<String, BlocEventListener> _listenerMap;

  /// Initializes this repository, adding the listeners produced by [generateListenerMap] to the given [channel].
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
  @mustCallSuper
  void dispose() {
    _listenerMap.forEach(channel.removeEventListener);
  }
}

/// [RepositorySource] holds all the the shared resources of all [Repository]s
class RepositorySource implements Disposable {
  final BlocEventChannel channel = BlocEventChannel();

  @override
  @mustCallSuper
  void dispose() {
    channel.dispose();
  }
}
