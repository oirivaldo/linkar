import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../classes/reserva.dart';
import '../main.dart';
import '../home.dart';

String textoRecusa = 'Observação de Recusa de Reserva:\nNenhum veículo associado.\n';

class TelaRecusarReserva extends StatefulWidget {
  @override
  _TelaRecusarReservaState createState() => _TelaRecusarReservaState();
}

class _TelaRecusarReservaState extends State<TelaRecusarReserva> {
  final _formKey = GlobalKey<FormState>();
  final _obsRecusaController = TextEditingController();
  DateTime recusa = DateTime.now();
  bool processando = false;
  late Reserva reserva;

  Future<void> _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onSelect) async {
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

  Future<void> carregarReserva() async {
    final Map<String, dynamic> arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int idReserva = arguments['idReserva'];
    reserva = await buscarReserva(idReserva);
    reserva.nomeUsuario = await buscarNomeUsuario(reserva.idUsuario);
    reserva.nomeStatusReserva = await buscarNomeStatusReserva(reserva.idStatusReserva);
  }

  Future<void> _enviarRecusaReserva(BuildContext context) async {
    recusa = recusa.toUtc();
    String dataHoraFormatted = DateFormat('yyyy-MM-ddTHH:mm:ss').format(recusa);

    final response = await supabase.from('Reservas').upsert({
      'idReserva': reserva.idReserva,
      'idStatusReserva': 4,
      'obsCheckin': textoRecusa + _obsRecusaController.text,
      'dataHoraCheckin': dataHoraFormatted,
      'obsCheckout': textoRecusa + _obsRecusaController.text,
      'dataHoraCheckout': dataHoraFormatted,
    }, onConflict: 'idReserva').execute();

    if (response == false) {
      print('Erro ao enviar recusa da reserva');
    } else {
      print('Recusa da reserva enviada com sucesso');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Recusar Reserva'),
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
              child: enviandoAoBanco == false
              ? FutureBuilder<void>(
                future: carregarReserva(),
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
                              title: Text('Previsão de Utilização'),
                              subtitle: Text(
                                  '${dataHora(reserva.dataHoraPrevistaCheckin)} - ${(dataHora(reserva.dataHoraPrevistaCheckout))}'),
                            ),
                            ListTile(
                              title: Text('Data da Recusa'),
                              subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy').format(recusa)}'),
                              trailing: Icon(
                                Icons.edit_calendar,
                              ),
                              onTap: () async {
                                await _selectDate(context, recusa,
                                        (DateTime date) {
                                      setState(() {
                                        recusa = date;
                                      });
                                    });
                              },
                            ),
                            ListTile(
                              title: Text('Horário de Recusa'),
                              subtitle: Text(
                                  '${DateFormat('HH:mm').format(recusa)}'),
                              trailing: Icon(
                                Icons.watch_later,
                              ),
                              onTap: () async {
                                await _selectTime(
                                    context, TimeOfDay.fromDateTime(recusa),
                                        (TimeOfDay time) {
                                      setState(() {
                                        recusa = DateTime(
                                          recusa.year,
                                          recusa.month,
                                          recusa.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      });
                                    });
                              },
                            ),
                            ListTile(
                              title: Text('Observações sobre a Recusa'),
                              subtitle: TextFormField(
                                controller: _obsRecusaController,
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
                                        Text('Confirmar a Recusa'),
                                        content: Text(
                                            'Deseja confirmar a Recusa?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Confirmar'),
                                            onPressed: () async {
                                              setState(() {
                                                processando = true;
                                                enviandoAoBanco = true;
                                                eventosCarregando = true;
                                                veiculosCarregando = true;
                                                veiculosEmUtilizacao = [];
                                                veiculosDisponiveis = [];
                                              });
                                              _enviarRecusaReserva(context);
                                              buscarEventosReservas().then((novosEventos) {
                                                eventos = novosEventos!;
                                              });
                                              transformarVeiculosEmUtilizacaoToList().then((novaUtilzacao){
                                                veiculosEmUtilizacao = novaUtilzacao;

                                              });
                                              transformarVeiculosDisponiveisToList().then((novaDisponibilidade){
                                                veiculosDisponiveis = novaDisponibilidade;
                                                processando = false;
                                                eventosCarregando = false;
                                                veiculosCarregando = false;
                                                enviandoAoBanco = false;
                                              });
                                              Navigator.of(context)
                                                  .popUntil((route) =>
                                              route.isFirst);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePage(),
                                                  ));
                                              Navigator.pushNamed(context,
                                                  '/recusaSucesso', arguments: reserva.idReserva);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Text('Realizar a Recusa de Reserva'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )
              : Center(child: SizedBox(child: CircularProgressIndicator(
              ),),)
            ),
          ],
        ));
  }
}
