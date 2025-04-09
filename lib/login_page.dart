import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'focus_node.dart'; // Assurez-vous que ce fichier existe et est correctement importé

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CustomFocusManager _focusManager = CustomFocusManager();
  String? _errorMessage;
  String? _cavalierId;
  String? _coursId;

  final Color beigeColor = const Color(0xFFF5F5DC);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusManager.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    const loginUrl = 'http://localhost/Exemple%20API/API%20BDD/login.php';
    try {
      final loginResponse = await http.post(
        Uri.parse(loginUrl),
        body: {'mail': email, 'password': password},
      );

      print('Response status: ${loginResponse.statusCode}');
      print('Response body: ${loginResponse.body}');

      if (loginResponse.statusCode == 200) {
        final loginData = json.decode(loginResponse.body);
        print("Login Data: $loginData");

        if (loginData['success']) {
          setState(() {
            _cavalierId = loginData['id']?.toString();
            _coursId = loginData['cours_id']?.toString();
          });

          // Redirection vers HomePage après une connexion réussie
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'cavalierId': _cavalierId,
              'coursId': _coursId,
            },
          );
        } else {
          setState(() {
            _errorMessage = loginData['message'] ?? 'Erreur de connexion';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur de connexion: ${loginResponse.reasonPhrase}';
        });
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      setState(() {
        _errorMessage = 'Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54, // Voile sombre pour la lisibilité
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 12.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: beigeColor.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo_equestre.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 100,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Focus(
                        focusNode: _focusManager.emailFocusNode,
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            _focusManager.requestPasswordFocus();
                          }
                        },
                        child: TextField(
                          key: const Key('emailField'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Nom d\'utilisateur',
                            labelStyle: const TextStyle(color: Colors.brown),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: ImageIcon(
                                const AssetImage('assets/image_utilisateur.png'),
                                color: Colors.brown,
                                size: 24.0,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown, width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                            fillColor: Colors.white.withOpacity(0.9),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Focus(
                        focusNode: _focusManager.passwordFocusNode,
                        child: TextField(
                          key: const Key('passwordField'),
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: const TextStyle(color: Colors.brown),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: ImageIcon(
                                const AssetImage('assets/verrouiller.png'),
                                color: Colors.brown,
                                size: 24.0,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown, width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                            fillColor: Colors.white.withOpacity(0.9),
                            filled: true,
                          ),
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        key: const Key('loginButton'),
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.brown,
                          elevation: 5,
                          shadowColor: Colors.brown.withOpacity(0.5),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.brown.shade700, Colors.brown.shade500],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: const Center(
                            child: Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}