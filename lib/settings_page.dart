import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'privacy_page.dart';
import 'about_page.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Volver al login y limpiar historial
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Perfil"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text("Privacidad"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("Sobre nosotros"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Cerrar sesión"),
          onTap: () {
            _logout(context);
          },
        ),
      ],
    );
  }
}
