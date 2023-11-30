import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkar/main.dart';
import '../classes/reserva.dart';
import '../classes/veiculo.dart';
import '../home.dart';

class TelaRealizarCheckin extends StatefulWidget {
  @override
  _TelaRealizarCheckinState createState() => _TelaRealizarCheckinState();
}

class _TelaRealizarCheckinState extends State<TelaRealizarCheckin> {
  final _formKey = GlobalKey<FormState>();
  final _obsCheckinController = TextEditingController();
  late Reserva reserva;
  late Veiculo veiculo;
  DateTime checkin = DateTime.now();
  bool processando = false;

  Future<void> carregarReservaEVeiculo() async {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int idReserva = arguments['idReserva'];
    final int idVeiculo = arguments['idVeiculo'];
    reserva = await buscarReserva(idReserva);
    reserva.nomeUsuario = await buscarNomeUsuario(reserva.idUsuario);
    reserva.nomeStatusReserva =
        await buscarNomeStatusReserva(reserva.idStatusReserva);
    veiculo = await buscarVeiculo(idVeiculo);
    veiculo.nomeTipoFrota = await buscarNomeTipoFrota(veiculo.idTipoFrota);
    veiculo.nomeModelo = await buscarNomeModelo(veiculo.idModelo);
    veiculo.nomeMarca = await buscarNomeMarca(veiculo.idMarca);
    veiculo.nomeStatusVeiculo =
        await buscarNomeStatusVeiculo(veiculo.idStatusVeiculo);
    veiculo.ano = await buscarAno(veiculo.idAno);
    veiculo.cor = await buscarCor(veiculo.idCor);
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onSelect) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (picked != null && picked != initialDate) {
      onSelect(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onSelect) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && picked != initialTime) {
      onSelect(picked);
    }
  }

  Future<void> _enviarCheckinReserva(BuildContext context) async {
    checkin = checkin.toUtc();
    String dataHoraFormatted = DateFormat('yyyy-MM-ddTHH:mm:ss').format(checkin);

    final response = await supabase.from('Reservas').upsert({
      'idReserva': reserva.idReserva,
      'idVeiculo': veiculo.idVeiculo,
      'idStatusReserva': 2,
      'obsCheckin': _obsCheckinController.text,
      'dataHoraCheckin': dataHoraFormatted,
    }, onConflict: 'idReserva').execute();

    if (response == false) {
      print('Deu Erro na no Envio do Check-in - Reserva');
    } else {
      print('Sucesso Reserva Check-in!');
    }
  }

  Future<void> _enviarCheckinVeiculo(BuildContext context) async {
    final response = await supabase.from('Veiculos').upsert({
      'idVeiculo': veiculo.idVeiculo,
      'idStatusVeiculo': 2,
      'idReserva': reserva.idReserva,
    }, onConflict: 'idVeiculo').execute();

    if (response == false) {
      print('Deu Erro na no Envio do Check-in - Veiculo');
    } else {
      print('Sucesso Veiculo Check-in!');
    }
  }

  Future<void> printCreatedAtForID(int id) async {
    final response = await supabase
        .from('teste')
        .select('created_at')
        .eq('id', id)
        .execute();

    if (response == null) {
      print('Erro ao buscar dados');
    } else if (response.data != null && response.data!.length > 0) {
      final created_at = response.data![0]['created_at'];
      final datahora = dataHora(created_at);
      print('created_at do ID $id: ' + datahora);
    } else {
      print('Nenhum resultado encontrado para o ID $id');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Realizar Check-in'),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Finalização:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: carregarReservaEVeiculo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child:
                        CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Erro ao carregar os dados'),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            title: Text('ID da Reserva'),
                            subtitle: Text(reserva.idReserva.toString()),
                            trailing: Icon(
                              Icons.sticky_note_2_outlined,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/detalhesReservaCheck',
                                  arguments: reserva);
                            },
                          ),
                          ListTile(
                            title: Text('Nome do Usuário'),
                            subtitle: Text(reserva.nomeUsuario),
                          ),
                          ListTile(
                            title: Text('Veículo'),
                            subtitle: Text(
                                '${veiculo.nomeMarca} ${veiculo.nomeModelo} ${veiculo.numeracao} - ${placaVeiculo(veiculo.placa)}'),
                            trailing: Icon(Icons.directions_car),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/detalhesVeiculoCheck',
                                  arguments: veiculo);
                            },
                          ),
                          ListTile(
                            title: Text('Previsão de Utilização'),
                            subtitle: Text(
                                '${dataHora(reserva.dataHoraPrevistaCheckin)} - ${(dataHora(reserva.dataHoraPrevistaCheckout))}'),
                          ),
                          ListTile(
                            title: Text('Data de Check-in'),
                            subtitle: Text(
                                '${DateFormat('dd/MM/yyyy').format(checkin)}'),
                            trailing: Icon(
                              Icons.edit_calendar,
                            ),
                            onTap: () async {
                              await _selectDate(context, checkin,
                                  (DateTime date) {
                                setState(() {
                                  checkin = date;
                                });
                              });
                            },
                          ),
                          ListTile(
                            title: Text('Horário de Check-in'),
                            subtitle:
                                Text('${DateFormat('HH:mm').format(checkin)}'),
                            trailing: Icon(
                              Icons.watch_later,
                            ),
                            onTap: () async {
                              await _selectTime(
                                  context, TimeOfDay.fromDateTime(checkin),
                                  (TimeOfDay time) {
                                setState(() {
                                  checkin = DateTime(
                                    checkin.year,
                                    checkin.month,
                                    checkin.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              });
                            },
                          ),
                          ListTile(
                            title: Text('Observações de Check-in'),
                            subtitle: TextFormField(
                              controller: _obsCheckinController,
                              decoration: InputDecoration(
                                labelText: 'Se desejar, faça suas observações',
                              ),
                              enabled: !processando,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: processando
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmar Check-in'),
                                            content: Text(
                                                'Deseja confirmar o Check-in?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Confirmar'),
                                                onPressed: () async {
                                                  setState(() {
                                                    processando = true;
                                                    eventosCarregando = true;
                                                    veiculosCarregando = true;
                                                    veiculosEmUtilizacao = [];
                                                    veiculosDisponiveis = [];
                                                  });
                                                  _enviarCheckinReserva(context);
                                                  _enviarCheckinVeiculo(context);
                                                  buscarEventosReservas().then((novosEventos) {
                                                    eventos = novosEventos!;
                                                  });
                                                  transformarVeiculosEmUtilizacaoToList().then((novaUtilzacao){
                                                    veiculosEmUtilizacao = novaUtilzacao;

                                                  });
                                                  transformarVeiculosDisponiveisToList().then((novaDisponibilidade){
                                                    veiculosDisponiveis = novaDisponibilidade;
                                                    if (mounted){
                                                      setState(() {
                                                        processando = false;
                                                        eventosCarregando = false;
                                                        veiculosCarregando = false;
                                                      });
                                                    }
                                                  });
                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                  Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) => HomePage(),));
                                                  Navigator.pushNamed(context, '/checkinSucesso', arguments: reserva.idReserva);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                            child: Text('Finalizar Check-in'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ]));
  }
}

String placaVeiculo(placaVeiculo) {
  if (placaVeiculo == '0') {
    return '-';
  }
  return placaVeiculo;
}
