import '../main.dart';

class Reserva {
  int _idReserva;
  String _justificativa;
  int _idUsuario;
  String _nomeUsuario;
  String _dataHoraCriacao;
  int _idStatusReserva;
  String _nomeStatusReserva;
  String _dataHoraCheckin;
  String _obsCheckin;
  String _dataHoraCheckout;
  String _obsCheckout;
  int _idVeiculo;
  int _numeracao;
  String _nomeMarca;
  String _nomeModelo;
  String _placa;
  String _nomeTipoFrota;
  String _dataHoraPrevistaCheckin;
  String _dataHoraPrevistaCheckout;

  Reserva({
    required int idReserva,
    required String justificativa,
    required int idUsuario,
    required String nomeUsuario,
    required String dataHoraCriacao,
    required int idStatusReserva,
    required nomeStatusReserva,
    required dataHoraCheckin,
    required obsCheckin,
    required dataHoraCheckout,
    required obsCheckout,
    required idVeiculo,
    required int numeracao,
    required String nomeMarca,
    required String nomeModelo,
    required String placa,
    required String nomeTipoFrota,
    required String dataHoraPrevistaCheckin,
    required String dataHoraPrevistaCheckout,
  })  : _idReserva = idReserva,
        _justificativa = justificativa,
        _idUsuario = idUsuario,
        _nomeUsuario = nomeUsuario,
        _dataHoraCriacao = dataHoraCriacao,
        _idStatusReserva = idStatusReserva,
        _nomeStatusReserva = nomeStatusReserva,
        _dataHoraCheckin = dataHoraCheckin,
        _obsCheckin = obsCheckin,
        _dataHoraCheckout = dataHoraCheckout,
        _obsCheckout = obsCheckout,
        _idVeiculo = idVeiculo,
        _numeracao = numeracao,
        _placa = placa,
        _nomeTipoFrota = nomeTipoFrota,
        _nomeModelo = nomeModelo,
        _nomeMarca = nomeMarca,
        _dataHoraPrevistaCheckin = dataHoraPrevistaCheckin,
        _dataHoraPrevistaCheckout = dataHoraPrevistaCheckout;


  @override
  String toString() {
    return 'Reserva{_idReserva: $_idReserva, _idUsuario: $_idUsuario, _idStatusReserva: $_idStatusReserva, _idVeiculo: $_idVeiculo, _numeracao: $_numeracao}';
  }

  String get nomeTipoFrota => _nomeTipoFrota;

  set nomeTipoFrota(String value) {
    _nomeTipoFrota = value;
  }

  String get nomeModelo => _nomeModelo;

  set nomeModelo(String value) {
    _nomeModelo = value;
  }

  String get nomeMarca => _nomeMarca;

  set nomeMarca(String value) {
    _nomeMarca = value;
  }

  String get placa => _placa;

  set placa(String value) {
    _placa = value;
  }

  int get numeracao => _numeracao;

  set numeracao(int value) {
    _numeracao = value;
  }

  String get nomeStatusReserva => _nomeStatusReserva;

  set nomeStatusReserva(String value) {
    _nomeStatusReserva = value;
  }

  String get nomeUsuario => _nomeUsuario;

  set nomeUsuario(String value) {
    _nomeUsuario = value;
  }

  int get idReserva => _idReserva;

  set idReserva(int value) {
    _idReserva = value;
  }

  String get justificativa => _justificativa;

  set justificativa(String value) {
    _justificativa = value;
  }

  int get idUsuario => _idUsuario;

  set idUsuario(int value) {
    _idUsuario = value;
  }

  String get dataHoraCriacao => _dataHoraCriacao;

  set dataHoraCriacao(String value) {
    _dataHoraCriacao = value;
  }

  int get idStatusReserva => _idStatusReserva;

  set idStatusReserva(int value) {
    _idStatusReserva = value;
  }

  String get dataHoraCheckin => _dataHoraCheckin;

  set dataHoraCheckin(String value) {
    _dataHoraCheckin = value;
  }

  String get obsCheckin => _obsCheckin;

  set obsCheckin(String value) {
    _obsCheckin = value;
  }

  String get dataHoraCheckout => _dataHoraCheckout;

  set dataHoraCheckout(String value) {
    _dataHoraCheckout = value;
  }

  String get obsCheckout => _obsCheckout;

  set obsCheckout(String value) {
    _obsCheckout = value;
  }

  int get idVeiculo => _idVeiculo;

  set idVeiculo(int value) {
    _idVeiculo = value;
  }

  String get dataHoraPrevistaCheckin => _dataHoraPrevistaCheckin;

  set dataHoraPrevistaCheckin(String value) {
    _dataHoraPrevistaCheckin = value;
  }

  String get dataHoraPrevistaCheckout => _dataHoraPrevistaCheckout;

  set dataHoraPrevistaCheckout(String value) {
    _dataHoraPrevistaCheckout = value;
  }

  factory Reserva.fromMap(Map<String, dynamic> map) {
    return Reserva(
      idReserva: map['idReserva'] as int,
      justificativa: map['justificativa'] as String,
      idUsuario: map['idUsuario'] as int,
      nomeUsuario: '',
      dataHoraCriacao: map['dataHoraCriacao'] as String,
      idStatusReserva: map['idStatusReserva'] as int,
      nomeStatusReserva: '',
      dataHoraCheckin: map['dataHoraCheckin'] as String? ?? '-',
      obsCheckin: map['obsCheckin'] as String? ?? '-',
      dataHoraCheckout: map['dataHoraCheckout'] as String? ?? '-',
      obsCheckout: map['obsCheckout'] as String? ?? '-',
      idVeiculo: map['idVeiculo'] as int? ?? 0,
      numeracao: map['numeracao'] as int? ?? 0,
      placa: map['placa'] as String? ?? '',
      nomeMarca: '',
      nomeModelo: '',
      nomeTipoFrota: '',
      dataHoraPrevistaCheckin: map['dataHoraPrevistaCheckin'] as String,
      dataHoraPrevistaCheckout: map['dataHoraPrevistaCheckout'] as String,
    );
  }
}

Future<String> buscarNomeUsuario(int idUsuario) async {
  final response = await supabase
      .from('Usuarios')
      .select('nomeUsuario')
      .eq('idUsuario', idUsuario)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Usuario Desconhecido';
  }

  final nomeUsuario = response.data[0]['nomeUsuario'] as String;
  return nomeUsuario;
}

Future<String> buscarNomeStatusReserva(int idStatusReserva) async {
  final response = await supabase
      .from('StatusReservas')
      .select('nomeStatusReserva')
      .eq('idStatusReserva', idStatusReserva)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    return 'Status da Reserva Desconhecido';
  }

  final nomeStatusReserva = response.data[0]['nomeStatusReserva'] as String;
  return nomeStatusReserva;
}