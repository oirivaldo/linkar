import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../classes/reserva.dart';
import '../classes/usuario.dart';
import '../main.dart';
import '../home.dart';

final reserva = Reserva(
  idReserva: 0,
  justificativa: '',
  idUsuario: 0,
  nomeUsuario: '',
  dataHoraCriacao: '',
  idStatusReserva: 0,
  nomeStatusReserva: '',
  dataHoraCheckin: '-',
  obsCheckin: '-',
  dataHoraCheckout: '-',
  obsCheckout: '-',
  idVeiculo: 0,
  numeracao: 0,
  placa: '',
  nomeMarca: '',
  nomeModelo: '',
  nomeTipoFrota: '',
  dataHoraPrevistaCheckin: '',
  dataHoraPrevistaCheckout: '',
);



class TelaCadastrarReserva extends StatefulWidget {
  @override
  _TelaCadastrarReservaState createState() => _TelaCadastrarReservaState();
}

class _TelaCadastrarReservaState extends State<TelaCadastrarReserva> {
  DateTime checkinPrevisto = DateTime.now().add(Duration(minutes: 5));
  DateTime checkoutPrevisto = DateTime.now().add(Duration(minutes: 65));
  final _formKey = GlobalKey<FormState>();
  List<Usuario> usuarios = [];
  var usuarioSelecionado;
  bool usuariosCarregando =
      true;

  @override
  void initState() {
    super.initState();
    usuarioSelecionado = null;
    _carregarUsuarios();
  }

  Future<void> _enviarReserva(BuildContext context) async {
    final response = await supabase.from('Reservas').upsert([
      {
        'idReserva': reserva.idReserva,
        'idUsuario': reserva.idUsuario,
        'dataHoraCriacao': DateTime.parse(reserva.dataHoraCriacao).toUtc().toIso8601String(),
        'justificativa': reserva.justificativa,
        'dataHoraPrevistaCheckin': DateTime.parse(reserva.dataHoraPrevistaCheckin).toUtc().toIso8601String(),
        'dataHoraPrevistaCheckout': DateTime.parse(reserva.dataHoraPrevistaCheckout).toUtc().toIso8601String(),
      }
    ]).execute();
    if (response == false) {
      throw Exception('Erro ao Cadastrar Reserva');
    } else {
      print('Reserva Cadastrada com Sucesso');

    }
  }

  Future<int> _obterProximoIdTabela(String tabela) async {
    final tamanhoTabela = await _tamanhoDaTabela(tabela);
    return tamanhoTabela + 1;
  }

