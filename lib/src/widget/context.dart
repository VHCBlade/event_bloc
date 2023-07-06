import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Adds event bloc convenience functions to [BuildContext]
extension EventBlocBuildContext on BuildContext {
  /// Convenience function that will find the closest [BlocEventChannel] in the
  /// [BuildContext] and calls [fireEvent]
  ///
  /// [withDelay] will cause the event to be fired with a short delay. This is
  /// useful when calling fireEvent in initState or other parts of the Widget
  /// building command to avoid interrupting the draw function.
  void fireEvent<T>(
    BlocEventType<T> eventType,
    T payload, {
    bool withDelay = false,
  }) {
    if (withDelay) {
      Future<void>.delayed(Duration.zero)
          .then((_) => fireEvent(eventType, payload));
      return;
    }
    read<BlocEventChannel>().fireEvent(eventType, payload);
  }

  /// Converts this [BuildContext] into a [Readable].
  Readable asReadable() => ReadableFromFunc(read);

  /// The closest ancestor [BlocEventChannel] in this [BuildContext]
  BlocEventChannel get eventChannel => read<BlocEventChannel>();

  /// Similar to the [WatchContext.watch] method from the Provider package.
  ///
  /// [Bloc]s normally won't automatically redraw the [Widget] that calls them,
  /// unless you specifically watch the [BlocNotifier]. This is a helper
  /// function to remove the boilerplate of retrieving the [BlocNotifier] and
  /// unwrapping it.
  T watchBloc<T extends Bloc>() => BlocProvider.watch<T>(this);

  /// Similar to the [ReadContext.read] method from the Provider package.
  T readBloc<T extends Bloc>() => BlocProvider.read<T>(this);

  /// Similar to the [SelectContext.select] method from the Provider package.
  R selectBloc<T extends Bloc, R>(R Function(T) selector) =>
      BlocProvider.select<T, R>(this, selector);
}
