import 'package:flutter/material.dart';
import '../classes/reserva.dart';
import '../classes/veiculo.dart';
import '../main.dart';
import '../home.dart';

class TelaVeiculosDisponiveisCheckin extends StatefulWidget {
  @override
  _TelaVeiculosDisponiveisCheckinState createState() =>
      _TelaVeiculosDisponiveisCheckinState();
}

class _TelaVeiculosDisponiveisCheckinState
    extends State<TelaVeiculosDisponiveisCheckin> {
  @override
  Widget build(BuildContext context) {
    final reserva = ModalRoute.of(context)!.settings.arguments as Reserva;

    return Scaffold(
        appBar: AppBar(
          title: Text('Realizar Check-in'),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selecione o Veículo Disponível:',
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
                  return Container(
                    child: Center(
                      child: FutureBuilder<List<Veiculo>>(
                        future: transformarVeiculosDisponiveisToList(),
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
                                final veiculo = snapshot.data![index];
                                veiculo.idReserva = 0;
                                return GestureDetector(
                                  onTap: () {
                                    veiculo.idReserva = reserva.idReserva;
                                    Navigator.pushNamed(
                                        context, '/realizarCheckin',
                                        arguments: {
                                          'idReserva': veiculo.idReserva,
                                          'idVeiculo': veiculo.idVeiculo
                                        });
                                  },
                                  child: ListTile(
                                    title:
                                    Text('${veiculo.numeracao} | ${veiculo.nomeMarca} ${veiculo.nomeModelo}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Placa ${veiculo.placa}'),
                                        veiculo.idStatusVeiculo == 2
                                            ?Text('${veiculo.nomeStatusVeiculo} | Reserva: ${veiculo.idReserva}')
                                            :Text('${veiculo.nomeStatusVeiculo}')
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.directions_car,
                                      color: getColorForStatus(veiculo.idStatusVeiculo),
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
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: double.infinity,
                      child: FutureBuilder<List<Veiculo>>(
                        future: transformarVeiculosDisponiveisToList(),
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
                                final veiculo = snapshot.data![index];
                                veiculo.idReserva = 0;
                                return GestureDetector(
                                  onTap: () {
                                    veiculo.idReserva = reserva.idReserva;
                                    Navigator.pushNamed(
                                        context, '/realizarCheckin',
                                        arguments: {
                                          'idReserva': veiculo.idReserva,
                                          'idVeiculo': veiculo.idVeiculo
                                        });
                                  },
                                  child: ListTile(
                                    leading: Text('V.${veiculo.numeracao}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                    title:
                                    Text('${veiculo.nomeMarca} ${veiculo.nomeModelo}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Veículo: ${veiculo.idVeiculo} - Placa ${veiculo.placa}'),
                                        veiculo.idStatusVeiculo == 2
                                            ?Text('${veiculo.nomeStatusVeiculo} | Reserva: ${veiculo.idReserva}')
                                            :Text('${veiculo.nomeStatusVeiculo}')
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.directions_car,
                                      color: getColorForStatus(veiculo.idStatusVeiculo),
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
        ]));
  }
}
