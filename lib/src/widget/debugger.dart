import 'package:event_bloc/event_bloc_errors.dart';
import 'package:event_bloc/src/widget/context.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Provides a [BlocEventChannelDebugger]. This allows you to handle how
/// your debugger will behave instead of just using the default.
class BlocEventChannelDebuggerProvider extends StatelessWidget {
  /// [create] creates the instance of the [BlocEventChannelDebugger] to be
  /// provided.
  const BlocEventChannelDebuggerProvider({
    required this.child,
    super.key,
    this.create,
  });

  /// Creates the instance of the [BlocEventChannelDebugger] to be
  /// provided.
  final BlocEventChannelDebugger Function(
    BuildContext,
    BlocEventChannel? parentChannel,
  )? create;

  /// The widget that will be affected by the created debugger.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Provider<BlocEventChannelDebugger>(
      create: (context) {
        final eventChannel = context.read<BlocEventChannel?>();

        if (create != null) {
          return create!(context, eventChannel);
        }

        return BlocEventChannelDebugger(
          parentChannel: eventChannel,
          printHandled: false,
          printUnhandled: true,
        );
      },
      dispose: (_, debugger) => debugger.dispose(),
      child: Provider<RepositorySource>(
        create: (context) =>
            RepositorySource(context.read<BlocEventChannelDebugger>()),
        child: Provider<BlocEventChannel>(
          create: (context) => context.read<RepositorySource>().channel,
          child: child,
        ),
      ),
    );
  }
}

/// Adds debug logging for fire error events. Add this to your
/// project to add debugging capabilities and fire your own
/// [ErrorEvent]s to track.
class BlocEventChannelErrorDebugger extends StatefulWidget {
  /// [printDebug] and [printUnexpected] determine which type
  /// of errors will be logged.
  ///
  /// Specify [printFunction] if you want to log it yourself
  /// rather than just print it to console.
  const BlocEventChannelErrorDebugger({
    required this.child,
    super.key,
    this.printDebug = false,
    this.printUnexpected = true,
    this.printFunction,
  });

  /// The child
  final Widget child;

  /// Whether the debug errors will be printed
  final bool printDebug;

  /// Whether to unexpected errors will be printed
  final bool printUnexpected;

  /// Overrides the default printing to console if specified
  final void Function(TrackedError)? printFunction;

  @override
  State<BlocEventChannelErrorDebugger> createState() =>
      _BlocEventChannelErrorDebuggerState();
}

class _BlocEventChannelErrorDebuggerState
    extends State<BlocEventChannelErrorDebugger> {
  late final List<BlocEventListener<TrackedError>> listeners;
  @override
  void initState() {
    super.initState();
    listeners = [
      context.eventChannel.eventBus.addEventListener(
        ErrorEvent.debugError.event,
        (_, error) {
          if (widget.printDebug) {
            printError(error);
          }
        },
      ),
      context.eventChannel.eventBus.addEventListener(
        ErrorEvent.unexpectedError.event,
        (_, error) {
          if (widget.printUnexpected) {
            printError(error);
          }
        },
      ),
    ];
  }

  void printError(TrackedError error) {
    if (widget.printFunction != null) {
      widget.printFunction!(error);
      return;
    }
    // ignore: avoid_print
    print('Error Found: ${error.message} - ${error.error}');
    // ignore: avoid_print
    print('Associated Event: ${error.associatedEvent}');
    // ignore: avoid_print
    print('Stack Trace: ${error.stackTrace}');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
