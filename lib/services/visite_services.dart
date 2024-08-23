import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisiteService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveVisitaData({

    required String titolo,
    required String luogo,
    required String data,
    required String ora,

  })async{
    final String uid=_auth.currentUser!.uid;
    try {
      final docRef = _firestore.collection("visite").doc();

      final String visitaId = docRef.id;

      await docRef.set({
        'id': visitaId,
        'titolo': titolo,
        'luogo': luogo,
        'data': data,
        'ora': ora,
        'id_user': uid,
      });
    } catch (e) {
      print('Errore durante il salvataggio dei dati: $e');
      throw Exception('Errore durante il salvataggio dei dati');
    }
  }

  Future<List<Map<String, dynamic>>> getAllVisitaData() async {
    final String uid = _auth.currentUser!.uid;

    try {
      final querySnapshot = await _firestore
          .collection('visite')
          .where('id_user', isEqualTo: uid)
          .orderBy('data')
          .get();

      List<Map<String, dynamic>> visitaDataList = [];
      for (var doc in querySnapshot.docs) {
        visitaDataList.add(doc.data());
      }

      return visitaDataList;
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
      throw Exception('Errore durante il recupero dei dati');
    }
  }

  Future<List<Map<String, dynamic>>> getNextVisitaData() async {
    final String uid = _auth.currentUser!.uid;
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final querySnapshot = await _firestore
          .collection('visite')
          .where('id_user', isEqualTo: uid)
          .get();

      List<Map<String, dynamic>> visitaDataList = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String? dataStr = data['data'] as String?;
        if (dataStr != null) {
          try {
            List<String> dateParts = dataStr.split('/');
            int day = int.parse(dateParts[0]);
            int month = int.parse(dateParts[1]);
            int year = int.parse(dateParts[2]);
            DateTime visitaDate = DateTime(year, month, day); // Solo data, senza ora

            if (visitaDate.isAfter(today) || visitaDate.isAtSameMomentAs(today)) {
              visitaDataList.add(data);
            }
          } catch (e) {
            print('Errore durante la conversione della data: $e');
            print(dataStr);
          }
        }
      }
      visitaDataList.sort((a, b) {
        List<String> datePartsA = (a['data'] as String).split('/');
        List<String> datePartsB = (b['data'] as String).split('/');

        DateTime dateA = DateTime(
          int.parse(datePartsA[2]),
          int.parse(datePartsA[1]),
          int.parse(datePartsA[0]),
        );
        DateTime dateB = DateTime(
          int.parse(datePartsB[2]),
          int.parse(datePartsB[1]),
          int.parse(datePartsB[0]),
        );
        return dateA.compareTo(dateB);
      });
      return visitaDataList;
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
      throw Exception('Errore durante il recupero dei dati');
    }
  }


  Future<void> eliminaVisita(String visitaId) async {
    try {
      await _firestore.collection('visite').doc(visitaId).delete();
    } catch (e) {
      print('Errore durante l\'eliminazione della visita: $e');
      throw Exception('Errore durante l\'eliminazione della visita');
    }
  }

  Future<void> updateVisitaData({
    required String id_visita,
    required String titolo,
    required String luogo,
    required String data,
    required String ora,
})async {
    try{
    _firestore.collection('visite').doc(id_visita).update({
      'titolo': titolo,
      'luogo': luogo,
      'data': data,
      'ora': ora,
    });
  }catch(e){
  print('Errore durante l\'aggiornamento dei dati: $e');
  throw Exception('Errore durante l\'aggiornamento dei dati');
  }
  }
  }




