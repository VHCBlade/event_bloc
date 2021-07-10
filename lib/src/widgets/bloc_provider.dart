import 'package:event_bloc/src/event_bloc/event_channel.dart';
import 'package:event_bloc/src/event_bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlocNotifier<T extends Bloc> with ChangeNotifier {
  final T model;

  BlocNotifier(this.model) {
    model.blocUpdated.add(notifyListeners);
  }
}

class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T Function(BuildContext, BlocEventChannel?) create;

  const BlocProvider({Key? key, required this.child, required this.create})
      : super(key: key);

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();
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
            create: (_) => BlocNotifier<T>(bloc)),
      ],
      child: widget.child,
    );
  }
}
