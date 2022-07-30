import 'package:event_bloc/event_bloc_no_widgets.dart';
import 'package:flutter/material.dart';

/// This is the building block of your [Repository] layer.
///
/// Place all of your platform specific and network specific implementations inside an individual Repository! This is also a great place to implement some test classes so that you can more easily test your [Bloc]s.
///
/// Provide this down with [RepositoryProvider]
abstract class Repository implements Disposable {
  /// This is shared between all [Repository]s in the repository layer.
  late final BlocEventChannel channel;
  late final Map<BlocEvent, BlocEventListener> _listenerMap;

  /// Initializes this repository, adding the listeners produced by [generateListenerMap] to the given [channel].
  ///
  /// This can only be used a single time.
  void initialize(BlocEventChannel channel) {
    this.channel = channel;
    _listenerMap = generateListenerMap(channel);
  }

  /// Generates the listener map that this [Repository] will remove from the [channel] when this repository is disposed.
  ///
  /// This method is assumed to have added the listeners to the channel itself.
  Map<BlocEvent, BlocEventListener> generateListenerMap(
      BlocEventChannel channel);

  @override
  @mustCallSuper
  void dispose() {
    _listenerMap.forEach(channel.removeBlocEventListener);
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
