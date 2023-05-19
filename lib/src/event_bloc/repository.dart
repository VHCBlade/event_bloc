import 'package:event_bloc/event_bloc.dart';
import 'package:meta/meta.dart';

/// This is the building block of your [Repository] layer.
///
/// Place all of your platform specific and network specific implementations
/// inside an individual Repository! This is also a great place to implement
/// some test classes so that you can more easily test your [Bloc]s.
///
/// Provide this down with RepositoryProvider
abstract class Repository implements Disposable {
  /// This is shared between all [Repository]s in the repository layer.
  late final BlocEventChannel channel;
  late final List<BlocEventListener<dynamic>> _listeners;

  /// Initializes this repository, adding the listeners produced by
  /// [generateListeners] to the given [channel].
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
  List<BlocEventListener<dynamic>> generateListeners(BlocEventChannel channel);

  @override
  @mustCallSuper
  void dispose() {
    _listeners.forEach((value) => value.unsubscribe());
  }
}

/// [RepositorySource] holds all the the shared resources of all [Repository]s
///
/// This will automatically be provided if one doesn't already exist in the
/// Widget tree when a RepositoryProvider generates a [Repository]
class RepositorySource implements Disposable {
  /// [debugger] can be specified to have this use the provided one, rather than
  /// generating its own.
  RepositorySource([BlocEventChannelDebugger? debugger]) {
    this.debugger = debugger ??
        BlocEventChannelDebugger(
          printHandled: false,
          printUnhandled: true,
        );
  }

  /// The debugger that will log events based on its settings.
  ///
  /// All [BlocEventChannel]s that have [channel] as an ancestor will be subject
  /// to this.
  late final BlocEventChannelDebugger debugger;

  /// This is the [BlocEventChannel] that is used to help debug the events that
  /// run through the all the [BlocEventChannel]s
  BlocEventChannel get debugChannel => debugger.eventChannel;

  /// This is the [BlocEventChannel] that will be used by all of the
  /// [Repository]s
  late final BlocEventChannel channel = BlocEventChannel(debugger.eventChannel);

  @override
  @mustCallSuper
  void dispose() {
    debugChannel.dispose();
    channel.dispose();
  }
}
