/// Tests for GoRouter configuration.
import 'package:app/functionality/routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Router is properly configured', () {
    expect(router.routeInformationParser, isNotNull);
    expect(router.routerDelegate, isNotNull);
  });
}
