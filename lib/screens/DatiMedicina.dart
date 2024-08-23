import 'package:flutter/material.dart';
import 'package:ycareapp/services/medicine_services.dart';
import 'package:ycareapp/models/orario.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class DatiMedicina extends StatefulWidget {
  final Map<String, dynamic>? medicina;

  const DatiMedicina({super.key, this.medicina});

  @override
  _DatiMedicinaState createState() => _DatiMedicinaState();
}

class _DatiMedicinaState extends State<DatiMedicina> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MedicinaService _medicineService = MedicinaService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();
  final TextEditingController _voltePerGiornoController = TextEditingController();
  DateTime _dataInizio = DateTime.now();
  List<Orario> _orari = [];
  bool _isEditing = false;
  String? _imageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadMedicineData();
  }

  void _loadMedicineData() {
    if (widget.medicina != null) {
      setState(() {
        _isEditing = true;
        _nomeController.text = widget.medicina!['titolo'] ?? '';
        _quantitaController.text = widget.medicina!['numeroMedicina'] ?? '';
        _voltePerGiornoController.text = widget.medicina!['volteGiorno'] ?? '';
        _dataInizio = DateTime.parse(widget.medicina!['dataInizio'] ?? DateTime.now().toString());
        _imageUrl = widget.medicina!['imageUrl'];

        if (widget.medicina!['orari'] != null) {
          _orari = List<Orario>.from(
            widget.medicina!['orari'].map((orario) => Orario.fromMap(orario)),
          );
        }
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('medicine_images/$uid/${DateTime.now().toIso8601String()}.png');
      final UploadTask uploadTask = storageRef.putFile(image);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Errore durante il caricamento dell\'immagine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante il caricamento dell\'immagine.')),
      );
      return null;
    }
  }


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveMedicine() async {
    final String nome = _nomeController.text;
    final String quantita = _quantitaController.text;
    final String voltePerGiorno = _voltePerGiornoController.text;

    if (nome.isEmpty || quantita.isEmpty || voltePerGiorno.isEmpty || _orari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, riempi tutti i campi e aggiungi gli orari.')),
      );
      return;
    }

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      if (_isEditing) {
        await _medicineService.updateMedicinaData(
          id_medicina: widget.medicina!['id'],
          titolo: nome,
          numeroMedicina: quantita,
          volteGiorno: voltePerGiorno,
          dataInizio: _dataInizio.toIso8601String().split('T')[0],
          orari: _orari,
          imageUrl: imageUrl,
        );
      } else {
        await _medicineService.saveMedicinaData(
          titolo: nome,
          numeroMedicina: quantita,
          volteGiorno: voltePerGiorno,
          dataInizio: _dataInizio.toIso8601String().split('T')[0], // Formatta la data
          orari: _orari,
          imageUrl: imageUrl,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicina salvata con successo!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante il salvataggio della medicina!')),
      );
    }
  }



  Future<void> _selectTime(int index) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _orari[index].orario = pickedTime.format(context);
      });
    }
  }

  void _generateOrari() {
    final int frequenza = int.tryParse(_voltePerGiornoController.text) ?? 1;
    setState(() {
      _orari = List.generate(
        frequenza,
            (index) => Orario(orario: '', preso: false), // Cambiato per non avere un orario predefinito
      );
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataInizio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _dataInizio) {
      setState(() {
        _dataInizio = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Medicina' : 'Nuova Medicina'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _imageUrl != null
                        ? Image.network(_imageUrl!, height: 150, width: 150, fit: BoxFit.cover)
                        : _selectedImage != null
                        ? Image.file(_selectedImage!, height: 150, width: 150, fit: BoxFit.cover)
                        : IconButton(
                      icon: Icon(Icons.add_a_photo, size: 50, color: Colors.blue),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome Medicina',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantitaController,
                decoration: InputDecoration(
                  labelText: 'Quantità Medicina',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _voltePerGiornoController,
                decoration: InputDecoration(
                  labelText: 'Volte al Giorno',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _generateOrari();
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: "${_dataInizio.toLocal()}".split(' ')[0]),
                    decoration: InputDecoration(
                      labelText: 'Data Inizio',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Orari della Medicina',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: _orari.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text('Orario: ${_orari[index].orario}'),
                        trailing: Switch(
                          value: _orari[index].preso,
                          onChanged: (bool value) {
                            setState(() {
                              _orari[index].preso = value;
                            });
                          },
                        ),
                        onTap: () => _selectTime(index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    _isEditing ? 'Aggiorna' : 'Salva',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
