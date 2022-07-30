# Event BLoC

Event Bloc is an event-based implementation of the BLoC pattern, the recommended State Management Pattern for Flutter by Google!

Event Bloc uses events and the [provider package](https://pub.dev/packages/provider) to simplify the state management process. It also gets rid of a lot of the boilerplate that is associated with other implementation of the BLoC pattern.

## Features

Add this to your Flutter app to:
* Add an easy to use State Management Solution that is equally easy to maintain
* Get the best of both the [Provider](https://pub.dev/packages/provider) Pattern and BLoC Pattern without using code generation
* Decouple business logic from UI presentation and platform implementations with minimal hassle
* Reduce Boiler Plate while still keeping the benefits of abstraction

## Getting Started

<img src="https://github.com/VHCBlade/event_bloc/blob/main/img/Event%20Bloc%20Diagram.jpg?raw=true?raw=true"
    alt="BLoC Implementation of Event BLoC" height="400"/>

The BLoC pattern is all about modularizing your code by separating it into 4 distinct layers, each with its own unique role to play. While traditionally, the BLoC pattern is implemented with nothing but streams, this can prove to be rather tedious and full of boilerplate. By combining the Provider Package and a BlocEventChannel as alternative means of communication, we're able to cut down on the repetition. Getting the advantages of well-designed modular system along with the convenience of Providers and Events.

Before diving deeper into the BLoC Pattern and this library's implementation of it, it's important that we understand what exactly it is that the Provider Package and the BlocEventChannel is adding. Streams are one specific implementation of the [Observer Pattern](https://en.wikipedia.org/wiki/Observer_pattern), a helpful tool for modularizing code. Events are passed into the Sink portion of the stream while Listeners on the stream respond to the events. While they are nice and can account for all possibilities, there are other more efficient techniques that can be used for more specific purposes.

[Provider's ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) is simply a different implementation of the Observer Pattern, specifically for the connection between BLoC and UI/Screen. The only event fired is that of the BLoC itself being updated, and the response of the Screen is to redraw itself with the new information. This greatly simplifies the communication of data changes from BLoC to UI. While ChangeNotifier is unable to communicate specific events, it is much more efficient at the things it can do than simple Streams. The right tool for the right job!

## BlocEventChannel - Generic Upward Stream

The BlocEventChannel is another more specific implementation of the Observer Pattern. The BlocEventChannel is designed to be an interconnected upward stream from UI all to the way to the Repository Layer. Events fired to one BlocEventChannel will trigger any listeners for that particular event that are present in that BlocEventChannel. Furthermore, these events will by default be propagated all the way up to the highest level BlocEventChannel.

From the UI level, the closest Event Channel can be retrieved by simply using Provider's convenient retrieval methods from the BuildContext. Blocs and Repositories gain access to eventChannels from their own specific providers (BlocProvider and RepositoryProvider respectively).

## Simple Example

The heart and soul of the pattern of course is the BLoC (Business Logic Component). The BLoC represents the current state of your app. If there's data that can change that needs to be presented to the user, it belongs in the BLoC. This package's implementation of BLoC automatically comes with an integration to ChangeNotifier and the BlocEventChannel.

```dart
import 'package:event_bloc/event_bloc.dart';

const INCREMENT_EVENT = 'increment';
const RESET_COUNTER_EVENT = 'reset-counter';

class CounterBloc extends Bloc {
  int counter = 0;

  CounterBloc({super.parentChannel}) {
    // Add listeners to event channel
    eventChannel.addEventListener(INCREMENT_EVENT,
        BlocEventChannel.simpleListener((_) => incrementCounter()));
    eventChannel.addEventListener(RESET_COUNTER_EVENT,
        BlocEventChannel.simpleListener((val) => resetCounter(val)));
  }

  void incrementCounter() {
    counter++;
    // If provided using BlocProvider, updateBloc calls will automatically redraw
    // dependent UI
    updateBloc();
  }

  void resetCounter(int val) {
    // Only call update bloc if the counter changed.
    updateBlocOnChange(change: () => counter = val, tracker: () => [counter]);
  }

  // Just an example, set this in the UI Screen Layer!
  static Widget wrapChildWidget(Widget child) {
    return BlocProvider(
        create: (context, channel) => CounterBloc(parentChannel: channel),
        child: child);
  }
}
```

For a more complete example, go to our [example page!](https://pub.dev/packages/event_bloc/example)