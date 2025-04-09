import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/app_drawer.dart';
import 'course_details_page.dart';

class MyCoursesPage extends StatefulWidget {
  final String cavalierId;

  const MyCoursesPage({super.key, required this.cavalierId});

  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> with SingleTickerProviderStateMixin {
  List<dynamic> myCourses = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _cardScaleAnimation;
  int _selectedIndex = 1;

  // Remplacez par votre vrai token ou supprimez si non utilisé
  final String authToken = 'votre_token_ici';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchMyCourses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchMyCourses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const String apiUrl = 'http://localhost/Exemple%20API/API%20BDD/get_my_courses.php';

    try {
      print('URL appelée: $apiUrl');
      print('Headers: Accept: application/json, Content-Type: application/x-www-form-urlencoded, Authorization: Bearer $authToken');
      print('Body: cavalier_id=${widget.cavalierId}');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $authToken',
        },
        body: {
          'cavalier_id': widget.cavalierId,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Délai dépassé : le serveur ne répond pas');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Données décodées: $data');
        if (data['success'] == true) {
          setState(() {
            myCourses = data['courses'] ?? [];
            isLoading = false;
          });
          if (myCourses.isEmpty) {
            setState(() {
              errorMessage = 'Vous n\'êtes inscrit à aucun cours';
            });
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Erreur inconnue de l\'API';
          });
        }
      } else {
        throw Exception('Erreur serveur : ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur détaillée : $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion : $e';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    AppNavigationBar.handleNavigation(context, index, widget.cavalierId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Cours',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: fetchMyCourses,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                'assets/recharger-les-fleches.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image1.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Cours auxquels vous êtes inscrit',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : errorMessage != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: fetchMyCourses,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                      : myCourses.isEmpty
                      ? const Center(
                    child: Text(
                      'Aucun cours trouvé',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    itemCount: myCourses.length,
                    itemBuilder: (context, index) {
                      final course = myCourses[index];
                      return ScaleTransition(
                        scale: _cardScaleAnimation,
                        child: Card(
                          elevation: 4,
                          color: Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/image2.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                            title: Text(
                              course['Libcours']?.toString() ?? 'Cours sans nom',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '${course['jour']?.toString() ?? 'N/A'} - ${course['HD']?.toString() ?? 'N/A'} à ${course['HF']?.toString() ?? 'N/A'}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: Image.asset(
                              'assets/plus-dinformation.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              _animationController.forward(from: 0);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailsPage(
                                    course: course,
                                    cavalierId: widget.cavalierId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigationBar(
        cavalierId: widget.cavalierId,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}