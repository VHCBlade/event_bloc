import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../repository_test.dart';

const adder = BlocEventType<int>("adder");
void main() {
  group("BuildContext", () {
    testWidgets("Event Channel", basicEventCheck);
  });
}

Future<void> createWidget(
    WidgetTester tester, TestRepository repository) async {
  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => repository,
      child: Builder(
        builder: (context) => CupertinoButton(
          key: const ValueKey("1"),
          onPressed: () => context.fireEvent(adder, 10),
          child: Container(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> fireEvent(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey("1")));
  await tester.pumpAndSettle();
}

Future<void> basicEventCheck(WidgetTester tester) async {
  int i = 0;
  await createWidget(
    tester,
    TestRepository(
      (eventChannel) =>
          [eventChannel.addEventListener<int>(adder, (_, val) => i += val)],
    ),
  );
  await fireEvent(tester);
  expect(i, 10);

  await fireEvent(tester);
  await fireEvent(tester);

  expect(i, 30);
}
