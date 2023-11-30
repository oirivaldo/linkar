import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkar/construtores/construtor_lista_veiculos.dart';
import 'package:table_calendar/table_calendar.dart';
import 'construtores/construtor_lista_eventos_dia.dart';
import 'dart:async';
import 'classes/evento.dart';
import 'classes/usuario.dart';
import 'classes/veiculo.dart';
import 'classes/reserva.dart';
import 'main.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

List<Veiculo> veiculosDisponiveis = [];
List<Veiculo> veiculosEmUtilizacao = [];
bool veiculosCarregando = true;
Map<DateTime, List<Evento>> eventos = {};
bool eventosCarregando = true;
final corDeRotulo = Colors.blue;
bool estaAberto = false;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;
  late List<Widget> _fabChildren;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  int contarVeiculosAtivos = 0;
  int numeroDeReservasNoDia = 0;


  @override
  void initState() {
    super.initState();
    _fabChildren = [];
    _carregarEventosReservas();
    _carregarVeiculos();
    selectedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
    focusedDay = DateTime.utc(focusedDay.year, focusedDay.month, focusedDay.day);
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    calcularNumeroDeVeiculosAtivos();
  }

  List<Evento> _getEventosDoDia(DateTime date) {
    return eventos[date] ?? [];
  }

  Future<void> _carregarEventosReservas() async {
    buscarEventosReservas().then((novosEventos) {
      if(mounted) {
        setState(() {
          eventos = novosEventos!;
          eventosCarregando = false;
        });
      }}
    );
  }

  Future<void> _carregarVeiculos() async {
    veiculosDisponiveis = await transformarVeiculosDisponiveisToList();
    veiculosEmUtilizacao = await transformarVeiculosEmUtilizacaoToList();
    if (mounted){
      setState(() {
        veiculosDisponiveis = veiculosDisponiveis;
        veiculosEmUtilizacao = veiculosEmUtilizacao;
        veiculosCarregando = false;
      });
    }
  }

  Future<int> calcularNumeroDeVeiculosAtivos() async {
    final veiculos = await transformarVeiculoToList();
    int qtVeiculos = 0;
    for (Veiculo veiculo in veiculos) {
      if (veiculo.idStatusVeiculo == 1 || veiculo.idStatusVeiculo == 2) {
        qtVeiculos = qtVeiculos + 1;
      }
    }
    setState(() {
      contarVeiculosAtivos = qtVeiculos;
    });
    return qtVeiculos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LinKar'),
        actions: [
          /*PopupMenuButton<String>(
            icon: Icon(Icons.menu),
            onSelected: (String choice) {
              // Aqui você pode lidar com as escolhas selecionadas
              if (choice == 'Opção 1') {
                // Lógica para a opção 1
              } else if (choice == 'Opção 2') {
                // Lógica para a opção 2
              } else if (choice == 'Opção 3') {
                // Lógica para a opção 3
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Opção 1',
                  child: Text('Opção 1'),
                ),
                PopupMenuItem<String>(
                  value: 'Opção 2',
                  child: Text('Opção 2'),
                ),
                PopupMenuItem<String>(
                  value: 'Opção 3',
                  child: Text('Opção 3'),
                ),
              ];
            },
          ),*/
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.app_registration),
          ),
          distance: 70,
          type: ExpandableFabType.up,
          children: [
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/gerirUsuarios',
                );
              },
            ),
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.directions_car),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/gerirVeiculos',
                );
              },
            ),
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.sticky_note_2_outlined),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/gerirReservas',
                );
              },
            ),
          ]),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildPage1Calendario(),
          _buildPage2Reservas(),
          _buildPage3Veiculos(),
          _buildPage4Usuarios(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
            _fabChildren = _buildFabChildren();
          });
        },
        items: [
          BottomNavigationBarItem(
            icon:
            Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuários',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.app_registration_rounded),
            label: 'Ações',
          ),*/
        ],
      ),
    );
  }

  Widget _buildPage1Calendario() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          eventosCarregando = true;
          veiculosCarregando = true;
          veiculosEmUtilizacao = [];
          veiculosDisponiveis = [];
        });
        buscarEventosReservas().then((novosEventos) {
          setState(() {
            eventos = novosEventos!;
          });
        });
        transformarVeiculosEmUtilizacaoToList().then((novaUtilzacao){
          setState(() {
            veiculosEmUtilizacao = novaUtilzacao;
          });
        });
        transformarVeiculosDisponiveisToList().then((novaDisponibilidade){
          setState((){
            veiculosDisponiveis = novaDisponibilidade;
            veiculosCarregando = false;
            eventosCarregando = false;
          });
        });
      },
      child: _buildPage1Calendario1(),
    );
  }

  Widget _buildPage1Calendario1() {
    return ListView(
      shrinkWrap: true,
      children: [
        eventosCarregando == true
            ? Container(
          margin: EdgeInsets.fromLTRB(0,16,0,0),
          child: Center(
              child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator()
              )),
        )
            : Container(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3.0),
                  bottomRight: Radius.circular(3.0),
                ),
              ),
              child: Icon(Icons.arrow_drop_down_outlined),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(
              'Reservas Ativas',
              style: TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold),
            ),],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Center(
            child: TableCalendar(
              pageJumpingEnabled: false,
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2099, 12, 31),
              focusedDay: focusedDay,
              locale: 'pt_BR',
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarFormat: format,
              /*onFormatChanged: (_format){
                  if (_format != format)
                    setState(() {
                      format = _format;
                    });
                },*/
              onPageChanged: (_focusedDay) {
                focusedDay = _focusedDay;
              },
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekVisible: true,
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  print(selectDay);
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                });
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },
              eventLoader: _getEventosDoDia,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final eventosDoDia = _getEventosDoDia(date);
                  if (eventosDoDia.isEmpty) {
                    return null;
                  }
                  final reservasDoDia = eventosDoDia.first.reservas;

                  int numeroDeReservas = reservasDoDia.length;
                  Color marcadorColor = calcularCorParaMarcador(
                      numeroDeReservas, contarVeiculosAtivos);
                  return Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: marcadorColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Center(
                        child:
                        eventosCarregando == true
                            ? Text('...', style: TextStyle( color: Colors.white),)
                            :Text(
                          numeroDeReservas.toString(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                withinRangeDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                disabledDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                holidayDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                outsideDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
          height: 30,
          width: 100,
          child: Center(
            child: Column(
              children: [
                Text(
                '${DateFormat('dd/MM/yyyy HH:mm').format(selectedDay).toString().substring(0, 10)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
        eventosCarregando == true ? Container(
          margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(child: Text('Carregando...', style: TextStyle(fontSize: 14),)),)
            : ListarEventosDia(eventos[selectedDay] ?? []),
        SizedBox(height: 8,),
        Divider(),
        Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
          height: 30,
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veículos - Disponibilidade Atual:',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
            height: 30,
            width: 100,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Em Utilização:',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  eventosCarregando == true
                      ? Text(
                    'Carregando...',
                  )
                      : Text(
                    '${veiculosEmUtilizacao.length.toString()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )

        ),
        eventosCarregando == true ? SizedBox()
            :ListarVeiculos(veiculosEmUtilizacao),
        Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
            height: 30,
            width: 100,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disponíveis:',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  eventosCarregando == true
                      ? Text(
                    'Carregando...',
                  )
                      : Text(
                    '${veiculosDisponiveis.length.toString()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )

        ),
        eventosCarregando == true ? SizedBox(height: 10,)
            : ListarVeiculos(veiculosDisponiveis),
      ],
    );
  }

  Widget _buildPage2Reservas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Layout para dispositivos móveis
          return Container(
            child: Center(
              child: FutureBuilder<List<Reserva>>(
                future: transformarReservaToList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    final double progressSize = 50.0;
                    return SizedBox(
                      width: progressSize,
                      height: progressSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
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
        }
      },
    );
  }

  Widget _buildPage3Veiculos() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Layout para dispositivos móveis
          return Container(
            child: Center(
              child: FutureBuilder<List<Veiculo>>(
                future: transformarVeiculoToList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
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
          );
        } else {
          // Layout para dispositivos web
          return Center(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: FutureBuilder<List<Veiculo>>(
                future: transformarVeiculoToList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    final double progressSize = 50.0;
                    return SizedBox(
                      width: progressSize,
                      height: progressSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
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
          );
        }
      },
    );
  }

  Widget _buildPage4Usuarios() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Layout para dispositivos móveis
          return Container(
            child: Center(
              child: FutureBuilder<List<Usuario>>(
                future: transformarUsuarioToList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Nenhum dado encontrado.');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final usuario = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detalhesUsuario',
                              arguments: usuario,
                            );
                          },
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
              child: FutureBuilder<List<Usuario>>(
                future: transformarUsuarioToList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    final double progressSize = 50.0;
                    return SizedBox(
                      width: progressSize,
                      height: progressSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
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
                        final usuario = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detalhesUsuario',
                              arguments: usuario,
                            );
                          },
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
    );
  }

  List<Widget> _buildFabChildren() {
    switch (_currentIndex) {
      case 0:
        return [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.search),
            onPressed: () {},
          ),
        ];
      case 1:
        return [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.add),
            onPressed: () {},
          ),
        ];
      default:
        return [];
    }
  }
}

