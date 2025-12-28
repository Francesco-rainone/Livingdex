import 'package:flutter/material.dart';

/// Simplifies adding keyboard shortcuts to a widget subtree.
class ShortcutHelper extends StatelessWidget {
  const ShortcutHelper(
      {required this.bindings, required this.child, super.key});

  /// Shortcut-to-callback mappings.
  final Map<ShortcutActivator, void Function()> bindings;

  /// Widget that listens for shortcuts.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(autofocus: true, child: child),
    );
  }
}

/// Wraps a scrollable child with pull-to-refresh functionality.
class PullToRefreshHelper extends StatefulWidget {
  const PullToRefreshHelper(
      {required this.onRefresh, required this.child, super.key});

  /// Async callback triggered on pull-down refresh.
  final Future<void> Function() onRefresh;

  /// Scrollable child widget (ListView, GridView, etc.).
  final Widget child;

  @override
  State<PullToRefreshHelper> createState() => _PullToRefreshHelperState();
}

class _PullToRefreshHelperState extends State<PullToRefreshHelper> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
}
