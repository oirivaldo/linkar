import 'package:flutter/material.dart';
import 'package:linkar/home.dart';
import '../classes/veiculo.dart';

class ListarVeiculos extends StatelessWidget {
  final List<Veiculo> veiculos;

  ListarVeiculos(this.veiculos);

  @override
  Widget build(BuildContext context) {
    if (veiculos.isNotEmpty) {
      return Column(
        children: veiculos.map((veiculo) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detalhesVeiculo',
                arguments: veiculo,
              );
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
        }).toList(),
      );
    } else if (veiculosCarregando == true) {
      return SizedBox(
        height: 8,
      );
    } else {
      return SizedBox(
        height: 8,
      );
    }
  }
}
