import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BlocEventChannelDebuggerProvider extends StatelessWidget {
  final BlocEventChannelDebugger Function(
      BuildContext, BlocEventChannel? parentChannel)? create;
  final Widget child;
  const BlocEventChannelDebuggerProvider({
    super.key,
    this.create,
    required this.child,
  });

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
