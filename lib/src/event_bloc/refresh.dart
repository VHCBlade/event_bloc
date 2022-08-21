import 'dart:async';

/// The [ActionQueuer] class is used to queue up [action]s and performed
/// within a specific sequence, depending on the implementation.
///
/// See [RefreshQueuer] and [SynchronizedQueuer] for concrete implementations of this class.
abstract class ActionQueuer<T> {
  final Future<T> Function() action;

  /// This defines the action to be done by this queuer.
  ActionQueuer(this.action);

  /// Queues up the [action] to be
  Future<T> queue();
}

/// The [RefreshQueuer] implements the command by causing calls to the
/// queue function while [action] is currently in progress to cause the
/// [action] to be called again after the current [action] is finished.
///
/// If ran multiple times while [action] is still running, this will only
/// run it once after the current [action] is done.
class RefreshQueuer extends ActionQueuer<void> {
  bool isRefreshing = false;
  bool performRefreshAfter = false;

  RefreshQueuer(super.action);

  /// Calls the [action]. If it is currently running, will queue the
  /// [action] to run again when it's done.
  Future<void> refresh() async {
    if (isRefreshing) {
      performRefreshAfter = true;
      return;
    }

    isRefreshing = true;
    await action();
    isRefreshing = false;
    if (performRefreshAfter) {
      performRefreshAfter = false;
      refresh();
    }
  }

  @override
  Future<void> queue() => refresh();
}

/// The [SingleActionQueuer] will run the [action] once and only once.
/// Subsequent calls while [action] is running will wait until [action] is
/// done before returning. Calls while [action] has ran already will be
/// ignored.
///
/// It is a good idea to run this for things such as asset loading.
class SingleActionQueuer extends ActionQueuer<void> {
  bool hasRan = false;
  Completer? _completer;

  SingleActionQueuer(super.action);

  @override
  Future<void> queue() async {
    if (hasRan) {
      return;
    }

    if (_completer != null) {
      await _completer!.future;
      return;
    }
    _completer = Completer();
    await action();
    hasRan = true;
    _completer!.complete();
    _completer = null;
  }
}
