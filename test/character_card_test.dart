import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_explorer/main.dart';

void main() {
  testWidgets('CharacterCard renders name and chips correctly', (
    WidgetTester tester,
  ) async {
    final mockCharacter = {
      'name': 'Rick Sanchez',
      'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      'status': 'Alive',
      'species': 'Human',
      'location': {'name': 'Earth (C-137)'},
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CharacterCard(character: mockCharacter)),
      ),
    );

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Alive'), findsOneWidget);
    expect(find.text('Human'), findsOneWidget);
    expect(find.text('Earth (C-137)'), findsOneWidget);
  });
}
