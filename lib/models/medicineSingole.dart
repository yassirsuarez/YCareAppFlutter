
class MedicinaSingole {
  final String id;
  final String titolo;
  final String numeroMedicina;
  final String volteGiorno;
  final String dataInizio;
  final String id_user;
  final String? imageUrl;
  final String orario;
  MedicinaSingole({
    required this.id,
    required this.titolo,
    required this.numeroMedicina,
    required this.volteGiorno,
    required this.dataInizio,
    required this.id_user,
    this.imageUrl,
    required this.orario,
  });
}
