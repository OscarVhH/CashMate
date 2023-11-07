import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//consulta
Future<List> getPeople() async {
  List people = [];
  CollectionReference collectionReferencePeople = db.collection('people');
  QuerySnapshot queryPeople = await collectionReferencePeople.get();
  queryPeople.docs.forEach((documento) {
    people.add(documento.data());
  });
  return people;
}

Future<List> getGasto() async {
  List gasto = [];
  CollectionReference collectionReferencePeople = db.collection('gasto');
  QuerySnapshot queryGasto = await collectionReferencePeople.get();
  queryGasto.docs.forEach((documento) {
    gasto.add(documento.data());
  });
  return gasto;
}

Future<Map<String, dynamic>> getGastoById(String gastoId) async {
  DocumentReference docRef = db.collection('gasto').doc(gastoId);
  DocumentSnapshot docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    return docSnapshot.data() as Map<String, dynamic>;
  } else {
    // Manejar el caso en el que el documento no existe.
    return {}; // Puedes devolver null u otra respuesta apropiada.
  }
}

//funcion para guardar
Future<void> addPeople(String nombre, String apellido) async {
  final DocumentReference newDocument = await FirebaseFirestore.instance
      .collection('people')
      .add({'nombre': nombre, 'apellido': apellido, 'id': '0', 'saldo': '0'});
  final DocumentReference documentReference =
      FirebaseFirestore.instance.collection('people').doc(newDocument.id);
  documentReference.update({
    'id': newDocument.id,
  });
}

Future<void> deletePersona(String collectionName, String documentId) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .delete();
  } catch (e) {
    // ignore: avoid_print
    print('error');
  }
}

Future<void> deleteGasto(String documentId) async {
  try {
    await FirebaseFirestore.instance
        .collection('gasto')
        .doc(documentId)
        .delete();
  } catch (e) {
    // ignore: avoid_print
    print('error');
  }
}

Future<void> addGasto(String title, double totalAmount, DateTime date,
    List<String> nombresPersonas, List<double> montosAsignados) async {
  try {
    //referencia a la base de datos Firestore
    final DocumentReference newDocument =
        await FirebaseFirestore.instance.collection('gasto').add({
      'titulo': title,
      'montoTotal': totalAmount,
      'fecha': date,
      'datosPersonas': nombresPersonas.asMap().map((index, nombre) {
        return MapEntry(nombre, montosAsignados[index]);
      }),
    });
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('gasto').doc(newDocument.id);
    documentReference.update({
      'id': newDocument.id,
    });
  } catch (e) {
    // Maneja posibles errores.
    print('Error al guardar el gasto: $e');
  }
}
