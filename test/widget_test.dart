import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet/main.dart';

void main() {
  testWidgets('Test de navigation et affichage des cours', (WidgetTester tester) async {
    // Construire l'application et déclencher un frame.
    await tester.pumpWidget(MyApp());

    // Vérifier que la page de connexion est affichée.
    expect(find.text('Connexion'), findsOneWidget);

    // Saisir les informations de connexion.
    await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password');

    // Appuyer sur le bouton de connexion.
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    // Vérifier que la navigation vers la page d'accueil s'est bien déroulée.
    expect(find.text('Accueil'), findsOneWidget);

    // Vérifier que les cours sont affichés.
    expect(find.text('Vos cours :'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
