import 'package:flutter/material.dart';
import 'appointment_page.dart'; // porque desde aquí abres el agendado

class DoctorAgendaPage extends StatelessWidget {
  final String especialidad;
  final String doctorId;
  final String doctorNombre;

  const DoctorAgendaPage({
    super.key,
    required this.especialidad,
    required this.doctorId,
    required this.doctorNombre,
  });

  // Demo: slots “ocupados” quemados
  List<DateTime> _demoCitas() {
    final now = DateTime.now();
    return [
      DateTime(now.year, now.month, now.day, 9, 0),
      DateTime(now.year, now.month, now.day, 10, 30),
      DateTime(now.year, now.month, now.day + 1, 12, 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final citas = _demoCitas();

    return Scaffold(
      appBar: AppBar(
        title: Text("Agenda de $doctorNombre"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.local_hospital, size: 18),
                label: Text(especialidad),
              ),
              Chip(
                avatar: const Icon(Icons.badge, size: 18),
                label: Text("ID: $doctorId"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Próximas citas (demo):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (citas.isEmpty)
            const Text("No hay citas registradas.")
          else
            ...citas.map((dt) {
              final timeOfDay = TimeOfDay(
                hour: dt.hour,
                minute: dt.minute,
              ).format(context);
              final fecha = "${dt.day}/${dt.month}/${dt.year}";
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text("$fecha • $timeOfDay"),
                  subtitle: Text(doctorNombre),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            }),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentPage(
                    especialidad: especialidad,
                    doctorNombre: doctorNombre,
                    doctorId: doctorId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Agendar nueva cita"),
          ),
          const SizedBox(height: 24),
          const Text(
            "Nota: Conecta Firestore para mostrar citas reales y evitar choques de horario.",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
