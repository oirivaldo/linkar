import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkar/main.dart';
import '../classes/reserva.dart';
import '../classes/veiculo.dart';
import '../home.dart';

class TelaRealizarCheckout extends StatefulWidget {
  @override
  _TelaRealizarCheckoutState createState() => _TelaRealizarCheckoutState();
}

class _TelaRealizarCheckoutState extends State<TelaRealizarCheckout> {
  final _formKey = GlobalKey<FormState>();
  final _obsCheckoutController = TextEditingController();
  late Reserva reserva;
  late Veiculo veiculo;
  DateTime checkout = DateTime.now();
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
      Function(DateTime) onSelect) async { final DateTime? picked = await showDatePicker(
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

  Future<void> _enviarCheckoutReserva(BuildContext context) async {
    checkout = checkout.toUtc();
    String dataHoraFormatted =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(checkout);


    final response = await supabase.from('Reservas').upsert({
      'idReserva': reserva.idReserva,
      'idVeiculo': veiculo.idVeiculo,
      'idStatusReserva': 3,
      'obsCheckout': _obsCheckoutController.text,
      'dataHoraCheckout': dataHoraFormatted,
    }, onConflict: 'idReserva').execute();

    if (response == false) {
      print('Deu Erro no Envio do Check-out - Reserva');
    } else {
      print('Sucesso Reserva Check-out!');
    }
  }

  Future<void> _enviarCheckoutVeiculo(BuildContext context) async {
    final response = await supabase.from('Veiculos').upsert({
      'idVeiculo': veiculo.idVeiculo,
      'idStatusVeiculo': 1,
      'idReserva': null,
    }, onConflict: 'idVeiculo').execute();

    if (response == false) {
      print('Deu Erro na no Envio do Check-out - Veiculo');
    } else {
      print('Sucesso Veiculo Check-out!');
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
          title: Text('Realizar Check-out'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              title: Text('Checkin Realizado em:'),
                              subtitle: Text(
                                  '${dataHora(reserva.dataHoraCheckin)}'),
                            ),
                            ListTile(
                              title: Text('Data de Check-out'),
                              subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy').format(checkout)}'),
                              trailing: Icon(
                                Icons.edit_calendar,
                              ),
                              onTap: () async {
                                await _selectDate(context, checkout, (DateTime date) {
                                  setState(() {
                                    checkout = date;
                                  });
                                });
                              },
                            ),
                            ListTile(
                              title: Text('Horário de Check-out'),
                              subtitle: Text(
                                  '${DateFormat('HH:mm').format(checkout)}'),
                              trailing: Icon(
                                Icons.watch_later,
                              ),
                              onTap: () async {
                                await _selectTime(
                                    context, TimeOfDay.fromDateTime(checkout),
                                    (TimeOfDay time) {
                                  setState(() {
                                    checkout = DateTime(
                                      checkout.year,
                                      checkout.month,
                                      checkout.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                });
                              },
                            ),
                            ListTile(
                              title: Text('Observações de Check-out'),
                              subtitle: TextFormField(
                                controller: _obsCheckoutController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Se desejar, faça suas observações',
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
                                              title:
                                                  Text('Confirmar Check-out'),
                                              content: Text(
                                                  'Deseja confirmar o Check-out?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Cancelar'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Fechar o AlertDialog
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Confirmar'),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      processando = true;
                                                      eventosCarregando = true;
                                                      veiculosCarregando = true;
                                                      veiculosEmUtilizacao = [];
                                                      veiculosDisponiveis = [];
                                                    });
                                                    _enviarCheckoutReserva(context);
                                                    _enviarCheckoutVeiculo(context);
                                                    buscarEventosReservas().then((novosEventos) {
                                                      eventos = novosEventos!;
                                                    });
                                                    transformarVeiculosEmUtilizacaoToList().then((novaUtilzacao){
                                                      veiculosEmUtilizacao = novaUtilzacao;

                                                    });
                                                    transformarVeiculosDisponiveisToList().then((novaDisponibilidade){
                                                      veiculosDisponiveis = novaDisponibilidade;
                                                      if(mounted){
                                                        setState(() {
                                                          processando = false;
                                                          eventosCarregando = false;
                                                          veiculosCarregando = false;
                                                        });
                                                      }
                                                    });
                                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                                    Navigator.pushReplacement( context, MaterialPageRoute( builder: (context) => HomePage(),));
                                                    Navigator.pushNamed(context, '/checkoutSucesso', arguments: reserva.idReserva);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                              child: Text('Realizar Check-out'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }
}

String placaVeiculo(placaVeiculo) {
  if (placaVeiculo == '0') {
    return '-';
  }
  return placaVeiculo;
}
