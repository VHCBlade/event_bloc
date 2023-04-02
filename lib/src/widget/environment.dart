import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/widgets.dart';

typedef CreateBloc<T extends Bloc> = T Function(
    Readable reader, BlocEventChannel? parentChannel);
typedef CreateRepository<T extends Repository> = T Function(Readable reader);

abstract class Readable {
  T read<T>();
}

/// This builds a similar environment to the Flutter Widget Tree to be used for
/// Unit Tests. This allows the environment for the widget tests and unit tests
/// to be the same, so long as they use the same [blocBuilders] and [repositoryBuilders]
///
/// For the Widget consumers of [blocBuilders] and [repositoryBuilders], please
/// look at [MultiRepositoryProvider] and [MultiBlocProvider]
class TestEnvironment implements Readable, Disposable {
  final RepositorySource repositorySource;
  final List<BlocBuilder> blocBuilders;
  final List<RepositoryBuilder> repositoryBuilders;

  final Map<Type, dynamic> _initializedMap = {};
  bool initialized = false;

  TestEnvironment({
    RepositorySource? repositorySource,
    required this.blocBuilders,
    required this.repositoryBuilders,
  }) : repositorySource = repositorySource ?? RepositorySource();

  @override
  T read<T>({bool allowUninitialized = false}) {
    if (!initialized && !allowUninitialized) {
      throw ArgumentError(
          "This test environment must be initialized before it is used!");
    }

    return _initializedMap[T] as T;
  }

  BlocEventChannel get eventChannel =>
      read<BlocEventChannel>(allowUninitialized: true);

  void initialize() {
    if (initialized) {
      return;
    }

    _initializedMap[BlocEventChannel] = repositorySource.channel;
    repositoryBuilders.forEach((element) {
      final repo = element.builder(
          ReadableFromFunc(<T>() => read<T>(allowUninitialized: true)));
      _initializedMap[element.builderType] = repo;
      repo.initialize(eventChannel);
    });

    blocBuilders.forEach((element) {
      final bloc = element.builder(
          ReadableFromFunc(<T>() => read<T>(allowUninitialized: true)),
          eventChannel);
      _initializedMap[element.builderType] = bloc;
      _initializedMap[BlocEventChannel] = bloc.eventChannel;
    });

    initialized = true;
  }

  @override
  void dispose() {
    if (!initialized) {
      return;
    }
    repositorySource.dispose();
    _initializedMap.forEach((key, value) {
      if (value is! Disposable) {
        return;
      }
      value.dispose();
    });
    initialized = false;
  }
}

class ReadableFromFunc implements Readable {
  final T Function<T>() _read;

  @override
  T read<T>() => _read<T>();

  ReadableFromFunc(this._read);
}

/// This lets you define a builder for a [Bloc] that can be used for
/// [MultiBlocProvider] and [TestEnvironment]
///
/// Unlike with [Provider], you need to specify the generic. Failing to do so
/// will set the generic to [Bloc] which is probably undesirable.
class BlocBuilder<T extends Bloc> {
  final CreateBloc<T> builder;
  Type get builderType => T;

  /// Unlike with [Provider], you need to specify the generic. Failing to do so
  /// will set the generic to [Bloc] which is probably undesirable.
  BlocBuilder(this.builder);

  BlocProvider<T> createProvider(Widget child) {
    return BlocProvider<T>.fromBuilder(builder: this, child: child);
  }
}

/// This lets you define a builder for a [Repository] that can be used for
/// [MultiRepositoryProvider] and [TestEnvironment]
///
/// Unlike with [Provider], you need to specify the generic. Failing to do so
/// will set the generic to [Repository] which is probably undesirable.
class RepositoryBuilder<T extends Repository> {
  final CreateRepository<T> builder;
  Type get builderType => T;

  /// Unlike with [Provider], you need to specify the generic. Failing to do so
  /// will set the generic to [Repository] which is probably undesirable.
  RepositoryBuilder(this.builder);

  RepositoryProvider<T> createProvider(Widget child) =>
      RepositoryProvider<T>.fromBuilder(builder: this, child: child);
}
