import 'package:flutter/material.dart';
import 'package:linkar/telas/tela_detalhes_veiculo.dart';
import '../classes/veiculo.dart';

String appBarTitle = 'Detalhamento do Veiculo';

class TelaDetalhesVeiculoCheck extends StatefulWidget {
  @override
  _TelaDetalhesVeiculoCheckState createState() =>
      _TelaDetalhesVeiculoCheckState();
}

class _TelaDetalhesVeiculoCheckState
    extends State<TelaDetalhesVeiculoCheck> {
  @override
  void initState() {
    super.initState();
  }

  int _currentIndex = 0;
  final PageController _pageController =
  PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final veiculo = ModalRoute.of(context)!.settings.arguments as Veiculo;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: _buildDetalheVeiculo1(veiculo),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: veiculo.idStatusVeiculo == 1 || veiculo.idStatusVeiculo == 2
            ? Icon(Icons.arrow_back_ios_new)
            : Icon(Icons.block),
        tooltip: veiculo.idStatusVeiculo == 1
            ? 'Voltar'
            : 'Voltar',
      ),
    );
  }

  Widget _buildDetalheVeiculo1(Veiculo veiculo) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Placa'),
                subtitle: Text(veiculo.placa),
              ),
              Divider(),
              ListTile(
                title: Text('ID do Veiculo'),
                subtitle: Text(veiculo.idVeiculo.toString()),
              ),
              Divider(),
              ListTile(
                title: Text('Numeração do Veículo'),
                subtitle: Text(veiculo.numeracao.toString()),
              ),
              Divider(),
              ListTile(
                title: Text('Marca'),
                subtitle: Text(veiculo.nomeMarca),
              ),
              Divider(),
              ListTile(
                title: Text('Modelo'),
                subtitle: Text(veiculo.nomeModelo),
              ),
              Divider(),
              ListTile(
                title: Text('Cor'),
                subtitle: Text(veiculo.cor),
              ),
              Divider(),
              ListTile(
                title: Text('Ano'),
                subtitle: Text(veiculo.ano),
              ),
              Divider(),
              ListTile(
                title: Text('Renavam'),
                subtitle: Text(veiculo.renavam),
              ),
              Divider(),
              ListTile(
                title: Text('Status do Veículo'),
                subtitle: Text(veiculo.nomeStatusVeiculo),
              ),
              Divider(),
              ListTile(
                title: Text('Tipo de Frota'),
                subtitle: Text(veiculo.nomeTipoFrota),
              ),
              Divider(),
              ListTile(
                title: Text('ID da Reserva Atual'),
                subtitle:
                Text(reservaIgualAZero(veiculo.idReserva.toString())),
              ),
              Divider(),
              ListTile(
                title: Text('Utilizado neste momento por'),
                subtitle: Text(usuarioNinguem(veiculo.nomeUsuario)),
              ),
              Divider(),
              SizedBox(height: 22.0),

            ],
          ),
        ),
      ),
    );
  }

  void _exibirSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text('Check-in indisponível devido ao status deste Veículo.'),),
      ),
    );
  }
}
