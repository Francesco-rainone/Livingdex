/// Tests for [ChatPage] message handling.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/ui/screens/chat.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:app/functionality/state.dart';

void main() {
  testWidgets('Sending message updates UI', (tester) async {
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          Provider<FakeFirebaseFirestore>.value(value: firestore),
        ],
        child: const MaterialApp(home: ChatPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Ciao');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Ciao'), findsOneWidget);
  });
}
