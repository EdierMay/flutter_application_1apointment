import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final consejos = [
      "Mantén una buena hidratación.",
      "Haz pausas si estás sentado mucho tiempo.",
      "Evita el estrés mediante ejercicios de respiración.",
      "Aplica compresas calientes o frías según el dolor.",
      "Consulta con un especialista si el dolor persiste más de 48 horas.",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Consejos Médicos")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: consejos.length,
        itemBuilder: (context, i) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(consejos[i], style: const TextStyle(fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