Color? getColorForStatus(int idStatus) {
  switch (idStatus) {
    case 1:
      return Colors.deepPurple[800];
    case 2:
      return Colors.orange;
    case 3:
      return Colors.grey[700];
    case 4:
      return Colors.blueGrey[900];
    default:
      return Colors.black;
  }
}

IconData getIconForStatus(int idStatus) {
  switch (idStatus) {
    case 1:
      return Icons.lock_open;
    case 2:
      return Icons.lock_clock;
    case 3:
      return Icons.build;
    case 4:
      return Icons.lock;
    default:
      return Icons.lock;
  }
}

String dataHora(dataHora) {
  if (dataHora != '-') {
    DateTime dateTime = DateTime.parse(dataHora).toLocal();
    String dataHoraFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    dataHora = dataHoraFormatada;
  }
  return dataHora;
}

DateTime findFirstWeekday(DateTime date) {
  while (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    date = date.add(Duration(days: 1));
  }
  return date;
}

Color calcularCorParaMarcador(int numeroDeReservas, int limite) {
  if (numeroDeReservas <= limite * 0.7 || limite == 0) {
    return Colors.blue;
  } else if (numeroDeReservas <= limite * 0.9) {
    return Colors.amber;
  } else if (numeroDeReservas < limite) {
    return Colors.deepOrange.shade300;
  } else {
    return Colors.red;
  }
}

