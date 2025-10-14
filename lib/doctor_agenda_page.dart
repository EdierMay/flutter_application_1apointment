import 'package:flutter/material.dart';
// Descomenta estas líneas si ya tienes Firestore
// import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAgendaPage extends StatelessWidget {
  final String especialidad;
  final String doctorId;
  final String doctorNombre;

  // Cambia a true si aún no tienes Firestore y quieres ver datos de ejemplo
  static const bool kDemoMode = false;

  const DoctorAgendaPage({
    super.key,
    required this.especialidad,
    required this.doctorId,
    required this.doctorNombre,
  });

  String _fmtFechaHora(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$d/$m/$y $hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    final title = "Agenda - $doctorNombre";

    // ----------- DEMO (sin Firestore) -----------
    if (kDemoMode) {
      final demo =
          [
            {
              'pacienteEmail': 'paciente1@mail.com',
              'motivo': 'Control de hipertensión',
              'estado': 'pendiente',
              'fechaHora': DateTime.now().add(const Duration(hours: 2)),
              'id': 'demo1',
            },
            {
              'pacienteEmail': 'paciente2@mail.com',
              'motivo': 'Dolor torácico',
              'estado': 'confirmada',
              'fechaHora': DateTime.now().add(const Duration(days: 1)),
              'id': 'demo2',
            },
          ]..sort(
            (a, b) => (a['fechaHora'] as DateTime).compareTo(
              b['fechaHora'] as DateTime,
            ),
          );

      return Scaffold(
        appBar: AppBar(title: Text(title), backgroundColor: Colors.teal),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) {
            final item = demo[i];
            final fechaHora = item['fechaHora'] as DateTime;
            return Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.event_available, color: Colors.teal),
                title: Text(_fmtFechaHora(fechaHora)),
                subtitle: Text(
                  "${item['pacienteEmail']}\nMotivo: ${item['motivo']}",
                ),
                isThreeLine: true,
                trailing: Chip(
                  label: Text((item['estado'] as String).toUpperCase()),
                  backgroundColor: Colors.teal.withOpacity(0.1),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: demo.length,
        ),
      );
    }

    // ----------- FIRESTORE (agenda real por médico) -----------
    // Ruta: especialidades/{especialidad}/doctores/{doctorId}/citas
    // Ordenamos por fechaHora ASC y mostramos próximas primero.
    // Nota: descomenta imports y este bloque si ya usas cloud_firestore.
    /*
    final query = FirebaseFirestore.instance
        .collection('especialidades')
        .doc(especialidad)
        .collection('doctores')
        .doc(doctorId)
        .collection('citas')
        .orderBy('fechaHora');

    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.teal),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          // Filtra pasadas y deja futuras/actuales
          final citas = docs.where((d) {
            final ts = d['fechaHora'];
            DateTime fecha;
            if (ts is Timestamp) {
              fecha = ts.toDate();
            } else if (ts is DateTime) {
              fecha = ts;
            } else {
              return false;
            }
            return !fecha.isBefore(now);
          }).toList()
            ..sort((a, b) {
              final aDt = (a['fechaHora'] as Timestamp).toDate();
              final bDt = (b['fechaHora'] as Timestamp).toDate();
              return aDt.compareTo(bDt);
            });

          if (citas.isEmpty) {
            return const Center(
              child: Text('Sin citas próximas para este médico.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: citas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final c = citas[i];
              final fechaHora = (c['fechaHora'] as Timestamp).toDate();
              final motivo = (c.data() as Map<String, dynamic>)['motivo'] ?? '';
              final estado = (c.data() as Map<String, dynamic>)['estado'] ?? 'pendiente';
              final email = (c.data() as Map<String, dynamic>)['pacienteEmail'] ?? '';
              final docId = c.id;

              return Card(
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.event_available, color: Colors.teal),
                  title: Text(_fmtFechaHora(fechaHora)),
                  subtitle: Text("$email\nMotivo: $motivo"),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: Chip(
                      label: Text(estado.toString().toUpperCase()),
                      backgroundColor: Colors.teal.withOpacity(0.1),
                    ),
                    onSelected: (value) async {
                      if (value == 'confirmar' || value == 'cancelar' || value == 'pendiente') {
                        await c.reference.update({'estado': value});
                      } else if (value == 'eliminar') {
                        await c.reference.delete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'confirmar',
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline),
                          title: Text('Confirmar'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pendiente',
                        child: ListTile(
                          leading: Icon(Icons.hourglass_top),
                          title: Text('Marcar como pendiente'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancelar',
                        child: ListTile(
                          leading: Icon(Icons.cancel_outlined),
                          title: Text('Cancelar'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
    */

    // Si aún no descomentas Firestore, muestra aviso:
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.teal),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Activa Firestore (descomenta imports y el bloque de StreamBuilder) '
            'o cambia kDemoMode=true para usar datos de ejemplo.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
