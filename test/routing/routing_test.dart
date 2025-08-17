// test/routing/routing_test.dart
import 'package:app/functionality/routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Configurazione route principale', () {
    expect(router.routeInformationParser, isNotNull);
    expect(router.routerDelegate, isNotNull);
  });
}
