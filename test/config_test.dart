/// Tests for config.dart constants.
import 'package:flutter_test/flutter_test.dart';
import 'package:app/config.dart';

void main() {
  test('Config values are valid', () {
    expect(geminiModel, isNotEmpty);
    expect(cloudRunHost, contains('run.app'));
  });
}
