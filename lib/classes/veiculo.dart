import 'package:linkar/main.dart';

class Veiculo {
  int _idVeiculo;
  int _numeracao;
  String _placa;
  int _idMarca;
  String _nomeMarca;
  int _idModelo;
  String _nomeModelo;
  int _idCor;
  String _cor;
  int _idAno;
  String _ano;
  String _renavam;
  int _idStatusVeiculo;
  String _nomeStatusVeiculo;
  int _idTipoFrota;
  String _nomeTipoFrota;
  String _localizacao;
  int _idReserva;
  String _nomeUsuario;

  Veiculo({
    required int idVeiculo,
    required int numeracao,
    required String placa,
    required int idMarca,
    required String nomeMarca,
    required int idModelo,
    required String nomeModelo,
    required int idCor,
    required String cor,
    required int idAno,
    required String ano,
    required String renavam,
    required int idStatusVeiculo,
    required nomeStatusVeiculo,
    required int idTipoFrota,
    required nomeTipoFrota,
    required localizacao,
    required idReserva,
    required nomeUsuario,
  })  : _idVeiculo = idVeiculo,
        _numeracao = numeracao,
        _placa = placa,
        _idMarca = idMarca,
        _nomeMarca = nomeMarca,
        _idModelo = idModelo,
        _nomeModelo = nomeModelo,
        _idCor = idCor,
        _cor = cor,
        _idAno = idAno,
        _ano = ano,
        _renavam = renavam,
        _idStatusVeiculo = idStatusVeiculo,
        _nomeStatusVeiculo = nomeStatusVeiculo,
        _idTipoFrota = idTipoFrota,
        _nomeTipoFrota = nomeTipoFrota,
        _localizacao = localizacao,
        _idReserva = idReserva,
        _nomeUsuario = nomeUsuario;

  @override
  String toString() {
    return 'Veiculo{_idVeiculo: $_idVeiculo, _numeracao: $_numeracao, _idMarca: $_idMarca, _idModelo: $_idModelo, _idCor: $_idCor, _idAno: $_idAno, _idStatusVeiculo: $_idStatusVeiculo, _idTipoFrota: $_idTipoFrota, $idReserva: idReserva}';
  }

  String get nomeUsuario => _nomeUsuario;

  set nomeUsuario(String value) {
    _nomeUsuario = value;
  }

  int get idReserva => _idReserva;

  set idReserva(int value) {
    _idReserva = value;
  }

  int get idVeiculo => _idVeiculo;

  set idVeiculo(int value) {
    _idVeiculo = value;
  }

  int get numeracao => _numeracao;

  set numeracao(int value) {
    _numeracao = value;
  }

  String get placa => _placa;

  set placa(String value) {
    _placa = value;
  }

  int get idMarca => _idMarca;

  set idMarca(int value) {
    _idMarca = value;
  }

  String get nomeMarca => _nomeMarca;

  set nomeMarca(String value) {
    _nomeMarca = value;
  }

  int get idModelo => _idModelo;

  set idModelo(int value) {
    _idModelo = value;
  }

  String get nomeModelo => _nomeModelo;

  set nomeModelo(String value) {
    _nomeModelo = value;
  }

  int get idCor => _idCor;

  set idCor(int value) {
    _idCor = value;
  }

  String get cor => _cor;

  set cor(String value) {
    _cor = value;
  }

  int get idAno => _idAno;

  set idAno(int value) {
    _idAno = value;
  }

  String get ano => _ano;

  set ano(String value) {
    _ano = value;
  }

  String get renavam => _renavam;

  set renavam(String value) {
    _renavam = value;
  }

  int get idStatusVeiculo => _idStatusVeiculo;

  set idStatusVeiculo(int value) {
    _idStatusVeiculo = value;
  }

  String get nomeStatusVeiculo => _nomeStatusVeiculo;

  set nomeStatusVeiculo(String value) {
    _nomeStatusVeiculo = value;
  }

  int get idTipoFrota => _idTipoFrota;

  set idTipoFrota(int value) {
    _idTipoFrota = value;
  }

  String get nomeTipoFrota => _nomeTipoFrota;

  set nomeTipoFrota(String value) {
    _nomeTipoFrota = value;
  }

  String get localizacao => _localizacao;

  set localizacao(String value) {
    _localizacao = value;
  }

  factory Veiculo.fromMap(Map<String, dynamic> map) {
    return Veiculo(
      idVeiculo: map['idVeiculo'] as int,
      numeracao: map['numeracao'] as int,
      placa: map['placa'] as String,
      idMarca: map['idMarca'] as int,
      nomeMarca: '',
      idModelo: map['idModelo'] as int,
      nomeModelo: '',
      idCor: map['idCor'] as int,
      cor: '',
      idAno: map['idAno'] as int,
      ano: '',
      renavam: map['renavam'] as String,
      idStatusVeiculo: map['idStatusVeiculo'] as int,
      nomeStatusVeiculo: '',
      idTipoFrota: map['idTipoFrota'] as int,
      nomeTipoFrota: '',
      localizacao: '',
      idReserva: map['idReserva'] as int? ?? 0,
      nomeUsuario: '',
    );
  }
}

Future<String> buscarCor(int idCor) async {
  final response = await supabase
      .from('CoresCarros')
      .select('cor')
      .eq('idCor', idCor)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Cor Desconhecida';
  }

  final cor = response.data[0]['cor'] as String;
  return cor;
}


Future<String> buscarAno(int idAno) async {
  final response = await supabase
      .from('Anos')
      .select('ano')
      .eq('idAno', idAno)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Ano Desconhecido';
  }

  final ano = response.data[0]['ano'] as String;
  return ano;
}

Future<String> buscarNomeStatusVeiculo(int idStatusVeiculo) async {
  final response = await supabase
      .from('StatusVeiculos')
      .select('nomeStatusVeiculo')
      .eq('idStatusVeiculo', idStatusVeiculo)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Status Desconhecido';
  }

  final nomeStatusVeiculo = response.data[0]['nomeStatusVeiculo'] as String;
  return nomeStatusVeiculo;
}

Future<String> buscarNomeTipoFrota(int idTipo) async {
  final response = await supabase
      .from('TiposFrota')
      .select('nomeTipoFrota')
      .eq('idTipo', idTipo)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Tipo Desconhecido';
  }

  final nomeTipoFrota = response.data[0]['nomeTipoFrota'] as String;
  return nomeTipoFrota;
}

Future<String> buscarNomeMarca(int idMarca) async {
  final response = await supabase
      .from('Marcas')
      .select('nomeMarca')
      .eq('idMarca', idMarca)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Marca Desconhecida';
  }

  final nomeMarca = response.data[0]['nomeMarca'] as String;
  return nomeMarca;
}

Future<String> buscarNomeModelo(int idModelo) async {
  final response = await supabase
      .from('Modelos')
      .select('nomeModelo')
      .eq('idModelo', idModelo)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Modelo Desconhecido';
  }

  final nomeModelo = response.data[0]['nomeModelo'] as String;
  return nomeModelo;
}


