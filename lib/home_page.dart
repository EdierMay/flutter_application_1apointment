import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'tips_page.dart';

// 👇 Usar SOLO el archivo unificado
import 'specialists_and_appointments.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final List<String> especialistas = const [
    "Cardiología",
    "Pediatría",
    "Dermatología",
    "Urología",
    "Ginecología",
    "Ortopedía",
  ];

  // Info para cada especialidad (se muestra dentro de la tarjeta expandible)
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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tipo "Hero" con gradiente
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
                  // Saludo + avatar
                  Row(
                    children: [
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              // El texto del saludo lo rellenamos abajo
                            ],
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  // Saludo (separado para poder insertar la variable)
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hola, $nombreUsuario",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Cuida tu salud con citas rápidas y seguras",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // CTA’s rápidos
                  Row(
                    children: [
                      Expanded(
                        child: _ctaCard(
                          icon: Icons.calendar_month_rounded,
                          label: "Agendar cita",
                          onTap: _openAgendarDesdeEspecialidad,
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

          // ---------- Especialidades (tarjetas expandibles) ----------
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
      ),
    );
  }

  /// ---------- Flujo: agendar desde especialidad ----------
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

    // Toma el primer doctor de esa especialidad (del archivo unificado)
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

    final first = docs.first; // { id, nombre, ... }

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

  /// ---------- Tarjeta de especialidad expandible ----------
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
              // Descripción
              Align(
                alignment: Alignment.centerLeft,
                child: Text(desc, style: const TextStyle(height: 1.35)),
              ),
              const SizedBox(height: 10),

              // Enfoques (chips)
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

              // CTAs
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
                        final first = docs.first; // { id, nombre, ... }
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
    switch (_currentIndex) {
      case 1:
        if (user == null) {
          return const Center(child: Text('Inicia sesión para ver mensajes'));
        }
        const doctorId = 'doctor123'; // cambia por tu doctorId real
        final chatId = _chatIdFor(user!.uid, doctorId);
        // Si tu MessagesPage no admite otherUserId, quita el argumento.
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        onPressed: _openAgendarDesdeEspecialidad,
        icon: const Icon(Icons.add),
        label: const Text("Agendar"),
      ),
    );
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
