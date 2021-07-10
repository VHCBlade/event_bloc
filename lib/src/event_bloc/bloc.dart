import 'package:collection/collection.dart';
import 'package:event_bloc/src/event_bloc/event_channel.dart';

final Function equality = const DeepCollectionEquality().equals;

abstract class Bloc {
  /// Add functions to this to be ran when the model is updated.
  List<void Function()> blocUpdated = [];

  /// Events that the UI fire to affect this model are received through here.
  BlocEventChannel get eventChannel;

  /// Updates the [Bloc] after calling [change] if the value returned by
  /// [tracker] changes.
  ///
  /// Slightly less efficient than writing the code yourself, but reduces
  /// boilerplate.
  void updateBlocOnChange(
      {required void Function() change,
      required List<dynamic> Function() tracker}) {
    final track = tracker();

    change();

    if (!equality(track, tracker())) {
      updateBloc();
    }
  }

  void updateBloc() => blocUpdated.forEach((element) => element());

  void dispose() {}
}
