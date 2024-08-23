import 'orario.dart';

class Medicina {
  final String id;
  final String titolo;
  final String numeroMedicina;
  final String volteGiorno;
  final String dataInizio;
  final String id_user;
  final List<Orario> orari;
  final String? imageUrl;

  Medicina({
    required this.id,
    required this.titolo,
    required this.numeroMedicina,
    required this.volteGiorno,
    required this.dataInizio,
    required this.id_user,
    required this.orari,
    this.imageUrl,
  });
}