  Future<int> _tamanhoDaTabela(String tabela) async {
    final response = await supabase.from(tabela).select().execute();

    if (response == false || response.data == null || response.data.isEmpty) {
      throw Exception('Erro ao consultar o tamanho da tabela');
    }

    final tamanho = response.data!.length;
    return tamanho;
  }


  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação de Reserva'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Por favor, confirme os detalhes da reserva:'),
                Text('Usuário: ${usuarioSelecionado.nomeUsuario}'),
                Text(
                    'Check-in Previsto: ${DateFormat('dd/MM/yyyy HH:mm').format(checkinPrevisto)}'),
                Text(
                    'Check-out Previsto: ${DateFormat('dd/MM/yyyy HH:mm').format(checkoutPrevisto)}'),
                Text('Justificativa: ${reserva.justificativa}'),
              ],
            ),
          ),
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
                reserva.dataHoraPrevistaCheckin = checkinPrevisto.toString();
                reserva.dataHoraPrevistaCheckout = checkoutPrevisto.toString();
                reserva.dataHoraCriacao = getDataHoraAtual();
                final proximoIdReserva = await _obterProximoIdTabela('Reservas');
                reserva.idReserva = proximoIdReserva;
                setState(() {
                  eventosCarregando = true;
                  usuariosCarregando = true;
                });
                _enviarReserva(context);
                buscarEventosReservas().then((novosEventos) {
                  eventos = novosEventos!;
                  if(mounted){
                    setState(() {
                      eventosCarregando = false;
                      usuariosCarregando = false;
                    });
                  }
                });

                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement( context, MaterialPageRoute( builder: (context) => HomePage(),));
                Navigator.pushNamed(context, '/cadastrarReservaSucesso', arguments: reserva.idReserva);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _carregarUsuarios() async {
    final listaUsuarios = await transformarUsuarioToList();
    setState(() {
      usuarios = listaUsuarios;
      usuariosCarregando = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cadastrar Reserva'),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: usuariosCarregando
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      margin: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: <Widget>[
                            DropdownButtonFormField<Usuario>(
                              value: usuarioSelecionado,
                              onChanged: (usuario) {
                                setState(() {
                                  usuarioSelecionado = usuario;
                                });
                              },
                              items: usuarios.map((Usuario user) {
                                return DropdownMenuItem<Usuario>(
                                  value:
                                      user,
                                  child: Text('${user.nomeUsuario}'),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                  labelText: 'Selecione um Usuário'),
                              validator: (usuario) {
                                if (usuario == null) {
                                  return 'Seleção obrigatória';
                                }
                                return null;
                              },
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 24, 0, 16),
                            child: Text('Previsão de Utilização:', style: TextStyle(fontSize: 16,),),),
                            Text('Check-in', style: TextStyle(fontSize: 16,),),
                            ListTile(
                              title: Text('Data:'),
                              subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy').format(checkinPrevisto)}'),
                              trailing: Icon(
                                Icons.edit_calendar,
                              ),
                              onTap: () async {
                                await _selectDate(context, checkinPrevisto,
                                        (DateTime date) {
                                      setState(() {
                                        checkinPrevisto = date;
                                      });
                                    });
                              },
                            ),
                            ListTile(
                              title: Text('Horário:'),
                              subtitle:
                              Text('${DateFormat('HH:mm').format(checkinPrevisto)}'),
                              trailing: Icon(
                                Icons.watch_later,
                              ),
                              onTap: () async {
                                await _selectTime(
                                    context, TimeOfDay.fromDateTime(checkinPrevisto),
                                        (TimeOfDay time) {
                                      setState(() {
                                        checkinPrevisto = DateTime(
                                          checkinPrevisto.year,
                                          checkinPrevisto.month,
                                          checkinPrevisto.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      });
                                    });
                              },
                            ),
                            Text('Check-out', style: TextStyle(fontSize: 16,),),
                            ListTile(
                              title: Text('Data:'),
                              subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy').format(checkoutPrevisto)}'),
                              trailing: Icon(
                                Icons.edit_calendar,
                              ),
                              onTap: () async {
                                await _selectDate(context, checkoutPrevisto, (DateTime date) {
                                  setState(() {
                                    checkoutPrevisto = date;
                                  });
                                });
                              },
                            ),
                            ListTile(
                              title: Text('Horário:'),
                              subtitle: Text(
                                  '${DateFormat('HH:mm').format(checkoutPrevisto)}'),
                              trailing: Icon(
                                Icons.watch_later,
                              ),
                              onTap: () async {
                                await _selectTime(
                                    context, TimeOfDay.fromDateTime(checkoutPrevisto),
                                        (TimeOfDay time) {
                                      setState(() {
                                        checkoutPrevisto = DateTime(
                                          checkoutPrevisto.year,
                                          checkoutPrevisto.month,
                                          checkoutPrevisto.day,
                                          time.hour,
                                          time.minute,

                                        );
                                      });
                                    });
                              },
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Justificativa*', helperText: '*Campo obrigatório'),
                              onSaved: (value) {
                                reserva.justificativa = value!;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (usuarioSelecionado != null) {
                                    reserva.idUsuario = usuarioSelecionado.idUsuario;
                                  }
                                  if (checkoutPrevisto.isBefore(checkinPrevisto)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'A data/hora de check-out previsto não pode ser anterior ao check-in previsto.'),
                                      ),
                                    );
                                  } else {
                                    _showConfirmationDialog(context);

                                  }
                                }
                              },
                              child: Text('Cadastrar Reserva'),
                            ),
                          ],
                        ),
                      ),
                    ))
        ]));
  }
}

String getDataHoraAtual() {
  DateTime now = DateTime.now();
  String dataHoraAtual = DateFormat('yyy-MM-dd HH:mm:ss').format(now);
  return dataHoraAtual;
}
