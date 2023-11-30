import 'package:flutter/material.dart';
import '../home.dart';
import '../classes/evento.dart';

class ListarEventosDia extends StatelessWidget {
  final List<Evento> eventosDoDia;

  ListarEventosDia(this.eventosDoDia);

  @override
  Widget build(BuildContext context) {
    if (eventosDoDia.isNotEmpty) {
      return Column(
        children: eventosDoDia.expand((evento) {
          return evento.reservas.map((reserva) {
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
          }).toList();
        }).toList(),
      );
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Center(child: Text('Nenhum Check-in ou Check-out pendente para este dia.'),
        ),
      );
    }
  }
}

