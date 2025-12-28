/// Tests for [SettingsScreen] theme toggle.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/ui/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:app/functionality/state.dart';

void main() {
  testWidgets('Dark mode toggle updates ThemeNotifier', (tester) async {
    final themeNotifier = ThemeNotifier();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeNotifier,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.byType(Switch));
    expect(themeNotifier.darkMode, isTrue);
  });
}
