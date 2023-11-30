import 'package:flutter/material.dart';

int numReserva = 0;

class TelaSucesso extends StatelessWidget {
  final String title;
  final String message;

  TelaSucesso({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Finalização:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80.0,
                    ),
                    SizedBox(height: 50.0),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.home,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TelaCheckinSucesso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    numReserva = ModalRoute.of(context)!.settings.arguments as int;
    return TelaSucesso(
      title: 'Realizar Check-in',
      message: 'Reserva Nº ${numReserva}\nCheck-in Realizado com Sucesso!',
    );
  }
}

class TelaCheckoutSucesso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    numReserva = ModalRoute.of(context)!.settings.arguments as int;
    return TelaSucesso(
      title: 'Realizar Check-out',
      message: 'Reserva Nº ${numReserva}\nCheck-out Realizado com Sucesso!',
    );
  }
}

class TelaRecusaSucesso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    numReserva = ModalRoute.of(context)!.settings.arguments as int;
    return TelaSucesso(
      title: 'Recusar Reserva',
      message: 'Reserva Nº ${numReserva}\nRecusa Realizada com Sucesso!',
    );
  }
}

class TelaCadastroReservaSucesso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    numReserva = ModalRoute.of(context)!.settings.arguments as int;
    return TelaSucesso(
      title: 'Cadastrar Reserva',
      message: 'Reserva Nº ${numReserva}\nCadastrada com Sucesso!',
    );
  }
}
