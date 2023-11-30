import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:linkar/classes/veiculo.dart';
import 'package:linkar/telas/tela_cadastrar_reserva.dart';
import 'package:linkar/telas/tela_detalhes_usuario.dart';
import 'package:linkar/telas/tela_gerir_reservas.dart';
import 'package:linkar/telas/tela_gerir_usuarios.dart';
import 'package:linkar/telas/tela_gerir_veiculos.dart';
import 'package:linkar/telas/tela_detalhes_reserva.dart';
import 'package:linkar/telas/tela_detalhes_reserva_check.dart';
import 'package:linkar/telas/tela_detalhes_veiculo.dart';
import 'package:linkar/telas/tela_detalhes_veiculo_check.dart';
import 'package:linkar/telas/tela_realizar_checkin.dart';
import 'package:linkar/telas/tela_realizar_checkout.dart';
import 'package:linkar/telas/tela_recusar_reserva.dart';
import 'package:linkar/telas/tela_reservas_disponiveis_checkin.dart';
import 'package:linkar/telas/tela_reservas_disponiveis_recusar.dart';
import 'package:linkar/telas/tela_sucesso.dart';
import 'package:linkar/telas/tela_veiculos_disponiveis_checkin.dart';
import 'package:linkar/home.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'classes/reserva.dart';
import 'classes/usuario.dart';
/*import 'classes/tipo_perfil.dart';*/

bool enviandoAoBanco = false;

final myTheme = ThemeData(
  useMaterial3: true,
  primarySwatch: Colors.deepPurple,
  primaryColor: Colors.deepPurple[800],
  scaffoldBackgroundColor: Colors.deepPurple[50],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.deepPurple[800],
    foregroundColor: Colors.white,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.deepPurple[50],
    selectedItemColor: Colors.deepPurple[800],
    unselectedItemColor: Colors.indigo[100],
  ),
);

Future<void> main() async {
  await Supabase.initialize(
    url: 'URL DO SUPABASE',
    anonKey: 'CHAVE ANONIMA DO SUPABASE',
  );
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive App',
      theme: myTheme,
      darkTheme: ThemeData.dark(), // Tema escuro padrão
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // Inglês (Estados Unidos)
        const Locale('pt', 'BR'), // Português (Brasil)
      ],// Define o tema com base no modo do sistema
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/detalhesReserva': (context) => TelaDetalhesReserva(),
        '/detalhesVeiculo': (context) => TelaDetalhesVeiculo(),
        '/reservasDisponiveisCheckin': (context) => TelaReservasDisponiveisCheckin(),
        '/veiculosDisponiveisCheckin': (context) => TelaVeiculosDisponiveisCheckin(),
        '/detalhesReservaCheck': (context) => TelaDetalhesReservaCheck(),
        '/detalhesVeiculoCheck': (context) => TelaDetalhesVeiculoCheck(),
        '/detalhesUsuario': (context) => TelaDetalhesUsuario(),
        '/realizarCheckin': (context) => TelaRealizarCheckin(),
        '/realizarCheckout': (context) => TelaRealizarCheckout(),
        '/reservasDisponiveisRecusa': (context) => TelaReservasDisponiveisRecusar(),
        '/recusarReserva': (context) => TelaRecusarReserva(),
        '/checkinSucesso' : (context) => TelaCheckinSucesso(),
        '/checkoutSucesso' : (context) => TelaCheckoutSucesso(),
        '/recusaSucesso' : (context) => TelaRecusaSucesso(),
        '/gerirReservas': (context) => TelaGerirReservas(),
        '/gerirVeiculos': (context) => TelaGerirVeiculos(),
        '/gerirUsuarios': (context) => TelaGerirUsuarios(),
        '/cadastrarReserva': (context) => TelaCadastrarReserva(),
        '/cadastrarReservaSucesso': (context) => TelaCadastroReservaSucesso(),

      }

    );
  }
}

Future<List<T>> transformarTabelaEmLista<T>({
  required SupabaseClient supabase,
  required String tabela,
  required T Function(Map<String, dynamic>) construtorObjeto,
  String? filtroColuna1,
  dynamic filtroValor1,
  String? filtroColuna2,
  dynamic filtroValor2,
}) async {
  final queryBuilder = supabase.from(tabela).select();

  if (filtroColuna1 != null && filtroValor1 != null) {
    queryBuilder.eq(filtroColuna1, filtroValor1);
  }

  if (filtroColuna2 != null && filtroValor2 != null) {
    queryBuilder.eq(filtroColuna2, filtroValor2);
  }

  final response = await queryBuilder.execute();

  if (response == false) {
    throw Exception('Erro ao buscar dados da tabela');
  }

  if (response.data != null) {
    final dataList = response.data as List<dynamic>;
    final listaObjetos = dataList.map((data) => construtorObjeto(data)).toList();
    return listaObjetos;
  }

  return [];
}

