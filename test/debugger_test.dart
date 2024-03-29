import 'package:event_bloc/event_bloc.dart';
import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';

import 'test_classes.dart';

void main() {
  group('BlocEventChannel Debugger', () {
    group('Print', () {
      group('Unhandled', unhandledTest);
      group('Handled', handledTest);
      group('Everything', everythingTest);
      group('Renamed Everything', renamedTest);
    });
  });
}

Map<String, Tuple2<BlocEventType<dynamic>, dynamic> Function()>
    get commonTestCases => {
          'int 1': () => Tuple2(TestBlocEvent.intEvent.event, 1),
          'int 6': () => Tuple2(TestBlocEvent.intEvent.event, 6),
          'bool true': () => Tuple2(TestBlocEvent.boolEvent.event, true),
          'bool false': () => Tuple2(TestBlocEvent.boolEvent.event, false),
          'void': () => Tuple2(TestBlocEvent.reloadEvent.event, null),
          'bool cool': () => Tuple2(TestBlocEvent.stringEvent.event, 'cool'),
          'bool Amazing': () =>
              Tuple2(TestBlocEvent.stringEvent.event, 'Amazing'),
        };

void unhandledTest() {
  SerializableListTester<Tuple2<BlocEventType<dynamic>, dynamic>>(
    testGroupName: 'BlocEventChannel Debugger Print',
    mainTestName: 'Unhandled',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) {
      final debugger = BlocEventChannelDebugger(
        printUnhandled: true,
        printHandled: false,
        printFunction: (_, a, message) => tester.addTestValue(message()),
      );

      test(debugger, value);
    },
    testMap: commonTestCases,
  ).runTests();
}

void handledTest() {
  SerializableListTester<Tuple2<BlocEventType<dynamic>, dynamic>>(
    testGroupName: 'BlocEventChannel Debugger Print',
    mainTestName: 'Handled',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) {
      final debugger = BlocEventChannelDebugger(
        printUnhandled: false,
        printHandled: true,
        printFunction: (_, a, message) => tester.addTestValue(message()),
      );

      test(debugger, value);
    },
    testMap: commonTestCases,
  ).runTests();
}

void everythingTest() {
  SerializableListTester<Tuple2<BlocEventType<dynamic>, dynamic>>(
    testGroupName: 'BlocEventChannel Debugger Print',
    mainTestName: 'Everything',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) {
      final debugger = BlocEventChannelDebugger(
        printUnhandled: true,
        printHandled: true,
        printFunction: (_, a, message) => tester.addTestValue(message()),
      );

      test(debugger, value);
    },
    testMap: commonTestCases,
  ).runTests();
}

void renamedTest() {
  SerializableListTester<Tuple2<BlocEventType<dynamic>, dynamic>>(
    testGroupName: 'BlocEventChannel Debugger Print',
    mainTestName: 'Renamed Everything',
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) {
      final debugger = BlocEventChannelDebugger(
        name: '[This is Epic!]',
        printUnhandled: true,
        printHandled: true,
        printFunction: (_, a, message) => tester.addTestValue(message()),
      );

      test(debugger, value);
    },
    testMap: commonTestCases,
  ).runTests();
}

void test(
  BlocEventChannelDebugger debugger,
  Tuple2<BlocEventType<dynamic>, dynamic> value,
) {
  BlocEventChannel addEventChannel(
    BlocEventChannel channel,
    BlocEventType<dynamic> event, [
    // ignore: avoid_positional_boolean_parameters
    bool propagate = true,
  ]) =>
      channel
        ..addEventListener(
          event,
          (event, value) => event.propagate = propagate,
        );

  final intBranch = addEventChannel(
    BlocEventChannel(debugger.eventChannel),
    TestBlocEvent.intEvent.event,
  );
  final boolBranch = addEventChannel(
    BlocEventChannel(debugger.eventChannel),
    TestBlocEvent.boolEvent.event,
  );
  final voidBranch = addEventChannel(
    BlocEventChannel(debugger.eventChannel),
    TestBlocEvent.reloadEvent.event,
  );
  final stringBranch = addEventChannel(
    BlocEventChannel(debugger.eventChannel),
    TestBlocEvent.stringEvent.event,
  );

  final eventChannels = [intBranch, boolBranch, voidBranch, stringBranch];

  for (var i = 0; i < 4; i++) {
    final branch = eventChannels[i];
    final subIntBranch =
        addEventChannel(BlocEventChannel(branch), TestBlocEvent.intEvent.event);
    final subBoolBranch = addEventChannel(
      BlocEventChannel(branch),
      TestBlocEvent.boolEvent.event,
    );

    final subVoidBranch = addEventChannel(
      BlocEventChannel(branch),
      TestBlocEvent.reloadEvent.event,
    );
    final subStringBranch = addEventChannel(
      BlocEventChannel(branch),
      TestBlocEvent.stringEvent.event,
    );

    final subSubIntBranchNoPropagte = addEventChannel(
      BlocEventChannel(subIntBranch),
      TestBlocEvent.intEvent.event,
      false,
    );
    final subSubIntBranchPropagte = addEventChannel(
      BlocEventChannel(subIntBranch),
      TestBlocEvent.intEvent.event,
      true,
    );

    eventChannels.addAll([
      subIntBranch,
      subBoolBranch,
      subVoidBranch,
      subStringBranch,
      subSubIntBranchNoPropagte,
      subSubIntBranchPropagte,
    ]);
  }
  eventChannels
      .forEach((element) => element.fireEvent(value.item1, value.item2));
}
