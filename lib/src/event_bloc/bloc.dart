import 'package:collection/collection.dart';
import 'package:event_bloc/src/event_bloc/event_channel.dart';
import 'package:flutter/material.dart';

final Function equality = const DeepCollectionEquality().equals;

abstract class Bloc implements Disposable {
  /// Add functions to this to be ran when the [Bloc] is updated.
  List<void Function()> blocUpdated = [];

  /// Events that the UI fire to affect this [Bloc] are received through here.
  BlocEventChannel get eventChannel;

  /// Updates the [Bloc] after calling [change] if the value returned by [tracker] changes.
  ///
  /// Slightly less efficient than writing the code yourself, but reduces boilerplate.
  void updateBlocOnChange(
      {required void Function() change,
      required List<dynamic> Function() tracker}) {
    final track = tracker();

    change();

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
