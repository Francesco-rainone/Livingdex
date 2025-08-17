// Import necessary packages and local files.
import '../utilities.dart'; // Contains shared utilities, like breakpoint constants.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Used for declarative routing.
import '../../../navigation_icons.dart'; // Custom icon set for the application.

/// Defines the navigation destinations for the bottom navigation bar.
/// This is typically used for compact screen sizes (e.g., mobile phones).
var navBarDestinations = const [
  NavigationDestination(
    icon: Icon(Navigation.pokemon), // Custom icon for the 'Capture' screen.
    label: 'Cattura',
  ),
  NavigationDestination(
    icon: Icon(
        Icons.settings), // Standard Flutter icon for the 'Settings' screen.
    label: 'Impostazioni',
  ),
];

/// Defines the navigation destinations for the side navigation rail.
/// This is used for medium and larger screen sizes (e.g., tablets, desktops).
var navRailDestinations = const [
  NavigationRailDestination(
    icon: Icon(Navigation.pokemon), // Custom icon for the 'Capture' screen.
    label: Text('Cattura'),
    padding: EdgeInsets.all(16),
  ),
  NavigationRailDestination(
    icon: Icon(
        Icons.settings), // Standard Flutter icon for the 'Settings' screen.
    label: Text('Impostazioni'),
    padding: EdgeInsets.all(16),
  ),
];

/// A responsive Scaffold widget that adapts its navigation UI based on screen width.
///
/// It displays a [BottomNavigationBar] on compact screens and a [NavigationRail]
/// (side navigation) on wider screens. This widget wraps the main content
/// of a screen, providing a consistent navigation structure.
class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar({
    required this.child,
    super.key,
  });

  /// The main content widget to be displayed within the Scaffold's body.
  final Widget child;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  // The index of the currently selected screen in the navigation bar/rail.
  int screenIndex = 0;

  /// Handles the selection of a navigation destination.
  ///
  /// This method uses `go_router` to navigate to the appropriate route
  /// based on the selected [index] and updates the state to reflect
  /// the new active screen.
  void selectDestination(int index) {
    // Navigate to the corresponding route using GoRouter.
    switch (index) {
      case 0:
        context.go('/home'); // Navigate to the home/capture screen.
        break;
      case 1:
        context.go('/settings'); // Navigate to the settings screen.
        break;
      // It's good practice to have a default case, even if all indices are handled.
      default:
        context.go('/home');
    }
    // Update the state to visually highlight the selected destination.
    setState(() {
      screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether to show the side navigation rail based on the screen width.
    // `Breakpoints.compact` is a predefined constant from 'utilities.dart'.
    final useSideNavRail =
        MediaQuery.sizeOf(context).width >= Breakpoints.compact;

    return Scaffold(
      body: Row(
        children: [
          // Conditionally display the navigation rail if the screen is wide enough.
          if (useSideNavRail)
            NavRail(
              backgroundColor:
                  Color(0xffff3334), // Custom background color for the rail.
              selectedIndex: screenIndex, // The currently active index.
              onDestinationSelected:
                  selectDestination, // Callback for item selection.
            ),
          // The main content area. It expands to fill the remaining horizontal space.
          Expanded(child: widget.child),
        ],
      ),
      // The bottom navigation bar is only shown on smaller screens (when the side rail is not used).
      bottomNavigationBar: useSideNavRail
          ? null // Hide the bottom bar on wider screens.
          : NavigationBar(
              backgroundColor:
                  Color(0xffff3334), // Custom background color for the bar.
              selectedIndex: screenIndex,
              onDestinationSelected: selectDestination,
              destinations:
                  navBarDestinations, // The list of items for the bottom bar.
            ),
    );
  }
}

/// A stateless widget that encapsulates the configuration for the [NavigationRail].
///
/// This helps to keep the main build method of [ScaffoldWithNavbar] cleaner
/// and makes the navigation rail's styling reusable.
class NavRail extends StatelessWidget {
  const NavRail({
    super.key,
    required this.backgroundColor,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  /// The background color of the navigation rail.
  final Color backgroundColor;

  /// The index of the currently selected destination.
  final int selectedIndex;

  /// The callback that is called when a new destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      backgroundColor: backgroundColor,
      onDestinationSelected: onDestinationSelected,
      // Ensures that labels are always visible next to the icons.
      labelType: NavigationRailLabelType.all,
      // Shows a visual indicator around the selected item's icon.
      useIndicator: true,
      // A leading widget can be used for a logo, menu button, or just for spacing.
      // Here, it adds vertical space at the top of the rail.
      leading: const SizedBox(height: 48),
      destinations: navRailDestinations, // The list of items for the side rail.
    );
  }
}
