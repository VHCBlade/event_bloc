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
