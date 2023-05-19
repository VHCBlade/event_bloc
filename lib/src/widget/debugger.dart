import 'package:event_bloc/event_bloc.dart';
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
