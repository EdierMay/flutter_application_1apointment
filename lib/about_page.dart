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
          "DoctorAppointmentApp v1.0\nDesarrollada por Edier May.\n\n"
          "DoctorAppointmentApp es una aplicación creada para facilitar la gestión de citas médicas entre pacientes y profesionales de la salud. "
          "Nuestro objetivo es ofrecer una herramienta sencilla, rápida y confiable que permita a los usuarios agendar, consultar y administrar sus citas "
          "desde cualquier lugar.\n\n"
          "Además de la función principal de agendamiento, la aplicación brinda acceso a información médica general, consejos de bienestar y recordatorios "
          "personalizados, ayudando a promover una atención médica más oportuna y organizada.\n\n"
          "Nuestra misión es mejorar la comunicación entre pacientes y médicos, reducir los tiempos de espera y optimizar la experiencia de atención "
          "en el sector salud mediante tecnología accesible y segura.\n\n"
          "Para más información o soporte, puedes contactarnos a través del correo: soporte@doctorappointmentapp.com",
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}
