import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/app_drawer.dart'; // Maintenant AppNavigationBar

class CourseDetailsPage extends StatefulWidget {
  final dynamic course;
  final String cavalierId;

  const CourseDetailsPage({super.key, required this.course, required this.cavalierId});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> with SingleTickerProviderStateMixin {
  bool isRegistered = false;
  bool isLoading = true;
  List<dynamic> sessions = [];
  Map<int, bool> participationStatus = {};
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    checkRegistrationStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> checkRegistrationStatus() async {
    setState(() {
      isLoading = true;
    });

    const String url = 'http://localhost/Exemple%20API/API%20BDD/check_inscription.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cavalier_id': widget.cavalierId,
          'cours_id': widget.course['idCours'].toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            isRegistered = data['isRegistered'] ?? false;
            isLoading = false;
          });
          fetchSessions();
        } else {
          showError('Erreur lors de la vérification de l\'inscription.');
        }
      } else {
        showError('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      showError('Erreur de connexion.');
    }
  }

  Future<void> fetchSessions() async {
    const String url = 'http://localhost/Exemple%20API/API%20BDD/get_sessions.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cours_id': widget.course['idCours'].toString(),
        },
      ).timeout(const Duration(seconds: 10));

      print('Fetch sessions response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            sessions = data['sessions'] ?? [];
          });
          for (var session in sessions) {
            fetchParticipationStatus(int.parse(session['idCourSeance'].toString()));
          }
        } else {
          showError('Erreur lors de la récupération des séances : ${data['message']}');
        }
      } else {
        showError('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      showError('Erreur de connexion : $e');
    }
  }

  Future<void> fetchParticipationStatus(int sessionId) async {
    const String url = 'http://localhost/Exemple%20API/API%20BDD/check_participation.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cavalier_id': widget.cavalierId,
          'session_id': sessionId.toString(),
          'course_id': widget.course['idCours'].toString(),
        },
      ).timeout(const Duration(seconds: 10));

      print('Check participation response for session $sessionId: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            participationStatus[sessionId] = data['isParticipating'] ?? true;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification de participation : $e');
    }
  }

  Future<void> toggleRegistration() async {
    _animationController.forward(from: 0);
    final String url = isRegistered
        ? 'http://localhost/Exemple%20API/API%20BDD/unsubscribe_course.php'
        : 'http://localhost/Exemple%20API/API%20BDD/subscribe_course.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cavalier_id': widget.cavalierId,
          'cours_id': widget.course['idCours'].toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            isRegistered = !isRegistered;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Action réussie'),
              backgroundColor: isRegistered ? Colors.green : Colors.red,
            ),
          );
          fetchSessions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion au serveur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> participateInSession(int sessionId) async {
    const String url = 'http://localhost/Exemple%20API/API%20BDD/participate_session.php';
    try {
      final body = {
        'cavalier_id': widget.cavalierId,
        'session_id': sessionId.toString(),
        'course_id': widget.course['idCours'].toString(),
      };
      print('Participate request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      print('Participate response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            participationStatus[sessionId] = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Inscription à la séance réussie'),
              backgroundColor: Colors.green,
            ),
          );
          fetchParticipationStatus(sessionId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion au serveur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> unparticipateInSession(int sessionId) async {
    const String url = 'http://localhost/Exemple%20API/API%20BDD/unparticipate_session.php';
    try {
      final body = {
        'cavalier_id': widget.cavalierId,
        'session_id': sessionId.toString(),
        'course_id': widget.course['idCours'].toString(),
      };
      print('Unparticipate request body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      print('Unparticipate response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            participationStatus[sessionId] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Désinscription de la séance réussie'),
              backgroundColor: Colors.red,
            ),
          );
          fetchParticipationStatus(sessionId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion au serveur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
          "Formulaire d'inscription",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Image.asset('assets/pingouin_back.png', width: 24, height: 24),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Détails du cours',
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
                const SizedBox(height: 12),
                _buildInfoRow('assets/un.png', 'Jour', widget.course['jour'].toString()),
                _buildInfoRow('assets/traverser.png', 'Heure', '${widget.course['HD']} - ${widget.course['HF']}'),
                _buildInfoRow('assets/equitation.png', 'Niveau', widget.course['RefGalop'].toString()),
                const SizedBox(height: 20),
                // Suppression des IDs :
                // _buildInfoCard('Cavalier ID', widget.cavalierId),
                // _buildInfoCard('Cours ID', widget.course['idCours'].toString()),
                Center(
                  child: isLoading
                      ? Image.asset(
                    'assets/verrouiller.png',
                    width: 24,
                    height: 24,
                  )
                      : ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: toggleRegistration,
                      icon: Image.asset(
                        isRegistered ? 'assets/traverser.png' : 'assets/jaccepte.png',
                        width: 24,
                        height: 24,
                      ),
                      label: Text(
                        isRegistered ? 'Se désinscrire' : "S'inscrire",
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isRegistered ? Colors.redAccent : Colors.greenAccent,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Séances du cours',
                  style: TextStyle(
                    fontSize: 24,
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
                const SizedBox(height: 12),
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(
                    child: Text(
                      'Aucune séance disponible',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final sessionId = int.parse(session['idCourSeance'].toString());
                      final isParticipating = participationStatus[sessionId] ?? true;

                      return Card(
                        elevation: 4,
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/logo_equestre.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          title: Text(
                            'Séance ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${session['DateCours'] ?? 'Non définie'}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              Text(
                                'Participation: ${isParticipating ? 'Oui' : 'Non'}',
                                style: TextStyle(
                                  color: isParticipating ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: isRegistered
                              ? ElevatedButton(
                            onPressed: () {
                              if (isParticipating) {
                                unparticipateInSession(sessionId);
                              } else {
                                participateInSession(sessionId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isParticipating ? Colors.redAccent : Colors.greenAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text(isParticipating ? 'Se désinscrire' : 'S\'inscrire'),
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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

  Widget _buildInfoRow(String imagePath, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            '$label : $value',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 3,
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label : ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}