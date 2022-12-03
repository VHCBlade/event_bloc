import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

class MultiBlocProvider extends StatelessWidget {
  final List<BlocBuilder> blocBuilders;
  final Widget child;

  const MultiBlocProvider(
      {super.key, required this.blocBuilders, required this.child});

  @override
  Widget build(BuildContext context) {
    if (blocBuilders.isEmpty) {
      return child;
    }

    Widget highestChild = child;
    for (final builder in blocBuilders.reversed) {
      final newProvider = builder.createProvider(highestChild);
      highestChild = newProvider;
    }

    return highestChild;
  }
}

class MultiRepositoryProvider extends StatelessWidget {
  final List<RepositoryBuilder> repositoryBuilders;
  final Widget child;

  const MultiRepositoryProvider(
      {super.key, required this.repositoryBuilders, required this.child});

  @override
  Widget build(BuildContext context) {
    if (repositoryBuilders.isEmpty) {
      return child;
    }

    Widget highestChild = child;
    for (final builder in repositoryBuilders.reversed) {
      final newProvider = builder.createProvider(highestChild);
      highestChild = newProvider;
    }

    return highestChild;
  }
}
