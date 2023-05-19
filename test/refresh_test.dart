// ignore_for_file: inference_failure_on_instance_creation

import 'dart:async';

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

Future<void> basicCheck() async {
  var i = 0;
  final queuer = RefreshQueuer(() async => i++);

  unawaited(queuer.refresh());
  await Future.delayed(Duration.zero);
  expect(i, 1);
  unawaited(queuer.refresh());
  await Future.delayed(Duration.zero);
  expect(i, 2);
  unawaited(queuer.refresh());
  await Future.delayed(Duration.zero);
  expect(i, 3);
  unawaited(queuer.refresh());
  await Future.delayed(Duration.zero);
  expect(i, 4);
}

Future<void> delayCheck() async {
  var i = 0;
  final queuer = RefreshQueuer(() async {
    await Future.delayed(const Duration(milliseconds: 10));
    i++;
  });

  unawaited(queuer.refresh());
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 1);
  unawaited(queuer.refresh());
  unawaited(queuer.refresh());
  unawaited(queuer.refresh());
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 2);
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 3);
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 3);
  unawaited(queuer.refresh());
  unawaited(queuer.refresh());
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 4);
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 5);
  unawaited(queuer.refresh());
  await Future.delayed(const Duration(milliseconds: 10));
  expect(i, 6);
}

Future<void> basicSingleActionCheck() async {
  var i = 0;
  final queuer = SingleActionQueuer(() async => i++);

  unawaited(queuer.queue());
  await Future.delayed(Duration.zero);
  expect(i, 1);
  unawaited(queuer.queue());
  await Future.delayed(Duration.zero);
  expect(i, 1);
  unawaited(queuer.queue());
  await Future.delayed(Duration.zero);
  expect(i, 1);
  unawaited(queuer.queue());
  await Future.delayed(Duration.zero);
  expect(i, 1);
}

Future<void> delaySingleActionCheck() async {
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
