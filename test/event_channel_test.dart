import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event', () {
    test('Basic', basicCheck);
    test('Multiple', multipleCheck);
    test('Remove', removeCheck);
    group('Propagation', () {
      test('Stop', stopPropagationCheck);
      test('Ignore', ignoreStopPropagationCheck);
    });
  });
}

const cool = BlocEventType<String>("Cool");
const listener = BlocEventType<String>("Listener");
const intense = BlocEventType<String>("Intense");

void basicCheck() {
  final channel = BlocEventChannel();
  var check = '';

  channel.addEventListener(cool, (_, a) => check += 'Cool');

  channel.addEventListener(listener, (_, val) => check += '$val');

  channel.fireEvent(cool, null);
  expect(check, 'Cool');
  channel.fireEvent(listener, null);
  expect(check, 'Coolnull');
  channel.fireEvent(listener, 'mega');
  expect(check, 'Coolnullmega');
  channel.fireEvent(cool, 'mega');
  expect(check, 'CoolnullmegaCool');
  channel.fireEvent(intense, 'mega');
  expect(check, 'CoolnullmegaCool');
}

const midEvent = BlocEventType<String>("Mid");
const bottomEvent = BlocEventType<String>("Bottom");
const altEvent = BlocEventType<String>("Alt");

void multipleCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);
  final alt = BlocEventChannel(main);

  var mainCheck = '';
  var nonMainCheck = '';

  main.addEventListener<String>(midEvent, (_, val) => mainCheck += val);
  main.addEventListener<String>(bottomEvent, (_, val) => mainCheck += val);
  main.addEventListener<String>(altEvent, (_, val) => mainCheck += val);
  mid.addEventListener<String>(midEvent, (_, val) => nonMainCheck += val);
  alt.addEventListener<String>(altEvent, (_, val) => nonMainCheck += val);
  bottom.addEventListener<String>(bottomEvent, (_, val) => nonMainCheck += val);

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'Mid');
  expect(mainCheck, nonMainCheck);
  alt.fireEvent(altEvent, 'Alt');
  expect(mainCheck, 'MidAlt');
  expect(mainCheck, nonMainCheck);
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidAltBottom');
  expect(mainCheck, nonMainCheck);

  mid.addEventListener<String>(bottomEvent, (_, val) => nonMainCheck += val);
  bottom.fireEvent(bottomEvent, 'Both');
  expect(mainCheck, 'MidAltBottomBoth');
  expect(nonMainCheck, 'MidAltBottomBothBoth');
}

void removeCheck() {
  final channel = BlocEventChannel();
  var check = 0;

  channel.addEventListener(cool, (_, a) => check++);
  final doubleCheck = channel.addEventListener(cool, (_, a) => check += 2);

  channel.fireEvent(cool, null);
  expect(check, 3);

  channel.removeEventListener(cool, doubleCheck);
  channel.fireEvent(cool, null);
  expect(check, 4);

  final tripleCheck = channel.addEventListener(cool, (_, a) => check += 3);
  channel.fireEvent(cool, null);
  expect(check, 8);

  tripleCheck.unsubscribe();
  channel.fireEvent(cool, null);
  expect(check, 9);

  channel.dispose();
  channel.fireEvent(cool, null);
  expect(check, 9);

  channel.addEventListener(cool, doubleCheck.eventListenerAction);
  channel.addEventListener(cool, doubleCheck.eventListenerAction);
  channel.fireEvent(cool, null);
  expect(check, 13);

  channel.dispose();
  channel.fireEvent(cool, null);
  expect(check, 13);
}

void stopPropagationCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);

  var mainCheck = '';
  var nonMainCheck = '';

  main.addEventListener<String>(midEvent, (_, val) => mainCheck += val);
  main.addEventListener<String>(bottomEvent, (_, val) => mainCheck += val);

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottom');

  mid.addEventListener<String>(midEvent, (event, val) {
    event.propagate = true;
    nonMainCheck += val;
  });
  bottom.addEventListener<String>(bottomEvent, (event, val) {
    event.propagate = false;
    nonMainCheck += val;
  });

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'MidBottomMid');
  expect(nonMainCheck, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottomMid');
  expect(nonMainCheck, 'MidBottom');

  mainCheck = '';
  nonMainCheck = '';
  mid.addEventListener<String>(midEvent, (event, val) {
    event.propagate = false;
    nonMainCheck += val;
  });

  mid.fireEvent(midEvent, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, '');
  expect(nonMainCheck, 'MidMidBottom');
}

void ignoreStopPropagationCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);

  var mainCheck = '';
  var nonMainCheck = '';

  main.addEventListener<String>(midEvent, (_, val) => mainCheck += val,
      ignoreStopPropagation: true);
  main.addEventListener<String>(bottomEvent, (_, val) => mainCheck += val,
      ignoreStopPropagation: true);

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottom');

  mid.addEventListener<String>(midEvent, (event, val) {
    event.propagate = true;
    nonMainCheck += val;
  });
  bottom.addEventListener<String>(bottomEvent, (event, val) {
    event.propagate = false;
    nonMainCheck += val;
  });

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'MidBottomMid');
  expect(nonMainCheck, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottomMidBottom');
  expect(nonMainCheck, 'MidBottom');

  mainCheck = '';
  nonMainCheck = '';
  mid.addEventListener<String>(midEvent, (event, val) {
    event.propagate = false;
    nonMainCheck += val;
  });

  mid.fireEvent(midEvent, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottom');
  expect(nonMainCheck, 'MidMidBottom');
}
