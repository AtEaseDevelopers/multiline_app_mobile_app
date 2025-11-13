import 'package:intl/intl.dart';

class Formatters {
  static String date(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);
  static String km(num value) => NumberFormat.decimalPattern().format(value);
}
