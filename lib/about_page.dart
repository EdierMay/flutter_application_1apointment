import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sobre nosotros")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "DoctorAppointmentApp v1.0\nDesarrollada por [Tu Nombre].\n\nUna aplicación para agendar citas médicas y ofrecer consejos médicos básicos.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
