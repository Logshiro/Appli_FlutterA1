import 'package:flutter/foundation.dart'; // Pour defaultTargetPlatform (debug)
import 'package:flutter/material.dart'; // Pour les widgets Material Design
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'dart:convert'; // Pour encoder/décoder JSON

import 'course_details_page.dart'; // Importe la page des détails du cours

// Widget principal avec état pour la page d'accueil
class HomePage extends StatefulWidget {
  final String cavalierId; // ID du cavalier passé en paramètre
  final String coursId; // ID du cours passé en paramètre

  const HomePage({
    super.key,
    required this.cavalierId,
    required this.coursId,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

// État de la page d'accueil
class _HomePageState extends State<HomePage> {
  List<dynamic> cours = []; // Liste des cours récupérés depuis l'API
  String? selectedJour; // Jour sélectionné pour le filtre
  String? selectedGalop; // Galop sélectionné pour le filtre
  String? libcours; // Libellé du cours pour le filtre
  bool isLoading = true; // Indicateur de chargement
  String? errorMessage; // Message d'erreur en cas de problème

  // Listes statiques pour les options des filtres
  final List<String> jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final List<String> galops = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

  @override
  void initState() {
    super.initState();
    fetchCours(); // Charge les cours au démarrage de la page
  }

  // Récupère les cours depuis l'API spécifiée
  Future<void> fetchCours() async {
    setState(() {
      isLoading = true; // Affiche l'indicateur de chargement
      errorMessage = null; // Réinitialise le message d'erreur
    });

    // URL pour récupérer les cours
    const String apiUrl = 'http://localhost/Exemple%20API/API%20BDD/get_cours_all.php';

    print('Platform: ${defaultTargetPlatform}'); // Affiche la plateforme (debug)
    print('Fetch URL: $apiUrl'); // Affiche l'URL utilisée (debug)

    try {
      print('Tentative de connexion à $apiUrl avec GET...'); // Log de la requête
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json', // Attend une réponse au format JSON
        },
      ).timeout(
        const Duration(seconds: 10), // Timeout de 10 secondes pour éviter un blocage
        onTimeout: () {
          throw Exception('Délai dépassé : le serveur ne répond pas');
        },
      );

      print('Response status: ${response.statusCode}'); // Affiche le code HTTP de la réponse
      print('Response body: ${response.body}'); // Affiche le corps de la réponse (debug)

      if (response.statusCode == 200) { // Réponse HTTP réussie
        final data = jsonDecode(response.body); // Décode la réponse JSON
        if (data['success'] == true) { // Vérifie si l'API indique un succès
          setState(() {
            cours = data['cours'] ?? []; // Assigne les cours ou une liste vide si null
            isLoading = false; // Fin du chargement
            print('Cours chargés : $cours'); // Log des cours récupérés (debug)
          });
          if (cours.isEmpty) {
            setState(() {
              errorMessage = 'Aucun cours renvoyé par l\'API'; // Message si la liste est vide
            });
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Erreur inconnue de l\'API'; // Message d'erreur de l'API
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Erreur serveur : ${response.statusCode} - ${response.reasonPhrase}'; // Erreur HTTP
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion : $e'; // Erreur réseau ou autre
      });
      print('Erreur détaillée : $e'); // Log de l'erreur (debug)
      print('Type d\'erreur : ${e.runtimeType}'); // Type de l'erreur (debug)
    }
  }

  // Retourne la liste des cours filtrés selon les critères sélectionnés
  List<dynamic> get filteredCours {
    return cours.where((cours) {
      // Vérifie chaque critère avec une gestion des valeurs nulles pour éviter les erreurs
      bool matchesJour = selectedJour == null || (cours['jour'] != null && cours['jour'] == selectedJour);
      bool matchesGalop = selectedGalop == null || (cours['RefGalop'] != null && cours['RefGalop'].toString() == selectedGalop);
      bool matchesLibcours = libcours == null || (cours['Libcours'] != null && cours['Libcours'].toLowerCase().contains(libcours!.toLowerCase()));
      return matchesJour && matchesGalop && matchesLibcours; // Combine les conditions
    }).toList();
  }

  // Réinitialise les filtres à leurs valeurs par défaut (null)
  void resetFilters() {
    setState(() {
      selectedJour = null; // Réinitialise le jour
      selectedGalop = null; // Réinitialise le galop
      libcours = null; // Réinitialise le libellé
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'), // Titre de la barre d'application
        actions: [
          IconButton(
            icon: Image.asset('assets/se-deconnecter.png'), // Icône de déconnexion
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/'); // Retourne à la page de connexion
            },
          ),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bienvenue sur la page d\'accueil!', style: TextStyle(fontSize: 24, color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text('Filtrer les cours :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Jour',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            child: DropdownButton<String>(
                              value: selectedJour,
                              hint: const Text('Jour'),
                              isExpanded: true,
                              icon: const ImageIcon(AssetImage('assets/un.png'), size: 24),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedJour = newValue;
                                });
                              },
                              items: jours.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Galop',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            child: DropdownButton<String>(
                              value: selectedGalop,
                              hint: const Text('Galop'),
                              isExpanded: true,
                              icon: const ImageIcon(AssetImage('assets/equitation.png'), size: 24),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedGalop = newValue;
                                });
                              },
                              items: galops.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Libellé du cours',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          libcours = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: resetFilters,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/reinitialiser.png', width: 24, height: 24, fit: BoxFit.cover),
                          const SizedBox(width: 8),
                          const Text('Réinitialiser'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Vos Cours proposés :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                      : filteredCours.isEmpty
                      ? const Center(child: Text('Aucun cours disponible', style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                    itemCount: filteredCours.length,
                    itemBuilder: (context, index) {
                      final coursItem = filteredCours[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailsPage(
                                course: coursItem,
                                cavalierId: widget.cavalierId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: Image.asset('assets/image2.jpg', width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(coursItem['Libcours'] ?? 'Cours sans nom', style: TextStyle(color: Colors.black)),
                            subtitle: Text('${coursItem['jour'] ?? 'N/A'} - ${coursItem['HD'] ?? 'N/A'} à ${coursItem['HF'] ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
