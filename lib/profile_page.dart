import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarDatosSimulados();
  }

  void _cargarDatosSimulados() {
    // Aquí puedes poner valores temporales si gustas
    nombreController.text = "Juan Pérez";
    edadController.text = "25";
    lugarController.text = "Guadalajara";
    padecimientosController.text = "Alergia estacional";
  }

  void _guardarPerfil() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil guardado localmente."),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade100,
                  child: const Icon(Icons.person, size: 60, color: Colors.teal),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.email ?? 'Usuario desconocido',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nombreController,
                  decoration: _inputDecoration("Nombre completo", Icons.person_outline),
                  validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: edadController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Edad", Icons.cake_outlined),
                  validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lugarController,
                  decoration: _inputDecoration("Lugar de nacimiento", Icons.location_on_outlined),
                  validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: padecimientosController,
                  decoration: _inputDecoration("Padecimientos", Icons.medical_services_outlined),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _guardarPerfil,
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar cambios"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
