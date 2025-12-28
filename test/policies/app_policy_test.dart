/// Tests for [Capabilities] and [Policy] classes.
import 'package:flutter_test/flutter_test.dart';
import 'package:app/functionality/adaptive/capabilities.dart';
import 'package:app/functionality/adaptive/policies.dart';

void main() {
  group('Capabilities', () {
    test('hasCamera returns true', () {
      expect(Capabilities.hasCamera, true);
    });

    test('hasPhysicalKeyboard returns true', () {
      expect(Capabilities.hasPhysicalKeyboard, true);
    });
  });

  group('Policy', () {
    test('shouldTakePicture reflects capabilities', () {
      expect(Policy.shouldTakePicture, Capabilities.hasCamera);
    });

    test('shouldHaveKeyboardShortcuts reflects capabilities', () {
      expect(
          Policy.shouldHaveKeyboardShortcuts, Capabilities.hasPhysicalKeyboard);
    });
  });
}
