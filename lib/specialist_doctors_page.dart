import 'package:flutter/material.dart';

class SpecialistDoctorsPage extends StatelessWidget {
  final String especialidad;

  const SpecialistDoctorsPage({super.key, required this.especialidad});

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

    return data[especialidad] ?? [];
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
                  ),
                );
              },
            ),
    );
  }
}
