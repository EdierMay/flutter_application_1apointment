import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacidad")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Política de Privacidad\n\n"
          "Última actualización: 22 de octubre de 2025\n\n"
          "Esta aplicación recopila y utiliza información personal únicamente con el propósito "
          "de brindar una mejor experiencia a los usuarios. Al utilizar esta aplicación, aceptas "
          "los términos descritos en esta política.\n\n"
          "1. Información que recopilamos:\n"
          "- Datos personales proporcionados voluntariamente, como nombre, correo electrónico o edad.\n"
          "- Datos de uso, como funciones utilizadas, fecha y hora de acceso y errores reportados.\n\n"
          "2. Uso de la información:\n"
          "La información recopilada se emplea para:\n"
          "- Proporcionar, mantener y mejorar las funcionalidades de la aplicación.\n"
          "- Personalizar la experiencia del usuario.\n"
          "- Enviar notificaciones o recordatorios relacionados con el servicio.\n\n"
          "3. Protección de datos:\n"
          "Implementamos medidas de seguridad técnicas y organizativas para proteger tu información. "
          "Sin embargo, ningún sistema es completamente infalible, por lo que recomendamos mantener "
          "la confidencialidad de tus credenciales y proteger tu dispositivo.\n\n"
          "4. Compartición de datos:\n"
          "No compartimos, vendemos ni alquilamos información personal a terceros. Solo se puede compartir "
          "información si es requerido por ley o para cumplir con obligaciones legales.\n\n"
          "5. Derechos del usuario:\n"
          "Puedes solicitar el acceso, modificación o eliminación de tus datos personales escribiendo al "
          "correo electrónico del desarrollador o soporte técnico de la aplicación.\n\n"
          "6. Cambios en esta política:\n"
          "Podemos actualizar esta política periódicamente. Cualquier cambio será notificado dentro de la aplicación.\n\n"
          "7. Contacto:\n"
          "Si tienes preguntas o inquietudes sobre esta Política de Privacidad, puedes contactarnos en: "
          "soporte@tuapp.com\n\n"
          "Al continuar utilizando la aplicación, confirmas que has leído y comprendido esta Política de Privacidad.",
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}
