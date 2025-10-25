// lib/specialists_and_appointments.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// =====================================
/// =  DATOS (simulados) DE ESPECIALIDAD =
/// =====================================
Map<String, List<Map<String, String>>> kEspecialidadesData = {
  "Cardiología": [
    {
      "nombre": "👨‍⚕️ Dr. Juan Pérez",
      "descripcion": "Especialista en enfermedades del corazón ❤️.",
      "imagen": "https://i.pravatar.cc/150?img=1",
    },
    {
      "nombre": "👩‍⚕️ Dra. Ana Martínez",
      "descripcion": "Experta en hipertensión y arritmias 💓.",
      "imagen": "https://i.pravatar.cc/150?img=12",
    },
  ],
  "Pediatría": [
    {
      "nombre": "👨‍⚕️ Dr. Luis Torres",
      "descripcion": "Cuida la salud de los más pequeños 👶.",
      "imagen": "https://i.pravatar.cc/150?img=8",
    },
    {
      "nombre": "👩‍⚕️ Dra. Fernanda Rivera",
      "descripcion": "Atiende niños con calidez y empatía 🧸.",
      "imagen": "https://i.pravatar.cc/150?img=13",
    },
  ],
  "Dermatología": [
    {
      "nombre": "👩‍⚕️ Dra. Sofía Gómez",
      "descripcion": "Tratamientos para piel, cabello y uñas 💅.",
      "imagen": "https://i.pravatar.cc/150?img=5",
    },
    {
      "nombre": "👨‍⚕️ Dr. Miguel Herrera",
      "descripcion": "Experto en acné, alergias y manchas 🌿.",
      "imagen": "https://i.pravatar.cc/150?img=28",
    },
  ],
  "Urología": [
    {
      "nombre": "👨‍⚕️ Dr. Carlos Ramírez",
      "descripcion": "Especialista en sistema urinario 💧.",
      "imagen": "https://i.pravatar.cc/150?img=15",
    },
    {
      "nombre": "👩‍⚕️ Dra. Paola Suárez",
      "descripcion": "Tratamiento integral de la salud renal ⚕️.",
      "imagen": "https://i.pravatar.cc/150?img=25",
    },
  ],
  "Ginecología": [
    {
      "nombre": "👩‍⚕️ Dra. Laura Velázquez",
      "descripcion": "Salud femenina integral 💗.",
      "imagen": "https://i.pravatar.cc/150?img=20",
    },
    {
      "nombre": "👩‍⚕️ Dra. Mariana Robles",
      "descripcion": "Especialista en salud reproductiva 🤰.",
      "imagen": "https://i.pravatar.cc/150?img=22",
    },
  ],
  "Ortopedía": [
    {
      "nombre": "👨‍⚕️ Dr. Enrique Díaz",
      "descripcion": "Lesiones, fracturas y rehabilitación 💪.",
      "imagen": "https://i.pravatar.cc/150?img=23",
    },
    {
      "nombre": "👩‍⚕️ Dra. Verónica Ruiz",
      "descripcion": "Cuida tu movilidad y bienestar físico 🦵.",
      "imagen": "https://i.pravatar.cc/150?img=16",
    },
  ],
};

String _slugify(String input) => input
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
    .replaceAll(RegExp(r'\s+'), '-')
    .replaceAll(RegExp(r'-+'), '-')
    .trim();

List<Map<String, String>> getDoctorsOf(String especialidad) {
  final list = kEspecialidadesData[especialidad] ?? [];
  return list
      .map((m) => {...m, "id": _slugify(m["nombre"] ?? "medico")})
      .toList();
}

/// =============================
/// =  SPECIALIST DOCTORS PAGE  =
/// =============================
class SpecialistDoctorsPage extends StatelessWidget {
  final String especialidad;

  const SpecialistDoctorsPage({super.key, required this.especialidad});

