class RefreshQueuer {
  bool isRefreshing = false;
  bool performRefreshAfter = false;
  final Future Function() action;

  RefreshQueuer(this.action);

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
}
