import 'package:event_bloc/event_bloc_no_widgets.dart';
import 'package:flutter/material.dart';

/// This is the building block of your [Repository] layer.
///
/// Place all of your platform specific and network specific implementations inside an individual Repository! This is also a great place to implement some test classes so that you can more easily test your [Bloc]s.
///
/// Provide this down with [RepositoryProvider]
class Repository implements Disposable {
  /// This is shared between all [Repository]s in the repository layer.
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

  /// Generates the listener map that this [Repository] will add to the shared [channel] to listen for events relevant to this [Repository]
  Map<String, BlocEventListener> generateListenerMap() => {};

  @override
  @mustCallSuper
  void dispose() {
    _listenerMap.forEach(channel.removeEventListener);
  }
}

/// [RepositorySource] holds all the the shared resources of all [Repository]s
///
/// This will automatically be provided if one doesn't already exist in the Widget tree when a [RepositoryProvider] generates a [Repository]
class RepositorySource implements Disposable {
  final BlocEventChannel channel = BlocEventChannel();

  @override
  @mustCallSuper
  void dispose() {
    channel.dispose();
  }
}
