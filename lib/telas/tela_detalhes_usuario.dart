import 'package:flutter/material.dart';
import '../classes/reserva.dart';
import '../classes/usuario.dart';
import '../main.dart';
import '../home.dart';

class TelaDetalhesUsuario extends StatefulWidget {
  @override
  _TelaDetalhesUsuarioState createState() => _TelaDetalhesUsuarioState();
}

class _TelaDetalhesUsuarioState extends State<TelaDetalhesUsuario> {
  List<Reserva> reservas = [];
  String nomeUsuario = "";
  String perfilUsuario = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var usuario = ModalRoute.of(context)!.settings.arguments as Usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhamento do Usuário'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: ListTile(
              trailing: Icon(Icons.person,),
              title: Text(
                  '${usuario.nomeUsuario}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(usuario.nomeTipoPerfil),
                  Text('ID: ${usuario.idUsuario}'),
                ],),
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Container( margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Center(child: Text('Reservas deste Usuário', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),),)
          ),
          Expanded(
              child: Container(
            child: Center(
              child: FutureBuilder<List<Reserva>>(
                future: buscarReservasPorUsuario(usuario.idUsuario),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Este usário não possui reservas em seu nome.');
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
                                reserva.idStatusReserva == 2 ||
                                        reserva.idStatusReserva == 3
                                    ? Text(
                                        'Reserva: ${reserva.idReserva} | Veículo: ${reserva.idVeiculo} - Placa: ${reserva.placa}')
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
                                  color: getColorForStatus(
                                      reserva.idStatusReserva),
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
          )),
        ],
      ),
    );
  }
}
