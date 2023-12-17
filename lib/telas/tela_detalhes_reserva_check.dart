import 'package:flutter/material.dart';
import '../classes/reserva.dart';
import '../home.dart';

String appBarTitle = 'Detalhamento da Reserva';

class TelaDetalhesReservaCheck extends StatefulWidget {

  @override
  _TelaDetalhesReservaCheckState createState() =>
      _TelaDetalhesReservaCheckState();
}

class _TelaDetalhesReservaCheckState
    extends State<TelaDetalhesReservaCheck> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var reserva = ModalRoute.of(context)!.settings.arguments as Reserva;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: _buildDetalheReserva1(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: reserva.idStatusReserva == 1 || reserva.idStatusReserva == 2 || reserva.idStatusReserva == 3 || reserva.idStatusReserva == 4
            ? Icon(Icons.arrow_back_ios_new)
            : Icon(Icons.block),
        tooltip: reserva.idStatusReserva == 1
            ? 'Voltar'
            : 'Voltar',
      ),
    );
  }

  Widget _buildDetalheReserva1() {
    final reserva = ModalRoute.of(context)!.settings.arguments as Reserva;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('ID da Reserva'),
                subtitle: Text(reserva.idReserva.toString()),
              ),
              Divider(),
              ListTile(
                title: Text('Nome do Usuário'),
                subtitle: Text(reserva.nomeUsuario),
              ),
              Divider(),
              ListTile(
                title: Text('Veículo Associado'),
                subtitle: Text(
                    '${reserva.nomeMarca} ${reserva.nomeModelo} - ${placaVeiculo(reserva.numeracao.toString())}'),
              ),
              Divider(),
              ListTile(
                title: Text('Justificativa'),
                subtitle: Text(reserva.justificativa),
              ),
              Divider(),
              ListTile(
                title: Text('Data/Hora de Criação'),
                subtitle: Text(dataHora(reserva.dataHoraCriacao)),
              ),
              Divider(),
              ListTile(
                title: Text('Status da Reserva'),
                subtitle: Text(reserva.nomeStatusReserva),
              ),
              Divider(),
              ListTile(
                title: Text('Previsão de Utilização'),
                subtitle: Text('${dataHora(reserva.dataHoraPrevistaCheckin)} - ${(dataHora(reserva.dataHoraPrevistaCheckout))}'),
              ),
              Divider(),
              ListTile(
                title: Text('Check-in Realizado'),
                subtitle: Text(dataHora(reserva.dataHoraCheckin)),
              ),
              Divider(),
              ListTile(
                title: Text('Observações no Check-in'),
                subtitle: Text(reserva.obsCheckin),
              ),
              Divider(),
              ListTile(
                title: Text('Check-out Realizado'),
                subtitle: Text(dataHora(reserva.dataHoraCheckout)),
              ),
              Divider(),
              ListTile(
                title: Text('Observações no Check-out'),
                subtitle: Text(reserva.obsCheckout),
              ),
              Divider(),
              SizedBox(height: 22.0),
            ],
          ),
        ),
      ),
    );
  }

  String placaVeiculo(placaVeiculo) {
    if (placaVeiculo == '0') {
      return '';
    }
    return placaVeiculo;
  }

  void _exibirSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text('Check-in indisponível devido ao status desta Reserva.')),
      ),
    );
  }
}
