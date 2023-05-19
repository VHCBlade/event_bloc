import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_classes.dart';

void main() {
  group('MultiProvider', () {
    testWidgets('Bloc', blocTest);
    testWidgets('Repository', repositoryTest);
  });
}

Future<void> repositoryTest(WidgetTester tester) async {
  dynamic repositoryVal = 'great';
  late String? Function() loadValue;
  await tester.pumpWidget(
    MultiRepositoryProvider(
      repositoryBuilders: [
        RepositoryBuilder<TestRepository>(
          (readable) => TestRepository.fromSetter((val) => repositoryVal = val),
        ),
        RepositoryBuilder<DependedTestRepository>((readable) {
          final repo = DependedTestRepository()..value = 'cool';
          readable.read<TestRepository>();
          loadValue = () => repo.value;
          return repo;
        }),
      ],
      child: Builder(
        builder: (context) => CupertinoButton(
          key: const ValueKey('1'),
          onPressed: () =>
              context.fireEvent(TestBlocEvent.stringEvent.event, 'Incredible'),
          child: Container(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(repositoryVal, 'great');
  expect(loadValue(), 'cool');

  await tester.tap(find.byKey(const ValueKey('1')));
  await tester.pumpAndSettle();
  expect(repositoryVal, 'Incredible');
  expect(loadValue(), 'Incredible');
}

Future<void> blocTest(WidgetTester tester) async {
  dynamic blocVal = 'great';
  late String? Function() loadValue;
  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => DependedTestRepository()..value = 'cool',
      child: MultiBlocProvider(
        blocBuilders: [
          BlocBuilder<TestBloc>(
            (readable, eventChannel) =>
                TestBloc.fromSetter((val) => blocVal = val, eventChannel),
          ),
          BlocBuilder<DependentTestBloc>((readable, eventChannel) {
            readable.read<TestBloc>();
            final bloc = DependentTestBloc(
              parentChannel: eventChannel,
              repository: readable.read<DependedTestRepository>(),
            );
            loadValue = () => bloc.value;

            return bloc;
          }),
        ],
        child: Builder(
          builder: (context) => CupertinoButton(
            key: const ValueKey('1'),
            onPressed: () =>
                context.fireEvent(TestBlocEvent.reloadEvent.event, null),
            child: Container(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(blocVal, 'great');
  expect(loadValue(), null);

  await tester.tap(find.byKey(const ValueKey('1')));
  await tester.pumpAndSettle();
  expect(blocVal, null);
  expect(loadValue(), 'cool');
}
