import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event', () {
    test('Basic', basicCheck);
    test('Multiple', multipleCheck);
    test('UserInitiated', userInitiatedCheck);
    test('Remove', removeCheck);
    test('EventBus', eventBusCheck);
    group('Propagation', () {
      test('Stop', stopPropagationCheck);
      test('Ignore', ignoreStopPropagationCheck);
    });
    test('Parent', parentCountCheck);
    test('Generic', genericCheck);
  });
}

const cool = BlocEventType<String>('Cool');
const listener = BlocEventType<String>('Listener');
const intense = BlocEventType<String>('Intense');

void basicCheck() {
  final channel = BlocEventChannel();
  var check = '';

  channel
    ..addEventListener(cool, (_, a) => check += 'Cool')
    ..addEventListener(listener, (_, val) => check += '$val')
    ..fireEvent(cool, null);
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

const midEvent = BlocEventType<String>('Mid');
const bottomEvent = BlocEventType<String>('Bottom');
const altEvent = BlocEventType<String>.fromObject(120);

void multipleCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);
  final alt = BlocEventChannel(main);

  var mainCheck = '';
  var nonMainCheck = '';

  main
    ..addEventListener<String>(midEvent, (_, val) => mainCheck += val)
    ..addEventListener<String>(bottomEvent, (_, val) => mainCheck += val)
    ..addEventListener<String>(altEvent, (_, val) => mainCheck += val);
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

void userInitiatedCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);
  final alt = BlocEventChannel(main);

  var mainCheck = '';
  var nonMainCheck = '';

  main
    ..addEventListener<String>(
      midEvent,
      (event, val) => event.eventType.userInitiated ? mainCheck += val : null,
    )
    ..addEventListener<String>(
      bottomEvent,
      (event, val) => event.eventType.userInitiated ? null : mainCheck += val,
    )
    ..addEventListener<String>(
      altEvent,
      (event, val) => event.eventType.userInitiated ? null : mainCheck += val,
    );
  mid.addEventListener<String>(
    midEvent,
    (event, val) => event.isUserInitiated ? null : nonMainCheck += val,
  );
  alt.addEventListener<String>(
    altEvent,
    (event, val) => event.isUserInitiated ? nonMainCheck += val : null,
  );
  bottom.addEventListener<String>(
    bottomEvent,
    (event, val) => event.isUserInitiated ? nonMainCheck += val : null,
  );

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'Mid');
  expect(nonMainCheck, '');
  mid.fireEvent(midEvent.copyWith(userInitiated: false), 'Mid');
  expect(mainCheck, 'Mid');
  expect(nonMainCheck, mainCheck);

  alt.fireEvent(altEvent.asUserInitiated, 'Alt');
  expect(mainCheck, 'Mid');
  expect(nonMainCheck, 'MidAlt');
  alt.fireEvent(altEvent.asNotUserInitiated, 'Alt');
  expect(mainCheck, 'MidAlt');
  expect(nonMainCheck, 'MidAlt');

  bottom.fireEvent(bottomEvent.asNotUserInitiated.asUserInitiated, 'Bottom');
  expect(mainCheck, 'MidAlt');
  expect(nonMainCheck, 'MidAltBottom');

  bottom.fireEvent(bottomEvent.asNotUserInitiated.asNotUserInitiated, 'Bottom');
  expect(mainCheck, 'MidAltBottom');
  expect(nonMainCheck, mainCheck);
}

void eventBusCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);
  final alt = BlocEventChannel(main);

  var mainCheck = '';
  var nonMainCheck = '';

  main
    ..addEventBusListener<String>(midEvent, (_, val) => mainCheck += val)
    ..addEventBusListener<String>(bottomEvent, (_, val) => mainCheck += val)
    ..addEventBusListener<String>(altEvent, (_, val) => mainCheck += val);
  mid.addEventBusListener<String>(midEvent, (_, val) => nonMainCheck += val);
  alt.addEventBusListener<String>(altEvent, (_, val) => nonMainCheck += val);
  bottom.addEventBusListener<String>(
    bottomEvent,
    (_, val) => nonMainCheck += val,
  );

  mid.eventBus.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'Mid');
  expect(mainCheck, nonMainCheck);
  alt.eventBus.fireEvent(altEvent, 'Alt');
  expect(mainCheck, 'MidAlt');
  expect(mainCheck, nonMainCheck);
  bottom.eventBus.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidAltBottom');
  expect(mainCheck, nonMainCheck);

  alt.dispose();
  main.dispose();

  mid.eventBus.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'MidAltBottom');
  expect(nonMainCheck, 'MidAltBottomMid');
  alt.eventBus.fireEvent(altEvent, 'Alt');
  expect(mainCheck, 'MidAltBottom');
  expect(nonMainCheck, 'MidAltBottomMid');
  bottom.eventBus.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidAltBottom');
  expect(nonMainCheck, 'MidAltBottomMidBottom');
}

void removeCheck() {
  final channel = BlocEventChannel();
  var check = 0;

  channel.addEventListener(cool, (_, a) => check++);
  final doubleCheck = channel.addEventListener(cool, (_, a) => check += 2);

  channel.fireEvent(cool, null);
  expect(check, 3);

  channel
    ..removeEventListener(cool, doubleCheck)
    ..fireEvent(cool, null);
  expect(check, 4);

  final tripleCheck = channel.addEventListener(cool, (_, a) => check += 3);
  channel.fireEvent(cool, null);
  expect(check, 8);

  tripleCheck.unsubscribe();
  channel.fireEvent(cool, null);
  expect(check, 9);

  channel
    ..dispose()
    ..fireEvent(cool, null);
  expect(check, 9);

  channel
    ..addEventListener(cool, doubleCheck.eventListenerAction)
    ..addEventListener(cool, doubleCheck.eventListenerAction)
    ..fireEvent(cool, null);
  expect(check, 13);

  channel
    ..dispose()
    ..fireEvent(cool, null);
  expect(check, 13);
}

void stopPropagationCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);

  var mainCheck = '';
  var nonMainCheck = '';

  main
    ..addEventListener<String>(midEvent, (_, val) => mainCheck += val)
    ..addEventListener<String>(bottomEvent, (_, val) => mainCheck += val);

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
  mid
    ..addEventListener<String>(midEvent, (event, val) {
      event.propagate = false;
      nonMainCheck += val;
    })
    ..fireEvent(midEvent, 'Mid');
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

  main
    ..addEventListener<String>(
      midEvent,
      (_, val) => mainCheck += val,
      ignoreStopPropagation: true,
    )
    ..addEventListener<String>(
      bottomEvent,
      (_, val) => mainCheck += val,
      ignoreStopPropagation: true,
    );

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
  mid
    ..addEventListener<String>(midEvent, (event, val) {
      event.propagate = false;
      nonMainCheck += val;
    })
    ..fireEvent(midEvent, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottom');
  expect(nonMainCheck, 'MidMidBottom');
}

void genericCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);

  var mainCheck = '';

  final listener = main.addGenericEventListener(
    (_, val) => mainCheck += '$val',
  );

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottom');

  mid.fireEvent(midEvent, 'Mid');
  expect(mainCheck, 'MidBottomMid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottomMidBottom');

  mainCheck = '';
  mid
    ..addEventListener<String>(midEvent, (event, val) {
      event.propagate = false;
    })
    ..fireEvent(midEvent, 'Mid');
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, 'MidBottom');

  main.removeGenericEventListener(listener);
  mainCheck = '';
  bottom.fireEvent(bottomEvent, 'Bottom');
  expect(mainCheck, '');
}

void parentCountCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);

  expect(bottom.parentCount, 2);
  expect(mid.parentCount, 1);
  expect(main.parentCount, 0);
}
