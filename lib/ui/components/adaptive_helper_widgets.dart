import 'package:flutter/material.dart';

/// A helper widget that simplifies the process of adding keyboard shortcuts
/// to a specific part of the widget tree.
///
/// This widget wraps its [child] with `CallbackShortcuts` and `Focus` to
/// ensure that the defined keyboard shortcuts are active and responsive when
/// the child is part of the UI.
class ShortcutHelper extends StatelessWidget {
  /// Creates a `ShortcutHelper` widget.
  ///
  /// The [bindings] map is required and defines the shortcut-to-action mappings.
  /// The [child] is the widget that will listen for these shortcuts.
  const ShortcutHelper(
      {required this.bindings, required this.child, super.key});

  /// A map that defines the keyboard shortcuts and their corresponding callback functions.
  ///
  /// The key is a `ShortcutActivator` (e.g., `SingleActivator(LogicalKeyboardKey.keyS, control: true)` for Ctrl+S),
  /// and the value is the function to execute when the shortcut is triggered.
  final Map<ShortcutActivator, void Function()> bindings;

  /// The widget to which the keyboard shortcuts will be applied.
  ///
  /// This widget and its descendants will be able to trigger the defined shortcuts.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // CallbackShortcuts is a Flutter widget that listens for key events
    // and invokes the corresponding callbacks from the `bindings` map.
    return CallbackShortcuts(
      bindings: bindings,
      // The `Focus` widget is crucial here. For shortcuts to be detected,
      // the part of the widget tree listening for them must have focus.
      // `autofocus: true` attempts to give it focus as soon as it's built.
      child: Focus(autofocus: true, child: child),
    );
  }
}

/// A wrapper widget that provides pull-to-refresh functionality to a
/// scrollable child widget.
///
/// It uses Flutter's built-in `RefreshIndicator` to display a loading
/// spinner and trigger a refresh action when the user pulls down on the [child].
class PullToRefreshHelper extends StatefulWidget {
  /// Creates a `PullToRefreshHelper` widget.
  ///
  /// The [onRefresh] callback is required and will be executed when a refresh
  /// is triggered. The [child] is typically a scrollable list.
  const PullToRefreshHelper(
      {required this.onRefresh, required this.child, super.key});

  /// The asynchronous function to be called when the user pulls down to refresh.
  ///
  /// This function should contain the logic for fetching new data (e.g., an API call)
  /// and must return a `Future` that completes when the refresh operation is finished.
  final Future<void> Function() onRefresh;

  /// The scrollable widget (e.g., `ListView`, `GridView`, `CustomScrollView`)
  /// that will display the pull-to-refresh indicator.
  final Widget child;

  @override
  State<PullToRefreshHelper> createState() => _PullToRefreshHelperState();
}

class _PullToRefreshHelperState extends State<PullToRefreshHelper> {
  // A GlobalKey for the RefreshIndicator. This key allows for programmatic
  // control over the refresh indicator, such as showing it manually via
  // `_refreshIndicatorKey.currentState?.show()`.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    // `RefreshIndicator` is the core widget that provides the pull-to-refresh UI and logic.
    return RefreshIndicator(
      // Assign the key to the widget to enable programmatic access.
      key: _refreshIndicatorKey,
      // The callback function passed from the parent widget. This is triggered
      // by the user's pull gesture.
      onRefresh: widget.onRefresh,
      // The content that will be refreshed. This is typically a scrollable list of items.
      child: widget.child,
    );
  }
}
