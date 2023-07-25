## 4.6.0

* Created BaseEventChannel and changed BlocEventChannel to extend from BaseEventChannel
* Added eventBus to BlocEventChannel that is a BaseEventChannel shared throughout the entire BlocEventChannel Tree
* Added tests for Blocs

## 4.5.2

* Updated Readme and example

## 4.5.1

* Added withDelay optional parameter to BuildContext's fireEvent as a convenience when calling it while the Widgets are building.

## 4.5.0

* Added userInitated to BlocEventType that can be set before firing an event to add more information
* Added isUserInitiated convenience function for BlocEvent

## 4.4.0

* Added actual implementation for addGenericEventListener and removeGenericEventListener

## 4.3.4

* Changed linter to very_good_analysis instead and implemented the recommended changes
* Added Documentation

## 4.3.3

* Removed Flutter dependence in BlocEventChannelDebugger

## 4.3.2

* Changed default BlocEventChannelDebugger in RepositorySource to print unhandled events.

## 4.3.1

* Added BlocEventChannelDebugger and BlocEventChannelDebuggerProvider, to help debug your event channels!
* Added allListener instantiation variable to BlocEventChannel to listen for all event regardless of type.
* Added names to BlocEventListenerAction, CreateBloc, CreateRepository typedefs to help the linter give a more meaningful lambda.
* Added depth and timesHandled to BlocEvent
* Changed RepositoryChannel debugChannel to be backed by a BlocEventChannelDebugger instead.

## 4.2.1

* Removed Unnecessary Flutter dependency for must call super (depends on meta instead)

## 4.2.0

* Added BlocBuilder and RepositoryBuilder
* Added constructor for BlocProvider and RepositoryProvider that lets them build out of their respective builders
* Added MultiBlocProvider and MultiRepositoryProvider that are generated from a List of BlocBuilders and RepositoryBuilders

## 4.1.0

* Removed redundant BuildContext from BuildContext Extension Functions

## 4.0.1

* Added parent count field in BlocEventChannel

## 4.0.0

* BREAKING CHANGE: Removed the old String events and replaced them all with the new BlocEventType Object.
* BREAKING CHANGE: BlocEvent has been renamed to BlocEventType.
* BREAKING CHANGE: Changed way of preventing propagation of events, to modifying of a provided BlocEvent class, rather than by changing a boolean value that is returned.
* Added more BuildContext extensions for convenience
* Added Generic Event Listeners to be able to listen for all types of events.

## 3.3.0

* Added BuildContext extension to add fireEvent method

## 3.2.0

* Added SingleActionQueuer and ActionQueuer interface

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
