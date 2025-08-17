// test/config_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/config.dart';

void main() {
  test('Dovrebbe avere valori di configurazione validi', () {
    expect(geminiModel, isNotEmpty);
    expect(cloudRunHost, contains('run.app'));
  });
}
