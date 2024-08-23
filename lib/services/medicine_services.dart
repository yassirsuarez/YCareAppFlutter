import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ycareapp/models/orario.dart';
import 'package:ycareapp/models/medicineSingole.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MedicinaService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveMedicinaData({
    required String titolo,
    required String numeroMedicina,
    required String volteGiorno,
    required String dataInizio,
    required List<Orario> orari,
    String? imageUrl,
  }) async {
    final String uid = _auth.currentUser!.uid;
    try {
      final docRef = _firestore.collection("medicine").doc();
      final String medicinaId = docRef.id;

      List<Map<String, dynamic>> orariMap = orari.map((orario) => {
        'orario': orario.orario,
        'preso': orario.preso,
      }).toList();

      await docRef.set({
        'id': medicinaId,
        'titolo': titolo,
        'numeroMedicina': numeroMedicina,
        'volteGiorno': volteGiorno,
        'dataInizio': dataInizio,
        'id_user': uid,
        'orari': orariMap,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
    } catch (e) {
      print('Errore durante il salvataggio dei dati: $e');
      throw Exception('Errore durante il salvataggio dei dati');
    }
  }

  Future<Map<String, dynamic>> getSpecificMedicineData(String id) async {
    try {
      final querySnapshot = await _firestore
          .collection('medicine')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final medicina = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return medicina;
      } else {
        throw Exception('Nessuna medicina trovata con l\'ID specificato');
      }
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
      throw Exception('Errore durante il recupero dei dati');
    }
  }

  Future<List<Map<String,dynamic>>> getAllMedicineData() async{
    final String uid = _auth.currentUser!.uid;

    try{
      final querySnapshot = await _firestore
          .collection('medicine')
          .where('id_user', isEqualTo: uid)
          .orderBy('dataInizio')
          .get();
      List<Map<String,dynamic>> visitaDataList=[];
      for (var doc in querySnapshot.docs) {
        visitaDataList.add(doc.data());
      }
      return visitaDataList;
    }catch(e){
      print('Errore durante il recupero dei dati: $e');
      throw Exception('Errore durante il recupero dei dati');
    }
  }
  Future<List<MedicinaSingole>> getAllSingoleMedicineData() async {
    final String uid = _auth.currentUser!.uid;

    try {
      final querySnapshot = await _firestore
          .collection('medicine')
          .where('id_user', isEqualTo: uid)
          .orderBy('dataInizio')
          .get();

      List<MedicinaSingole> medicineList = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<dynamic> orariList = data['orari'] ?? [];

        for (var orario in orariList) {
          if (orario['preso'] == false) {
            medicineList.add(
              MedicinaSingole(
                id: doc.id,
                titolo: data['titolo'] ?? '',
                numeroMedicina: data['numeroMedicina'] ?? '',
                volteGiorno: data['volteGiorno'] ?? '',
                dataInizio: data['dataInizio'] ?? '',
                id_user: data['id_user'] ?? '',
                imageUrl: data['imageUrl'],
                orario: orario['orario'] ?? '',
              ),
            );
          }
        }
      }
      medicineList.sort((a, b) {
        return _parseTime(a.orario).compareTo(_parseTime(b.orario));
      });
      return medicineList;
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
      throw Exception('Errore durante il recupero dei dati');
    }
  }


  Future<void> eliminaMedicina(String medicinaId) async{
    try{
      await _firestore.collection('medicine').doc(medicinaId).delete();
    }catch(e){
      print('Errore durante l\'eliminazione della visita: $e');
      throw Exception('Errore durante l\'eliminazione della visita');
    }
  }

  Future<void> updateMedicinaData({
    required String id_medicina,
    required String titolo,
    required String numeroMedicina,
    required String volteGiorno,
    required String dataInizio,
    required List<Orario> orari,
    String? imageUrl,
  }) async {
    try {
      List<Map<String, dynamic>> orariMap = orari.map((orario) => {
        'orario': orario.orario,
        'preso': orario.preso,
      }).toList();
      await _firestore.collection('medicine').doc(id_medicina).update({
        'titolo': titolo,
        'numeroMedicina': numeroMedicina,
        'volteGiorno': volteGiorno,
        'dataInizio': dataInizio,
        'orari': orariMap,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
    } catch (e) {
      print('Errore durante l\'aggiornamento dei dati: $e');
      throw Exception('Errore durante l\'aggiornamento dei dati');
    }
  }
  Future<void> updatePresaMedicinaData({
    required String id_medicina,
    required String numeroMedicina,
    required String orario,
  }) async {
    try {
      int numero = int.parse(numeroMedicina) - 1;

      DocumentSnapshot docSnapshot = await _firestore.collection('medicine').doc(id_medicina).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> medicinaData = docSnapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> orari = List<Map<String, dynamic>>.from(medicinaData['orari']);

        for (var orarioEntry in orari) {
          if (orarioEntry['orario'] == orario) {
            orarioEntry['preso'] = true;
            break;
          }
        }

        await _firestore.collection('medicine').doc(id_medicina).update({
          'numeroMedicina': numero.toString(),
          'orari': orari,
        });
      } else {
        throw Exception('Il documento non esiste.');
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento dei dati: $e');
      throw Exception('Errore durante l\'aggiornamento dei dati');
    }
  }

  Future<void> updateAllMedicineOrari() async {
    try {
      final querySnapshot = await _firestore.collection('medicine').get();

      for (var doc in querySnapshot.docs) {
        final docId = doc.id;
        final medicinaData = doc.data();
        final List<dynamic> orariList = medicinaData['orari'] ?? [];

        final updatedOrariList = orariList.map((orario) {
          return {
            ...orario,
            'preso': false,
          };
        }).toList();

        await _firestore.collection('medicine').doc(docId).update({
          'orari': updatedOrariList,
        });
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento degli orari: $e');
    }
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(0, 1, 1, hour, minute);
  }
}