import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacidad")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Aquí puedes escribir información sobre la política de privacidad de la aplicación.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
