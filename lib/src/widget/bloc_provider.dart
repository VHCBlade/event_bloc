import 'package:event_bloc/src/event_bloc/event_channel.dart';
import 'package:event_bloc/src/event_bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// maps the [Bloc] to the [ChangeNotifier] widget from [Provider]
class BlocNotifier<T extends Bloc> with ChangeNotifier {
  final T bloc;

  BlocNotifier(this.bloc) {
    bloc.blocUpdated.add(notifyListeners);
  }
}

/// Provides a [Bloc] and will automatically wrap and provide the equivalent [BlocNotifier] and [BlocEventChannel]
///
/// Also provides static functions to get the [Bloc] when provided with the [BuildContext]
class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T Function(BuildContext, BlocEventChannel?) create;

  const BlocProvider({Key? key, required this.child, required this.create})
      : super(key: key);

  /// Similar to the [BuildContext.watch] method from the Provider package.
  ///
  /// [Bloc]s normally won't automatically redraw the [Widget] that calls them,
  /// unless you specifically watch the [BlocNotifier]. This is a helper
  /// function to remove the boilerplate of retrieving the [BlocNotifier] and
  /// unwrapping it.
  static T watch<T extends Bloc>(BuildContext context) =>
      context.watch<BlocNotifier<T>>().bloc;

  /// Similar to the [BuildContext.read] method from the Provider package.
  static T read<T extends Bloc>(BuildContext context) =>
      context.read<BlocNotifier<T>>().bloc;

  /// Similar to the [BuildContext.watch] method from the Provider package.
  static R select<T extends Bloc, R>(
          BuildContext context, R Function(T) selector) =>
      context.select<BlocNotifier<T>, R>((a) => selector(a.bloc));

  @override
  BlocProviderState<T> createState() => BlocProviderState<T>();
}

class BlocProviderState<T extends Bloc> extends State<BlocProvider<T>> {
  late final T bloc;

  @override
  void initState() {
    super.initState();
    BlocEventChannel? eventChannel;
    try {
      eventChannel = context.read<BlocEventChannel>();
    } on Object {
      // If something goes wrong, just set it to null.
      // Most common will be the absence of the event channel
      eventChannel = null;
    }

    bloc = widget.create(context, eventChannel);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.eventChannel.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: bloc.eventChannel),
        Provider.value(value: bloc),
        ChangeNotifierProvider<BlocNotifier<T>>(
            create: (_) => BlocNotifier<T>(bloc)),
      ],
      child: widget.child,
    );
  }
}
