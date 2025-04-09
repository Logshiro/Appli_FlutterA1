import 'package:flutter/material.dart';
import 'login_page.dart'; // Importe la page de connexion
import 'home_page.dart'; // Importe la page d'accueil
import 'course_details_page.dart'; // Importe la page des détails du cours
import 'my_courses_page.dart'; // Importe la page "Mes Cours"
import 'profile_page.dart'; // Importe la page "Profil"

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Mon Application Équestre',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: '/', // Route initiale : page de connexion
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const LoginPage(),
          );
        } else if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => HomePage(
              cavalierId: args?['cavalierId'] ?? 'default_cavalier_id',
              coursId: args?['coursId'] ?? '',
            ),
          );
        } else if (settings.name == '/course_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CourseDetailsPage(
              course: args['course'],
              cavalierId: args['cavalierId'],
            ),
          );
        } else if (settings.name == '/my_courses') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MyCoursesPage(
              cavalierId: args['cavalierId'],
            ),
          );
        } else if (settings.name == '/profile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProfilePage(
              cavalierId: args['cavalierId'],
            ),
          );
        }
        return null;
      },
    );
  }
}