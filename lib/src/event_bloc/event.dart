class BlocEvent<T> {
  final String eventName;

  const BlocEvent(this.eventName);
  const BlocEvent.fromObject(Object eventType) : eventName = '$eventType';
}
