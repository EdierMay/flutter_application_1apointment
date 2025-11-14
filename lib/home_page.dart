import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'tips_page.dart';
import 'specialists_and_appointments.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _userRole = 'Paciente'; // 'Paciente' o 'Médico'
  bool _loadingRole = true;

  // Selección del médico (para Dashboard y Mensajes del médico)
  String? _medEspecialidad;
  String? _medDoctorId;
  String? _medDoctorNombre;

  final List<String> especialistas = const [
    "Cardiología",
    "Pediatría",
    "Dermatología",
    "Urología",
    "Ginecología",
    "Ortopedía",
  ];

  // Info para cada especialidad (tarjetas expandibles)
  final Map<String, Map<String, dynamic>> _especialidadInfo = {
    "Cardiología": {
      "tagline": "Salud del corazón y vasos sanguíneos",
      "desc":
          "Prevención, diagnóstico y tratamiento de enfermedades cardiovasculares como hipertensión, arritmias y cardiopatías.",
      "focus": [
        "Hipertensión",
        "Arritmias",
        "Dolor torácico",
        "Colesterol alto",
      ],
      "icon": Icons.monitor_heart_rounded,
    },
    "Pediatría": {
      "tagline": "Atención médica integral para niños",
      "desc":
          "Control del crecimiento y desarrollo, vacunación y manejo de enfermedades pediátricas comunes.",
      "focus": ["Vacunas", "Resfriados", "Alergias", "Desarrollo"],
      "icon": Icons.child_care_rounded,
    },
    "Dermatología": {
      "tagline": "Cuidado de la piel, cabello y uñas",
      "desc":
          "Tratamientos para acné, dermatitis, alopecia y manchas. Procedimientos clínicos y estéticos.",
      "focus": ["Acné", "Dermatitis", "Manchas", "Alopecia"],
      "icon": Icons.spa_rounded,
    },
    "Urología": {
      "tagline": "Vías urinarias y aparato reproductor",
      "desc":
          "Diagnóstico y tratamiento de infecciones urinarias, cálculos renales y salud prostática.",
      "focus": ["ITU", "Cálculos", "Próstata", "Incontinencia"],
      "icon": Icons.water_drop_rounded,
    },
    "Ginecología": {
      "tagline": "Salud femenina integral",
      "desc":
          "Revisiones, salud reproductiva, planificación familiar y control prenatal.",
      "focus": ["Chequeos", "Ciclo menstrual", "Embarazo", "Papanicolau"],
      "icon": Icons.female_rounded,
    },
    "Ortopedía": {
      "tagline": "Huesos, articulaciones y movilidad",
      "desc":
          "Atención de lesiones, dolor articular y rehabilitación para mejorar la función física.",
      "focus": ["Lesiones", "Lumbalgia", "Rodilla", "Rehabilitación"],
      "icon": Icons.accessibility_new_rounded,
    },
  };

  late final AnimationController _anim;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    if (user == null) {
      setState(() => _loadingRole = false);
      return;
    }
    try {
      final doc = await _db.collection('users').doc(user!.uid).get();
      final data = doc.data();
      final role = (data?['rol'] as String?) ?? 'Paciente';

      setState(() {
        _userRole = role;
        _loadingRole = false;
      });

      if (role == 'Médico') {
        _initMedicoDefaults();
      }
    } catch (e) {
      setState(() => _loadingRole = false);
    }
  }

  void _initMedicoDefaults() {
    if (especialistas.isEmpty) return;
    final esp = especialistas.first;
    final docs = getDoctorsOf(esp);

    setState(() {
      _medEspecialidad = esp;
      if (docs.isNotEmpty) {
        _medDoctorId = docs.first['id'];
        _medDoctorNombre = docs.first['nombre'];
      } else {
        _medDoctorId = null;
        _medDoctorNombre = null;
      }
    });
  }

  // Ir al dashboard DEL médico seleccionado
  void _goToDashboardForMedico() {
    if (_medEspecialidad == null ||
        _medDoctorId == null ||
        _medDoctorNombre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la especialidad y el médico primero.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          especialidad: _medEspecialidad!,
          doctorId: _medDoctorId!,
          doctorNombre: _medDoctorNombre!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Color get _brand => const Color(0xFF0EA5A4);
  Color get _brandDark => const Color(0xFF0B7E7D);

  /// ---------- UI HOME ----------
  Widget _buildHomeContent() {
    final String nombreUsuario = user?.email?.split('@').first ?? "Paciente";
    final bool esMedico = _userRole == 'Médico';

    return RefreshIndicator(
      onRefresh: () async {
        await _reloadHome();
        await _loadUserRole();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tipo Hero
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_brand, _brandDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _brand.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeIn,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [],
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            esMedico
                                ? Icons.medical_information_rounded
                                : Icons.person,
                            color: _brandDark,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            esMedico ? "Bienvenido doctor(a)" : "Hola",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            nombreUsuario,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            esMedico
                                ? "Administra tus pacientes, citas y mensajes desde un solo lugar."
                                : "Cuida tu salud con citas rápidas y seguras.",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // CTA rápidos
                    Row(
                      children: [
                        Expanded(
                          child: _ctaCard(
                            icon: esMedico
                                ? Icons.bar_chart_rounded
                                : Icons.calendar_month_rounded,
                            label: esMedico ? "Ver dashboard" : "Agendar cita",
                            onTap: esMedico
                                ? _goToDashboardForMedico
                                : _openAgendarDesdeEspecialidad,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ctaCard(
                            icon: Icons.tips_and_updates_rounded,
                            label: "Consejos",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TipsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 SOLO MÉDICOS: configuración rápida + mini panel
            if (esMedico) ...[
              _buildMedicoSelectorCard(),
              const SizedBox(height: 12),
              _buildMedicoMiniPanel(),
            ],

            // 🔹 SOLO PACIENTES: sección de especialidades
            if (!esMedico) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Especialidades",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: especialistas.map((esp) {
                    final data = _especialidadInfo[esp]!;
                    return _specialtyExpandableCard(
                      title: esp,
                      tagline: data["tagline"] as String,
                      desc: data["desc"] as String,
                      focus: (data["focus"] as List<String>),
                      icon: (data["icon"] as IconData),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ---------- Card de selección para médicos ----------
  Widget _buildMedicoSelectorCard() {
    final docs = _medEspecialidad != null
        ? getDoctorsOf(_medEspecialidad!)
        : <Map<String, String>>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: const Color(0xFFF7F9FC),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.medical_services_rounded, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    "Configuración rápida del médico",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Selecciona tu especialidad y tu nombre para filtrar el Dashboard y los mensajes.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _medEspecialidad,
                decoration: const InputDecoration(
                  labelText: "Especialidad",
                  border: OutlineInputBorder(),
                ),
                items: especialistas
                    .map(
                      (esp) => DropdownMenuItem(value: esp, child: Text(esp)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final nuevosDocs = getDoctorsOf(value);
                  setState(() {
                    _medEspecialidad = value;
                    if (nuevosDocs.isNotEmpty) {
                      _medDoctorId = nuevosDocs.first['id'];
                      _medDoctorNombre = nuevosDocs.first['nombre'];
                    } else {
                      _medDoctorId = null;
                      _medDoctorNombre = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _medDoctorId,
                decoration: const InputDecoration(
                  labelText: "Médico",
                  border: OutlineInputBorder(),
                ),
                items: docs
                    .map(
                      (d) => DropdownMenuItem(
                        value: d['id'],
                        child: Text(d['nombre'] ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final docSel = docs.firstWhere(
                    (d) => d['id'] == value,
                    orElse: () => {},
                  );
                  setState(() {
                    _medDoctorId = value;
                    _medDoctorNombre = docSel['nombre'];
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _goToDashboardForMedico,
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text("Ir al Dashboard"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1; // pestaña Mensajes
                        });
                      },
                      icon: const Icon(Icons.message_rounded),
                      label: const Text("Ver mensajes"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- Mini panel bonito para el médico ----------
  Widget _buildMedicoMiniPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text(
            "Panel rápido del médico",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            "Accesos directos a lo que más usas en la consulta.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.event_available_rounded,
                  title: "Citas",
                  subtitle: "Revisa tu agenda\npor especialidad.",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.groups_rounded,
                  title: "Pacientes",
                  subtitle: "Visualiza a los\npacientes atendidos.",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "Mensajes",
                  subtitle: "Responde dudas\nde tus pacientes.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _brand.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _brand.withOpacity(0.1),
            child: Icon(icon, color: _brandDark, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- Flujo: agendar desde especialidad (PACIENTE) ----------
  Future<void> _openAgendarDesdeEspecialidad() async {
    final esp = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _RoundedSheet(
          title: "Elige una especialidad",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: especialistas.map((e) {
              return ListTile(
                leading: Icon(_iconFor(e), color: _brandDark),
                title: Text(e),
                onTap: () => Navigator.pop(ctx, e),
              );
            }).toList(),
          ),
        );
      },
    );

    if (esp == null) return;

    final docs = getDoctorsOf(esp);
    if (docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay médicos disponibles en $esp")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpecialistDoctorsPage(especialidad: esp),
        ),
      );
      return;
    }

    final first = docs.first;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorAgendaPage(
          especialidadInicial: esp,
          doctorIdInicial: first['id']!,
          doctorNombreInicial: first['nombre']!,
        ),
      ),
    );
  }

  /// ---------- Tarjeta CTA ----------
  Widget _ctaCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _brand.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _brandDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _brandDark),
          ],
        ),
      ),
    );
  }

  /// ---------- Tarjeta de especialidad expandible (PACIENTE) ----------
  Widget _specialtyExpandableCard({
    required String title,
    required String tagline,
    required String desc,
    required List<String> focus,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _brand.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: _brand.withOpacity(0.06),
            highlightColor: _brand.withOpacity(0.06),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: _brand.withOpacity(0.12),
              child: Icon(icon, color: _brandDark),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              tagline,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(desc, style: const TextStyle(height: 1.35)),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: focus.map((f) {
                    return Chip(
                      label: Text(f),
                      backgroundColor: _brand.withOpacity(0.08),
                      side: BorderSide(color: _brand.withOpacity(0.20)),
                      labelStyle: TextStyle(color: Colors.grey.shade800),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandDark,
                        side: BorderSide(color: _brand.withOpacity(0.35)),
                      ),
                      icon: const Icon(Icons.groups_rounded),
                      label: const Text("Ver médicos"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SpecialistDoctorsPage(especialidad: title),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text("Agendar"),
                      onPressed: () {
                        final docs = getDoctorsOf(title);
                        if (docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No hay médicos en $title")),
                          );
                          return;
                        }
                        final first = docs.first;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorAgendaPage(
                              especialidadInicial: title,
                              doctorIdInicial: first['id']!,
                              doctorNombreInicial: first['nombre']!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String esp) {
    switch (esp) {
      case "Cardiología":
        return Icons.monitor_heart_rounded;
      case "Pediatría":
        return Icons.child_care_rounded;
      case "Dermatología":
        return Icons.spa_rounded;
      case "Urología":
        return Icons.water_drop_rounded;
      case "Ginecología":
        return Icons.female_rounded;
      default:
        return Icons.accessibility_new_rounded;
    }
  }

  /// ---------- Chat ID determinístico ----------
  String _chatIdFor(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}_${list[1]}';
  }

  /// ---------- Body según tab ----------
  Widget _buildBody() {
    if (_loadingRole) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentIndex) {
      case 1:
        if (user == null) {
          return const Center(child: Text('Inicia sesión para ver mensajes'));
        }

        // Si es médico, usa su doctorId configurado
        if (_userRole == 'Médico') {
          if (_medDoctorId == null) {
            return const Center(
              child: Text(
                'Configura tu especialidad y médico en la pantalla de Inicio.',
              ),
            );
          }
          final chatId = _chatIdFor(user!.uid, _medDoctorId!);
          return MessagesPage(chatId: chatId, otherUserId: _medDoctorId);
        }

        // Si es paciente, por ahora un chat fijo con doctor123 (ejemplo)
        const doctorId = 'doctor123';
        final chatId = _chatIdFor(user!.uid, doctorId);
        return MessagesPage(chatId: chatId, otherUserId: doctorId);

      case 2:
        return const SettingsPage();

      default:
        return _buildHomeContent();
    }
  }

  void _onNavTap(int idx) => setState(() => _currentIndex = idx);

  @override
  Widget build(BuildContext context) {
    final bool esMedico = _userRole == 'Médico';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text("Inicio"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _brand,
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        indicatorColor: _brand.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              onPressed: esMedico
                  ? _goToDashboardForMedico
                  : _openAgendarDesdeEspecialidad,
              icon: Icon(esMedico ? Icons.bar_chart_rounded : Icons.add),
              label: Text(esMedico ? "Dashboard" : "Agendar"),
            )
          : null,
    );
  }

  /// ---------- Pull-to-refresh ----------
  Future<void> _reloadHome() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {});
  }
}

/// ---------- Bottom sheet con bordes redondeados ----------
class _RoundedSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _RoundedSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(child: child),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
