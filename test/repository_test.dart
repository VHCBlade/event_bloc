import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_classes.dart';

const fire = BlocEventType<int>('fire');
const water = BlocEventType<String>('water');
const earth = BlocEventType<bool>('earth');
const wind = BlocEventType<void>('wind');

void main() {
  group('Repository', () {
    test('Basic', basicCheck);
    test('Dispose', disposeCheck);
    test('Multiple', multipleCheck);
  });
}

void basicCheck() {
  Object? val;

  final eventChannel = BlocEventChannel();

  TestRepository(
    (channel) => [
      channel.addEventListener<int>(fire, (_, newVal) => val = newVal),
      channel.addEventListener<String>(water, (_, newVal) => val = newVal),
      channel.addEventListener<bool>(earth, (_, newVal) => val = newVal),
      channel.addEventListener<void>(wind, (_, newVal) => val = null),
    ],
  ).initialize(eventChannel);

  eventChannel.fireEvent<int>(fire, 10);
  expect(val, 10);
  eventChannel.fireEvent<String>(water, 'Amazing');
  expect(val, 'Amazing');
  eventChannel.fireEvent<bool>(earth, true);
  expect(val, true);
  eventChannel.fireEvent<void>(wind, null);
  expect(val, null);
  eventChannel.fireEvent<bool>(earth, false);
  expect(val, false);
  eventChannel.fireEvent<String>(water, 'Cool');
  expect(val, 'Cool');
  eventChannel.fireEvent<void>(wind, null);
  expect(val, null);
  eventChannel.fireEvent<int>(fire, 20);
  expect(val, 20);
}

void disposeCheck() {
  Object? val;

  final eventChannel = BlocEventChannel();

  final repository = TestRepository(
    (channel) => [
      channel.addEventListener<int>(fire, (_, newVal) => val = newVal),
      channel.addEventListener<String>(water, (_, newVal) => val = newVal),
      channel.addEventListener<bool>(earth, (_, newVal) => val = newVal),
      channel.addEventListener<void>(wind, (_, newVal) => val = null),
    ],
  )..initialize(eventChannel);

  eventChannel.fireEvent<int>(fire, 10);
  expect(val, 10);

  repository.dispose();

  eventChannel.fireEvent<String>(water, 'Amazing');
  expect(val, 10);
  eventChannel.fireEvent<bool>(earth, true);
  expect(val, 10);
  eventChannel.fireEvent<void>(wind, null);
  expect(val, 10);
  eventChannel.fireEvent<bool>(earth, false);
  expect(val, 10);
  eventChannel.fireEvent<String>(water, 'Cool');
  expect(val, 10);
  eventChannel.fireEvent<void>(wind, null);
  expect(val, 10);
  eventChannel.fireEvent<int>(fire, 20);
  expect(val, 10);
}

void multipleCheck() {
  var val = 0;

  final eventChannel = BlocEventChannel();

  TestRepository(
    (channel) => [
      channel.addEventListener<int>(fire, (event, add) => val += add),
    ],
  ).initialize(eventChannel);

  eventChannel.fireEvent<int>(fire, 10);
  expect(val, 10);
  eventChannel.fireEvent<int>(fire, 20);
  expect(val, 30);
  eventChannel.fireEvent<int>(fire, -5);
  expect(val, 25);
}
