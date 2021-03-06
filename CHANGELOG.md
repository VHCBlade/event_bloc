## 3.1.1

* Fixed issue where multiple RepositoryProviders without an explicit RepositorySource would lead to only the last Repository being attached to the event channel.
* Added RepositoryProvider Test

## 3.1.0

* Added Constructor for [Bloc] that automatically creates an event channel and makes the passed channel the new channel's parent.
* Upgraded minimum dart sdk to 2.17.0

## 3.0.0

* Converted Repository ListenerMap to be responsible for adding the listeners to the [BlocEventChannel]. Will now also use the BlocEvent as the key for the map.
* Added RefreshQueuer. This allows for easy queueing of asynchronous actions that can potentially be called multiple times. Typically this will be used for refresh actions.
* Changed Repository to be an abstract class.
* Added Repository and RefreshQueuer tests.
* Upgraded Linter to 2.0.1 and updated code to match new rules.
* Updated License

## 2.1.0

* Added BlocEvent<T> for firing events with a specific type.
* Added addBlocEventListener, removeBlocEventListener, and fireBlocEvent to help with the use of the BlocEvent
* Updated BlocEventChannel.addEventListener to return the listener that was attached to the event channel.

## 2.0.0

* Upgraded flutter packages to 3.0.0

## 1.1.1

* Added BlocEventChannelProvider for easily reading BlocEventChannels from BuildContexts.

## 1.1.0

* Added updateBlocOnFutureChange to Bloc to support asynchronous changes.

## 1.0.1

* Added More Documentation
* Added Dispose Method to RepositorySource

## 1.0.0+1

* Fixed RepositoryProvider to provide BlocEventChannel rather than RepositorySource

## 1.0.0

* Added BlocEventChannel, allowing for an event-based solution to State Management
* Added Bloc, with integration to the BlocEventChannel
* Added BlocProvider, which will automatically update UI that listens to it (using the provided static methods)
* Added Repository, with integration to the BlocEventChannel
* Added RepositoryProvider
