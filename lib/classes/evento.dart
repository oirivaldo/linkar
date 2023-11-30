import 'package:linkar/classes/reserva.dart';

class Evento {
  final DateTime date;
  final List<Reserva> reservas;

  Evento({
    required this.date,
    required this.reservas,
  });
}