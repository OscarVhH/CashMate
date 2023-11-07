import 'package:cashmateapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddGastoPage extends StatefulWidget {
  const AddGastoPage({super.key});

  @override
  State<AddGastoPage> createState() => _AddGastoPageState();
}

class _AddGastoPageState extends State<AddGastoPage> {
  DateTime selectedDate = DateTime.now(); // Almacena la fecha seleccionada
  TextEditingController amountController = TextEditingController(
      text: '100'); // Controlador para el campo de cantidad
  TextEditingController titleController = TextEditingController();
  // Función para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Gasto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Concepto"),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Fecha de pago'),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 10),
                      Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Espacio entre campos
            TextField(
              textAlign: TextAlign.right,
              controller: amountController,
              decoration: const InputDecoration(
                hintText: "Cantidad",
                prefixText: '\$ ', // Agrega el signo de pesos como prefijo
              ),
              keyboardType: TextInputType.number, // Teclado numérico
              onChanged: (value) {
                // Actualiza el valor del controlador cuando cambia el campo de cantidad.
                setState(() {});
              },
            ),

            Expanded(
                child: ListarPersonas(
              initialAmount: double.parse(
                  amountController.text.isEmpty ? '0' : amountController.text),
              selectedDate: selectedDate,
              title: titleController.text,
            )),
          ],
        ),
      ),
    );
  }
}

class ListarPersonas extends StatefulWidget {
  final double initialAmount;
  final DateTime selectedDate;
  final String title;

  const ListarPersonas(
      {Key? key,
      required this.initialAmount,
      required this.selectedDate,
      required this.title})
      : super(key: key);

  @override
  State<ListarPersonas> createState() => _ListarPersonasState();
}

class _ListarPersonasState extends State<ListarPersonas> {
  List<TextEditingController> amountControllers = [];

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de selección y controladores
    getPeople().then((peopleList) {
      setState(() {
        amountControllers = List.generate(
          peopleList.length,
          (index) => TextEditingController(text: '0'),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
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
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          final person = snapshot.data?[index];
                          final amountController = amountControllers[index];
                          return ListBody(
                            children: [
                              ListTile(
                                title: Text(
                                  '${person['nombre']} ${person['apellido']}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                trailing: SizedBox(
                                  width: 100,
                                  child: TextField(
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      prefixText: '\$',
                                    ),
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              String title = widget.title;
                              double totalAmount = widget.initialAmount;
                              DateTime selectedDate = widget.selectedDate;
                              List<String> nombresPersonas = [];
                              List<double> montosAsignados = [];

                              // Itera a través de los controladores de montos y recopila los datos.
                              for (int i = 0;
                                  i < amountControllers.length;
                                  i++) {
                                nombresPersonas
                                    .add(snapshot.data![i]['nombre']);
                                montosAsignados.add(
                                    double.parse(amountControllers[i].text));
                              }

                              // Llama a la función para guardar el gasto

                              await addGasto(title, totalAmount, selectedDate,
                                      nombresPersonas, montosAsignados)
                                  .then((_) =>
                                      {Navigator.of(context).pushNamed('/')});
                            },
                            child: const Text("Guardar"),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              double totalAmount = widget.initialAmount;
                              if (totalAmount <= 0) {
                                // Manejar el caso en el que la cantidad inicial sea cero o negativa.
                                return;
                              }

                              // Calcula la cantidad que se debe asignar a cada persona.
                              double amountPerPerson =
                                  totalAmount / amountControllers.length;

                              // Asigna la cantidad a cada controlador de TextField.
                              for (int i = 0;
                                  i < amountControllers.length;
                                  i++) {
                                amountControllers[i].text =
                                    amountPerPerson.toStringAsFixed(2);
                              }

                              // Actualiza el estado para reflejar los cambios en los TextField.
                              setState(() {});
                            },
                            child: const Text("Distribuir"),
                          ),
                        )
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
