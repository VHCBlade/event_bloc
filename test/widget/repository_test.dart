import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../repository_test.dart';

const adder = BlocEvent<int>("adder");

void main() {
  group('Repository', () {
    group('Event', () {
      testWidgets('Basic', basicEventCheck);
      testWidgets('Dispose', disposeEventCheck);
      testWidgets('Multiple', multipleEventCheck);
    });
  });
}

Future<void> createWidget(
    WidgetTester tester, TestRepository repository) async {
  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => repository,
      child: Builder(
        builder: (context) => CupertinoButton(
          key: const ValueKey("1"),
          onPressed: () =>
              BlocEventChannelProvider.of(context).fireBlocEvent(adder, 10),
          child: Container(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> fireEvent(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey("1")));
  await tester.pumpAndSettle();
}

Future<void> basicEventCheck(WidgetTester tester) async {
  int i = 0;
  await createWidget(
    tester,
    TestRepository(
        {adder: BlocEventChannel.simpleListener((val) => i += val as int)}),
  );
  await fireEvent(tester);
  expect(i, 10);

  await fireEvent(tester);
  await fireEvent(tester);

  expect(i, 30);
}

Future<void> disposeEventCheck(WidgetTester tester) async {
  int i = 0;
  final repository = TestRepository(
      {adder: BlocEventChannel.simpleListener((val) => i += val as int)});
  await createWidget(tester, repository);
  await fireEvent(tester);
  expect(i, 10);

  repository.dispose();

  await fireEvent(tester);
  await fireEvent(tester);

  expect(i, 10);
}

Future<void> multipleEventCheck(WidgetTester tester) async {
  int i = 0;
  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => TestRepository(
          {adder: BlocEventChannel.simpleListener((val) => i += val as int)}),
      child: RepositoryProvider(
        create: (_) => TestRepository(
            {adder: BlocEventChannel.simpleListener((val) => i += val as int)}),
        child: Builder(
          builder: (context) => CupertinoButton(
            key: const ValueKey("1"),
            onPressed: () =>
                BlocEventChannelProvider.of(context).fireBlocEvent(adder, 10),
            child: Container(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await fireEvent(tester);
  expect(i, 20);

  await fireEvent(tester);
  await fireEvent(tester);

  expect(i, 60);
}
