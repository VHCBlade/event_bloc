import 'package:event_bloc/event_bloc.dart';

/// Fires Debug Messages using [printFunction]. The debug messages that are
/// fired are handled by [printHandled] and [printUnhandled]
///
/// All [BlocEventChannel]s that have [eventChannel] as an ancestor are subject
/// to this debugger. Their events will be evaluated by this debugger and
/// handled appropriately.
///
/// Even if [BlocEvent.propagate] is false, the will still be subject to
/// debugging.
class BlocEventChannelDebugger {
  /// [name] is prepended before all debug messages
  ///
  /// [parentChannel] is made the parent channel of [eventChannel]
  ///
  /// [printUnhandled] and [printUnhandled] determine what type of events will
  /// be printed
  ///
  /// [printFunction] determines how the debug message will be handled.
  BlocEventChannelDebugger({
    BlocEventChannel? parentChannel,
    this.name = '[BlocEventChannel]',
    this.printHandled = false,
    this.printUnhandled = true,
    this.printBus = false,
    this.printFunction,
  }) {
    eventChannel = BlocEventChannel(parentChannel, handleEvent);
    eventChannel.eventBus.addGenericEventListener(handleBusEvent);
  }

  /// [BlocEventChannel]s need this as an ancestor to be subject to this
  /// debugger.
  late final BlocEventChannel eventChannel;

  /// Prepended before all debug messages.
  final String name;

  /// If true, messages that haven't been handled at all by any
  /// [BlocEventListener] will be printed.
  final bool printUnhandled;

  /// If true, messages that have been handled by at least one
  /// [BlocEventListener] will be printed.
  final bool printHandled;

  /// If true, ALL messages that are fired in [eventChannel]'s
  /// event bus will be printed.
  final bool printBus;

  /// Handles how the debug messages will be printed.
  ///
  /// If not provided, all messages will be printed to console.
  final dynamic Function(
    BlocEvent<dynamic> event,
    dynamic value,
    String Function() defaultMessage,
  )? printFunction;

  /// Removes the listeners from the event bus
  void dispose() {}

  /// Handles all [BlocEvent]s that pass through any of the descendants of
  /// [eventChannel]
  void handleEvent(BlocEvent<dynamic> event, dynamic value) {
    final shouldPrint = event.timesHandled == 0 ? printUnhandled : printHandled;

    if (shouldPrint) {
      _printEvent(event, value);
    }
  }

  /// Handles all [BlocEvent]s that pass through any of the descendants of
  /// [eventChannel]'s eventBus
  void handleBusEvent(BlocEvent<dynamic> event, dynamic value) {
    if (printBus) {
      _printEvent(event, value);
    }
  }

  void _printEvent(BlocEvent<dynamic> event, dynamic value) {
    printFunction == null
        ? defaultPrint(event, value)
        : printFunction!(
            event,
            value,
            () => createPrintMessage(event, value),
          );
  }

  /// Prints to console. used if [printFunction] is unspecified.
  void defaultPrint(BlocEvent<dynamic> event, dynamic value) {
    // ignore: avoid_print
    print(createPrintMessage(event, value));
  }

  /// Creates the debug message for the given [event].
  String createPrintMessage(BlocEvent<dynamic> event, dynamic value) =>
      '$name Event - ${event.eventType}, Times Handled - ${event.timesHandled},'
      ' Propagating - ${event.propagate}, Depth - ${event.depth},'
      ' Value - $value';
}
