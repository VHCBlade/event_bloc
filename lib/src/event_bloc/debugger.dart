import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/foundation.dart';

class BlocEventChannelDebugger {
  late final BlocEventChannel eventChannel;
  final String name;
  final bool printUnhandled;
  final bool printHandled;
  final BlocEventListenerAction? printFunction;

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
          : printFunction!(event, value);
    }
  }

  void defaultPrint(BlocEvent event, dynamic value) {
    if (kDebugMode) {
      print("$name Times Handled - ${event.timesHandled}");
    }
  }

  String printMessage(BlocEvent event, dynamic value) =>
      "$name Times Handled - ${event.timesHandled}";
}
