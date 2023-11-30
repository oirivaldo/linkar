import 'package:flutter/material.dart';
import '../classes/reserva.dart';
import '../main.dart';
import '../home.dart';

class TelaReservasDisponiveisRecusar extends StatefulWidget {
  @override
  _TelaReservasDisponiveisRecusarState createState() =>
      _TelaReservasDisponiveisRecusarState();
}

class _TelaReservasDisponiveisRecusarState
    extends State<TelaReservasDisponiveisRecusar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recusar Reserva'),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Selecione a Reserva a ser Encerrada por Recusa:',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Layout para dispositivos móveis
                return Container(
                  child: Center(
                    child: FutureBuilder<List<Reserva>>(
                      future: transformarReservasDisponiveisToList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erro: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('Nenhum dado encontrado.');
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final reserva = snapshot.data![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/recusarReserva', arguments: {
                                    'idReserva': reserva.idReserva,
                                  });
                                },
                                child: ListTile(
                                  title: Text('${reserva.nomeUsuario}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      reserva.idStatusReserva == 2 || reserva.idStatusReserva == 3
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
                );
              } else {
                // Layout para dispositivos web
                return Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                    child: FutureBuilder<List<Reserva>>(
                      future: transformarReservaToList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          final double progressSize = 50.0;
                          return SizedBox(
                            width: progressSize,
                            height: progressSize,
                            child: CircularProgressIndicator(
                              strokeWidth: 4.0,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Erro: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('Nenhum dado encontrado.');
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/recusarReserva', arguments: {
                                    'idReserva': data.idReserva,
                                  });
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.sticky_note_2_outlined,
                                    color:
                                    getColorForStatus(data.idStatusReserva),
                                    size: 30.0,
                                  ),
                                  title: Text('${data.nomeUsuario}'),
                                  subtitle: Text(
                                      'Reserva: ${data.idReserva}\n${dataHora(data.dataHoraPrevistaCheckin)} - ${(dataHora(data.dataHoraPrevistaCheckout))}'),
                                  trailing: Text(
                                    (data.nomeStatusReserva),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ]),
    );
  }
}