Future<List<Reserva>> transformarReservaToList() async {
  final reservas = await transformarTabelaEmLista(supabase: supabase, tabela: 'Reservas', construtorObjeto: (data) => Reserva.fromMap(data));
  for (Reserva i in reservas){
    i.nomeUsuario = await buscarNomeUsuario(i.idUsuario);
    i.nomeStatusReserva = await buscarNomeStatusReserva(i.idStatusReserva);
    if (i.idVeiculo != 0){
      Veiculo veiculo = await buscarVeiculo(i.idVeiculo);
      i.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
      i.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
      i.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
      i.numeracao = veiculo.numeracao;
      i.placa = veiculo.placa;
    }
  }
  reservas.sort((a, b) {
    final statusComparison = a.idStatusReserva.compareTo(b.idStatusReserva);
    if (statusComparison != 0) {
      return statusComparison;
    }
    return a.idReserva.compareTo(b.idReserva);
  });
  return reservas;
}

Future<List<Reserva>> transformarReservaToListCalendario() async {
  final reservas = await transformarTabelaEmLista(supabase: supabase, tabela: 'Reservas', construtorObjeto: (data) => Reserva.fromMap(data));
  for (Reserva i in reservas){
    i.nomeUsuario = await buscarNomeUsuario(i.idUsuario);
    i.nomeStatusReserva = await buscarNomeStatusReserva(i.idStatusReserva);
    if (i.idVeiculo != 0){
      Veiculo veiculo = await buscarVeiculo(i.idVeiculo);
      i.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
      i.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
      i.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
      i.numeracao = veiculo.numeracao;
      i.placa = veiculo.placa;
    }
  }
  reservas.sort((a, b) {
    final idStatusReservaComparison = a.idStatusReserva.compareTo(b.idStatusReserva);
    if (idStatusReservaComparison != 0) {
      return idStatusReservaComparison;
    }
    final dataHoraPrevistaCheckinComparison = a.dataHoraPrevistaCheckin.compareTo(b.dataHoraPrevistaCheckin);
    if (dataHoraPrevistaCheckinComparison != 0) {
      return dataHoraPrevistaCheckinComparison;
    }
    return a.dataHoraCriacao.compareTo(b.dataHoraCriacao);
  });
  return reservas;
}

Future<List<Reserva>> transformarReservasDisponiveisToList() async {
  try {
    final reservas = await transformarTabelaEmLista<Reserva>(
      supabase: supabase,
      tabela: 'Reservas',
      construtorObjeto: (data) => Reserva.fromMap(data),
      filtroColuna1: 'idStatusReserva',
      filtroValor1: '1',
    );
    for (Reserva i in reservas) {
      i.nomeUsuario = await buscarNomeUsuario(i.idUsuario);
      i.nomeStatusReserva = await buscarNomeStatusReserva(i.idStatusReserva);
    }
    reservas.sort((a, b) => a.idReserva.compareTo(b.idReserva));

    return reservas;
  } catch (e) {
    print('Erro ao buscar veículos disponíveis: $e');
    return [];
  }
}

Future<Reserva> carregarReservaToObjeto(int idReserva) async {
  Reserva reserva = await buscarReserva(idReserva);
  reserva.nomeUsuario = await buscarNomeUsuario(reserva.idUsuario);
  reserva.nomeStatusReserva = await buscarNomeStatusReserva(reserva.idStatusReserva);
  if (reserva.idVeiculo != 0){
    Veiculo veiculo = await buscarVeiculo(reserva.idVeiculo);
    reserva.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
    reserva.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
    reserva.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
    reserva.numeracao = veiculo.numeracao;
    reserva.placa = veiculo.placa;
}
return reserva;

}

