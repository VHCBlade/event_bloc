/// Event Bloc is an event-based implementation of the BLoC pattern, the recommended State Management Pattern for Flutter by Google!
///
/// Most Important Classes:
/// - [BlocEventChannel] - Fire events up the event Channel tree for seamless integration without coupling!
/// - [Bloc] - The main Building BLoCk of the BLoC Pattern! Build your BLoC layer with these.
/// - [Repository] - Build your Repository Layer with these!
library event_bloc;

export 'package:event_bloc/src/widgets/bloc_provider.dart';
export 'package:event_bloc/src/widgets/event_channel.dart';
export 'package:event_bloc/src/widgets/repository_provider.dart';

export 'package:event_bloc/event_bloc_no_widgets.dart';
