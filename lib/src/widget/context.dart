import 'package:event_bloc/event_bloc.dart';
import 'package:event_bloc/src/widget/bloc_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension EventBlocBuildContext on BuildContext {
  /// Convenience function that will find the closest [BlocEventChannel] in the
  /// [BuildContext] and calls [fireEvent]
  void fireEvent<T>(BlocEventType<T> eventType, T payload) {
    read<BlocEventChannel>().fireEvent(eventType, payload);
  }

  /// The closest ancestor [BlocEventChannel] in this [BuildContext]
  BlocEventChannel get eventChannel => read<BlocEventChannel>();

  /// Similar to the [BuildContext.watch] method from the Provider package.
  ///
  /// [Bloc]s normally won't automatically redraw the [Widget] that calls them,
  /// unless you specifically watch the [BlocNotifier]. This is a helper
  /// function to remove the boilerplate of retrieving the [BlocNotifier] and
  /// unwrapping it.
  T watchBloc<T extends Bloc>(BuildContext context) =>
      BlocProvider.watch<T>(context);

  /// Similar to the [BuildContext.read] method from the Provider package.
  T readBloc<T extends Bloc>(BuildContext context) =>
      BlocProvider.read<T>(context);

  /// Similar to the [BuildContext.watch] method from the Provider package.
  R selectBloc<T extends Bloc, R>(
          BuildContext context, R Function(T) selector) =>
      BlocProvider.select<T, R>(context, selector);
}
