import 'package:cashmateapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({Key? key});

  @override
  State<AddNamePage> createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController lastNameController = TextEditingController(text: "");

  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Persona'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Nombre',
              ),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                hintText: 'Apellido',
              ),
            ),
            const SizedBox(height: 20), // Espacio entre campos
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validar que los campos no estén vacíos
                if (nameController.text.isEmpty ||
                    lastNameController.text.isEmpty) {
                  setState(() {
                    errorMessage = "Por favor, completa ambos campos.";
                  });
                } else {
                  // Si los campos no están vacíos, guardar la información
                  await addPeople(nameController.text, lastNameController.text)
                      .then((_) {
                    Navigator.of(context).pushNamed('/personas');
                  });
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