  @override
  Widget build(BuildContext context) {
    final doctors = getDoctorsOf(especialidad);

    return Scaffold(
      appBar: AppBar(
        title: Text("👩‍⚕️ Especialistas en $especialidad 👨‍⚕️"),
        backgroundColor: Colors.teal,
      ),
      body: doctors.isEmpty
          ? const Center(
              child: Text(
                "⚠️ No hay médicos disponibles en esta especialidad.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(doctor['imagen']!),
                      radius: 28,
                    ),
                    title: Text(
                      doctor['nombre']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      doctor['descripcion']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.event_note,
                            color: Colors.teal,
                          ),
                          tooltip: 'Ver agenda del médico',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorAgendaPage(
                                  especialidadInicial: especialidad,
                                  doctorIdInicial: doctor['id']!,
                                  doctorNombreInicial: doctor['nombre']!,
                                ),
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentPage(
                            especialidad: especialidad,
                            doctorNombre: doctor['nombre']!,
                            doctorId: doctor['id']!,
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

/// =======================
/// =   DOCTOR AGENDA     =
/// =======================
/// - Cambiar especialidad y médico.
/// - Leer citas en vivo.
/// - Editar / Eliminar (CRUD completo).
class DoctorAgendaPage extends StatefulWidget {
  final String especialidadInicial;
  final String doctorIdInicial;
  final String doctorNombreInicial;

  const DoctorAgendaPage({
    super.key,
    required this.especialidadInicial,
    required this.doctorIdInicial,
    required this.doctorNombreInicial,
  });

  @override
  State<DoctorAgendaPage> createState() => _DoctorAgendaPageState();
}

class _DoctorAgendaPageState extends State<DoctorAgendaPage> {
  late String _especialidadSel;
  String? _doctorIdSel;
  String? _doctorNombreSel;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _especialidadSel = widget.especialidadInicial;
    _doctorIdSel = widget.doctorIdInicial;
    _doctorNombreSel = widget.doctorNombreInicial;
  }

  // DELETE: elimina en doctor-path y en mirror del usuario
  Future<void> _deleteAppointment({
    required String especialidad,
    required String doctorId,
    required String appointmentId,
  }) async {
    try {
      final doctorDocRef = _db
          .collection('especialidades')
          .doc(especialidad)
          .collection('doctores')
          .doc(doctorId)
          .collection('citas')
          .doc(appointmentId);

      // Lee para conocer pacienteId y eliminar espejo
      final snap = await doctorDocRef.get();
      final data = snap.data() as Map<String, dynamic>?;
      final pacienteId = data?['pacienteId'] as String?;

      final batch = _db.batch();
      batch.delete(doctorDocRef);

      if (pacienteId != null && pacienteId.isNotEmpty) {
        final userRef = _db
            .collection('users')
            .doc(pacienteId)
            .collection('appointments')
            .doc(appointmentId);
        batch.delete(userRef);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error al eliminar cita: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctors = getDoctorsOf(_especialidadSel);

    final citasQuery = (_doctorIdSel == null)
        ? null
        : _db
              .collection('especialidades')
              .doc(_especialidadSel)
              .collection('doctores')
              .doc(_doctorIdSel!)
              .collection('citas')
              .orderBy('fechaHora'); // ya filtramos en UI

    return Scaffold(
      appBar: AppBar(title: const Text("Agenda"), backgroundColor: Colors.teal),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selector de especialidad
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _especialidadSel,
                  decoration: const InputDecoration(
                    labelText: "Especialidad",
                    border: OutlineInputBorder(),
                  ),
                  items: kEspecialidadesData.keys
                      .map(
                        (esp) => DropdownMenuItem(value: esp, child: Text(esp)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final nuevosDocs = getDoctorsOf(value);
                    setState(() {
                      _especialidadSel = value;
                      if (nuevosDocs.isNotEmpty) {
                        _doctorIdSel = nuevosDocs.first['id'];
                        _doctorNombreSel = nuevosDocs.first['nombre'];
                      } else {
                        _doctorIdSel = null;
                        _doctorNombreSel = null;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Médicos de la especialidad seleccionada
          const Text(
            "Médicos por especialidad:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          if (doctors.isEmpty)
            const Text("No hay médicos para esta especialidad.")
          else
            ...doctors.map((doc) {
              final isSelected = doc['id'] == _doctorIdSel;
              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.teal : Colors.grey.shade300,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(doc['imagen']!),
                    radius: 22,
                  ),
                  title: Text(doc['nombre']!),
                  subtitle: Text(doc['descripcion']!),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.teal)
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: () {
                    setState(() {
                      _doctorIdSel = doc['id'];
                      _doctorNombreSel = doc['nombre'];
                    });
                  },
                ),
              );
            }),

          const SizedBox(height: 16),

          // Agenda del médico seleccionado
          if (_doctorIdSel == null)
            const Text("Selecciona un médico para ver su agenda.")
          else ...[
            Row(
              children: [
                const Icon(Icons.badge, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Agenda de ${_doctorNombreSel ?? 'Médico'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (citasQuery == null)
              const SizedBox.shrink()
            else
              StreamBuilder<QuerySnapshot>(
                stream: citasQuery.snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Text(
                      "No se pudieron cargar las citas.",
                      style: TextStyle(color: Colors.redAccent),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.hourglass_empty),
                        title: const Text("Sin citas"),
                        subtitle: Text(
                          "No hay citas para ${_doctorNombreSel ?? 'este médico'}.",
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final ts = data['fechaHora'] as Timestamp?;
                      final dt = ts?.toDate().toLocal();
                      final hora = dt != null
                          ? TimeOfDay.fromDateTime(dt).format(context)
                          : '--:--';
                      final fecha = dt != null
                          ? "${dt.day}/${dt.month}/${dt.year}"
                          : '--/--/----';
                      final paciente =
                          (data['pacienteEmail'] as String?) ?? 'Paciente';

                      return Dismissible(
                        key: ValueKey(d.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          final ok =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Cancelar cita"),
                                  content: const Text(
                                    "¿Seguro que deseas eliminar esta cita? Esta acción no se puede deshacer.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("No"),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Sí, eliminar"),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (ok) {
                            try {
                              await _deleteAppointment(
                                especialidad: _especialidadSel,
                                doctorId: _doctorIdSel!,
                                appointmentId: d.id,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Cita eliminada"),
                                  ),
                                );
                              }
                              return true;
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "No se pudo eliminar. Intenta de nuevo.",
                                    ),
                                  ),
                                );
                              }
                              return false;
                            }
                          }
                          return false;
                        },
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.event_available),
                            title: Text("$fecha • $hora"),
                            subtitle: Text(paciente),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar cita',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AppointmentPage(
                                          especialidad: _especialidadSel,
                                          doctorNombre: _doctorNombreSel,
                                          doctorId: _doctorIdSel,
                                          appointmentId: d.id, // <- EDIT
                                          initialData:
                                              data, // <- para precargar
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Eliminar cita',
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    final ok =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Cancelar cita"),
                                            content: const Text(
                                              "¿Seguro que deseas eliminar esta cita?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text("No"),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text(
                                                  "Sí, eliminar",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                    if (!ok) return;
                                    try {
                                      await _deleteAppointment(
                                        especialidad: _especialidadSel,
                                        doctorId: _doctorIdSel!,
                                        appointmentId: d.id,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Cita eliminada"),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "No se pudo eliminar. Intenta de nuevo.",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _doctorIdSel == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentPage(
                            especialidad: _especialidadSel,
                            doctorNombre: _doctorNombreSel,
                            doctorId: _doctorIdSel,
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.add),
              label: const Text("Agendar nueva cita"),
            ),
          ],

          const SizedBox(height: 24),
          const Text(
            "Tip: Cambia la especialidad y elige otro médico para ver su agenda.",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// =  APPOINTMENT PAGE =
/// =====================
/// CREATE + UPDATE: si viene appointmentId, se edita; si no, se crea.
class AppointmentPage extends StatefulWidget {
  final String? especialidad;
  final String? doctorNombre;
  final String? doctorId;

  // NUEVO: edición
  final String? appointmentId; // null = crear, no null = editar
  final Map<String, dynamic>? initialData; // para precargar campos

  const AppointmentPage({
    super.key,
    this.especialidad,
    this.doctorNombre,
    this.doctorId,
    this.appointmentId,
    this.initialData,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final motivoController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool get isEditing => widget.appointmentId != null;

  @override
  void initState() {
    super.initState();
    // Precargar datos si estamos editando
    final data = widget.initialData;
    if (data != null) {
      motivoController.text = (data['motivo'] as String?) ?? '';
      final ts = data['fechaHora'] as Timestamp?;
      final dt = ts?.toDate().toLocal();
      if (dt != null) {
        selectedDate = DateTime(dt.year, dt.month, dt.day);
        selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

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

    try {
      Query q = _db
          .collection('especialidades')
          .doc(especialidad)
          .collection('doctores')
          .doc(doctorId)
          .collection('citas')
          .where(
            'fechaHora',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioUtc),
          )
          .where('fechaHora', isLessThanOrEqualTo: Timestamp.fromDate(finUtc));

      // Al editar, ignora la misma cita
      if (isEditing) {
        q = q.where(FieldPath.documentId, isNotEqualTo: widget.appointmentId);
      }

      final snap = await q.limit(1).get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('hasTimeConflict error: $e');
      return false;
    }
  }

  Future<void> _saveAppointment() async {
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Debes iniciar sesión.")));
      return;
    }

    if (selectedDate == null ||
        selectedTime == null ||
        motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    if (widget.especialidad == null ||
        widget.doctorId == null ||
        widget.doctorNombre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falta información del médico/especialidad."),
        ),
      );
      return;
    }

    final localDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final hayConflicto = await hasTimeConflict(
      especialidad: widget.especialidad!,
      doctorId: widget.doctorId!,
      fechaHoraLocal: localDateTime,
    );

    if (hayConflicto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ese horario ya está ocupado. Elige otro."),
        ),
      );
      return;
    }

    final fechaUtc = localDateTime.toUtc();

    final baseData = {
      'pacienteId': user!.uid,
      'pacienteEmail': user!.email,
      'especialidad': widget.especialidad,
      'doctorId': widget.doctorId,
      'doctorNombre': widget.doctorNombre,
      'motivo': motivoController.text.trim(),
      'fechaHora': Timestamp.fromDate(fechaUtc),
      'timezoneClient': DateTime.now().timeZoneName,
      'estado': 'pendiente',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final batch = _db.batch();

      DocumentReference<Map<String, dynamic>> doctorCitaRef;
      DocumentReference<Map<String, dynamic>> userCitaRef;

      if (isEditing) {
        // UPDATE (mantiene el mismo ID en ambos lados)
        doctorCitaRef = _db
            .collection('especialidades')
            .doc(widget.especialidad!)
            .collection('doctores')
            .doc(widget.doctorId!)
            .collection('citas')
            .doc(widget.appointmentId!);

        userCitaRef = _db
            .collection('users')
            .doc(user!.uid)
            .collection('appointments')
            .doc(widget.appointmentId!);

        batch.update(doctorCitaRef, baseData);
        batch.update(userCitaRef, baseData);
      } else {
        // CREATE
        doctorCitaRef = _db
            .collection('especialidades')
            .doc(widget.especialidad!)
            .collection('doctores')
            .doc(widget.doctorId!)
            .collection('citas')
            .doc();

        userCitaRef = _db
            .collection('users')
            .doc(user!.uid)
            .collection('appointments')
            .doc(doctorCitaRef.id);

        batch.set(doctorCitaRef, {
          ...baseData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.set(userCitaRef, {
          ...baseData,
          'createdAt': FieldValue.serverTimestamp(),
          'pathDoctor': doctorCitaRef.path,
        });
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal,
          content: Text(
            "${isEditing ? 'Cita actualizada' : 'Cita agendada'} con ${widget.doctorNombre} el "
            "${localDateTime.day}/${localDateTime.month}/${localDateTime.year} "
            "${selectedTime!.format(context)}",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error guardando cita: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo guardar la cita. Intenta de nuevo."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDoctor = (widget.doctorNombre != null && widget.doctorId != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Cita" : "Agendar Cita"),
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
              icon: Icon(isEditing ? Icons.check : Icons.save),
              label: Text(isEditing ? "Guardar cambios" : "Guardar cita"),
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
