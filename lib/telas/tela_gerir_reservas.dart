import 'package:flutter/material.dart';
import '../classes/reserva.dart';
import '../main.dart';
import '../home.dart';

class TelaGerirReservas extends StatefulWidget {
  @override
  _TelaGerirReservasState createState() => _TelaGerirReservasState();
}

class _TelaGerirReservasState extends State<TelaGerirReservas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerir Reservas'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: _buildLayout(3),
              );
            } else {
              return _buildLayout(3);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLayout(int crossAxisCount) {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: FutureBuilder<List<Reserva>>(
              future: transformarReservaToList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  final double progressSize = 40.0;
                  return Center(
                    child: Container(
                      width: progressSize,
                      height: progressSize,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 4.0,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum dado encontrado.');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final reserva = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detalhesReserva',
                            arguments: reserva,
                          );
                        },
                        child: ListTile(
                          title: Text('${reserva.nomeUsuario}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              reserva.idStatusReserva == 2
                                  ? Text('Reserva: ${reserva.idReserva} | Veículo: ${reserva.idVeiculo} - Placa: ${reserva.placa}')
                                  : Text(
                                  'Reserva ${reserva.idReserva} - ${reserva.nomeStatusReserva}'),
                              Text(
                                  '${dataHora(reserva.dataHoraPrevistaCheckin)} - ${(dataHora(reserva.dataHoraPrevistaCheckout))}',
                                  style: TextStyle(fontSize: 11.0)),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                color:
                                getColorForStatus(reserva.idStatusReserva),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        _buildButtons(crossAxisCount),
      ],
    );
  }

  Widget _buildButtons(int crossAxisCount) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: EdgeInsets.all(8.0),
      shrinkWrap: true,
      children: [
        _buildActionButton("Cadastrar Reserva", Icons.add, () {
          Navigator.pushNamed(context, '/cadastrarReserva');
        }),
        _buildActionButton("Recusar Reserva", Icons.close, () {
          Navigator.pushNamed(context, '/reservasDisponiveisRecusa');
        }),
        _buildActionButton("Pesquisar Reservas", Icons.search, () {
          // Não implementado
        }),
        _buildActionButton("Relatório de Reservas", Icons.analytics, () {
          // Não implementado
        }),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Function() onPressed) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38.0),
            SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
