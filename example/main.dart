import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

/// It is best practice to place all of your [BlocEventType]s inside an enum
/// such as this one. This allows you to have an easy place to find all of them.
///
/// Perhaps it would be a good idea to have multiple enums based on different
/// event types.
///
/// You can add the type <T> to specify the type that these events will accept.
enum ExampleEvents<T> {
  increment<void>(),
  decrement<void>(),
  ;

  /// Place this function in your event enums to automatically generate the
  /// [BlocEventType]s from your enum values!
  BlocEventType<T> get event => BlocEventType<T>('$this');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Provide the Repositories and Blocs to the Widget tree.
    return RepositoryProvider(
      create: (_) => ExampleRepository(),
      child: BlocProvider(
        create: (context, channel) => ExampleBloc(
          repo: context.read<ExampleRepository>(),
          parentChannel: channel,
        ),
        child: const MaterialApp(home: ExampleScreen()),
      ),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('The counter is currently at ${bloc.counter}'),
          Container(height: 10),
          ElevatedButton(
            onPressed: bloc.incrementCounter,
            child: const Text('Increment'),
          ),
          Container(height: 10),
          ElevatedButton(
            // Alternate way of calling using an event. This doesn't require
            // the bloc, just the event channel.
            onPressed: () =>
                context.fireEvent<void>(ExampleEvents.decrement.event, null),
            child: const Text('Decrement'),
          ),
        ],
      ),
    );
  }
}

class ExampleBloc extends Bloc {
  ExampleBloc({required this.repo, super.parentChannel}) {
    // this will be called whenever updateBloc is called
    blocUpdated.add(() => repo.saveData(counter));
    // Add event listeners as an alternative to calling the corresponding
    // methods directly.
    eventChannel
      ..addEventListener(
        ExampleEvents.increment.event,
        (_, a) => incrementCounter(),
      )
      ..addEventListener(
        ExampleEvents.decrement.event,
        (_, a) => decrementCounter(),
      );
  }
  final ExampleRepository repo;

  int counter = 0;

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
      tracker: () => [counter],
    );
  }
}

class ExampleRepository extends Repository {
  /// [generateListeners] is used to add [BlocEventListener]s to the shared
  /// [BlocEventChannel] of all [Repository]s and automatically remove them
  /// when this [Repository] is disposed.
  @override
  List<BlocEventListener<dynamic>> generateListeners(
    BlocEventChannel channel,
  ) =>
      [];

  // Define methods that can be used by a Bloc
  Future<void> saveData(int data) async {
    // ignore: avoid_print
    print('Saved Counter Value! $data');
    // Insert implementation here.
  }
}
