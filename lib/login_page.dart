import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'focus_node.dart'; // Assurez-vous que ce fichier existe et est correctement importé

class LoginPage extends StatefulWidget {
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
    _focusManager.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

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

          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'cours': [], 'cavalierId': _cavalierId, 'coursId': _coursId},
          );
        } else {
          setState(() {
            _errorMessage = loginData['message'];
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image2.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: Padding(
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
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
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
                          key: Key('emailField'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Nom d\'utilisateur',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: ImageIcon(
                                AssetImage('assets/image_utilisateur.png'),
                                color: Colors.brown,
                                size: 24.0,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown, width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Focus(
                        focusNode: _focusManager.passwordFocusNode,
                        child: TextField(
                          key: Key('passwordField'),
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: ImageIcon(
                                AssetImage('assets/verrouiller.png'),
                                color: Colors.brown,
                                size: 24.0,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.brown, width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          ),
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        key: Key('loginButton'),
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.brown,
                          elevation: 5,
                          shadowColor: Colors.brown.withOpacity(0.5),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.brown.shade700, Colors.brown.shade500],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            const Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
