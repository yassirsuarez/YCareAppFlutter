import 'package:flutter/material.dart';
import 'package:ycareapp/screens/ListaVisite.dart';
import 'package:ycareapp/services/visite_services.dart';
import 'DatiVisita.dart';

class VisiteScreen extends StatefulWidget {
  const VisiteScreen({super.key});

  @override
  _VisiteScreenState createState() => _VisiteScreenState();
}

class _VisiteScreenState extends State<VisiteScreen> {
  List<Map<String, dynamic>> _visiteData = [];
  final VisiteService _visiteService = VisiteService();

  @override
  void initState() {
    super.initState();
    _getNextVisitaData();
  }

  Future<void> _getNextVisitaData() async {
    try {
      List<Map<String, dynamic>> data = await _visiteService.getNextVisitaData();
      setState(() {
        _visiteData = data;
      });
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
    }
  }

  Future<void> _eliminaVisita(String visitaId) async {
    try {
      await _visiteService.eliminaVisita(visitaId);
      _getNextVisitaData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita eliminata con successo!')),
      );
    } catch (e) {
      print('Errore durante l\'eliminazione della visita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante l\'eliminazione della visita.')),
      );
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
            Text('Le tue prossime visite',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DatiVisita()),
                    );
                    if (result == true) {
                      _getNextVisitaData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Aggiungi Visita'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Listavisite()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Guarda Storico'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _visiteData.isEmpty
                  ? Center(
                child: Text(
                  'Ancora non ci sono appuntamenti',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _visiteData.length,
                itemBuilder: (context, index) {
                  final visita = _visiteData[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: Icon(Icons.local_hospital, color: Colors.deepPurple),
                      title: Text(visita['titolo'] ?? 'Titolo non disponibile', style: const TextStyle(fontSize: 18)),
                      subtitle: Text('${visita['luogo']} - ${visita['data']} - ${visita['ora']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DatiVisita(visita: visita),
                                ),
                              );
                              if (result == true) {
                                _getNextVisitaData();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmed = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Conferma Eliminazione'),
                                    content: const Text('Sei sicuro di voler eliminare questa visita?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Annulla'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Elimina'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmed == true) {
                                _eliminaVisita(visita['id']);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
