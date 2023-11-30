class TipoPerfil {
  final int idTipoPerfil;
  final String nomeTipoPerfil;

  TipoPerfil({
    required this.idTipoPerfil,
    required this.nomeTipoPerfil,
  });

  factory TipoPerfil.fromMap(Map<String, dynamic> map) {
    return TipoPerfil(
      idTipoPerfil: map['idTipoPerfil'] as int,
      nomeTipoPerfil: map['nomeTipoPerfil'] as String,
    );
  }
}