import 'package:collection/collection.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:meta/meta.dart';

final bool Function(dynamic, dynamic) _equality =
    const DeepCollectionEquality().equals;

/// The main building block of your BLoC Layer!
///
/// Place all of your state management code here, along with any other business
/// logic that is independent of specific platform implementations. Specific
/// implementations belong in the [Repository] layer, and should be provided in
/// the constructor of your own class that extends [Bloc]. Also be sure to add
/// any event listeners you need in the constructor as well!
///
/// Any calls to [updateBloc] will cause the UI to redraw, given that you use
/// BlocProvider to create and retrieve the [Bloc].
abstract class Bloc implements Disposable {
  /// [parentChannel] is set as the parent of the [BlocEventChannel]
  /// [eventChannel] of this [Bloc]
  Bloc({required BlocEventChannel? parentChannel})
      : eventChannel = BlocEventChannel(parentChannel);

  /// Add functions to this to be ran when the [Bloc] is updated.
  List<void Function()> blocUpdated = [];

  /// Events that the UI fire to affect this [Bloc] are received through here.
  final BlocEventChannel eventChannel;

  /// Updates the [Bloc] after calling [change] if the value returned by
  /// [tracker] changes.
  ///
  /// Slightly less efficient than writing the code yourself, but reduces
  /// boilerplate.
  ///
  /// Note the [change] has to be a synchronous call. If [change] returns a
  /// future, use [updateBlocOnFutureChange] instead.
  void updateBlocOnChange({
    required dynamic Function() change,
    required List<dynamic> Function() tracker,
  }) {
    final track = tracker();

    change();

    if (!_equality(track, tracker())) {
      updateBloc();
    }
  }

  /// Updates the [Bloc] after calling [change] if the value returned by
  /// [tracker] changes.
  ///
  /// Slightly less efficient than writing the code yourself, but reduces
  /// boilerplate.
  ///
  /// Unlike the similar [updateBlocOnChange], this supports the change
  /// function returning a super.
  Future<void> updateBlocOnFutureChange({
    required Future<dynamic> Function() change,
    required List<dynamic> Function() tracker,
  }) async {
    final track = tracker();

    await change();

    if (!_equality(track, tracker())) {
      updateBloc();
    }
  }

  /// Signal that this [Bloc] has been updated. This will call all listeners
  /// added to [blocUpdated].
  void updateBloc() => blocUpdated.forEach((element) => element());

  @override
  @mustCallSuper
  void dispose() {
    eventChannel.dispose();
  }
}
