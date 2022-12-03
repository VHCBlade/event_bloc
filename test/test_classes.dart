import 'package:event_bloc/event_bloc.dart';

enum TestBlocEvent<T> {
  stringEvent<String>(),
  intEvent<int>(),
  boolEvent<bool>(),
  reloadEvent<void>(),
  ;

  BlocEventType<T> get event => BlocEventType<T>("$this");
}

class TestRepository extends Repository {
  final List<BlocEventListener> Function(BlocEventChannel) listenerGenerator;

  TestRepository(this.listenerGenerator);

  factory TestRepository.fromSetter(void Function(dynamic val) set) {
    return TestRepository(
      (channel) => [
        channel.addEventListener<int>(
            TestBlocEvent.intEvent.event, (_, newVal) => set(newVal)),
        channel.addEventListener<String>(
            TestBlocEvent.stringEvent.event, (_, newVal) => set(newVal)),
        channel.addEventListener<bool>(
            TestBlocEvent.boolEvent.event, (_, newVal) => set(newVal)),
        channel.addEventListener<void>(
            TestBlocEvent.reloadEvent.event, (_, newVal) => set(null)),
      ],
    );
  }

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) {
    return listenerGenerator(channel);
  }
}

class TestBloc extends Bloc {
  final List<BlocEventListener> Function(BlocEventChannel) listenerGenerator;

  factory TestBloc.fromSetter(
      void Function(dynamic val) set, BlocEventChannel? parentChannel) {
    return TestBloc(
      (channel) => [
        channel.addEventListener<int>(
            TestBlocEvent.intEvent.event, (_, newVal) => set(newVal)),
        channel.addEventListener<String>(
            TestBlocEvent.stringEvent.event, (_, newVal) => set(newVal)),
        channel.addEventListener<bool>(
            TestBlocEvent.boolEvent.event, (_, newVal) => set(newVal)),
        channel.addEventListener<void>(
            TestBlocEvent.reloadEvent.event, (_, newVal) => set(null)),
      ],
      parentChannel: parentChannel,
    );
  }

  TestBloc(this.listenerGenerator, {required super.parentChannel}) {
    listenerGenerator(eventChannel);
  }
}

class DependedTestRepository extends Repository {
  String value = "";

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [
        channel.addEventListener<String>(
            TestBlocEvent.stringEvent.event, (_, val) => value = val)
      ];
}

class DependentTestBloc extends Bloc {
  final DependedTestRepository repository;
  String? value;

  DependentTestBloc({required super.parentChannel, required this.repository}) {
    eventChannel.addEventListener(
        TestBlocEvent.reloadEvent.event, (_, val) => value = repository.value);
  }
}
