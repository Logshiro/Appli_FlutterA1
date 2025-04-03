import 'package:flutter/material.dart'; // Pour les widgets Material Design
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'dart:convert'; // Pour encoder/décoder JSON

// Widget principal avec état pour la page des détails d'un cours
class CourseDetailsPage extends StatefulWidget {
  final dynamic course; // Données du cours passé en paramètre
  final String cavalierId; // ID du cavalier passé en paramètre

  const CourseDetailsPage({super.key, required this.course, required this.cavalierId});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

// État de la page des détails du cours
class _CourseDetailsPageState extends State<CourseDetailsPage> {
  bool isRegistered = false; // Indique si le cavalier est inscrit au cours
  bool isLoading = true; // Indique si la vérification de l'inscription est en cours
  List<dynamic> sessions = []; // Liste des séances du cours

  @override
  void initState() {
    super.initState();
    checkRegistrationStatus(); // Vérifie l'état d'inscription au démarrage
  }

  // Vérifie si le cavalier est déjà inscrit au cours en appelant l'API check_inscription.php
  Future<void> checkRegistrationStatus() async {
    setState(() {
      isLoading = true; // Affiche un indicateur de chargement
    });

    const String url = 'http://localhost/Exemple%20API/API%20BDD/check_inscription.php';
    print('Check URL: $url'); // Log de l'URL (debug)

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json', // Attend une réponse JSON
          'Content-Type': 'application/x-www-form-urlencoded', // Format des données envoyées
        },
        body: {
          'cavalier_id': widget.cavalierId, // ID du cavalier
          'cours_id': widget.course['idCours'].toString(), // ID du cours
        },
      ).timeout(const Duration(seconds: 10)); // Timeout de 10 secondes

      print('Check response status: ${response.statusCode}'); // Log du statut HTTP
      print('Check response body: ${response.body}'); // Log de la réponse

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            isRegistered = data['isRegistered'] ?? false; // Met à jour l'état d'inscription
            isLoading = false; // Fin du chargement
          });
          fetchSessions(); // Récupère les séances du cours
        } else {
          showError('Erreur lors de la vérification de l\'inscription.');
          print('Erreur API (check): ${data['message']}'); // Log de l'erreur API
        }
      } else {
        showError('Erreur serveur : ${response.statusCode}'); // Erreur HTTP
        print('Erreur serveur (check): ${response.statusCode}'); // Log de l'erreur HTTP
      }
    } catch (e) {
      showError('Erreur de connexion.'); // Erreur réseau
      print('Erreur de connexion (check): $e'); // Log de l'erreur réseau
    }
  }

  // Récupère les séances du cours
  Future<void> fetchSessions() async {
    const String url = 'http://localhost/Exemple%20API/API%20BDD/get_sessions.php';
    print('Fetch sessions URL: $url'); // Log de l'URL (debug)

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json', // Attend une réponse JSON
          'Content-Type': 'application/x-www-form-urlencoded', // Format des données envoyées
        },
        body: {
          'cours_id': widget.course['idCours'].toString(), // ID du cours
        },
      ).timeout(const Duration(seconds: 10)); // Timeout de 10 secondes

      print('Fetch sessions response status: ${response.statusCode}'); // Log du statut HTTP
      print('Fetch sessions response body: ${response.body}'); // Log de la réponse

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            sessions = data['sessions'] ?? []; // Met à jour la liste des séances
          });
        } else {
          showError('Erreur lors de la récupération des séances.');
          print('Erreur API (fetch sessions): ${data['message']}'); // Log de l'erreur API
        }
      } else {
        showError('Erreur serveur : ${response.statusCode}'); // Erreur HTTP
        print('Erreur serveur (fetch sessions): ${response.statusCode}'); // Log de l'erreur HTTP
      }
    } catch (e) {
      showError('Erreur de connexion.'); // Erreur réseau
      print('Erreur de connexion (fetch sessions): $e'); // Log de l'erreur réseau
    }
  }

  // Gère l'inscription ou la désinscription du cavalier
  Future<void> toggleRegistration() async {
    final String url = isRegistered
        ? 'http://localhost/Exemple%20API/API%20BDD/unsubscribe_course.php'
        : 'http://localhost/Exemple%20API/API%20BDD/subscribe_course.php';
    print('Toggle URL: $url'); // Log de l'URL (debug)

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json', // Attend une réponse JSON
          'Content-Type': 'application/x-www-form-urlencoded', // Format des données envoyées
        },
        body: {
          'cavalier_id': widget.cavalierId, // ID du cavalier
          'cours_id': widget.course['idCours'].toString(), // ID du cours
        },
      ).timeout(const Duration(seconds: 10)); // Timeout de 10 secondes

      print('Toggle response status: ${response.statusCode}'); // Log du statut HTTP
      print('Toggle response body: ${response.body}'); // Log de la réponse

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            isRegistered = !isRegistered; // Inverse l'état d'inscription
          });
          // Affiche un message de confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Action réussie')),
          );
          fetchSessions(); // Récupère les séances du cours
        } else {
          // Affiche une erreur si l'API échoue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${data['message']}')),
          );
        }
      } else {
        // Affiche une erreur si la requête HTTP échoue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion au serveur')),
        );
      }
    } catch (e) {
      // Affiche une erreur en cas de problème réseau
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
      print('Erreur de connexion (toggle): $e'); // Log de l'erreur
    }
  }

  // Fonction pour afficher les erreurs via un SnackBar
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulaire d'inscription"), // Titre de la barre d'application
        leading: IconButton(
          icon: Image.asset('assets/pingouin_back.png'), // Bouton de retour avec une image
          onPressed: () {
            Navigator.of(context).pop(); // Retourne à la page précédente
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond
          Image.asset(
            'assets/image1.jpg',
            fit: BoxFit.cover,
          ),
          // Contenu de la page
          Padding(
            padding: const EdgeInsets.all(16.0), // Marge intérieure
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Détails du cours :',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text('Jour : ${widget.course['jour']}', style: const TextStyle(fontSize: 18, color: Colors.white)), // Affiche le jour
                Text('Heure : ${widget.course['HD']} - ${widget.course['HF']}', style: const TextStyle(fontSize: 18, color: Colors.white)), // Affiche les horaires
                Text('Niveau de Galop : ${widget.course['RefGalop']}', style: const TextStyle(fontSize: 18, color: Colors.white)), // Affiche le galop
                const SizedBox(height: 20),
                Text(
                  'ID du Cavalier : ${widget.cavalierId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'ID du Cours : ${widget.course['idCours']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator() // Affiche un indicateur pendant le chargement
                      : ElevatedButton(
                    onPressed: toggleRegistration, // Appelle la fonction pour s'inscrire/désinscrire
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      backgroundColor: isRegistered ? Colors.red : Colors.green, // Rouge pour désinscription, vert pour inscription
                    ),
                    child: Text(
                      isRegistered ? 'Se désinscrire' : "S'inscrire", // Texte selon l'état
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Séances du cours :',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(child: Text('Aucune séance disponible', style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ListTile(
                        subtitle: Text('Date: ${session['DateCours'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
