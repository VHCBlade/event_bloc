import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const fire = BlocEvent<int>("fire");
const water = BlocEvent<String>("water");
const earth = BlocEvent<bool>("earth");
const wind = BlocEvent<void>("wind");

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

  final repository = TestRepository({
    fire: BlocEventChannel.simpleListener((newVal) => val = newVal),
    water: BlocEventChannel.simpleListener((newVal) => val = newVal),
    earth: BlocEventChannel.simpleListener((newVal) => val = newVal),
    wind: BlocEventChannel.simpleListener((_) => val = null),
  });

  repository.initialize(eventChannel);

  eventChannel.fireBlocEvent<int>(fire, 10);
  expect(val, 10);
  eventChannel.fireBlocEvent<String>(water, "Amazing");
  expect(val, "Amazing");
  eventChannel.fireBlocEvent<bool>(earth, true);
  expect(val, true);
  eventChannel.fireBlocEvent<void>(wind, null);
  expect(val, null);
  eventChannel.fireBlocEvent<bool>(earth, false);
  expect(val, false);
  eventChannel.fireBlocEvent<String>(water, "Cool");
  expect(val, "Cool");
  eventChannel.fireBlocEvent<void>(wind, null);
  expect(val, null);
  eventChannel.fireBlocEvent<int>(fire, 20);
  expect(val, 20);
}

void disposeCheck() {
  Object? val;

  final eventChannel = BlocEventChannel();

  final repository = TestRepository({
    fire: BlocEventChannel.simpleListener((newVal) => val = newVal),
    water: BlocEventChannel.simpleListener((newVal) => val = newVal),
    earth: BlocEventChannel.simpleListener((newVal) => val = newVal),
    wind: BlocEventChannel.simpleListener((_) => val = null),
  });

  repository.initialize(eventChannel);

  eventChannel.fireBlocEvent<int>(fire, 10);
  expect(val, 10);

  repository.dispose();

  eventChannel.fireBlocEvent<String>(water, "Amazing");
  expect(val, 10);
  eventChannel.fireBlocEvent<bool>(earth, true);
  expect(val, 10);
  eventChannel.fireBlocEvent<void>(wind, null);
  expect(val, 10);
  eventChannel.fireBlocEvent<bool>(earth, false);
  expect(val, 10);
  eventChannel.fireBlocEvent<String>(water, "Cool");
  expect(val, 10);
  eventChannel.fireBlocEvent<void>(wind, null);
  expect(val, 10);
  eventChannel.fireBlocEvent<int>(fire, 20);
  expect(val, 10);
}

void multipleCheck() {
  var val = 0;

  final eventChannel = BlocEventChannel();

  final repository = TestRepository({
    fire: BlocEventChannel.simpleListener((add) => val += add as int),
  });

  repository.initialize(eventChannel);

  eventChannel.fireBlocEvent<int>(fire, 10);
  expect(val, 10);
  eventChannel.fireBlocEvent<int>(fire, 20);
  expect(val, 30);
  eventChannel.fireBlocEvent<int>(fire, -5);
  expect(val, 25);
}

class TestRepository extends Repository {
  final Map<BlocEvent, BlocEventListener> listenerMap;

  TestRepository(this.listenerMap);

  @override
  Map<BlocEvent, BlocEventListener> generateListenerMap(
      BlocEventChannel channel) {
    final map = <BlocEvent, BlocEventListener>{};

    for (final key in listenerMap.keys) {
      map[key] = channel.addBlocEventListener(key, listenerMap[key]!);
    }

    return map;
  }
}
