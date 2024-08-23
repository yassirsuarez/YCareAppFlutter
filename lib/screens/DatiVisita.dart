import 'package:flutter/material.dart';
import 'package:ycareapp/services/visite_services.dart';


class DatiVisita extends StatefulWidget {
  final Map<String, dynamic>? visita;

  const DatiVisita({super.key, this.visita});

  @override
  _DatiVisitaState createState() => _DatiVisitaState();
}

class _DatiVisitaState extends State<DatiVisita> {
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _luogoController = TextEditingController();

  String _data = '';
  String _ora = '';
  bool _isEditing = false;

  final VisiteService _visitaService = VisiteService();

  @override
  void initState() {
    super.initState();
    if (widget.visita != null) {
      _isEditing = true;
      _titoloController.text = widget.visita!['titolo'] ?? '';
      _luogoController.text = widget.visita!['luogo'] ?? '';
      _data = widget.visita!['data'] ?? '';
      _ora = widget.visita!['ora'] ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _data = "${pickedDate.toLocal().day}/${pickedDate.toLocal().month}/${pickedDate.toLocal().year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _ora = pickedTime.format(context); // Format the time as a string
      });
    }
  }

  Future<void> _saveVisitaData() async {
    final String titolo = _titoloController.text;
    final String luogo = _luogoController.text;

    if (titolo.isEmpty || luogo.isEmpty || _data.isEmpty || _ora.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, riempi tutti i campi.')),
      );
      return;
    }
    try {
      if (_isEditing) {
        await _visitaService.updateVisitaData(
          id_visita: widget.visita!['id'],
          titolo: titolo,
          luogo: luogo,
          data: _data,
          ora: _ora,
        );
      } else {
        await _visitaService.saveVisitaData(
          titolo: titolo,
          luogo: luogo,
          data: _data,
          ora: _ora,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Dati aggiornati con successo!' : 'Dati salvati con successo!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante il salvataggio dei dati!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Visita' : 'Nuova Visita'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titoloController,
              decoration: InputDecoration(
                labelText: 'Titolo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _luogoController,
              decoration: InputDecoration(
                labelText: 'Luogo',
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
                    labelText: _data.isEmpty ? 'Seleziona la data' : _data,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: _ora.isEmpty ? 'Seleziona l\'ora' : _ora,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Icon(Icons.access_time, color: Colors.deepPurple),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveVisitaData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
    );
  }

}

