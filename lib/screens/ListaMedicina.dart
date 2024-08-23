import 'package:flutter/material.dart';
import 'package:ycareapp/models/medicine.dart';
import 'DatiMedicina.dart';
import 'package:ycareapp/services/medicine_services.dart';
import 'package:share_plus/share_plus.dart';

class Listamedicine extends StatefulWidget {
  const Listamedicine({super.key});

  @override
  _ListamedicineState createState() => _ListamedicineState();
}
void _shareOnWhatsApp(String titolo,String numero, String volte,String data) {
  String content = '''
Titolo: ${titolo}
Quantità: ${numero}
Volte al giorno: ${volte}
Data Inizio: ${data}
''';
  Share.share(
    content,
    subject: 'Dettagli Medicina',
    sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
  );
}

class _ListamedicineState extends State<Listamedicine> {
  List<Map<String, dynamic>> _medicineData = [];
  final MedicinaService _medicinaService = MedicinaService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAllMedicinaData();
  }

  Future<void> _eliminaMedicina(String medicinaId, int index) async {
    try {
      await _medicinaService.eliminaMedicina(medicinaId);
      setState(() {
        _medicineData.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicina eliminata con successo!')),
      );
    } catch (e) {
      print('Errore durante l\'eliminazione della medicina: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante l\'eliminazione della medicina.')),
      );
    }
  }

  Future<void> _getAllMedicinaData() async {
    try {
      List<Map<String, dynamic>> data = await _medicinaService.getAllMedicineData();
      setState(() {
        _medicineData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Medicine'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicineData.isEmpty
          ? const Center(child: Text('Nessuna medicina disponibile'))
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _medicineData.length,
        itemBuilder: (context, index) {
          final medicina = _medicineData[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: medicina['imageUrl'] != null
                            ? Image.network(
                          medicina['imageUrl'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.medical_services, size: 80, color: Colors.teal),
                      ),
                      const SizedBox(width: 16.0),
                      // Dati Medicina
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicina['titolo'] ?? 'Nome non disponibile',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            const SizedBox(height: 5),
                            Text('Quantità: ${medicina['numeroMedicina'] ?? 'N/A'}'),
                            Text('Volte al giorno: ${medicina['volteGiorno'] ?? 'N/A'}'),
                            Text('Data Inizio: ${medicina['dataInizio']?.split('T')[0] ?? 'N/A'}'),
                            Text('Orari: ${medicina['orari']?.map((o) => o['orario'])?.join(", ") ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Icone sotto l'immagine e i dati, centrate orizzontalmente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DatiMedicina(medicina: medicina),
                            ),
                          );
                          if (result == true) {
                            _getAllMedicinaData();
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
                                content: const Text('Sei sicuro di voler eliminare questa Medicina?'),
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
                            _eliminaMedicina(medicina['id'], index);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.teal),
                        onPressed: () {
                          _shareOnWhatsApp(medicina['titolo'],medicina['numeroMedicina'],medicina['volteGiorno'],medicina['dataInizio']);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
