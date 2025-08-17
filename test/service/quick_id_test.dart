import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:app/ui/screens/quick_id.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Definizione dell'interfaccia del servizio
abstract class AnalysisService {
  Future<String> analyzeImage(Uint8List image);
}

// Mock del servizio
class MockAnalysisService extends Mock implements AnalysisService {}

void main() {
  group('Quick ID Service Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockAnalysisService mockService;

    setUpAll(() {
      registerFallbackValue(Uint8List(0));
    });

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockService = MockAnalysisService();
    });

    testWidgets('Generazione metadati con Firestore mockato', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirebaseFirestore>.value(value: fakeFirestore),
            Provider<AnalysisService>.value(value: mockService),
          ],
          child: const MaterialApp(home: GenerateMetadataScreen()),
        ),
      );

      // Simula la cattura di un'immagine
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      verify(() => mockService.analyzeImage(any())).called(1);
    });
  });
}
