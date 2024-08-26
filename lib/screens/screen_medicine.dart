import 'package:flutter/material.dart';
import 'package:ycareapp/services/medicine_services.dart';
import 'package:ycareapp/screens/ListaMedicina.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ycareapp/models/medicineSingole.dart';
import 'DatiMedicina.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  List<MedicinaSingole> _medicineData = [];
  final MedicinaService _medicinaService = MedicinaService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getMedicinaSingolaData();
  }

  Future<void> _getMedicinaSingolaData() async {
    try {
      List<MedicinaSingole> data = await _medicinaService.getAllSingoleMedicineData();
      setState(() {
        _medicineData = data;
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
            const Text(
              'I tuoi prossimi medicinali',
              style: TextStyle(
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
                      MaterialPageRoute(builder: (context) => const DatiMedicina()),
                    );
                    if (result == true) {
                      _getMedicinaSingolaData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Aggiungi Medicinale'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Listamedicine()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Storico'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await _medicinaService.updateAllMedicineOrari();
                await _getMedicinaSingolaData();
                setState(() {
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text('Ripristino Giornaliero'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _medicineData.isEmpty
                  ? const Center(
                child: Text(
                  'Non ci sono medicine da prendere',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
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
                                child: medicina.imageUrl != null
                                    ? Image.network(
                                  medicina.imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(Icons.medical_services, size: 80, color: Colors.teal),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicina.titolo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text('Quantità: ${medicina.numeroMedicina}'),
                                    Text('Volte al giorno: ${medicina.volteGiorno}'),
                                    Text('Data Inizio: ${medicina.dataInizio.split('T')[0]}'),
                                    Text('Orario: ${medicina.orario}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await _medicinaService.updatePresaMedicinaData(
                                    id_medicina: medicina.id,
                                    numeroMedicina: medicina.numeroMedicina,
                                    orario: medicina.orario,
                                  );
                                  await _getMedicinaSingolaData();
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final medicinaData = await _medicinaService.getSpecificMedicineData(medicina.id);
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DatiMedicina(medicina: medicinaData),
                                    ),
                                  );
                                  if (result == true) {
                                    _getMedicinaSingolaData();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.teal),
                                onPressed: () {
                                  _shareOnWhatsApp(
                                    medicina.titolo,
                                    medicina.numeroMedicina,
                                    medicina.volteGiorno,
                                    medicina.dataInizio,
                                  );
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
            ),
          ],
        ),
      ),
    );
  }

  void _shareOnWhatsApp(String titolo, String numeroMedicina, String volteGiorno, String dataInizio) {
    final message = 'Titolo: $titolo\nQuantità: $numeroMedicina\nVolte al giorno: $volteGiorno\nData Inizio: $dataInizio';
    Share.share(message);
  }
}
