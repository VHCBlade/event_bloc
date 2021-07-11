import 'package:event_bloc/event_bloc_no_widgets.dart';

class TestBloc extends Bloc {
  @override
  final BlocEventChannel eventChannel;

  TestBloc(this.eventChannel);
}
