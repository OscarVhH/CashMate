import 'package:cashmateapp/pages/add_name.dart';
import 'package:cashmateapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personas del departamento"),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/');
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: FutureBuilder(
        future: getPeople(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(
              child: Text('No hay datos disponibles.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final person = snapshot.data?[index];

                return Dismissible(
                  key: Key(person['id']),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                              '¿Estás seguro de que deseas eliminar ${person['nombre']} ${person['apellido']}?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                deletePersona('people', person['id']);
                                setState(() {
                                  snapshot.data?.removeAt(index);
                                  Navigator.of(context).pop(false);
                                });
                              },
                              child: const Text('Eliminar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8), // Espaciado interno
                    leading: CircleAvatar(
                      // Icono o imagen a la izquierda
                      backgroundColor:
                          Colors.cyan, // Color de fondo del círculo
                      child: Text(
                        // Iniciales del nombre y apellido
                        '${person['nombre'][0]}${person['apellido'][0]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      // Nombre y apellido
                      '${person['nombre']} ${person['apellido']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const AddNamePage(),
              ),
            );
          }),
    );
  }
}
