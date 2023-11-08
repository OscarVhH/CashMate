import 'package:cashmateapp/pages/add_gasto.dart';
import 'package:cashmateapp/pages/add_name.dart';
import 'package:cashmateapp/pages/detalleGasto.dart';
import 'package:cashmateapp/pages/home_page.dart';
import 'package:cashmateapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
//importaciones de firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/add': (context) => const AddGastoPage(),
        '/personas': (context) => const Home(),
        '/addPerson': (context) => const AddNamePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // Define las páginas que deseas mostrar en el cuerpo.
  final List<Widget> _pages = [
    const Page1(),
    const Page2(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('CashMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_sharp),
            onPressed: () {
              Navigator.of(context).pushNamed('/personas');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'GASTOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'SALDOS',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGasto(),
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
            child: Text('No hay gastos registrados.'),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              final gasto = snapshot.data?[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Alinea el texto a la derecha
                  children: [
                    Text(
                      gasto['titulo'],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.blue), // Personaliza el estilo del título
                    ),
                    Text(
                      '\$${gasto['montoTotal']}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .green), // Personaliza el estilo del montoTotal
                    ),
                  ],
                ),
                onTap: () {
                  // Al hacer clic en un elemento, navega a la pantalla de detalles del gasto.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetallesGasto(gasto['id']),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGasto(),
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
            child: Text('No hay gastos registrados.'),
          );
        } else {
          final gasto = snapshot.data;
          final Map<String, double> combinedData = {};

          if (gasto != null) {
            for (int indice = 0; indice < gasto.length; indice++) {
              final datosPersonas =
                  gasto[indice]['datosPersonas'] as Map<String, dynamic>;

              datosPersonas.forEach((nombre, monto) {
                final double doubleMonto = (monto as num)
                    .toDouble(); // Asegúrate de que el monto sea un double

                if (combinedData.containsKey(nombre)) {
                  // Si ya tenemos datos para este nombre, sumamos el monto existente
                  combinedData[nombre] =
                      (combinedData[nombre] ?? 0) + doubleMonto;
                } else {
                  // Si no tenemos datos para este nombre, lo agregamos
                  combinedData[nombre] = doubleMonto;
                }
              });
            }
          }

          // Procesar los datos consolidados para crear la gráfica
          final List<PieChartSectionData> sections =
              generatePieChartSections(combinedData);

          // Crear la gráfica consolidada
          final PieChart pieChart = PieChart(
            PieChartData(
              sections: sections,
              // Otras configuraciones de la gráfica, como el tamaño y la posición, pueden ajustarse aquí
            ),
          );

          return pieChart;
        }
      },
    );
  }

  List<PieChartSectionData> generatePieChartSections(
      Map<String, double> combinedData) {
    List<PieChartSectionData> sections = [];

    // Itera a través de los datos consolidados y crea secciones para la gráfica
    combinedData.forEach((nombre, monto) {
      final section = PieChartSectionData(
        color: Colors.blueAccent, // Puedes definir colores aleatorios
        value: monto,
        titleStyle: const TextStyle(color: Colors.white),
        title: '$nombre \$$monto', // Muestra el nombre y el monto
        radius: 100, // Radio de la sección
      );

      sections.add(section);
    });

    return sections;
  }
}
