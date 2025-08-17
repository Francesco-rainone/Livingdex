import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/ui/components/core_components.dart';
import 'package:app/models/metadata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('MetadataCard', () {
    testWidgets('Mostra shimmer durante il caricamento', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetadataCard(
              loading: true,
              metadata: null,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('Mostra metadati quando disponibili', (tester) async {
      final mockMetadata = Metadata(
        suggestedQuestions: ['Q1', 'Q2'],
        name: 'Pikachu',
        height: '0.4 m',
        weight: '6.0 kg',
        description: 'Roditore elettrico',
        type: ['Elettrico'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetadataCard(
              loading: false,
              metadata: mockMetadata,
            ),
          ),
        ),
      );

      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('0.4 m'), findsOneWidget);
    });
  });

  group('TagCapsule', () {
    testWidgets('Mostra 3 tag correttamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagCapsule(
              tags: const ['Elettrico', 'Velocità', 'Piccolo'],
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Chip), findsNWidgets(3));
    });
  });

  group('TextCapsule', () {
    testWidgets('Mostra contenuto e pulsante copia', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextCapsule(
              content: 'Descrizione di prova',
              enableCopy: true,
              loading: false,
            ),
          ),
        ),
      );

      expect(find.text('Descrizione di prova'), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.copy), findsOneWidget);
    });
  });
}
