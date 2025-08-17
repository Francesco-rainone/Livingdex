// test/main_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Avvio applicazione', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
