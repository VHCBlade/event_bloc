import 'package:event_bloc/event_bloc.dart';

enum TestBlocEvent<T> {
  stringEvent<String>(),
  intEvent<int>(),
  boolEvent<bool>(),
  reloadEvent<void>(),
  ;

  BlocEventType<T> get event => BlocEventType<T>('$this');
}

class TestRepository extends Repository {
  TestRepository(this.listenerGenerator);

  factory TestRepository.fromSetter(void Function(dynamic val) set) {
    return TestRepository(
      (channel) => [
        channel.addEventListener<int>(
          TestBlocEvent.intEvent.event,
          (_, newVal) => set(newVal),
        ),
        channel.addEventListener<String>(
          TestBlocEvent.stringEvent.event,
          (_, newVal) => set(newVal),
        ),
        channel.addEventListener<bool>(
          TestBlocEvent.boolEvent.event,
          (_, newVal) => set(newVal),
        ),
        channel.addEventListener<void>(
          TestBlocEvent.reloadEvent.event,
          (_, newVal) => set(null),
        ),
      ],
    );
  }
  final List<BlocEventListener<dynamic>> Function(BlocEventChannel)
      listenerGenerator;

  @override
  List<BlocEventListener<dynamic>> generateListeners(BlocEventChannel channel) {
    return listenerGenerator(channel);
  }
}

class TestBloc extends Bloc {
  TestBloc(this.listenerGenerator, {required super.parentChannel}) {
    listenerGenerator(eventChannel);
  }

  factory TestBloc.fromSetter(
    void Function(dynamic val) set,
    BlocEventChannel? parentChannel,
  ) {
    return TestBloc(
      (channel) => [
        channel.addEventListener<int>(
          TestBlocEvent.intEvent.event,
          (_, newVal) => set(newVal),
        ),
        channel.addEventListener<String>(
          TestBlocEvent.stringEvent.event,
          (_, newVal) => set(newVal),
        ),
        channel.addEventListener<bool>(
          TestBlocEvent.boolEvent.event,
          (_, newVal) => set(newVal),
        ),
        channel.addEventListener<void>(
          TestBlocEvent.reloadEvent.event,
          (_, newVal) => set(null),
        ),
      ],
      parentChannel: parentChannel,
    );
  }
  final List<BlocEventListener<dynamic>> Function(BlocEventChannel)
      listenerGenerator;
}

class DependedTestRepository extends Repository {
  String value = '';

  @override
  List<BlocEventListener<dynamic>> generateListeners(
    BlocEventChannel channel,
  ) =>
      [
        channel.addEventListener<String>(
          TestBlocEvent.stringEvent.event,
          (_, val) => value = val,
        )
      ];
}

class DependentTestBloc extends Bloc {
  DependentTestBloc({required super.parentChannel, required this.repository}) {
    eventChannel.addEventListener(
      TestBlocEvent.reloadEvent.event,
      (_, val) => value = repository.value,
    );
  }
  final DependedTestRepository repository;
  String? value;
}
