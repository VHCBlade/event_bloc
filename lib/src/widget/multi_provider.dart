import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

/// Provides multiple [Bloc]s through [BlocBuilder]s
class MultiBlocProvider extends StatelessWidget {
  /// [blocBuilders] provides the generation of the blocs to be provided.
  const MultiBlocProvider({
    required this.blocBuilders,
    required this.child,
    super.key,
  });

  /// Provides the generation of the blocs to be provided.
  final List<BlocBuilder> blocBuilders;

  /// The widget to which the [Bloc]s will be provided
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (blocBuilders.isEmpty) {
      return child;
    }

    var highestChild = child;
    for (final builder in blocBuilders.reversed) {
      final newProvider = builder.createProvider(highestChild);
      highestChild = newProvider;
    }

    return highestChild;
  }
}

/// Provides multiple [Repository]s through [RepositoryBuilder]s
class MultiRepositoryProvider extends StatelessWidget {
  /// [repositoryBuilders] provides the generation of the repositories to be
  /// provided.
  const MultiRepositoryProvider({
    required this.repositoryBuilders,
    required this.child,
    super.key,
  });

  /// Provides the generation of the repositories to be provided.
  final List<RepositoryBuilder> repositoryBuilders;

  /// The widget to which the [Repository]s will be provided
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (repositoryBuilders.isEmpty) {
      return child;
    }

    var highestChild = child;
    for (final builder in repositoryBuilders.reversed) {
      final newProvider = builder.createProvider(highestChild);
      highestChild = newProvider;
    }

    return highestChild;
  }
}
