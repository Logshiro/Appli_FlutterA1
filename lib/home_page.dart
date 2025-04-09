import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/app_drawer.dart'; // Maintenant AppNavigationBar
import 'course_details_page.dart';

class HomePage extends StatefulWidget {
  final String cavalierId;
  final String coursId;

  const HomePage({
    super.key,
    required this.cavalierId,
    required this.coursId,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<dynamic> cours = [];
  String? selectedJour;
  String? selectedGalop;
  String? libcours;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _cardScaleAnimation;
  int _selectedIndex = 0; // Index par défaut pour "Accueil"

  final List<String> jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final List<String> galops = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

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
    fetchCours();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchCours() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const String apiUrl = 'http://localhost/Exemple%20API/API%20BDD/get_cours_all.php';

    print('Platform: ${defaultTargetPlatform}');
    print('Fetch URL: $apiUrl');

    try {
      print('Tentative de connexion à $apiUrl avec GET...');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
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
        if (data['success'] == true) {
          setState(() {
            cours = data['cours'] ?? [];
            isLoading = false;
            print('Cours chargés : $cours');
          });
          if (cours.isEmpty) {
            setState(() {
              errorMessage = 'Aucun cours renvoyé par l\'API';
            });
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Erreur inconnue de l\'API';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Erreur serveur : ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion : $e';
      });
      print('Erreur détaillée : $e');
      print('Type d\'erreur : ${e.runtimeType}');
    }
  }

  List<dynamic> get filteredCours {
    return cours.where((cours) {
      bool matchesJour = selectedJour == null || (cours['jour'] != null && cours['jour'].toString() == selectedJour);
      bool matchesGalop = selectedGalop == null || (cours['RefGalop'] != null && cours['RefGalop'].toString() == selectedGalop);
      bool matchesLibcours = libcours == null || (cours['Libcours'] != null && cours['Libcours'].toString().toLowerCase().contains(libcours!.toLowerCase()));
      return matchesJour && matchesGalop && matchesLibcours;
    }).toList();
  }

  void resetFilters() {
    setState(() {
      selectedJour = null;
      selectedGalop = null;
      libcours = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtres réinitialisés'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    AppNavigationBar.handleNavigation(context, index, widget.cavalierId);
  }

  void _showFilterDialog() {
    // Variables locales pour stocker les valeurs temporaires dans le dialog
    String? tempJour = selectedJour;
    String? tempGalop = selectedGalop;
    String? tempLibcours = libcours;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text(
                'Filtrer les cours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Jour',
                            value: tempJour,
                            items: jours,
                            icon: 'assets/un.png',
                            onChanged: (String? newValue) {
                              dialogSetState(() {
                                tempJour = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Galop',
                            value: tempGalop,
                            items: galops,
                            icon: 'assets/equitation.png',
                            onChanged: (String? newValue) {
                              dialogSetState(() {
                                tempGalop = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Libellé du cours',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.blueAccent),
                        ),
                        fillColor: Colors.white.withOpacity(0.95),
                        filled: true,
                        prefixIcon: Image.asset(
                          'assets/libelle-de-referencement.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                      onChanged: (value) {
                        dialogSetState(() {
                          tempLibcours = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        dialogSetState(() {
                          tempJour = null;
                          tempGalop = null;
                          tempLibcours = null;
                        });
                      },
                      icon: Image.asset('assets/reinitialiser.png', width: 24, height: 24),
                      label: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedJour = tempJour;
                      selectedGalop = tempGalop;
                      libcours = tempLibcours;
                    });
                    Navigator.of(context).pop(); // Applique les filtres et ferme
                  },
                  child: const Text('Appliquer', style: TextStyle(color: Colors.blueGrey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme sans appliquer
                  },
                  child: const Text('Annuler', style: TextStyle(color: Colors.blueGrey)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accueil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset('assets/filtre.png', width: 24, height: 24),
            onPressed: _showFilterDialog, // Ouvre la popup des filtres
            tooltip: 'Filtrer les cours',
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenue sur la page d\'accueil !',
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
                    const SizedBox(height: 20),
                    const Text(
                      'Vos cours proposés',
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
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isLoading
                      ? Center(
                    child: Image.asset(
                      'assets/verrouiller.png',
                      width: 24,
                      height: 24,
                    ),
                  )
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
                          onPressed: fetchCours,
                          child: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                      : filteredCours.isEmpty
                      ? const Center(
                    child: Text(
                      'Aucun cours disponible',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    itemCount: filteredCours.length,
                    itemBuilder: (context, index) {
                      final coursItem = filteredCours[index];
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
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/pingouin_back.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                            title: Text(
                              coursItem['Libcours']?.toString() ?? 'Cours sans nom',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '${coursItem['jour']?.toString() ?? 'N/A'} - ${coursItem['HD']?.toString() ?? 'N/A'} à ${coursItem['HF']?.toString() ?? 'N/A'}',
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
                                    course: coursItem,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String icon,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        fillColor: Colors.white.withOpacity(0.95),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(label),
        isExpanded: true,
        icon: ImageIcon(
          AssetImage(icon),
          size: 24,
          color: Colors.black54,
        ),
        underline: Container(),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}