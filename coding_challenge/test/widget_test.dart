// Widget tests for the Pokemon Search App
//
// This test suite verifies the basic functionality of the Pokemon search app
// including search bar presence, initial loading state, and basic interactions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coding_challenge/main.dart';

void main() {
  testWidgets('Pokemon Search App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the search bar is present
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search Pokémon...'), findsOneWidget);

    // Verify that the app title is present
    expect(find.text('Pokémon Search'), findsOneWidget);

    // Wait for initial data to load
    await tester.pumpAndSettle();

    // Verify that Pokemon cards are loaded (or loading indicator)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Search functionality test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Find the search field
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Enter search text
    await tester.enterText(searchField, 'pikachu');
    await tester.pump();

    // Verify the text was entered
    expect(find.text('pikachu'), findsOneWidget);
  });
}
