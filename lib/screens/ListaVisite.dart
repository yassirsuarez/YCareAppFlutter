import 'package:flutter/material.dart';
import 'DatiVisita.dart';
import 'package:ycareapp/services/visite_services.dart';
import 'package:url_launcher/url_launcher.dart';

class Listavisite extends StatefulWidget  {
  const Listavisite({super.key});

  @override
  _ListavisiteState createState() => _ListavisiteState();
}

class _ListavisiteState extends State<Listavisite> {
  List<Map<String, dynamic>> _visiteData = [];
  final VisiteService _visiteService = VisiteService();

  @override
  void initState() {
    super.initState();
    _getAllVisitaData();
  }

  Future<void> _openGoogleMaps(String query) async {
    final String encodedQuery = Uri.encodeComponent(query);

    final String geoUrl = 'geo:0,0?q=$encodedQuery';
    final String webUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';

    if (await canLaunch(geoUrl)) {
      print('Lancio Google Maps con geo URL: $geoUrl');
      await launch(geoUrl);
    } else {
      print('Geo URL fallito, provo con l\'URL web: $webUrl');
      if (await canLaunch(webUrl)) {
        await launch(webUrl);
      } else {
        throw 'Impossibile lanciare Google Maps per la query: $query';
      }
    }
  }

  Future<void> _eliminaVisita(String visitaId, int index) async {
    try {
      await _visiteService.eliminaVisita(visitaId);
      setState(() {
        _visiteData.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita eliminata con successo!')),
      );
    } catch (e) {
      print('Errore durante l\'eliminazione della visita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Errore durante l\'eliminazione della visita.')),
      );
    }
  }

  Future<void> _getAllVisitaData() async {
    try {
      List<Map<String, dynamic>> data = await _visiteService.getAllVisitaData();
      setState(() {
        _visiteData = data;
      });
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visite'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _visiteData.isEmpty
                  ? const Center(
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
                      leading: Icon(
                        Icons.local_hospital,
                        color: Colors.deepPurple,
                      ),
                      title: Text(
                        visita['titolo'] ?? 'Titolo non disponibile',
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final String luogo = visita['luogo'] ??
                                  'Luogo non disponibile';
                              _openGoogleMaps(luogo);
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Luogo: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    visita['luogo'] ?? 'Luogo non disponibile',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Data: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                visita['data'] ?? 'Data non disponibile',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Ora: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                visita['ora'] ?? 'Ora non disponibile',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DatiVisita(visita: visita),
                                ),
                              );
                              if (result == true) {
                                _getAllVisitaData();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmed = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Conferma Eliminazione'),
                                    content: const Text(
                                        'Sei sicuro di voler eliminare questa visita?'),
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
                                _eliminaVisita(visita['id'], index);
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

