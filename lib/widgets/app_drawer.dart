import 'package:flutter/material.dart';

class AppNavigationBar extends StatelessWidget {
  final String cavalierId;
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigationBar({
    super.key,
    required this.cavalierId,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.blueGrey[900]?.withOpacity(0.95), // Fond sombre avec légère transparence
      selectedItemColor: Colors.white, // Couleur des éléments sélectionnés
      unselectedItemColor: Colors.white70, // Couleur des éléments non sélectionnés
      iconSize: 30, // Taille des icônes augmentée pour une meilleure visibilité
      selectedFontSize: 14, // Taille de la police pour l'élément sélectionné
      unselectedFontSize: 12, // Taille de la police pour les éléments non sélectionnés
      type: BottomNavigationBarType.fixed, // Assure que tous les éléments sont visibles
      elevation: 10, // Ombre pour détacher la barre du fond
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/accueil.png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
            color: currentIndex == 0 ? Colors.white : Colors.white70, // Ajuste la couleur selon l'état
          ),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/equitation.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            color: currentIndex == 1 ? Colors.white : Colors.white70,
          ),
          label: 'Mes Cours',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/image_utilisateur.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            color: currentIndex == 2 ? Colors.white : Colors.white70,
          ),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/se-deconnecter.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            color: currentIndex == 3 ? Colors.white : Colors.white70,
          ),
          label: 'Déconnexion',
        ),
      ],
    );
  }

  static void handleNavigation(BuildContext context, int index, String cavalierId) {
    switch (index) {
      case 0: // Accueil
        if (ModalRoute.of(context)?.settings.name != '/home') {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'cavalierId': cavalierId, 'coursId': ''},
          );
        }
        break;
      case 1: // Mes Cours
        Navigator.pushReplacementNamed(
          context,
          '/my_courses',
          arguments: {'cavalierId': cavalierId},
        );
        break;
      case 2: // Profil
        Navigator.pushReplacementNamed(
          context,
          '/profile',
          arguments: {'cavalierId': cavalierId},
        );
        break;
      case 3: // Déconnexion
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }
}