Future<Map<DateTime, List<Evento>>?> buscarEventosReservas() async {
  Map<DateTime, List<Evento>> novosEventos = {};

  final reservas = await transformarReservaToListCalendario();
  for (Reserva reserva in reservas) {
    if (reserva.idStatusReserva == 1 || reserva.idStatusReserva == 2) {
      String checkinString = reserva.dataHoraPrevistaCheckin;
      String checkoutString = reserva.dataHoraPrevistaCheckout;

      DateTime checkin = DateTime.parse(checkinString);
      DateTime checkout = DateTime.parse(checkoutString);

      checkin = checkin.toLocal();
      checkout = checkout.toLocal();

      int diasDeUtilizacao = checkout.difference(checkin).inDays;

      for (int i = 0; i <= diasDeUtilizacao; i++) {
        DateTime dataEvento = checkin.add(Duration(days: i));
        dataEvento =
            DateTime.utc(dataEvento.year, dataEvento.month, dataEvento.day);

        if (novosEventos[dataEvento] == null) {
          novosEventos[dataEvento] = [
            Evento(date: dataEvento, reservas: [reserva])
          ];
        } else {
          Evento eventoExistente = novosEventos[dataEvento]!.firstWhere(
            (evento) => evento.date == dataEvento,
            orElse: () => Evento(date: dataEvento, reservas: []),
          );
          eventoExistente.reservas.add(reserva);
        }
      }
    }
  }

  return novosEventos;
}
