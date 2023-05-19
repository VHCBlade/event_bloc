import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// maps the [Bloc] to the [ChangeNotifier] widget from [Provider]
class BlocNotifier<T extends Bloc> with ChangeNotifier {
  /// maps the [Bloc] to the [ChangeNotifier] widget from [Provider]
  BlocNotifier(this.bloc) {
    bloc.blocUpdated.add(notifyListeners);
  }

  /// The bloc that will have its [Bloc.updateBloc] attached to
  /// [notifyListeners]
  final T bloc;
}

/// Provides a [Bloc] and will automatically wrap and provide the equivalent
/// [BlocNotifier] and [BlocEventChannel]
///
/// Also provides static functions to get the [Bloc] when provided with the
/// [BuildContext]
///
/// If you wish to reduce the nesting of using multiple [BlocProvider]s, look
/// into using [MultiBlocProvider] with some [BlocBuilder]s
class BlocProvider<T extends Bloc> extends StatefulWidget {
  /// [create] generates the bloc that will be provided.
  const BlocProvider({
    required this.create,
    required this.child,
    super.key,
  });

  /// [builder] is used to create the bloc to be provided.
  factory BlocProvider.fromBuilder({
    required BlocBuilder<T> builder,
    required Widget child,
  }) =>
      BlocProvider(
        create: (context, channel) =>
            builder.builder(context.asReadable(), channel),
        child: child,
      );

  /// The child to whom the bloc will be provied.
  final Widget child;

  /// The function to create the instance of the bloc to be provided.
  final T Function(BuildContext, BlocEventChannel?) create;

  /// Similar to the [WatchContext.watch] method from the Provider package.
  ///
  /// [Bloc]s normally won't automatically redraw the [Widget] that calls them,
  /// unless you specifically watch the [BlocNotifier]. This is a helper
  /// function to remove the boilerplate of retrieving the [BlocNotifier] and
  /// unwrapping it.
  static T watch<T extends Bloc>(BuildContext context) =>
      context.watch<BlocNotifier<T>>().bloc;

  /// Similar to the [ReadContext.read] method from the Provider package.
  static T read<T extends Bloc>(BuildContext context) =>
      context.read<BlocNotifier<T>>().bloc;

  /// Similar to the [SelectContext.select] method from the Provider package.
  static R select<T extends Bloc, R>(
    BuildContext context,
    R Function(T) selector,
  ) =>
      context.select<BlocNotifier<T>, R>((a) => selector(a.bloc));

  @override
  State<BlocProvider<T>> createState() => _BlocProviderState<T>();
}

class _BlocProviderState<T extends Bloc> extends State<BlocProvider<T>> {
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
          create: (_) => BlocNotifier<T>(bloc),
        ),
      ],
      child: widget.child,
    );
  }
}
