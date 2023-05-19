import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_classes.dart';

void main() {
  group('Test Environment', () {
    test('Basic', basicCheck);
    test('Dependency', dependencyCheck);
  });
}

void dependencyCheck() {
  Object? repositoryVal;
  final env = TestEnvironment(
    blocBuilders: [
      BlocBuilder<DependentTestBloc>(
        (readable, eventChannel) => DependentTestBloc(
          parentChannel: eventChannel,
          repository: readable.read<DependedTestRepository>(),
        ),
      )
    ],
    repositoryBuilders: [
      RepositoryBuilder<Repository>(
        (readable) => TestRepository.fromSetter((val) => repositoryVal = val),
      ),
      RepositoryBuilder<DependedTestRepository>(
        (readable) => DependedTestRepository(),
      ),
    ],
  )..initialize();

  env.eventChannel.fireEvent(TestBlocEvent.stringEvent.event, 'cool');
  expect(env.read<DependedTestRepository>().value, 'cool');
  expect(repositoryVal, 'cool');
  expect(env.read<Repository>(), isA<TestRepository>());
  expect(env.read<DependentTestBloc>().value, null);

  env.eventChannel.fireEvent(TestBlocEvent.reloadEvent.event, null);
  expect(env.read<DependedTestRepository>().value, 'cool');
  expect(repositoryVal, null);
  expect(env.read<Repository>(), isA<TestRepository>());
  expect(env.read<DependentTestBloc>().value, 'cool');
}

void basicCheck() {
  Object? blocVal;
  Object? repositoryVal;
  final env = TestEnvironment(
    blocBuilders: [
      BlocBuilder<TestBloc>(
        (readable, eventChannel) =>
            TestBloc.fromSetter((val) => blocVal = val, eventChannel),
      )
    ],
    repositoryBuilders: [
      RepositoryBuilder<TestRepository>(
        (readable) => TestRepository.fromSetter((val) => repositoryVal = val),
      ),
    ],
  )..initialize();

  env.eventChannel.fireEvent(TestBlocEvent.intEvent.event, 1);
  expect(blocVal, 1);
  expect(repositoryVal, 1);

  env.eventChannel.fireEvent(TestBlocEvent.stringEvent.event, 'cool');
  expect(blocVal, 'cool');
  expect(repositoryVal, 'cool');

  env.eventChannel.fireEvent(TestBlocEvent.reloadEvent.event, null);
  expect(blocVal, null);
  expect(repositoryVal, null);

  env.repositorySource.channel.fireEvent(TestBlocEvent.boolEvent.event, false);
  expect(blocVal, null);
  expect(repositoryVal, false);

  env.dispose();

  env.eventChannel.fireEvent(TestBlocEvent.stringEvent.event, 'cool');
  expect(blocVal, null);
  expect(repositoryVal, false);
}
