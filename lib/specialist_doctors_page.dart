import 'package:flutter/material.dart';
import 'appointment_page.dart'; // porque navega a agendar
import 'doctor_agenda_page.dart'; // porque muestra la agenda

class SpecialistDoctorsPage extends StatelessWidget {
  final String especialidad;

  const SpecialistDoctorsPage({super.key, required this.especialidad});

  // Pequeña utilidad para generar IDs tipo slug
  String _slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  // Simulación de médicos por especialidad
  List<Map<String, String>> getDoctors(String especialidad) {
    final Map<String, List<Map<String, String>>> data = {
      "Cardiología": [
        {
          "nombre": "Dr. Juan Pérez",
          "descripcion": "Especialista en enfermedades del corazón.",
          "imagen": "https://i.pravatar.cc/150?img=1",
        },
        {
          "nombre": "Dra. Ana Martínez",
          "descripcion": "Experta en hipertensión y arritmias.",
          "imagen": "https://i.pravatar.cc/150?img=12",
        },
      ],
      "Pediatría": [
        {
          "nombre": "Dr. Luis Torres",
          "descripcion": "Cuida la salud de los más pequeños.",
          "imagen": "https://i.pravatar.cc/150?img=8",
        },
      ],
      "Dermatología": [
        {
          "nombre": "Dra. Sofia Gómez",
          "descripcion": "Tratamientos para piel, cabello y uñas.",
          "imagen": "https://i.pravatar.cc/150?img=5",
        },
      ],
      "Urología": [
        {
          "nombre": "Dr. Carlos Ramírez",
          "descripcion": "Especialista en sistema urinario.",
          "imagen": "https://i.pravatar.cc/150?img=15",
        },
      ],
      "Ginecología": [
        {
          "nombre": "Dra. Laura Velázquez",
          "descripcion": "Salud femenina integral.",
          "imagen": "https://i.pravatar.cc/150?img=20",
        },
      ],
      "Ortopedía": [
        {
          "nombre": "Dr. Enrique Díaz",
          "descripcion": "Lesiones y fracturas óseas.",
          "imagen": "https://i.pravatar.cc/150?img=23",
        },
      ],
    };

    final list = data[especialidad] ?? [];
    // agrega un id slug por cada médico
    return list
        .map((m) => {...m, "id": _slugify(m["nombre"] ?? "medico")})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = getDoctors(especialidad);

    return Scaffold(
      appBar: AppBar(
        title: Text("Especialistas en $especialidad"),
        backgroundColor: Colors.teal,
      ),
      body: doctors.isEmpty
          ? const Center(child: Text("No hay médicos disponibles."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(doctor['imagen']!),
                      radius: 28,
                    ),
                    title: Text(doctor['nombre']!),
                    subtitle: Text(doctor['descripcion']!),
                    // 👇 Trailing combinado: botón para ver agenda + flecha
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.event_note),
                          tooltip: 'Ver agenda',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorAgendaPage(
                                  especialidad: especialidad,
                                  doctorId:
                                      doctor['id']!, // el slug que generamos
                                  doctorNombre: doctor['nombre']!,
                                ),
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    // 👇 onTap intacto: sigue abriendo AppointmentPage con el doctor elegido
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentPage(
                            especialidad: especialidad,
                            doctorNombre: doctor['nombre']!,
                            doctorId:
                                doctor['id']!, // <- clave para su propia agenda
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
