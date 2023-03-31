import 'package:event_bloc/event_bloc.dart';
import 'package:meta/meta.dart';

/// This is the building block of your [Repository] layer.
///
/// Place all of your platform specific and network specific implementations inside an individual Repository! This is also a great place to implement some test classes so that you can more easily test your [Bloc]s.
///
/// Provide this down with [RepositoryProvider]
abstract class Repository implements Disposable {
  /// This is shared between all [Repository]s in the repository layer.
  late final BlocEventChannel channel;
  late final List<BlocEventListener> _listeners;

  /// Initializes this repository, adding the listeners produced by [generateListenerMap] to the given [channel].
  ///
  /// This can only be used a single time.
  void initialize(BlocEventChannel channel) {
    this.channel = channel;
    _listeners = generateListeners(channel);
  }

  /// Generates the listener map that this [Repository] will remove from the
  /// [channel] when this repository is disposed.
  ///
  /// This method is assumed to have added the listeners to the channel itself.
  List<BlocEventListener> generateListeners(BlocEventChannel channel);

  @override
  @mustCallSuper
  void dispose() {
    _listeners.forEach((value) => value.unsubscribe());
  }
}

/// [RepositorySource] holds all the the shared resources of all [Repository]s
///
/// This will automatically be provided if one doesn't already exist in the
/// Widget tree when a [RepositoryProvider] generates a [Repository]
class RepositorySource implements Disposable {
  /// This is the [BlocEventChannel] that is used to help debug the events that
  /// run through the all the [BlocEventChannel]s
  final BlocEventChannel debugChannel = BlocEventChannel();

  /// This is the [BlocEventChannel] that will be used by all of the
  /// [Repository]s
  late final BlocEventChannel channel = BlocEventChannel(debugChannel);

  @override
  @mustCallSuper
  void dispose() {
    channel.dispose();
  }
}
