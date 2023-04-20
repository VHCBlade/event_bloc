import 'package:event_bloc/event_bloc.dart';

class BlocEventChannelDebugger {
  late final BlocEventChannel eventChannel;
  final String name;
  final bool printUnhandled;
  final bool printHandled;
  final Function(
          BlocEvent event, dynamic value, String Function() defaultMessage)?
      printFunction;

  BlocEventChannelDebugger({
    BlocEventChannel? parentChannel,
    this.name = "[BlocEventChannel]",
    this.printHandled = false,
    this.printUnhandled = true,
    this.printFunction,
  }) {
    eventChannel = BlocEventChannel(parentChannel, handleEvent);
  }

  void handleEvent(BlocEvent event, dynamic value) {
    bool shouldPrint = event.timesHandled == 0 ? printUnhandled : printHandled;

    if (shouldPrint) {
      printFunction == null
          ? defaultPrint(event, value)
          : printFunction!(
              event, value, () => createPrintMessage(event, value));
    }
  }

  void defaultPrint(BlocEvent event, dynamic value) {
    // ignore: avoid_print
    print(createPrintMessage(event, value));
  }

  String createPrintMessage(BlocEvent event, dynamic value) =>
      "$name Event - ${event.eventType}, Times Handled - ${event.timesHandled}, Propagating - ${event.propagate}, Depth - ${event.depth}, Value - $value";
}