Future<List<Reserva>> buscarReservasPorUsuario(int idUsuario) async {
  try {
    final reservas = await transformarTabelaEmLista<Reserva>(
      supabase: supabase,
      tabela: 'Reservas',
      construtorObjeto: (data) => Reserva.fromMap(data),
      filtroColuna1: 'idUsuario',
      filtroValor1: idUsuario,
    );

    for (Reserva i in reservas) {
      i.nomeUsuario = await buscarNomeUsuario(i.idUsuario);
      i.nomeStatusReserva = await buscarNomeStatusReserva(i.idStatusReserva);
      if (i.idVeiculo != 0){
        Veiculo veiculo = await buscarVeiculo(i.idVeiculo);
        i.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
        i.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
        i.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
        i.numeracao = veiculo.numeracao;
        i.placa = veiculo.placa;
      }
    }
    reservas.sort((a, b) {
      final statusComparison = a.idStatusReserva.compareTo(b.idStatusReserva);
      if (statusComparison != 0) {
        return statusComparison;
      }
      return a.idReserva.compareTo(b.idReserva);
    });
    return reservas;
  } catch (e) {
    print('Erro ao buscar reservas do usuário: $e');
    return [];
  }
}

Future<List<Reserva>> buscarReservasPorVeiculo(int idVeiculo) async {
  try {
    final reservas = await transformarTabelaEmLista<Reserva>(
      supabase: supabase,
      tabela: 'Reservas',
      construtorObjeto: (data) => Reserva.fromMap(data),
      filtroColuna1: 'idVeiculo',
      filtroValor1: idVeiculo,
    );

    for (Reserva i in reservas) {
      i.nomeUsuario = await buscarNomeUsuario(i.idUsuario);
      i.nomeStatusReserva = await buscarNomeStatusReserva(i.idStatusReserva);
      if (i.idVeiculo != 0){
        Veiculo veiculo = await buscarVeiculo(i.idVeiculo);
        i.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
        i.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
        i.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
        i.numeracao = veiculo.numeracao;
        i.placa = veiculo.placa;
      }
    }

    reservas.sort((a, b) {
      final statusComparison = a.idStatusReserva.compareTo(b.idStatusReserva);
      if (statusComparison != 0) {
        return statusComparison;
      }
      return a.idReserva.compareTo(b.idReserva);
    });

    return reservas;
  } catch (e) {
    print('Erro ao buscar reservas do usuário: $e');
    return [];
  }
}


Future<List<Veiculo>> transformarVeiculoToList() async {
  final veiculos = await transformarTabelaEmLista(supabase: supabase, tabela: 'Veiculos', construtorObjeto: (data) => Veiculo.fromMap(data));
  for (Veiculo i in veiculos){
    i.nomeTipoFrota = await buscarNomeTipoFrota(i.idTipoFrota);
    i.nomeModelo = await buscarNomeModelo(i.idModelo);
    i.nomeMarca = await buscarNomeMarca(i.idMarca);
    i.nomeStatusVeiculo = await buscarNomeStatusVeiculo(i.idStatusVeiculo);
    i.ano = await buscarAno(i.idAno);
    i.cor = await buscarCor(i.idCor);
    if(i.idReserva != 0){
      Reserva reserva = await buscarReserva(i.idReserva);
      i.nomeUsuario = await buscarNomeUsuario(reserva.idUsuario);
    }

  }
  veiculos.sort((a, b) {
    final idStatusVeiculoComparasion = a.idStatusVeiculo.compareTo(b.idStatusVeiculo);
    if (idStatusVeiculoComparasion != 0) {
      return idStatusVeiculoComparasion;
    }
    return a.numeracao.compareTo(b.numeracao);
  });

  return veiculos;
}

Future<List<Veiculo>> transformarVeiculosDisponiveisToList() async {
  try {
    final veiculos = await transformarTabelaEmLista<Veiculo>(
      supabase: supabase,
      tabela: 'Veiculos',
      construtorObjeto: (data) => Veiculo.fromMap(data),
      filtroColuna1: 'idStatusVeiculo',
      filtroValor1: '1',
    );
    for (Veiculo i in veiculos){
      i.nomeTipoFrota = await buscarNomeTipoFrota(i.idTipoFrota);
      i.nomeModelo = await buscarNomeModelo(i.idModelo);
      i.nomeMarca = await buscarNomeMarca(i.idMarca);
      i.nomeStatusVeiculo = await buscarNomeStatusVeiculo(i.idStatusVeiculo);
      i.ano = await buscarAno(i.idAno);
      i.cor = await buscarCor(i.idCor);
    }
    veiculos.sort((a, b) {
      final nomeModeloComparison = a.nomeModelo.compareTo(b.nomeModelo);
      if (nomeModeloComparison != 0) {
        return nomeModeloComparison;
      }
      return a.numeracao.compareTo(b.numeracao);
    });

    return veiculos;
  } catch (e) {
    print('Erro ao buscar veículos disponíveis: $e');
    return [];
  }
}

