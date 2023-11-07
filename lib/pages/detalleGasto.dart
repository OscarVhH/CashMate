import 'package:cashmateapp/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetallesGasto extends StatelessWidget {
  final String gastoId;

  const DetallesGasto(this.gastoId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Gasto'),
      ),
      body: FutureBuilder(
        future: getGastoById(gastoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No hay datos disponibles.'),
            );
          } else {
            Map<String, dynamic>? gasto = snapshot.data;

            // Obtén los datos del gasto.
            String titulo = gasto?['titulo'];
            double montoTotal = gasto?['montoTotal'];
            Timestamp timestamp = gasto?['fecha'];
            DateTime fecha = timestamp.toDate();
            Map<String, dynamic> datosPersonas = gasto?['datosPersonas'];

            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Título: $titulo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Monto Total: $montoTotal'),
                    Text('Fecha: $fecha'),
                    const Text('Datos de las Personas:'),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: datosPersonas.length,
                      itemBuilder: (context, index) {
                        final nombre = datosPersonas.keys.toList()[index];
                        final monto = datosPersonas[nombre];
                        return ListTile(
                          title: Text('$nombre: $monto'),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            deleteGasto(gastoId);
                            Navigator.of(context).pushNamed('/');
                          },
                          child: const Text("Eliminar"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
