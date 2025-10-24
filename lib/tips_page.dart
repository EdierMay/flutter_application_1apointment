import 'dart:math';
import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final Random _random = Random();
  late String _tipActual;
  late Color _colorFondo;

  final List<String> _consejos = [
    "Mantén una buena hidratación durante el día.",
    "Duerme al menos 7 a 8 horas cada noche.",
    "Evita el estrés con respiraciones profundas.",
    "No te saltes tus comidas principales.",
    "Camina al menos 30 minutos diarios.",
    "Evita el exceso de cafeína y alcohol.",
    "Realiza chequeos médicos una vez al año.",
    "Lávate las manos frecuentemente.",
    "Usa protector solar todos los días.",
    "Mantén una buena postura al sentarte.",
    "Reduce el consumo de azúcar y ultraprocesados.",
    "Haz estiramientos si trabajas sentado.",
    "Come frutas y verduras variadas cada día.",
    "Evita fumar y ambientes con humo.",
    "No automediques los antibióticos.",
  ];

  @override
  void initState() {
    super.initState();
    _generarNuevoConsejo();
  }

  void _generarNuevoConsejo() {
    setState(() {
      _tipActual = _consejos[_random.nextInt(_consejos.length)];
      _colorFondo = Color.fromARGB(
        255,
        180 + _random.nextInt(75),
        200 + _random.nextInt(55),
        180 + _random.nextInt(75),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      appBar: AppBar(
        title: const Text("Consejos Médicos"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Nuevo consejo",
            onPressed: _generarNuevoConsejo,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.teal, size: 48),
                const SizedBox(height: 16),
                Text(
                  _tipActual,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _generarNuevoConsejo,
                  icon: const Icon(Icons.autorenew),
                  label: const Text("Nuevo consejo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
}
