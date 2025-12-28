import '../utilities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation_icons.dart';

/// Bottom navigation bar destinations for compact screens.
var navBarDestinations = const [
  NavigationDestination(
    icon: Icon(Navigation.pokemon),
    label: 'Cattura',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings),
    label: 'Impostazioni',
  ),
];

/// Navigation rail destinations for medium+ screens.
var navRailDestinations = const [
  NavigationRailDestination(
    icon: Icon(Navigation.pokemon),
    label: Text('Cattura'),
    padding: EdgeInsets.all(16),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.settings),
    label: Text('Impostazioni'),
    padding: EdgeInsets.all(16),
  ),
];

/// Responsive scaffold with bottom nav (compact) or side rail (wider screens).
class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar({
    required this.child,
    super.key,
  });

  /// Main content widget.
  final Widget child;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  int screenIndex = 0;

  /// Navigates to route based on selected index.
  void selectDestination(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/settings');
        break;
      default:
        context.go('/home');
    }
    setState(() {
      screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final useSideNavRail =
        MediaQuery.sizeOf(context).width >= Breakpoints.compact;

    return Scaffold(
      body: Row(
        children: [
          if (useSideNavRail)
            NavRail(
              backgroundColor: Color(0xffff3334),
              selectedIndex: screenIndex,
              onDestinationSelected: selectDestination,
            ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: useSideNavRail
          ? null
          : NavigationBar(
              backgroundColor: Color(0xffff3334),
              selectedIndex: screenIndex,
              onDestinationSelected: selectDestination,
              destinations: navBarDestinations,
            ),
    );
  }
}

/// Configurable NavigationRail wrapper.
class NavRail extends StatelessWidget {
  const NavRail({
    super.key,
    required this.backgroundColor,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  final Color backgroundColor;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      backgroundColor: backgroundColor,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      leading: const SizedBox(height: 48),
      destinations: navRailDestinations,
    );
  }
}
