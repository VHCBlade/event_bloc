import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Provides a [Repository] down the Widget tree. Will also automatically call necessary functions to initialize the [Repository].
///
/// If you wish to reduce the nesting of using multiple [RepositoryProvider]s, look into
/// using [MultiRepositoryProvider] with some [BlocBuilder]s
class RepositoryProvider<T extends Repository> extends StatefulWidget {
  final Widget child;
  final T Function(BuildContext) create;

  const RepositoryProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  factory RepositoryProvider.fromBuilder(
          {required RepositoryBuilder<T> builder, required Widget child}) =>
      RepositoryProvider(
        create: (context) => builder.builder(context.asReadable()),
        child: child,
      );

  @override
  RepositoryProviderState<T> createState() => RepositoryProviderState<T>();
}

class RepositoryProviderState<T extends Repository>
    extends State<RepositoryProvider<T>> {
  late final T repo;
  late final RepositorySource source;
  late final bool newSource;

  @override
  void initState() {
    super.initState();
    repo = widget.create(context);
    try {
      source = context.read<RepositorySource>();
      newSource = false;
    } on Object {
      source = RepositorySource();
      newSource = true;
    }
    repo.initialize(source.channel);
  }

  @override
  void dispose() {
    repo.dispose();
    if (newSource) {
      source.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retVal = Provider<T>.value(value: repo, child: widget.child);
    return newSource
        ? Provider<BlocEventChannel>.value(
            value: source.channel,
            child: Provider<RepositorySource>.value(
              value: source,
              child: retVal,
            ),
          )
        : retVal;
  }
}
