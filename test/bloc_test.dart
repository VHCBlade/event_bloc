import 'package:event_bloc/event_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bloc', () {
    test('updateBlocOnChange', () {
      final testBloc = TestBloc(parentChannel: BlocEventChannel());
      var i = 0;
      testBloc.blocUpdated.add(() => i++);
      testBloc.updateBlocOnChange(
        change: () => testBloc.value = 'Great',
        tracker: () => [testBloc.value],
      );

      expect(i, 1);
      testBloc.updateBlocOnChange(
        change: () => testBloc.value = 'Incredible',
        tracker: () => [testBloc.number],
      );

      expect(i, 1);
      testBloc.updateBlocOnChange(
        change: () => testBloc
          ..value = 'Incredible'
          ..number = 24,
        tracker: () => [testBloc.number, testBloc.value],
      );

      expect(i, 1);
      testBloc.updateBlocOnChange(
        change: () => testBloc
          ..value = 'Incredible'
          ..number = 12,
        tracker: () => [testBloc.number, testBloc.value],
      );

      expect(i, 2);
    });
    test('updateBlocOnFutureChange', () async {
      final testBloc = TestBloc(parentChannel: BlocEventChannel());
      var i = 0;
      testBloc.blocUpdated.add(() => i++);
      await testBloc.updateBlocOnFutureChange(
        change: () async => testBloc.value = 'Great',
        tracker: () => [testBloc.value],
      );

      expect(i, 1);
      await testBloc.updateBlocOnFutureChange(
        change: () async => testBloc.value = 'Incredible',
        tracker: () => [testBloc.number],
      );

      expect(i, 1);
      await testBloc.updateBlocOnFutureChange(
        change: () async => testBloc
          ..value = 'Incredible'
          ..number = 24,
        tracker: () => [testBloc.number, testBloc.value],
      );

      expect(i, 1);
      await testBloc.updateBlocOnFutureChange(
        change: () async => testBloc
          ..value = 'Incredible'
          ..number = 12,
        tracker: () => [testBloc.number, testBloc.value],
      );

      expect(i, 2);
    });
  });
}

class TestBloc extends Bloc {
  TestBloc({required super.parentChannel});

  String value = 'incredible';
  int number = 24;
}
