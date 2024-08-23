import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UtenteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserData({
    required String nome,
    required String cognome,
    required String dataNascita,
    required String peso,
    required String altezza,
    required String genere,
    String ? imageUrl,
  }) async {
    final String uid = _auth.currentUser!.uid;

    try {
      await _firestore.collection('utenti').doc(uid).set({
        'nome': nome,
        'cognome': cognome,
        'dataNascita': dataNascita,
        'peso': peso,
        'altezza': altezza,
        'genere': genere,
        'id_user': uid,
        'imageUrl':imageUrl,
      });
    } catch (e) {
      print('Errore durante il salvataggio dei dati: $e');
      throw Exception('Errore durante il salvataggio dei dati');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final String uid = _auth.currentUser!.uid;

    try {
      final doc = await _firestore.collection('utenti').doc(uid).get();
      if (doc.exists) {
        return doc.data()!;
      } else {
        throw Exception('Documento non trovato');
      }
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
      throw Exception('Errore durante il recupero dei dati');
    }
  }

  Future<void> updateUserData({
    required String nome,
    required String cognome,
    required String dataNascita,
    required String peso,
    required String altezza,
    required String genere,
    String ? imageUrl,
  }) async {
    final String uid = _auth.currentUser!.uid;

    try {
      await _firestore.collection('utenti').doc(uid).update({
        'nome': nome,
        'cognome': cognome,
        'dataNascita': dataNascita,
        'peso': peso,
        'altezza': altezza,
        'genere': genere,
        'id_user': uid,
        'imageUrl':imageUrl,
      });
    } catch (e) {
      print('Errore durante l\'aggiornamento dei dati: $e');
      throw Exception('Errore durante l\'aggiornamento dei dati');
    }
  }


  Future<String?> getProfileImageUrl(String filePath) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Errore durante il recupero dell\'immagine: $e');
      return null;
    }
  }
}
