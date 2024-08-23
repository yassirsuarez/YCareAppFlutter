import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ycareapp/services/utenti_services.dart';
import 'package:ycareapp/models/utenti.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'DatiProfilo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UtenteService _utenteService = UtenteService();
  Utente? user;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userData = await _utenteService.getUserData();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final imageUrl = await FirebaseStorage.instance
          .ref('foto_profilo/$uid.png')
          .getDownloadURL();

      setState(() {
        user = Utente(
          id: uid,
          nome: userData['nome'] ?? 'Non specificato',
          cognome: userData['cognome'] ?? 'Non specificato',
          dataNascita: userData['dataNascita'] ?? 'Non specificato',
          peso: userData['peso'] ?? 'Non specificato',
          altezza: userData['altezza'] ?? 'Non specificato',
          genere: userData['genere'] ?? 'Non specificato',
          imageUrl: imageUrl,
        );
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benvenuto${user != null ? ', ${user!.nome}' : ''}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (user == null) ...[
              Text(
                'Questa è la tua app di benessere e monitoraggio. Completa il tuo profilo per iniziare a usare tutte le funzionalità.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Datiprofilo()),
                    );
                    if (result == true) {
                      await _getUserData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Inserisci Dati'),
                ),
              ),
            ],
            if (user != null) ...[
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('assets/placeholder.png') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.deepPurple),
                        title: Text('${user!.nome} ${user!.cognome}', style: const TextStyle(fontSize: 24, color: Colors.black)),
                      ),
                      ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                        title: Text('Data di Nascita: ${user!.dataNascita}', style: const TextStyle(fontSize: 18, color: Colors.black87)),
                      ),
                      ListTile(
                        leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                        title: Text('Peso: ${user!.peso}', style: const TextStyle(fontSize: 18, color: Colors.black87)),
                      ),
                      ListTile(
                        leading: Icon(Icons.height, color: Colors.deepPurple),
                        title: Text('Altezza: ${user!.altezza}', style: const TextStyle(fontSize: 18, color: Colors.black87)),
                      ),
                      ListTile(
                        leading: Icon(Icons.transgender, color: Colors.deepPurple),
                        title: Text('Genere: ${user!.genere}', style: const TextStyle(fontSize: 18, color: Colors.black87)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Datiprofilo()),
                    );
                    if (result == true) {
                      await _getUserData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Modifica Profilo'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
