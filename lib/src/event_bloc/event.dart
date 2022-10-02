import 'package:equatable/equatable.dart';

class BlocEventType<T> extends Equatable {
  final String eventName;

  const BlocEventType(this.eventName);
  const BlocEventType.fromObject(Object eventType) : eventName = '$eventType';

  @override
  List<Object?> get props => [eventName];
}

class BlocEvent<T> {
  final BlocEventType<T> eventType;
  bool propagate = true;

  BlocEvent(this.eventType);
}
