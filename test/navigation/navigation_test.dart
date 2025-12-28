/// Tests for [ScaffoldWithNavbar] navigation component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/ui/components/navigation.dart';

void main() {
  testWidgets('Renders NavigationRail on wide screens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldWithNavbar(child: Container()),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
