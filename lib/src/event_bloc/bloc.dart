import 'package:collection/collection.dart';
import 'package:event_bloc/src/event_bloc/event_channel.dart';
import 'package:flutter/material.dart';

final Function equality = const DeepCollectionEquality().equals;

/// The main building block of your BLoC Layer!
///
/// Place all of your state management code here, along with any other business logic that is independent of specific platform implementations. Specific implementations belong in the [Repository] layer, and should be provided in the constructor of your own class that extends [Bloc]. Also be sure to add any event listeners you need in the constructor as well!
///
/// Any calls to [updateBloc] will cause the UI to redraw, given that you use [BlocProvider] to create and retrieve the [Bloc].
abstract class Bloc implements Disposable {
  /// Add functions to this to be ran when the [Bloc] is updated.
  List<void Function()> blocUpdated = [];

  /// Events that the UI fire to affect this [Bloc] are received through here.
  final BlocEventChannel eventChannel;

  Bloc({required BlocEventChannel? parentChannel})
      : eventChannel = BlocEventChannel(parentChannel);

  /// Updates the [Bloc] after calling [change] if the value returned by [tracker] changes.
  ///
  /// Slightly less efficient than writing the code yourself, but reduces boilerplate.
  ///
  /// Note the [change] has to be a synchronous call. If [change] returns a future, use [updateBlocOnFutureChange] instead.
  void updateBlocOnChange(
      {required Function() change, required List Function() tracker}) {
    final track = tracker();

    change();

    if (!equality(track, tracker())) {
      updateBloc();
    }
  }

  /// Updates the [Bloc] after calling [change] if the value returned by [tracker] changes.
  ///
  /// Slightly less efficient than writing the code yourself, but reduces boilerplate.
  ///
  /// Unlike the similar [updateBlocOnChange], this supports the change function returning a super.
  Future<void> updateBlocOnFutureChange(
      {required Future Function() change,
      required List Function() tracker}) async {
    final track = tracker();

    await change();

    if (!equality(track, tracker())) {
      updateBloc();
    }
  }

  /// Signal that this [Bloc] has been updated. This will call all listeners added to [blocUpdated].
  void updateBloc() => blocUpdated.forEach((element) => element());

  @override
  @mustCallSuper
  void dispose() {
    eventChannel.dispose();
  }
}
