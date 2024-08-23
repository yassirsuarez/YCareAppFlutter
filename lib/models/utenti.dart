class Utente {
  final String id;
  final String nome;
  final String cognome;
  final String dataNascita;
  final String peso;
  final String altezza;
  final String genere;
  final String? imageUrl;

  Utente({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.dataNascita,
    required this.peso,
    required this.altezza,
    required this.genere,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'dataNascita': dataNascita,
      'peso': peso,
      'altezza': altezza,
      'genere': genere,
      'imageUrl': imageUrl,
    };
  }

  factory Utente.fromMap(Map<String, dynamic> map, String documentId) {
    return Utente(
      id: documentId,
      nome: map['nome'],
      cognome: map['cognome'],
      dataNascita: map['dataNascita'],
      peso: map['peso'],
      altezza: map['altezza'],
      genere: map['genere'],
      imageUrl: map['imageUrl'],
    );
  }
}
