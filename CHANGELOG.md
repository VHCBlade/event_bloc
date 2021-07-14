## 1.0.0+1

* Fixed RepositoryProvider to provide BlocEventChannel rather than RepositorySource

## 1.0.0

* Added BlocEventChannel, allowing for an event-based solution to State Management
* Added Bloc, with integration to the BlocEventChannel
* Added BlocProvider, which will automatically update UI that listens to it (using the provided static methods)
* Added Repository, with integration to the BlocEventChannel
* Added RepositoryProvider
