import 'package:flutter/material.dart';
import 'login_page.dart';  // Ensure this path is correct
import 'home_page.dart';
import 'inscrit_cours_page.dart';  // Ensure this path is correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haras Des Neuilles',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return HomePage(
              cavalierId: args['cavalierId'] ?? 'Inconnu',
              coursId: args['coursId'] ?? 'Inconnu',
            );
          } else {
            return Scaffold(
              appBar: AppBar(title: Text('Erreur')),
              body: Center(child: Text('Erreur lors du chargement des cours.')),
            );
          }
        },
        '/inscrit': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          if (args != null && args['cours'] is List<dynamic> && args['cavalierId'] != null && args['coursId'] != null) {
            return InscritCoursPage(
              cours: args['cours'],
              cavalierId: args['cavalierId'],
              coursId: args['coursId'],
            );
          } else {
            return Scaffold(
              appBar: AppBar(title: Text('Erreur')),
              body: Center(child: Text('Erreur lors du chargement des cours.')),
            );
          }
        },
      },
    );
  }
}
