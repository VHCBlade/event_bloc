/// This is the same as the [event_bloc] library except without all of the Widgets.
///
/// Use this if you want to be very strict about the separation of your business logic from you UI. Especially good if you want to keep them in separate repositories.
library event_bloc_no_widgets;

export 'package:event_bloc/src/event_bloc/bloc.dart';
export 'package:event_bloc/src/event_bloc/event.dart';
export 'package:event_bloc/src/event_bloc/event_channel.dart';
export 'package:event_bloc/src/event_bloc/repository.dart';
export 'package:event_bloc/src/event_bloc/refresh.dart';
