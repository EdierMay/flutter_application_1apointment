import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// NO importes specialist_doctors_page.dart ni doctor_agenda_page.dart aquí
// import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Descomenta si ya usas Firestore

class AppointmentPage extends StatefulWidget {
  final String? especialidad;
  final String? doctorNombre;
  final String? doctorId; // <- clave estable por médico

  const AppointmentPage({
    super.key,
    this.especialidad,
    this.doctorNombre,
    this.doctorId,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final motivoController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  /// 🔎 Nueva función: valida si ya hay una cita en el mismo rango de tiempo
  Future<bool> hasTimeConflict({
    required String especialidad,
    required String doctorId,
    required DateTime fechaHoraLocal,
    Duration ventana = const Duration(minutes: 30),
  }) async {
    if (especialidad.isEmpty || doctorId.isEmpty) return false;

    final fechaUtc = fechaHoraLocal.toUtc();
    final inicioUtc = fechaUtc.subtract(ventana);
    final finUtc = fechaUtc.add(ventana);

    // ------------------- FIRESTORE -------------------
    // Descomenta el import y este bloque para activarlo
    /*
    try {
      final snap = await FirebaseFirestore.instance
          .collection('especialidades')
          .doc(especialidad)
          .collection('doctores')
          .doc(doctorId)
          .collection('citas')
          .where('fechaHora', isGreaterThanOrEqualTo: inicioUtc)
          .where('fechaHora', isLessThanOrEqualTo: finUtc)
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('hasTimeConflict error: $e');
      return false;
    }
    */

    // ------------------- SIN FIRESTORE -------------------
    return false;
  }

  Future<void> _saveAppointment() async {
    if (user == null) return;

    if (selectedDate == null ||
        selectedTime == null ||
        motivoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // DEMO (sin Firestore):
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Cita agendada (demo) con ${widget.doctorNombre ?? 'Médico'}"
          " el ${dateTime.day}/${dateTime.month}/${dateTime.year} ${selectedTime!.format(context)}",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasDoctor = (widget.doctorNombre != null && widget.doctorId != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agendar Cita"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.especialidad != null || hasDoctor) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.especialidad != null)
                    Chip(
                      avatar: const Icon(Icons.local_hospital, size: 18),
                      label: Text(widget.especialidad!),
                    ),
                  if (hasDoctor)
                    Chip(
                      avatar: const Icon(Icons.person, size: 18),
                      label: Text(widget.doctorNombre!),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                selectedDate == null
                    ? "Selecciona fecha"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              onTap: _pickDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                selectedTime == null
                    ? "Selecciona hora"
                    : selectedTime!.format(context),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(labelText: "Motivo de la cita"),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveAppointment,
              icon: const Icon(Icons.save),
              label: const Text("Guardar cita"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
