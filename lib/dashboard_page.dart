import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  final String especialidad;
  final String doctorId;
  final String doctorNombre;

  const DashboardPage({
    super.key,
    required this.especialidad,
    required this.doctorId,
    required this.doctorNombre,
  });

  @override
  Widget build(BuildContext context) {
    // 👉 Todas las consultas se limitan al médico y especialidad seleccionados
    final citasRef = FirebaseFirestore.instance
        .collection('especialidades')
        .doc(especialidad)
        .collection('doctores')
        .doc(doctorId)
        .collection('citas');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard médico'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: citasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar las citas.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Indicador 1: total de citas
          final totalCitas = docs.length;

          // Indicador 2: citas pendientes
          final pendientes = docs
              .where(
                (d) =>
                    (d.data() as Map<String, dynamic>)['estado'] == 'pendiente',
              )
              .length;

          // Indicador 3: pacientes únicos
          final pacientesSet = <String>{};
          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final pid = data['pacienteId'] as String?;
            if (pid != null) pacientesSet.add(pid);
          }
          final totalPacientes = pacientesSet.length;

          // Últimas 5 citas
          final ultimas = List.from(docs);
          ultimas.sort((a, b) {
            final da =
                (a['fechaHora'] as Timestamp?)?.toDate() ?? DateTime(2000);
            final db =
                (b['fechaHora'] as Timestamp?)?.toDate() ?? DateTime(2000);
            return db.compareTo(da);
          });
          final ultimas5 = ultimas.take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Resumen de actividad',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$doctorNombre • $especialidad',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),

              _indicatorCard(
                icon: Icons.event_note,
                title: 'Total de citas',
                subtitle: 'Todas las citas de este médico',
                value: totalCitas.toString(),
              ),
              const SizedBox(height: 12),
              _indicatorCard(
                icon: Icons.schedule_rounded,
                title: 'Citas pendientes',
                subtitle: "Citas con estado 'pendiente'",
                value: pendientes.toString(),
              ),
              const SizedBox(height: 12),
              _indicatorCard(
                icon: Icons.groups_rounded,
                title: 'Pacientes únicos',
                subtitle: 'Pacientes diferentes atendidos',
                value: totalPacientes.toString(),
              ),

              const SizedBox(height: 24),
              const Text(
                'Últimas citas registradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              if (ultimas5.isEmpty)
                const Text(
                  'Aún no hay citas registradas para este médico.',
                  style: TextStyle(color: Colors.black54),
                )
              else
                ...ultimas5.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final ts = data['fechaHora'] as Timestamp?;
                  final dt = ts?.toDate().toLocal();
                  final fecha = dt != null
                      ? '${dt.day.toString().padLeft(2, '0')}/'
                            '${dt.month.toString().padLeft(2, '0')}/'
                            '${dt.year}'
                      : '--/--/----';
                  final hora = dt != null
                      ? TimeOfDay.fromDateTime(dt).format(context)
                      : '--:--';
                  final paciente =
                      (data['pacienteEmail'] as String?) ?? 'Paciente';
                  final motivo = (data['motivo'] as String?) ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.event_available),
                      title: Text('$fecha • $hora'),
                      subtitle: Text(
                        '$paciente\n$motivo',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: motivo.isNotEmpty,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _indicatorCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Icon(icon, color: Colors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
