// test/widgets/adaptive_helper_widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/ui/components/adaptive_helper_widgets.dart';

void main() {
  group('ShortcutHelper', () {
    testWidgets('Trigger scorciatoia Ctrl+T', (tester) async {
      bool triggered = false;

      await tester.pumpWidget(
        ShortcutHelper(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
                triggered = true
          },
          child: Container(),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      expect(triggered, isTrue);
    });
  });
}
