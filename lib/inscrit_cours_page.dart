import 'package:flutter/material.dart';

class InscritCoursPage extends StatelessWidget {
  final List<dynamic> cours;
  final String cavalierId;
  final String coursId;

  const InscritCoursPage({
    super.key,
    required this.cours,
    required this.cavalierId,
    required this.coursId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cours Inscrits'),
      ),
      body: ListView.builder(
        itemCount: cours.length,
        itemBuilder: (context, index) {
          final coursItem = cours[index];
          return ListTile(
            title: Text(coursItem['Libcours']),
            subtitle: Text('${coursItem['jour']} - ${coursItem['HD']} à ${coursItem['HF']}'),
          );
        },
      ),
    );
  }
}
