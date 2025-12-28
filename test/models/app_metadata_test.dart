/// Tests for [Metadata] model serialization and widget building.
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/metadata.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('Metadata', () {
    test('fromJson handles different input types', () {
      final jsonList = {
        'name': 'Pikachu',
        'description': 'Electric Mouse',
        'suggestedQuestions': ['Q1', 'Q2'],
        'height': '0.4m',
        'weight': '6kg',
        'type': ['Electric']
      };

      final jsonString = {
        'name': 'Bulbasaur',
        'description': 'Grass Pokemon',
        'suggestedQuestions': 'SingleQuestion',
        'height': '0.7m',
        'weight': '6.9kg',
        'type': 'Grass'
      };

      final fromList = Metadata.fromJson(jsonList);
      final fromString = Metadata.fromJson(jsonString);

      expect(fromList.suggestedQuestions, ['Q1', 'Q2']);
      expect(fromString.suggestedQuestions, ['SingleQuestion']);
      expect(fromList.type, ['Electric']);
      expect(fromString.type, ['Grass']);
    });

    test('toString returns correct format', () {
      final metadata = Metadata(
        name: 'Test',
        description: 'Desc',
        suggestedQuestions: [],
        height: '1m',
        weight: '10kg',
        type: [],
      );
      expect(metadata.toString(),
          'Metadata(name: Test, description: Desc, suggestedQuestions: [], height: 1m, weight: 10kg, type: [])');
    });

    testWidgets('buildNameAndDescription shows loading state', (tester) async {
      final metadata = Metadata(
        name: 'Test',
        description: 'Desc',
        suggestedQuestions: [],
        height: '1m',
        weight: '10kg',
        type: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: metadata.buildNameAndDescription(loading: true),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsNWidgets(2));
    });
  });
}
