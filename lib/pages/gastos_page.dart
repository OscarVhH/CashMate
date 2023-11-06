import 'package:flutter/material.dart';

class ListaGastos extends StatefulWidget {
  const ListaGastos({super.key});

  @override
  State<ListaGastos> createState() => _ListaGastosState();
}

class _ListaGastosState extends State<ListaGastos> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Puedes personalizar este Container según tus necesidades.
      color: Colors.blue,
      child: const Center(
        child: Text(
          'Este es un widget de otra clase',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
