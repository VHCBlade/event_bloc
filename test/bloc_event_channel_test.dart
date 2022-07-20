import 'package:event_bloc/event_bloc_no_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const void1 = BlocEvent<void>("cool");
const string = BlocEvent<String>("great");
const int1 = BlocEvent<int>("amazing");
const bool1 = BlocEvent<bool>("superb");

void main() {
  group('BlocEvent', () {
    test('Basic', basicCheck);
    test('Remove', removeCheck);
  });
}

void basicCheck() {
  final channel = BlocEventChannel();
  var check = '';

  channel.addBlocEventListener(
      void1, BlocEventChannel.simpleListener((_) => check += "Cool"));

  channel.addBlocEventListener(
      string, BlocEventChannel.simpleListener<String>((val) => check += val));
  channel.addBlocEventListener(int1,
      BlocEventChannel.simpleListener<int>((val) => check = '$val' + check));

  channel.fireBlocEvent(void1, null);
  expect(check, 'Cool');
  channel.fireBlocEvent<String>(string, 'mega');
  expect(check, 'Coolmega');
  channel.fireBlocEvent<int>(int1, 2);
  expect(check, '2Coolmega');
  channel.fireBlocEvent(bool1, null);
  expect(check, '2Coolmega');
  channel.fireBlocEvent<String>(string, '4U');
  expect(check, '2Coolmega4U');
  channel.fireBlocEvent<bool>(bool1, false);
  expect(check, '2Coolmega4U');
  channel.fireBlocEvent<void>(void1, null);
  expect(check, '2Coolmega4UCool');
}

void removeCheck() {
  final channel = BlocEventChannel();
  var check = '';

  final addedListener = channel.addBlocEventListener<void>(
      void1, BlocEventChannel.simpleListener((_) => check += "Cool"));

  channel.fireBlocEvent(void1, null);
  expect(check, 'Cool');

  channel.removeBlocEventListener(void1, addedListener);

  channel.fireBlocEvent(void1, null);
  expect(check, 'Cool');
}
