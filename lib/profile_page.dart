import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/app_drawer.dart'; // AppNavigationBar

class ProfilePage extends StatefulWidget {
  final String cavalierId;

  const ProfilePage({super.key, required this.cavalierId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2;
  Map<String, dynamic>? cavalierData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCavalierData();
  }

  Future<void> fetchCavalierData() async {
    try {
      final url = Uri.parse('http://localhost/Exemple%20API/API%20BDD/get_cavalier.php?id=${widget.cavalierId}');
      print('URL appelée: $url');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Délai de connexion dépassé'),
      );
      print('Code de statut: ${response.statusCode}');
      print('Réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            cavalierData = data;
            isLoading = false;
          });
        } else {
          throw Exception('Format de données invalide: ${response.body}');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur complète: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
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
          'Profil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cavalierData != null && cavalierData!['error'] == null
            ? SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/logo_equestre.png'), // Nouvelle image
                backgroundColor: Colors.white, // Fond blanc en cas de transparence
              ),
              const SizedBox(height: 20),
              Text(
                '${cavalierData!['PrenomCavalier']} ${cavalierData!['NomCavalier']}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard('Numéro de licence', cavalierData!['Numlicence'].toString()),
              _buildInfoCard('Date de naissance', cavalierData!['DateNaissanceCavalier']),
              _buildInfoCard('Responsable', '${cavalierData!['PreNomResponsable']} ${cavalierData!['NomResponsable']}'),
              _buildInfoCard('Téléphone', cavalierData!['TelResponsable']),
              _buildInfoCard('Email', cavalierData!['MailResponsable']),
              _buildInfoCard('Commune', cavalierData!['Nomcommune']),
              _buildInfoCard('Code postal', cavalierData!['COPResponsable'].toString()),
              _buildInfoCard('Assurance', cavalierData!['Assurance']),
            ],
          ),
        )
            : const Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: Colors.white, fontSize: 18),
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

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}