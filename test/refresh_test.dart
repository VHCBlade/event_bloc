import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefreshQueuer', () {
    test('Basic', basicCheck);
    test('Delay', delayCheck);
  });
  group('SingleActionQueuer', () {
    test('Basic', basicSingleActionCheck);
    test('Delay', delaySingleActionCheck);
  });
}

void basicCheck() async {
  int i = 0;
  final queuer = RefreshQueuer(() async => i++);

  queuer.refresh();
  await Future.delayed(Duration.zero);
  expect(i, 1);
  queuer.refresh();
  await Future.delayed(Duration.zero);
  expect(i, 2);
  queuer.refresh();
  await Future.delayed(Duration.zero);
  expect(i, 3);
  queuer.refresh();
  await Future.delayed(Duration.zero);
  expect(i, 4);
}

void delayCheck() async {
  int i = 0;
  final queuer = RefreshQueuer(() async {
    await Future.delayed(const Duration(milliseconds: 10));
    i++;
  });

  queuer.refresh();
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 1);
  queuer.refresh();
  queuer.refresh();
  queuer.refresh();
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 2);
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 3);
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 3);
  queuer.refresh();
  queuer.refresh();
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 4);
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 5);
  queuer.refresh();
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 6);
}

void basicSingleActionCheck() async {
  int i = 0;
  final queuer = SingleActionQueuer(() async => i++);

  queuer.queue();
  await Future.delayed(Duration.zero);
  expect(i, 1);
  queuer.queue();
  await Future.delayed(Duration.zero);
  expect(i, 1);
  queuer.queue();
  await Future.delayed(Duration.zero);
  expect(i, 1);
  queuer.queue();
  await Future.delayed(Duration.zero);
  expect(i, 1);
}

void delaySingleActionCheck() async {
  int i = 0;
  final queuer = SingleActionQueuer(() async {
    await Future.delayed(const Duration(milliseconds: 10));
    i++;
  });

  queuer.queue();
  await Future.delayed(const Duration(milliseconds: 5));
  queuer.queue();
  queuer.queue();
  queuer.queue();
  expect(i, 0);
  await Future.delayed(const Duration(milliseconds: 5));
  expect(i, 1);
  queuer.queue();
  queuer.queue();
  queuer.queue();
  await Future.delayed(const Duration(milliseconds: 5));
  expect(i, 1);
  await Future.delayed(const Duration(milliseconds: 5));
  expect(i, 1);
  await Future.delayed(const Duration(milliseconds: 5));
  expect(i, 1);
}
