import 'package:flutter/material.dart';
import 'package:linkar/main.dart';
import '../classes/reserva.dart';
import '../classes/veiculo.dart';
import '../home.dart';

String appBarTitle = 'Detalhamento do Veiculo';


class TelaDetalhesVeiculo extends StatefulWidget {
  @override
  _TelaDetalhesVeiculoState createState() => _TelaDetalhesVeiculoState();
}

class _TelaDetalhesVeiculoState extends State<TelaDetalhesVeiculo> {
  late Reserva reserva;
  late Veiculo veiculo;

  @override
  void initState() {
    super.initState();
    appBarTitle = 'Detalhamento do Veiculo';
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              appBarTitle =
                  'Detalhamento do Veículo';
            } else if (index == 1) {
              appBarTitle =
                  'Reservas Associadas';
            }
          });
        },
        children: [
          _buildDetalheVeiculo1(),
          _buildDetalheVeiculo2(),
        ],
      ),
      floatingActionButton: veiculo.idStatusVeiculo == 1 ||
          veiculo.idStatusVeiculo == 2
          ? FloatingActionButton.extended(
        label: veiculo.idStatusVeiculo == 1
            ? Text('Realizar Check-in')
            : Text('Realizar Check-out'),
        onPressed: () {
          if (veiculo.idStatusVeiculo == 1) {
            Navigator.pushNamed(context, '/reservasDisponiveisCheckin',
                arguments: veiculo);
          } else if (veiculo.idStatusVeiculo == 2) {
            Navigator.pushNamed(context, '/realizarCheckout', arguments: {
              'idReserva': veiculo.idReserva,
              'idVeiculo': veiculo.idVeiculo,
            });
          } else {
            _exibirSnackBar(context);
          }
        },
        tooltip: veiculo.idStatusVeiculo == 1
            ? 'Realizar Check-in'
            : veiculo.idStatusVeiculo == 2
            ? 'Realizar Check-out'
            : 'Indisponível',
      )
          : FloatingActionButton(
        onPressed: () {
          if (veiculo.idStatusVeiculo == 1) {
            Navigator.pushNamed(context, '/reservasDisponiveisCheckin',
                arguments: veiculo);
          } else if (veiculo.idStatusVeiculo == 2) {
            Navigator.pushNamed(context, '/realizarCheckout', arguments: {
              'idReserva': reserva.idReserva,
              'idVeiculo': reserva.idVeiculo,
            });
          } else {
            _exibirSnackBar(context);
          }
        },
        child: veiculo.idStatusVeiculo == 1
            ? Icon(Icons.add)
            : veiculo.idStatusVeiculo == 2
            ? Icon(Icons.remove)
            : Icon(Icons.block),
        tooltip: veiculo.idStatusVeiculo == 1
            ? 'Realizar Check-in'
            : veiculo.idStatusVeiculo == 2
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
            icon: Icon(Icons.directions_car),
            label: 'Veiculo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            label: 'Reservas Associadas',
          ),
        ],
      ),
    );
  }

  Widget _buildDetalheVeiculo1() {
    final veiculo = ModalRoute.of(context)!.settings.arguments as Veiculo;
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
      ),
    );
  }

  Widget _buildDetalheVeiculo2() {
    final veiculo = ModalRoute.of(context)!.settings.arguments as Veiculo;
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
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
            ),
            Divider(
              thickness: 2,
            ),
            Container( margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Center(child: Text('Reservas Associadas a este Veiculo', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),),)
            ),
            Expanded(
                child: Container(
                  child: Center(
                    child: FutureBuilder<List<Reserva>>(
                      future: buscarReservasPorVeiculo(veiculo.idVeiculo),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erro: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('Este veículo não possui reservas associadas a ele.');
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final reserva = snapshot.data![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/detalhesReservaCheck',
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

String placaVeiculo(placaVeiculo) {
  if (placaVeiculo == '0') {
    return '-';
  }
  return placaVeiculo;
}

String reservaIgualAZero(reserva) {
  if (reserva == '0') {
    return '-';
  }
  return reserva;
}

String usuarioNinguem(nomeUsuario) {
  if (nomeUsuario == ''){
    return 'Ninguém';
  }
  return nomeUsuario;
}

void _exibirSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(child: Text('Check-in indisponível devido ao status deste Veículo.'),),
    ),
  );
}