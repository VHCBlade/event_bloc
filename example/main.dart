import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

const INCREMENT_EVENT = 'increment';
const DECREMENT_EVENT = 'decrement';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Provide the Repositories and Blocs to the Widget tree.
    return RepositoryProvider(
      create: (_) => ExampleRepository(),
      child: BlocProvider(
        create: (context, channel) => ExampleBloc(
            repo: context.read<ExampleRepository>(), parentChannel: channel),
        child: const MaterialApp(home: ExampleScreen()),
      ),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the watch function of BlocProvider rather than the one given by the
    // Provider package. This is to be convenient over calling
    // context.watch<BlocNotifier<ExampleBloc>>().bloc
    //
    // This will automatically redraw whenever bloc.updateBloc is called.
    final bloc = BlocProvider.watch<ExampleBloc>(context);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('The counter is currently at ${bloc.counter}'),
        Container(height: 10),
        ElevatedButton(
            onPressed: () => bloc.incrementCounter(),
            child: const Text('Increment')),
        Container(height: 10),
        ElevatedButton(
            // Alternate way of calling using an event. This doesn't require
            // the bloc, just the event channel.
            onPressed: () => context
                .read<BlocEventChannel>()
                .fireEvent(DECREMENT_EVENT, null),
            child: const Text('Decrement')),
      ]),
    );
  }
}

class ExampleBloc extends Bloc {
  @override
  final BlocEventChannel eventChannel;
  final ExampleRepository repo;

  int counter = 0;

  ExampleBloc({required this.repo, BlocEventChannel? parentChannel})
      : eventChannel = BlocEventChannel(parentChannel) {
    // this will be called whenever updateBloc is called
    blocUpdated.add(() => repo.saveData(counter));
    // Add event listeners as an alternative to calling the corresponding methods
    // directly.
    eventChannel.addEventListener(INCREMENT_EVENT,
        BlocEventChannel.simpleListener((_) => incrementCounter()));
    eventChannel.addEventListener(DECREMENT_EVENT,
        BlocEventChannel.simpleListener((_) => decrementCounter()));
  }

  void incrementCounter() {
    counter++;
    // Always call this after making changes to things displayed by the UI
    updateBloc();
  }

  void decrementCounter() {
    // This is a convenience method that will only call updateBloc if the value
    // returned by tracker changes. This saves frames from being redrawn
    // unnecessarily
    updateBlocOnChange(
        change: () {
          if (counter == 0) {
            return;
          }
          counter--;
        },
        tracker: () => [counter]);
  }
}

class ExampleRepository extends Repository {
  /// [generateListenerMap] is used to add [BlocEventListener]s to the shared
  /// [BlocEventChannel] of all [Repository]s and automatically remove them
  /// when this [Repository] is disposed.
  @override
  Map<String, BlocEventListener> generateListenerMap() => {};

  // Define methods that can be used by a Bloc
  Future<void> saveData(int data) async {
    // ignore: avoid_print
    print('Saved Counter Value! $data');
    // Insert implementation here.
  }
}
