import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event', () {
    test('Basic', basicCheck);
    test('Multiple', multipleCheck);
    test('Remove', removeCheck);
    test('Stop Propagation', stopPropagationCheck);
  });
}

void basicCheck() {
  final channel = BlocEventChannel();
  var check = '';

  channel.addEventListener('Cool', (_) {
    check += 'Cool';
    return false;
  });

  channel.addEventListener(
      'Listener', BlocEventChannel.simpleListener((val) => check += '$val'));

  channel.fireEvent('Cool', null);
  expect(check, 'Cool');
  channel.fireEvent('Listener', null);
  expect(check, 'Coolnull');
  channel.fireEvent('Listener', 'mega');
  expect(check, 'Coolnullmega');
  channel.fireEvent('Cool', 'mega');
  expect(check, 'CoolnullmegaCool');
  channel.fireEvent('Track', 'mega');
  expect(check, 'CoolnullmegaCool');
}

void multipleCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);
  final alt = BlocEventChannel(main);

  var mainCheck = '';
  var nonMainCheck = '';

  main.addEventListener(
      'Mid', BlocEventChannel.simpleListener((val) => mainCheck += '$val'));
  main.addEventListener(
      'Bottom', BlocEventChannel.simpleListener((val) => mainCheck += '$val'));
  main.addEventListener(
      'Alt', BlocEventChannel.simpleListener((val) => mainCheck += '$val'));
  mid.addEventListener(
      'Mid', BlocEventChannel.simpleListener((val) => nonMainCheck += '$val'));
  alt.addEventListener(
      'Alt', BlocEventChannel.simpleListener((val) => nonMainCheck += '$val'));
  bottom.addEventListener('Bottom',
      BlocEventChannel.simpleListener((val) => nonMainCheck += '$val'));

  mid.fireEvent('Mid', 'Mid');
  expect(mainCheck, 'Mid');
  expect(mainCheck, nonMainCheck);
  alt.fireEvent('Alt', 'Alt');
  expect(mainCheck, 'MidAlt');
  expect(mainCheck, nonMainCheck);
  bottom.fireEvent('Bottom', 'Bottom');
  expect(mainCheck, 'MidAltBottom');
  expect(mainCheck, nonMainCheck);

  mid.addEventListener('Bottom',
      BlocEventChannel.simpleListener((val) => nonMainCheck += '$val'));
  bottom.fireEvent('Bottom', 'Both');
  expect(mainCheck, 'MidAltBottomBoth');
  expect(nonMainCheck, 'MidAltBottomBothBoth');
}

void removeCheck() {
  final channel = BlocEventChannel();
  var check = 0;

  channel.addEventListener(
      'Cool', BlocEventChannel.simpleListener((_) => check++));
  final doubleCheck = BlocEventChannel.simpleListener((_) => check += 2);
  channel.addEventListener('Cool', doubleCheck);

  channel.fireEvent('Cool', null);
  expect(check, 3);

  channel.removeEventListener('Cool', doubleCheck);
  channel.fireEvent('Cool', null);
  expect(check, 4);

  channel.addEventListener('Cool', doubleCheck);
  channel.fireEvent('Cool', null);
  expect(check, 7);

  channel.dispose();
  channel.fireEvent('Cool', null);
  expect(check, 7);

  channel.addEventListener('Cool', doubleCheck);
  channel.fireEvent('Cool', null);
  expect(check, 9);
}

void stopPropagationCheck() {
  final main = BlocEventChannel();
  final mid = BlocEventChannel(main);
  final bottom = BlocEventChannel(mid);

  var mainCheck = '';
  var nonMainCheck = '';

  main.addEventListener(
      'Mid', BlocEventChannel.simpleListener((val) => mainCheck += '$val'));
  main.addEventListener(
      'Bottom', BlocEventChannel.simpleListener((val) => mainCheck += '$val'));

  mid.fireEvent('Mid', 'Mid');
  expect(mainCheck, 'Mid');
  bottom.fireEvent('Bottom', 'Bottom');
  expect(mainCheck, 'MidBottom');

  mid.addEventListener(
      'Mid',
      BlocEventChannel.simpleListener((val) => nonMainCheck += '$val',
          stopPropagation: false));
  bottom.addEventListener(
      'Bottom',
      BlocEventChannel.simpleListener((val) => nonMainCheck += '$val',
          stopPropagation: true));

  mid.fireEvent('Mid', 'Mid');
  expect(mainCheck, 'MidBottomMid');
  expect(nonMainCheck, 'Mid');
  bottom.fireEvent('Bottom', 'Bottom');
  expect(mainCheck, 'MidBottomMid');
  expect(nonMainCheck, 'MidBottom');

  mainCheck = '';
  nonMainCheck = '';
  mid.addEventListener(
      'Mid',
      BlocEventChannel.simpleListener((val) => nonMainCheck += '$val',
          stopPropagation: true));

  mid.fireEvent('Mid', 'Mid');
  bottom.fireEvent('Bottom', 'Bottom');
  expect(mainCheck, '');
  expect(nonMainCheck, 'MidMidBottom');
}
