import 'package:flutter/material.dart';
import '../classes/veiculo.dart';
import '../main.dart';
import '../home.dart';

class TelaGerirVeiculos extends StatefulWidget {
  @override
  _TelaGerirVeiculosState createState() => _TelaGerirVeiculosState();
}

class _TelaGerirVeiculosState extends State<TelaGerirVeiculos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerir Veiculos'),
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
            child: FutureBuilder<List<Veiculo>>(
              future: transformarVeiculoToList(),
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
                      final veiculo = snapshot.data![index];
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
        _buildActionButton("Cadastrar Veiculo", Icons.add, () {
          // Não implementado
        }),
        _buildActionButton("Editar Veículo", Icons.edit, () {
          // Não implementado
        }),
        _buildActionButton("Alterar Status Veiculo", Icons.bolt, () {
          // Não implementado
        }),
        _buildActionButton("Pesquisar Veículo", Icons.search, () {
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
