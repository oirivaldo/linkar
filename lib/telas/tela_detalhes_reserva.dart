import 'package:flutter/material.dart';
import 'package:linkar/main.dart';
import '../classes/reserva.dart';
import '../classes/veiculo.dart';
import '../home.dart';

String appBarTitle = 'Detalhamento da Reserva';
String check = 'Check-in';

class TelaDetalhesReserva extends StatefulWidget {
  @override
  _TelaDetalhesReservaState createState() => _TelaDetalhesReservaState();
}

class _TelaDetalhesReservaState extends State<TelaDetalhesReserva> {
  late Reserva reserva;
  late Veiculo veiculo;

  @override
  void initState() {
    super.initState();
    appBarTitle = 'Detalhamento da Reserva';
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
    final reserva = ModalRoute.of(context)!.settings.arguments as Reserva;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              appBarTitle =
                  'Detalhamento da Reserva';
            } else if (index == 1) {
              appBarTitle =
                  'Veículo Associado';
            }
            if (reserva.idStatusReserva == 1) {
              check = 'Check-in';
            } else if ((reserva.idStatusReserva == 2)) {
              check = 'Check-out';
            }
          });
        },
        children: [
          _buildDetalheReserva1(),
          _buildDetalheReserva2(),
        ],
      ),
      floatingActionButton: reserva.idStatusReserva == 1 ||
              reserva.idStatusReserva == 2
          ? FloatingActionButton.extended(
              label: reserva.idStatusReserva == 1
                  ? Text('Realizar Check-in')
                  : Text('Realizar Check-out'),
              onPressed: () {
                if (reserva.idStatusReserva == 1) {
                  Navigator.pushNamed(context, '/veiculosDisponiveisCheckin',
                      arguments: reserva);
                } else if (reserva.idStatusReserva == 2) {
                  Navigator.pushNamed(context, '/realizarCheckout', arguments: {
                    'idReserva': reserva.idReserva,
                    'idVeiculo': reserva.idVeiculo,
                  });
                } else {
                  _exibirSnackBar(context);
                }
              },
              tooltip: reserva.idStatusReserva == 1
                  ? 'Realizar Check-in'
                  : reserva.idStatusReserva == 2
                      ? 'Realizar Check-out'
                      : 'Indisponível',
            )
          : FloatingActionButton(
              onPressed: () {
                if (reserva.idStatusReserva == 1) {
                  Navigator.pushNamed(context, '/veiculosDisponiveisCheckin',
                      arguments: reserva);
                } else if (reserva.idStatusReserva == 2) {
                  Navigator.pushNamed(context, '/realizarCheckout', arguments: {
                    'idReserva': reserva.idReserva,
                    'idVeiculo': reserva.idVeiculo,
                  });
                } else {
                  _exibirSnackBar(context);
                }
              },
              child: reserva.idStatusReserva == 1
                  ? Icon(Icons.add)
                  : reserva.idStatusReserva == 2
                      ? Icon(Icons.remove)
                      : Icon(Icons.block),
              tooltip: reserva.idStatusReserva == 1
                  ? 'Realizar Check-in'
                  : reserva.idStatusReserva == 2
                      ? 'Realizar Check-out'
                      : 'Indisponível',
            ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {

          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons
                .sticky_note_2_outlined),
            label: 'Reserva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Veiculo Associado',
          ),
        ],
      ),
    );
  }

  Widget _buildDetalheReserva1() {
    reserva = ModalRoute.of(context)!.settings.arguments as Reserva;

    return Scaffold(
      body: SingleChildScrollView(
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
                  subtitle: Text(
                      '${dataHora(reserva.dataHoraPrevistaCheckin)} - ${(dataHora(reserva.dataHoraPrevistaCheckout))}'),
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
      ),
    );
  }

  Widget _buildDetalheReserva2() {
    reserva = ModalRoute.of(context)!.settings.arguments as Reserva;

    if (reserva.idVeiculo != 0) {
      return FutureBuilder<Veiculo>(
        future: carregarVeiculoToObjeto(reserva.idVeiculo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {

            return Center(
              child: Text('Erro ao buscar o Veículo: ${snapshot.error}'),
            );
          } else {

            veiculo = snapshot.data!;

            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text('ID do Veículo'),
                          subtitle: Text(veiculo.idVeiculo.toString()),
                        ),
                        Divider(),
                        ListTile(
                          title: Text('Numeração do Veículo'),
                          subtitle: Text(veiculo.numeracao.toString()),
                        ),
                        Divider(),
                        ListTile(
                          title: Text('Placa'),
                          subtitle: Text(veiculo.placa),
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
                          title: Text('Localização'),
                          subtitle: Text(veiculo.localizacao),
                        ),
                        Divider(),
                        SizedBox(height: 22.0),

                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      );
    } else {

      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              child: ListTile(
                title: Text(
                    'Até o momento não existe nenhum Veículo associado a esta Reserva. Se o Botão abaixo estiver habilitado, é possível a realização de Check-in.'),
              ),
            ),
          ),
        ),
      );
    }
  }
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
