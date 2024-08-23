import 'package:flutter/material.dart';
import 'package:ycareapp/services/utenti_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class Datiprofilo extends StatefulWidget {
  const Datiprofilo({super.key});

  @override
  _DatiprofiloState createState() => _DatiprofiloState();
}

class _DatiprofiloState extends State<Datiprofilo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _altezzaController = TextEditingController();

  String _dataNascita = '';
  String _genere = 'Maschio';
  String? _imageUrl ;
  File? _selectedImage;

  final UtenteService _userService = UtenteService();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.getUserData();
      setState(() {
        _nomeController.text = userData['nome'] ?? '';
        _cognomeController.text = userData['cognome'] ?? '';
        _dataNascita = userData['dataNascita'] ?? '';
        _pesoController.text = userData['peso'] ?? '';
        _altezzaController.text = userData['altezza'] ?? '';
        _genere = userData['genere'] ?? 'Maschio';
        _imageUrl = userData['imageUrl'];

        if (_imageUrl != null && _imageUrl!.isNotEmpty) {
          _loadImageFromStorage();
        }

        _isEditing = true;
      });
    } catch (e) {
      print('Errore durante il recupero dei dati: $e');
    }
  }

  Future<void> _loadImageFromStorage() async {
    try {
      final String uid = _auth.currentUser!.uid;
      final Reference storageRef = FirebaseStorage.instance.ref().child('foto_profilo/${uid}.png');

      final String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print('Errore durante il recupero dell\'immagine: $e');
      setState(() {
        _imageUrl = 'assets/images/default_profile.png';
      });
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

  Future<void> _uploadImage(File imageFile) async {
    try {
      final String uid = _auth.currentUser!.uid;
      String fileName = 'foto_profilo/${uid}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Immagine caricata con successo!')),
      );
    } catch (e) {
      print('Errore durante il caricamento dell\'immagine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il caricamento dell\'immagine')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dataNascita = "${pickedDate.toLocal().day}/${pickedDate.toLocal().month}/${pickedDate.toLocal().year}";
      });
    }
  }

  Future<void> _saveUserData() async {
    final String nome = _nomeController.text;
    final String cognome = _cognomeController.text;
    final String peso = _pesoController.text;
    final String altezza = _altezzaController.text;

    if (nome.isEmpty || cognome.isEmpty || _dataNascita.isEmpty || peso.isEmpty || altezza.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, riempi tutti i campi e carica una foto.')),
      );
      return;
    }

    try {
      if (_selectedImage != null) {
        if (_imageUrl != null) {
          await _uploadImage(_selectedImage!);
        } else {
          File defaultImageFile = await _getDefaultImageFile();
          await _uploadImage(defaultImageFile);
        }
      } else {
        if (_imageUrl != null) {
        } else {
          File defaultImageFile = await _getDefaultImageFile();
          await _uploadImage(defaultImageFile);
        }
      }


      if (_isEditing) {
        await _userService.updateUserData(
          nome: nome,
          cognome: cognome,
          dataNascita: _dataNascita,
          peso: peso,
          altezza: altezza,
          genere: _genere,
          imageUrl: _imageUrl ?? '',
        );
      } else {
        await _userService.saveUserData(
          nome: nome,
          cognome: cognome,
          dataNascita: _dataNascita,
          peso: peso,
          altezza: altezza,
          genere: _genere,
          imageUrl: _imageUrl ?? '',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati salvati con successo!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante il salvataggio dei dati!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dati Profilo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : _imageUrl != null
                      ? NetworkImage(_imageUrl!)
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cognomeController,
              decoration: InputDecoration(
                labelText: 'Cognome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: _dataNascita.isEmpty ? 'Seleziona la data' : _dataNascita,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Genere',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _genere,
                    onChanged: (String? newValue) {
                      setState(() {
                        _genere = newValue!;
                      });
                    },
                    items: <String>['Maschio', 'Femmina']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pesoController,
              decoration: InputDecoration(
                labelText: 'Peso',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Inserisci il peso in kg',
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _altezzaController,
              decoration: InputDecoration(
                labelText: 'Altezza',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Inserisci l\'altezza in cm',
                suffixText: 'cm',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isEditing ? 'Aggiorna' : 'Salva',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

Future<File> _getDefaultImageFile() async {
  final byteData = await rootBundle.load('assets/images/default_profile.png');
  final file = File('${(await getTemporaryDirectory()).path}/default_profile.png');
  return await file.writeAsBytes(byteData.buffer.asUint8List());
}

