class Orario {
  String orario;
  bool preso;

  Orario({required this.orario, required this.preso});

  Map<String, dynamic> toMap() {
    return {
      'orario': orario,
      'preso': preso,
    };
  }

  factory Orario.fromMap(Map<String, dynamic> map) {
    return Orario(
      orario: map['orario'] as String,
      preso: map['preso'] as bool,
    );
  }
}
