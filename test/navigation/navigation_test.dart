// test/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/ui/components/navigation.dart';

void main() {
  testWidgets('Navigazione tra schermate', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldWithNavbar(child: Container()),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
