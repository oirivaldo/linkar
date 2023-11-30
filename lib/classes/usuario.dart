import '../main.dart';

class Usuario {
  int _idUsuario;
  String _nomeUsuario;
  int _idTipoPerfil;
  String _nomeTipoPerfil;

  Usuario({
    required int idUsuario,
    required String nomeUsuario,
    required int idTipoPerfil,
    required String nomeTipoPerfil,
  })  : _idUsuario = idUsuario,
        _nomeUsuario = nomeUsuario,
        _idTipoPerfil = idTipoPerfil,
        _nomeTipoPerfil = nomeTipoPerfil;

  int get idUsuario => _idUsuario;

  set idUsuario(int value) {
    _idUsuario = value;
  }

  String get nomeUsuario => _nomeUsuario;

  set nomeUsuario(String value) {
    _nomeUsuario = value;
  }

  int get idTipoPerfil => _idTipoPerfil;

  set idTipoPerfil(int value) {
    _idTipoPerfil = value;
  }

  String get nomeTipoPerfil => _nomeTipoPerfil;

  set nomeTipoPerfil(String value) {
    _nomeTipoPerfil = value;
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'] as int,
      nomeUsuario: map['nomeUsuario'] as String,
      idTipoPerfil: map['idTipoPerfil'] as int,
      nomeTipoPerfil: '',
    );
  }
}

Future<String> buscarNomeTipoPerfil(int idTipoPerfil) async {
  final response = await supabase
      .from('TiposPerfil')
      .select('nomeTipoPerfil')
      .eq('idTipoPerfil', idTipoPerfil)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Tipo Perfil Desconhecido';
  }

  final nomeTipoPerfil = response.data[0]['nomeTipoPerfil'] as String;
  return nomeTipoPerfil;
}

Future<void> criarUsuario(idUsuario, nomeUsuario, idTipoPerfil) async {
  try {
    final response = await supabase
        .from('Usuarios')
        .upsert({'idUsuario': idUsuario,
      'nomeUsuario': nomeUsuario,
      'idTipoPerfil': idTipoPerfil,}).execute();

  } catch (e) {
    throw Exception('Erro ao criar o usuário: $e');
  }
}




