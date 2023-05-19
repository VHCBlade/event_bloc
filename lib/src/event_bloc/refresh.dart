import 'dart:async';

/// The [ActionQueuer] class is used to queue up [action]s and performed
/// within a specific sequence, depending on the implementation.
///
/// See [RefreshQueuer] and [SingleActionQueuer] for concrete implementations of
/// this class.
abstract class ActionQueuer<T> {
  /// This defines the action to be done by this queuer.
  ActionQueuer(this.action);

  /// The action to be done.
  final Future<T> Function() action;

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
  /// [action] is the refresh action done.
  RefreshQueuer(super.action);

  /// Whether an [action] is currently being performed right now.
  bool isRefreshing = false;

  /// Whether another [action] should be called after the current one
  /// finishes.
  bool performRefreshAfter = false;

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
      unawaited(refresh());
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
  /// [action] is the single action to be ran.
  SingleActionQueuer(super.action);

  /// Shows whether [action] has been started or not.
  bool hasRan = false;
  Completer<dynamic>? _completer;

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