Future<List<Veiculo>> transformarVeiculosEmUtilizacaoToList() async {
  try {
    final veiculos = await transformarTabelaEmLista<Veiculo>(
      supabase: supabase,
      tabela: 'Veiculos',
      construtorObjeto: (data) => Veiculo.fromMap(data),
      filtroColuna1: 'idStatusVeiculo',
      filtroValor1: '2',
    );
    for (Veiculo i in veiculos){
      i.nomeTipoFrota = await buscarNomeTipoFrota(i.idTipoFrota);
      i.nomeModelo = await buscarNomeModelo(i.idModelo);
      i.nomeMarca = await buscarNomeMarca(i.idMarca);
      i.nomeStatusVeiculo = await buscarNomeStatusVeiculo(i.idStatusVeiculo);
      i.ano = await buscarAno(i.idAno);
      i.cor = await buscarCor(i.idCor);
    }
    veiculos.sort((a, b) {
      return a.numeracao.compareTo(b.numeracao);
    });
    return veiculos;
  } catch (e) {
    print('Erro ao buscar veículos disponíveis: $e');
    return [];
  }
}

Future<Veiculo> carregarVeiculoToObjeto(int idVeiculo) async {
  Veiculo veiculo = await buscarVeiculo(idVeiculo);
  veiculo.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
  veiculo.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
  veiculo.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
  veiculo.nomeStatusVeiculo = await buscarNomeStatusVeiculo(veiculo.idStatusVeiculo);
  veiculo.ano = await buscarAno(veiculo.idAno);
  veiculo.cor = await buscarCor(veiculo.idCor);
  if(veiculo.idReserva != 0){
    Reserva reserva = await buscarReserva(veiculo.idReserva);
    veiculo.nomeUsuario = await buscarNomeUsuario(reserva.idUsuario);
  }
  return veiculo;

}

Future<List<Usuario>> transformarUsuarioToList() async {
  final usuarios = await transformarTabelaEmLista(supabase: supabase, tabela: 'Usuarios', construtorObjeto: (data) => Usuario.fromMap(data));
  for (Usuario i in usuarios){
    i.nomeTipoPerfil = await buscarNomeTipoPerfil(i.idTipoPerfil);
  }
  usuarios.sort((a, b) => a.nomeUsuario.compareTo(b.nomeUsuario));
  return usuarios;
}

/*Future<List<TipoPerfil>> transformarTipoPerfilToList() async {
  final tiposPerfil = await transformarTabelaEmLista(supabase: supabase, tabela: 'TiposPerfil', construtorObjeto: (data) => TipoPerfil.fromMap(data));
  for (TipoPerfil i in tiposPerfil){

  }
  tiposPerfil.sort((a, b) => a.idTipoPerfil.compareTo(b.idTipoPerfil));
  return tiposPerfil;
}*/

Future<int> contarLinhasTabela(SupabaseClient supabase, String tabela) async {
  final response = await supabase.from(tabela).select('COUNT(*)').execute();

  if (response.data == null) {
    throw Exception('Erro ao contar linhas da tabela');
  }

  if (response.data != null && response.data.isNotEmpty) {
    return response.data[0]['count'] as int;
  }

  return 0;
}

Future<Veiculo> buscarVeiculo(int idVeiculo) async {
  final response = await supabase
      .from('Veiculos')
      .select('*')
      .eq('idVeiculo', idVeiculo)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    throw Exception('Veiculo Desconhecido');
  }

  final veiculoData = response.data[0];
  final veiculo = Veiculo.fromMap(
      veiculoData);

  return veiculo;

}

Future<Usuario> buscarUsuario(int idUsuario) async {
  final response = await supabase
      .from('Usuarios')
      .select('*')
      .eq('idUsuario', idUsuario)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    throw Exception('Usuario Desconhecido');
  }

  final usuarioData = response.data[0];
  final usuario = Usuario.fromMap(
      usuarioData);

  return usuario;

}

Future<Reserva> buscarReserva(int idReserva) async {
  final response = await supabase
      .from('Reservas')
      .select('*')
      .eq('idReserva', idReserva)
      .execute();

  if (response.data == null || response.data.isEmpty) {
    throw Exception('Reserva Desconhecida');
  }

  final reservaData = response.data[0];
  final reserva = Reserva.fromMap(
      reservaData);

  return reserva;

}


