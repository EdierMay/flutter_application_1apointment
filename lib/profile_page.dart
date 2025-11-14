import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController lugarController = TextEditingController();
  final TextEditingController padecimientosController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loading = true;
  bool _saving = false;
  DateTime? _updatedAt;

  // Rol
  String _selectedRole = 'Paciente';
  final List<String> _roles = const ['Paciente', 'Médico'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await _db.collection('users').doc(user!.uid).get();
      final data = doc.data();

      if (data != null) {
        nombreController.text = (data['nombre'] as String?) ?? '';
        edadController.text = (data['edad']?.toString()) ?? '';
        lugarController.text = (data['lugarNacimiento'] as String?) ?? '';
        padecimientosController.text = (data['padecimientos'] as String?) ?? '';
        _selectedRole = (data['rol'] as String?) ?? 'Paciente';
        final ts = data['updatedAt'];
        if (ts is Timestamp) _updatedAt = ts.toDate();
      } else {
        nombreController.text = '';
        edadController.text = '';
        lugarController.text = '';
        padecimientosController.text = '';
        _selectedRole = 'Paciente';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cargar el perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar tu perfil')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      int? edadInt;
      if (edadController.text.trim().isNotEmpty) {
        edadInt = int.tryParse(edadController.text.trim());
      }

      final data = {
        'uid': user!.uid,
        'email': user!.email,
        'nombre': nombreController.text.trim(),
        'edad': edadInt,
        'lugarNacimiento': lugarController.text.trim(),
        'padecimientos': padecimientosController.text.trim(),
        'rol': _selectedRole, // guardamos rol
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db
          .collection('users')
          .doc(user!.uid)
          .set(data, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil guardado en la nube."),
          backgroundColor: Colors.teal,
        ),
      );

      final fresh = await _db.collection('users').doc(user!.uid).get();
      final ts = fresh.data()?['updatedAt'];
      if (ts is Timestamp) {
        setState(() => _updatedAt = ts.toDate());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    lugarController.dispose();
    padecimientosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'Usuario desconocido';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.teal.shade100,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_updatedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Actualizado: ${_fmtFecha(_updatedAt!)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Dropdown de Rol
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: _inputDecoration(
                          "Rol en la app",
                          Icons.badge_outlined,
                        ),
                        items: _roles
                            .map(
                              (rol) => DropdownMenuItem<String>(
                                value: rol,
                                child: Text(rol),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nombreController,
                        decoration: _inputDecoration(
                          "Nombre completo",
                          Icons.person_outline,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Campo requerido"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: edadController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          "Edad",
                          Icons.cake_outlined,
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return "Campo requerido";
                          final n = int.tryParse(v);
                          if (n == null || n <= 0 || n > 120) {
                            return "Edad no válida";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: lugarController,
                        decoration: _inputDecoration(
                          "Lugar de nacimiento",
                          Icons.location_on_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Campo requerido"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: padecimientosController,
                        decoration: _inputDecoration(
                          "Padecimientos",
                          Icons.medical_services_outlined,
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _guardarPerfil,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _saving ? "Guardando..." : "Guardar cambios",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            disabledBackgroundColor: Colors.teal.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _fmtFecha(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return "$dd/$mm/$yyyy $hh:$min";
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
