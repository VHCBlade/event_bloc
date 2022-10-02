import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Provides a [Repository] down the Widget tree. Will also automatically call necessary functions to initialize the [Repository].
class RepositoryProvider<T extends Repository> extends StatefulWidget {
  final Widget child;
  final T Function(BuildContext) create;

  const RepositoryProvider(
      {Key? key, required this.child, required this.create})
      : super(key: key);

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
